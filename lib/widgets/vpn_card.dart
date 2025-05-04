import 'package:alpha/controllers/home_controller.dart';
import 'package:alpha/models/vpn.dart';
import 'package:alpha/services/vpn_engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VpnCard extends StatelessWidget {
  final Vpn vpn;

  const VpnCard({super.key, required this.vpn});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () async {
          controller.autoRotating.value = false;
          controller.showRotationMessage.value = false;
          controller.stopAutoRotation();

          controller.vpn.value = vpn;
          Get.back();

          if (controller.vpnState.value == VpnEngine.vpnDisconnected) {
            await VpnEngine.stopVpn();
            controller.connectToVpnWithConfig(vpn);
          } else {
            controller.connectToVpnWithConfig(vpn);
          }
        },
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/flags/${vpn.countryShort.toLowerCase()}.png',
              height: 40,
              width: 55,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(
            vpn.countryLong,
            style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          subtitle: Text('IP: ${vpn.ip}'),
          trailing: const Icon(CupertinoIcons.globe),
        ),
      ),
    );
  }
}
