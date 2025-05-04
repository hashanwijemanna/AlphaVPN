class Vpn {
  late final String hostname;
  late final String ip;
  late final String ping;
  late final int speed;
  late final String countryLong;
  late final String countryShort;
  late final String openVPNConfigDataBase64;

  Vpn({
    required this.hostname,
    required this.ip,
    required this.ping,
    required this.speed,
    required this.countryLong,
    required this.countryShort,
    required this.openVPNConfigDataBase64,
  });

  Vpn.fromJson(Map<String, dynamic> json) {
    hostname = json['HostName'] ?? '';
    ip = json['IP'] ?? '';
    ping = json['Ping']?.toString() ?? '0';  // Safely converting to string
    speed = json['Speed'] ?? 0;
    countryLong = json['CountryLong'] ?? '';  // Default value if null
    countryShort = json['CountryShort'] ?? 'XX';     // Default value if null
    openVPNConfigDataBase64 = json['OpenVPN_ConfigData_Base64'] ?? ''; // Default to empty string
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['HostName'] = hostname;
    data['IP'] = ip;
    data['Ping'] = ping;
    data['Speed'] = speed;
    data['CountryLong'] = countryLong;
    data['CountryShort'] = countryShort;
    data['OpenVPN_ConfigData_Base64'] = openVPNConfigDataBase64;
    return data;
  }
}
