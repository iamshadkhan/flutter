import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CSV Reader',
      home: CsvReader(),
    );
  }
}

class CsvReader extends StatefulWidget {
  @override
  _CsvReaderState createState() => _CsvReaderState();
}

class _CsvReaderState extends State<CsvReader> {
  List<Map<String, dynamic>> csvData = [];

  Future<void> loadCsvData() async {
    String csvRawData = await rootBundle.loadString('assets/data.csv');
    List<List> decodedRows =
        CsvToListConverter(shouldParseNumbers: false).convert(csvRawData);
    setState(() {
      csvData = decodedRows.cast<Map<String, dynamic>>();
    });
  }

  @override
  void initState() {
    super.initState();
    loadCsvData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CSV Reader'),
        centerTitle: true,
      ),
      body: csvData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  columns: List<DataColumn>.generate(
                      csvData[0].length,
                      (index) => DataColumn(
                            label: Text(csvData[0][index].toString()),
                          )),
                  rows: List<DataRow>.generate(
                      csvData.length - 1,
                      (index) => DataRow(
                            cells: List<DataCell>.generate(
                                csvData[0].length,
                                (index2) => DataCell(Text(
                                      csvData[index + 1][index2].toString(),
                                    ))),
                          )),
                ),
              ),
            ),
    );
  }
}
