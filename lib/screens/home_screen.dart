import 'dart:convert';
import 'package:alpha/controllers/home_controller.dart';
import 'package:alpha/models/vpn.dart';
import 'package:alpha/models/vpn_config.dart';
import 'package:alpha/screens/location_screen.dart';
import 'package:alpha/widgets/count_down_timer.dart';
import 'package:alpha/widgets/home_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/vpn_status.dart';
import '../services/vpn_engine.dart';
import '../apis/apis.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final HomeController _controller = Get.put(HomeController());
  final RxBool multiLayerActive = false.obs;
  final RxList<String> connectedIps = <String>[].obs;
  final RxList<String> appLogs = <String>[].obs;

  @override
  Widget build(BuildContext context) {
    VpnEngine.vpnStageSnapshot().listen((event) {
      _controller.vpnState.value = event;
    });

    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Obx(() => _vpnButton(context)),
              Obx(() => CountDownTimer(startTimer: _controller.startTimer.value)),
              Obx(() => _controller.showRotationMessage.value ? _rotationMessage() : const SizedBox.shrink()),
              const SizedBox(height: 15),
              Obx(() => _buildVpnInfo()),
              const SizedBox(height: 30),
              _buildNetworkStatus(),
              const SizedBox(height: 30),
              Obx(() => _multiLayerSection()),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _bottomPanel(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      leadingWidth: 100,
      leading: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.power_settings_new, color: Colors.red, size: 28),
            onPressed: () async {
              await VpnEngine.stopVpn();
              _controller.stopAutoRotation();
              multiLayerActive.value = false;
              connectedIps.clear();
              _controller.vpn.value = Vpn.fromJson({});
              _controller.vpnState.value = VpnEngine.vpnDisconnected;
              _controller.startTimer.value = false;
              _controller.showRotationMessage.value = false;
              _controller.vpn.update((val) { val?.ip = ''; });
              appLogs.insert(0, '🛑 Kill Switch Activated and FULL Reset');
              debugPrint('🛑 Kill Switch Activated and FULL Reset');
              if (appLogs.length > 200) appLogs.removeLast();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🛡️ VPN Killed. UI Fully Reset!')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.terminal, color: Colors.black, size: 28),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Colors.black,
                  title: const Text('Application Logs', style: TextStyle(color: Colors.green)),
                  content: Container(
                    width: double.maxFinite,
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: Obx(() {
                      return ListView.builder(
                        itemCount: appLogs.length,
                        reverse: true,
                        itemBuilder: (context, index) => SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(appLogs[index], style: const TextStyle(color: Colors.green)),
                        ),
                      );
                    }),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close', style: TextStyle(color: Colors.green)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      title: Text(
        'AlphaVPN',
        style: GoogleFonts.righteous(
          textStyle: TextStyle(
            color: Colors.black.withOpacity(0.8),
            letterSpacing: 3,
          ),
        ),
      ),
      actions: [
        IconButton(
          padding: const EdgeInsets.only(right: 8),
          icon: const Icon(Icons.info_outline, size: 27, color: Colors.black),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('About AlphaVPN'),
                content: const Text(
                  'AlphaVPN is powered by VPNGate servers.\n\n'
                      '- Connect to secure VPN\n'
                      '- Rotate IPs automatically\n'
                      '- Multi-Layer VPN routing\n\nStay secure! 🚀\n\n\n'
                      'Powered by Hashan Wijemanna.\n'
                      '2025 All Rights Reserved',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          },
        )
      ],
    );
  }


  // 🔘 VPN Button Section
  Widget _vpnButton(BuildContext context) {
    var mq = MediaQuery.of(context).size;
    return Column(
      children: [
        InkWell(
          onTap: () => _controller.connectToVpn(),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(.3),
            ),
            child: Container(
              width: mq.height * .14,
              height: mq.height * .14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 7),
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: AssetImage(_controller.getButtonImg),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Text(
          _controller.getIpAddress,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: mq.height * .015, bottom: mq.height * .02),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          decoration: BoxDecoration(
            color: _controller.getButtonColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            _controller.vpnState.value == VpnEngine.vpnDisconnected
                ? _controller.getButtonText
                : _controller.vpnState.replaceAll('_', ' ').toUpperCase(),
            style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // 🌍 VPN Info Section
  Widget _buildVpnInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        HomeCard(
          title: _controller.vpn.value.countryLong.isEmpty ? 'Country' : _controller.vpn.value.countryLong,
          subtitle: 'COUNTRY',
          icon: CircleAvatar(
            backgroundColor: Colors.blue,
            radius: 30,
            backgroundImage: _controller.vpn.value.countryLong.isEmpty
                ? null
                : AssetImage('assets/flags/${_controller.vpn.value.countryShort.toLowerCase()}.png'),
            child: _controller.vpn.value.countryLong.isEmpty
                ? const Icon(Icons.vpn_lock_rounded, size: 30, color: Colors.white)
                : null,
          ),
        ),
        HomeCard(
          title: _controller.vpn.value.ping.isEmpty ? '100 ms' : '${_controller.vpn.value.ping} ms',
          subtitle: 'PING',
          icon: const CircleAvatar(
            backgroundColor: Colors.orange,
            radius: 30,
            child: Icon(Icons.network_check_rounded, size: 30, color: Colors.black),
          ),
        ),
      ],
    );
  }

  // 📶 Network Stats
  Widget _buildNetworkStatus() {
    return StreamBuilder<VpnStatus?>(
      initialData: VpnStatus(),
      stream: VpnEngine.vpnStatusSnapshot(),
      builder: (context, snapshot) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          HomeCard(
            title: '${snapshot.data?.byteIn ?? '0 kbps'}',
            subtitle: 'DOWNLOAD',
            icon: const CircleAvatar(
              backgroundColor: Colors.green,
              radius: 30,
              child: Icon(Icons.arrow_downward, size: 30, color: Colors.white),
            ),
          ),
          HomeCard(
            title: '${snapshot.data?.byteOut ?? '0 kbps'}',
            subtitle: 'UPLOAD',
            icon: const CircleAvatar(
              backgroundColor: Colors.white,
              radius: 30,
              child: Icon(Icons.arrow_upward, size: 30, color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  // 🌎 Bottom Panel
  Widget _bottomPanel(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => Get.to(() => LocationScreen()),
            child: Container(
              color: Colors.black.withOpacity(0.3),
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Row(
                children: [
                  Icon(CupertinoIcons.globe, color: Colors.white, size: 28),
                  SizedBox(width: 10),
                  Text('Change Location', style: TextStyle(color: Colors.white, fontSize: 18)),
                  Spacer(),
                  CircleAvatar(backgroundColor: Colors.black26, child: Icon(Icons.keyboard_arrow_right, color: Colors.white)),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () {
              if (_controller.autoRotating.value) {
                _controller.stopAutoRotation();
                appLogs.insert(0, '⏹️ Auto IP Rotation Stopped');
              } else {
                _controller.startAutoRotation();
                appLogs.insert(0, '🔄 Auto IP Rotation Started');
              }
              if (appLogs.length > 200) appLogs.removeLast();
            },
            child: Container(
              color: Colors.black.withOpacity(0.3),
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(Icons.autorenew_rounded, color: Colors.white, size: 28),
                  const SizedBox(width: 10),
                  Obx(() => Text(
                    _controller.autoRotating.value ? 'Stop Auto-Rotation' : 'Rotate IPs',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  )),
                  const Spacer(),
                  const CircleAvatar(backgroundColor: Colors.black26, child: Icon(Icons.vpn_key, color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rotationMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.yellow.shade800.withOpacity(0.9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          '🔁 Auto IP Rotation active...',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // 🛡️ MultiLayer Section
  Widget _multiLayerSection() {
    return Column(
      children: [
        const Text("🔒 Multi-Layer VPN (3 Layers)", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        if (multiLayerActive.value)
          Column(
            children: List.generate(3, (i) =>
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "Layer ${i + 1}: ${connectedIps.length > i ? connectedIps[i] : 'Connected'}",
                    style: const TextStyle(color: Colors.greenAccent),
                  ),
                )
            ),
          ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  if (multiLayerActive.value) return;
                  final vpnList = await APIs.getVPNServers();
                  if (vpnList.length >= 3) {
                    multiLayerActive.value = true;
                    connectedIps.clear();
                    for (int i = 0; i < 3; i++) {
                      final vpn = vpnList[i];
                      final config = utf8.decode(base64Decode(vpn.openVPNConfigDataBase64));
                      await VpnEngine.startVpn(VpnConfig(country: vpn.countryLong, username: 'vpn', password: 'vpn', config: config));
                      connectedIps.add(vpn.ip);
                      appLogs.insert(0, '✅ Connected Layer ${i+1} - ${vpn.ip}');
                      if (appLogs.length > 200) appLogs.removeLast();
                      await Future.delayed(const Duration(seconds: 3));
                    }
                  } else {
                    Get.snackbar('MultiLayer VPN', 'Not enough servers (3 needed)');
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                child: const Text('Start Multi-Layer'),
              ),
              const SizedBox(width: 5),
              ElevatedButton(
                onPressed: () async {
                  if (!multiLayerActive.value) return;
                  await VpnEngine.stopVpn();
                  connectedIps.clear();
                  multiLayerActive.value = false;
                  appLogs.insert(0, '⛔️ Multi-Layer VPN Stopped');
                  if (appLogs.length > 200) appLogs.removeLast();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                child: const Text('Stop Multi-Layer'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
