import 'package:flutter/material.dart';

const Color kDevBackground = Color(0xFFF7F9FC);         
const Color kDevCardBg = Colors.white;                  
const Color kDevCardBorder = Color(0xFF007BFF);         
const Color kDevTitleColor = Colors.black87;            
const Color kDevLabelColor = Color(0xFF007BFF);         
const Color kDevMessageTextColor = Colors.blueAccent;   

class DeveloperScreen extends StatelessWidget {
  const DeveloperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDevBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: AppBar(
          backgroundColor: const Color(0xFF007BFF),
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(28),
            ),
          ),
          centerTitle: false,
          title: const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              "Developer",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, 
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: kDevCardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kDevCardBorder, width: 1.8),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: const AssetImage('assets/image/zeva.jpg'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Zeva Mila Sabrina",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: kDevTitleColor,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "124230043",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Container(
              width: double.infinity, 
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: kDevCardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kDevCardBorder, width: 1.8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Pesan dan Kesan",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: kDevLabelColor,
                    ),
                  ),
                  SizedBox(height: 12),

                  Text(
                    "Mata Kuliahnya sangat menantang :)",
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: kDevMessageTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

    );
  }
}
