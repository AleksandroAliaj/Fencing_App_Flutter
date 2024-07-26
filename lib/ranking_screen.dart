import 'package:flutter/material.dart';
import 'search_screen.dart'; // Importa la nuova schermata

class RankingScreen extends StatelessWidget {
  const RankingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16.0),
      childAspectRatio: 3 / 2,
      children: <Widget>[
        _buildCategoryCard(context, 'Fioretto Femminile', Icons.woman),
        _buildCategoryCard(context, 'Fioretto Maschile', Icons.man),
        _buildCategoryCard(context, 'Sciabola Femminile', Icons.woman),
        _buildCategoryCard(context, 'Sciabola Maschile', Icons.man),
        _buildCategoryCard(context, 'Spada Femminile', Icons.woman),
        _buildCategoryCard(context, 'Spada Maschile', Icons.man),
      ],
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, IconData icon) {
    return Card(
      elevation: 4.0,
      child: InkWell(
        onTap: () {
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
            Icon(icon, size: 48.0),
            const SizedBox(height: 8.0),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
