import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';

import 'csv_picker.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CSV Reader',
      home: CsvPicker(),
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
    // print(csvRawData);
    List<List<dynamic>> decodedRows =
        CsvToListConverter(shouldParseNumbers: false).convert(csvRawData);
    print("decodedRows: $decodedRows");
    List<dynamic> keys = decodedRows[0];
    // decodedRows.removeAt(0);
    // decodedRows.forEach((element) {
    //   print("element: $element");
    //   for(var i =0;i<element.length;i++)
    //     {
    //       print("element[i]: ${element[i]}");
    //       csvData[keys[i]]=element[i];
    //     }
    // });
    print("csvData: $csvData");
    setState(() {
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
