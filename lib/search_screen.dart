// ignore_for_file: use_super_parameters, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

class SearchScreen extends StatefulWidget {
  final String category;

  const SearchScreen({Key? key, required this.category}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _athletes = [];
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _top10Athletes = [];

  @override
  void initState() {
    super.initState();
    _loadCsvData();
  }

  Future<void> _loadCsvData() async {
    String fileName;
    switch (widget.category) {
      case 'Fioretto Femminile':
        fileName = 'fioretto_f.csv';
        break;
      case 'Fioretto Maschile':
        fileName = 'fioretto_m.csv';
        break;
      case 'Sciabola Femminile':
        fileName = 'sciabola_f.csv';
        break;
      case 'Sciabola Maschile':
        fileName = 'sciabola_m.csv';
        break;
      case 'Spada Femminile':
        fileName = 'spada_f.csv';
        break;
      case 'Spada Maschile':
        fileName = 'spada_m.csv';
        break;
      default:
        throw Exception('Categoria non valida');
    }

    String csvData = await rootBundle.loadString('assets/$fileName');
    List<List<dynamic>> csvTable = const CsvToListConverter().convert(csvData, fieldDelimiter: ';');
    
    setState(() {
      _athletes = csvTable.skip(1).map((row) {
        return {
          'Rank': row[0],
          'NOME': row[1],
        };
      }).toList();

      _top10Athletes = _athletes.take(10).toList();
      _searchResults = _athletes;
    });
  }

  void _onSearch() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _searchResults = _athletes.where((athlete) =>
        athlete['NOME'].toString().toLowerCase().contains(query)
      ).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cerca un atleta',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _onSearch,
                ),
              ),
              onChanged: (value) => _onSearch(),
            ),
            const SizedBox(height: 16),
            Text(
              'Top 10 Atleti',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _searchResults.isEmpty
                ? const Center(child: Text('Nessun risultato trovato'))
                : ListView.builder(
                    itemCount: _searchController.text.isEmpty ? _top10Athletes.length : _searchResults.length,
                    itemBuilder: (context, index) {
                      final athlete = _searchController.text.isEmpty ? _top10Athletes[index] : _searchResults[index];
                      return ListTile(
                        title: Text(athlete['NOME'].toString()),
                        subtitle: Text('Rank: ${athlete['Rank'].toString()}'),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}