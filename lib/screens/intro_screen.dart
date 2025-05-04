import 'package:alpha/global_data.dart';
import 'package:alpha/screens/home_screen.dart';
import 'package:flutter/material.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _controller = PageController();
  int currentIndex = 0;

  List<String> images = [
    'assets/intro/1.png',
    'assets/intro/2.png',
    'assets/intro/3.png',
    'assets/intro/4.png',
    'assets/intro/5.png',
  ];

  @override
  Widget build(BuildContext context) {
    var mq = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: images.length,
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Container(
                  width: mq.width,
                  height: mq.height,
                  child: Image.asset(
                    images[index],
                    fit: BoxFit.cover, // <-- ✨ Fills the whole screen nicely
                  ),
                );
              },
            ),
            // Back button
            Positioned(
              left: 10,
              top: mq.height * 0.45,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () {
                  if (currentIndex > 0) {
                    _controller.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
                  }
                },
              ),
            ),
            // Forward button
            Positioned(
              right: 10,
              top: mq.height * 0.45,
              child: IconButton(
                icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                onPressed: () async {
                  if (currentIndex == images.length - 1) {
                    await GlobalData.setIntroSeen(); // Save into file
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => HomeScreen()),
                    );
                  } else {
                    _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
