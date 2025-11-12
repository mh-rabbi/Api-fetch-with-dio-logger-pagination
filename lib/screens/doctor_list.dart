import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';


void printApiUrl() {
  String? apiUrl = dotenv.env['DOC_URL'];
  if (apiUrl != null) {
    Logger().d('API URL: $apiUrl');
  }
}

class DoctorListApp extends StatefulWidget {
  const DoctorListApp({super.key});

  @override
  State<DoctorListApp> createState() => _DoctorListAppState();
}

class _DoctorListAppState extends State<DoctorListApp> {
  String? apiUrl;
  String responseBody = 'Fetching...';
  final logger = Logger();

  @override
  void initState() {
    super.initState();
    apiUrl = dotenv.env['DOC_URL'];
  }

  void fetchApiData() async {
    if (apiUrl == null) {
      setState(() {
        responseBody = 'ApI not found';
      });
      return;
    }
    try {
      final dio = Dio();
      logger.d('Making GET request to $apiUrl/doctor/available-doctors');
      final response = await dio.get('$apiUrl/doctor/available-doctors');
      setState(() {
        responseBody = response.data.toString();
      });
    } catch (e) {
      logger.e('Error making GET request: $e');
      setState(() {
        responseBody = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String? apiUrl = dotenv.env['DOC_URL'];
    printApiUrl();

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Doctor List')),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('API URL: $apiUrl'),
              Text('Respone body: $responseBody'),
              ElevatedButton(
                onPressed: fetchApiData,
                child: Text('Fetch API Data'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
