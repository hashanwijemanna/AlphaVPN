import 'package:alpha/controllers/location_controller.dart';
import 'package:alpha/widgets/vpn_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class LocationScreen extends StatelessWidget {
  LocationScreen({super.key});

  final LocationController _controller = Get.put(LocationController());

  @override
  Widget build(BuildContext context) {
    // Fetch VPN data when the screen is built
    _controller.getVpnData();

    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        backgroundColor: Colors.white, // White app bar background
        centerTitle: true,
        title: Text(
          'VPN Locations',
          style: GoogleFonts.righteous(
            textStyle: TextStyle(
              color: Colors.black.withOpacity(0.8), // Set title text color to black
              letterSpacing: 3,
            ),
          ),
        ),
      ),
      // Main body of the screen
      body: Obx(
            () => _controller.isLoading.value
            ? _loadingWidget() // Show loading widget while data is being fetched
            : _controller.vpnList.isEmpty
            ? _noVPNFound() // Show if no VPNs are found
            : _vpnData(context), // Show VPN data when available
      ),
    );
  }

  // Widget to display the VPN data in a list
  Widget _vpnData(BuildContext context) {
    var mq = MediaQuery.of(context).size;

    return ListView.builder(
      itemCount: _controller.vpnList.length,
      padding: EdgeInsets.only(
        top: mq.height * 0.015,
        bottom: mq.height * 0.05,
        left: mq.width * 0.04,
        right: mq.width * 0.04,
      ),
      itemBuilder: (ctx, i) {
        // Use VpnCard widget to display each VPN
        return VpnCard(vpn: _controller.vpnList[i]);
      },
    );
  }

  // Loading widget displayed while fetching data
  Widget _loadingWidget() => SizedBox(
    width: double.infinity,
    height: double.infinity,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LottieBuilder.asset('assets/lottie/loading.json'),
        SizedBox(height: 20),
        Text(
          'Loading Servers ...',
          style: TextStyle(
            fontSize: 25,
            color: Colors.white.withOpacity(0.5),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );

  // Widget displayed when no VPN servers are found
  Widget _noVPNFound() => SizedBox(
    width: double.infinity,
    height: double.infinity,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LottieBuilder.asset('assets/lottie/404.json'),
        SizedBox(height: 20),
        Text(
          'No Servers Found !!',
          style: TextStyle(
            fontSize: 25,
            color: Colors.white.withOpacity(0.5),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
