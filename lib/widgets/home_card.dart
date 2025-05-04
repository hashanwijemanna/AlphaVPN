import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

class HomeCard extends StatelessWidget {
  final String title, subtitle;
  final Widget icon;

  const HomeCard({super.key, required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    var mq = MediaQuery.of(context).size;

    return SizedBox(
      width: mq.width * .45,
      child: Column(
        children: [
          icon,

          SizedBox(height: 6,),
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.6),
            ),
          ),

          SizedBox(height: 6,),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.5),
            ),
          ),

        ],
      ),
    );
  }
}
