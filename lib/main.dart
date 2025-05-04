import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/route_manager.dart';
import 'dart:async';
import 'screens/home_screen.dart';
import 'screens/intro_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'global_data.dart'; // NEW: Import GlobalData

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GlobalData.loadIntroSeen();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 10,
        ),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5), () async {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

      if (GlobalData.introSeen) {
        Get.off(() => HomeScreen());
      } else {
        Get.off(() => const IntroScreen());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: Container(
                    width: screenWidth * 0.3,
                    height: screenHeight * 0.3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/wolf_face.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
                child: Container(
                  width: screenWidth * 0.6,
                  height: 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.black,
                      width: 2.0,
                    ),
                  ),
                  child: const ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    child: LinearProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Column(
                  children: [
                    Text(
                      'AlphaVPN',
                      style: GoogleFonts.righteous(
                        color: Colors.black45.withOpacity(0.7),
                        fontSize: 30,
                        letterSpacing: 3,
                      ),
                    ),
                    Text(
                      '2025 All Rights Reserved.',
                      style: GoogleFonts.righteous(
                        color: Colors.black45.withOpacity(0.3),
                        fontSize: 10,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
