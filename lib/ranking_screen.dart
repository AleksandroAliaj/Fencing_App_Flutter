// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'search_screen.dart'; 

class RankingScreen extends StatelessWidget {
  const RankingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16.0),
      childAspectRatio: 1, 
      children: <Widget>[
        _buildCategoryButton(context, 'Fioretto Femminile', Icons.woman),
        _buildCategoryButton(context, 'Fioretto Maschile', Icons.man),
        _buildCategoryButton(context, 'Sciabola Femminile', Icons.woman),
        _buildCategoryButton(context, 'Sciabola Maschile', Icons.man),
        _buildCategoryButton(context, 'Spada Femminile', Icons.woman),
        _buildCategoryButton(context, 'Spada Maschile', Icons.man),
      ],
    );
  }

  Widget _buildCategoryButton(BuildContext context, String title, IconData icon) {
    final double buttonSize = MediaQuery.of(context).size.width * 0.30; 

    return Container(
      margin: const EdgeInsets.all(8.0),
      width: buttonSize,
      height: buttonSize,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white, 
          side: const BorderSide(color: Colors.black, width: 2), 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), 
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchScreen(category: title),
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, color: Colors.black, size: 35.0), 
            const SizedBox(height: 6.0), 
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
