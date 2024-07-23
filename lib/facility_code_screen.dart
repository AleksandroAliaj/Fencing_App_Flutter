import 'package:flutter/material.dart';
import 'profile_screen.dart';

class FacilityCodeScreen extends StatelessWidget {
  final String facilityCode;

  const FacilityCodeScreen({super.key, required this.facilityCode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Facility Code'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Your Facility Code is:',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Text(
              facilityCode,
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              child: const Text('Go to Profile'),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
