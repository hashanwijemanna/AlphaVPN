import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/vpn.dart';
import '../models/vpn_config.dart';
import '../services/vpn_engine.dart';
import '../apis/apis.dart';

class HomeController extends GetxController {
  final Rx<Vpn> vpn = Vpn.fromJson({}).obs;
  final vpnState = VpnEngine.vpnDisconnected.obs;
  final RxBool startTimer = false.obs;
  final RxBool autoRotating = false.obs;
  final RxBool showRotationMessage = false.obs;
  Timer? _rotationTimer;

  void connectToVpn() {
    connectToVpnWithConfig(vpn.value);
  }

  void connectToVpnWithConfig(Vpn selectedVpn) {
    if (selectedVpn.openVPNConfigDataBase64.isEmpty) return;

    final config = _decodeConfig(selectedVpn.openVPNConfigDataBase64);
    final vpnConfig = VpnConfig(
      country: selectedVpn.countryLong,
      username: 'vpn',
      password: 'vpn',
      config: config,
    );

    print('📡 Connecting to: ${selectedVpn.countryLong}');
    VpnEngine.startVpn(vpnConfig);
    startTimer.value = true;
  }

  void startAutoRotation() {
    autoRotating.value = true;
    showRotationMessage.value = true;
    _rotationTimer?.cancel();
    _rotationTimer = Timer.periodic(const Duration(seconds: 60), (_) => rotateIp());
    rotateIp();
  }

  void stopAutoRotation() {
    autoRotating.value = false;
    showRotationMessage.value = false;
    _rotationTimer?.cancel();
  }

  Future<void> rotateIp() async {
    print("🔁 Rotating IP...");
    final vpnList = await APIs.getVPNServers();

    if (vpnList.isNotEmpty) {
      final selectedVpn = vpnList.firstWhere(
            (e) => e.openVPNConfigDataBase64.isNotEmpty,
        orElse: () => vpnList.first,
      );

      final configDecoded = _decodeConfig(selectedVpn.openVPNConfigDataBase64);

      final vpnConfig = VpnConfig(
        config: configDecoded,
        country: selectedVpn.countryLong,
        username: "vpn",
        password: "vpn",
      );

      try {
        await VpnEngine.stopVpn();
        await Future.delayed(const Duration(seconds: 2));
      } catch (e) {
        debugPrint("⚠️ Error stopping VPN: $e");
      }

      print("🚀 Rotated VPN to ${selectedVpn.countryLong}...");
      await VpnEngine.startVpn(vpnConfig);
      vpn.value = selectedVpn;
      startTimer.value = true;
      print("✅ VPN connected to ${selectedVpn.countryLong}");
    } else {
      debugPrint("⚠️ No VPN servers found.");
    }
  }

  String _decodeConfig(String base64) {
    final data = Base64Decoder().convert(base64);
    return Utf8Decoder().convert(data);
  }

  Color get getButtonColor => switch (vpnState.value) {
    VpnEngine.vpnDisconnected => Colors.red,
    VpnEngine.vpnConnected => Colors.green,
    _ => Colors.orangeAccent,
  };

  String get getButtonText => switch (vpnState.value) {
    VpnEngine.vpnDisconnected => 'Tap to Connect',
    VpnEngine.vpnConnected => 'Disconnect',
    _ => 'Connecting...',
  };

  String get getIpAddress => vpn.value.ip.isNotEmpty ? vpn.value.ip : '';

  String get getButtonImg => switch (vpnState.value) {
    VpnEngine.vpnConnected => 'assets/images/connect.gif',
    _ => 'assets/images/wolf_face.png',
  };
}
