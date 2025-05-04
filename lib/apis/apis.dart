import 'dart:convert';
import 'dart:developer';
import 'package:csv/csv.dart';
import 'package:http/http.dart';
import '../models/vpn.dart';

class APIs {
  static Future<List<Vpn>> getVPNServers() async {
    final List<Vpn> vpnList = [];
    try {
      final res = await get(Uri.parse('https://www.vpngate.net/api/iphone/'));
      if (res.statusCode == 200 && res.body.contains("#")) {
        final csvString = res.body.split("#")[1].replaceAll('*', '');
        List<List<dynamic>> list = const CsvToListConverter().convert(csvString);
        final header = list[0];

        for (int i = 1; i < list.length - 1; ++i) {
          Map<String, dynamic> tempJson = {};
          for (int j = 0; j < header.length; ++j) {
            tempJson[header[j].toString()] = list[i][j];
          }
          vpnList.add(Vpn.fromJson(tempJson));
        }
        vpnList.shuffle();
      } else {
        log('Failed to load VPN data or invalid format');
      }
    } catch (e) {
      log('getVPNServers Exception: $e');
    }
    return vpnList;
  }
}