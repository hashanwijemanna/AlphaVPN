import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart';
import '../models/vpn_status.dart';
import '../models/vpn_config.dart';
import '../apis/apis.dart';
import '../models/vpn.dart';
import '../models/vpn_config.dart';

class VpnEngine {
  ///Channel to native
  static final String _eventChannelVpnStage = "vpnStage";
  static final String _eventChannelVpnStatus = "vpnStatus";
  static final String _methodChannelVpnControl = "vpnControl";

  ///Snapshot of VPN Connection Stage
  static Stream<String> vpnStageSnapshot() =>
      EventChannel(_eventChannelVpnStage).receiveBroadcastStream().cast();

  ///Snapshot of VPN Connection Status
  static Stream<VpnStatus?> vpnStatusSnapshot() =>
      EventChannel(_eventChannelVpnStatus)
          .receiveBroadcastStream()
          .map((event) => VpnStatus.fromJson(jsonDecode(event)))
          .cast();

  ///Start VPN easily
  static Future<void> startVpn(VpnConfig vpnConfig) async {
    log(vpnConfig.config);
    return MethodChannel(_methodChannelVpnControl).invokeMethod(
      "start",
      {
        "config": vpnConfig.config,
        "country": vpnConfig.country,
        "username": vpnConfig.username,
        "password": vpnConfig.password,
      },
    );
  }

  static Future<void> rotateIP() async {
    final vpnList = await APIs.getVPNServers();

    if (vpnList.isNotEmpty) {
      final selectedVpn = vpnList.first; // Pick the top random VPN

      final configDecoded = Utf8Decoder().convert(
        Base64Decoder().convert(selectedVpn.openVPNConfigDataBase64),
      );

      final vpnConfig = VpnConfig(
        config: configDecoded,
        country: selectedVpn.countryLong,
        username: "vpn",
        password: "vpn",
      );

      // Stop current connection if any
      await stopVpn();

      // Start new connection
      await startVpn(vpnConfig);
    }
  }

  ///Stop vpn
  static Future<void> stopVpn() =>
      MethodChannel(_methodChannelVpnControl).invokeMethod("stop");

  ///Open VPN Settings
  static Future<void> openKillSwitch() =>
      MethodChannel(_methodChannelVpnControl).invokeMethod("kill_switch");

  ///Trigger native to get stage connection
  static Future<void> refreshStage() =>
      MethodChannel(_methodChannelVpnControl).invokeMethod("refresh");

  ///Get latest stage
  static Future<String?> stage() =>
      MethodChannel(_methodChannelVpnControl).invokeMethod("stage");

  ///Check if vpn is connected
  static Future<bool> isConnected() =>
      stage().then((value) => value?.toLowerCase() == "connected");

  ///All Stages of connection
  static const String vpnConnected = "connected";
  static const String vpnDisconnected = "disconnected";
  static const String vpnWaitConnection = "wait_connection";
  static const String vpnAuthenticating = "authenticating";
  static const String vpnReconnect = "reconnect";
  static const String vpnNoConnection = "no_connection";
  static const String vpnConnecting = "connecting";
  static const String vpnPrepare = "prepare";
  static const String vpnDenied = "denied";
}
