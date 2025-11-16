
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

import '../models/doctors.dart';

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
  //String responseBody = 'Fetching...';
  List<Doctor> doctors = [];
  bool isLoading = false;
  bool isDataLoading = false;
  bool hasNextPage = false;
  final logger = Logger();

  final ScrollController _scrollController = ScrollController();

  int? size = 10;
  int page = 0;

  @override
  void initState() {
    super.initState();
    apiUrl = dotenv.env['DOC_URL'];
    _scrollController.addListener(scrollListener);
    fetchApiData();
  }

  void fetchApiData({bool isPaginating = false}) async {
    if (apiUrl == null) {
      setState(() {
        //responseBody = 'ApI not found';
        doctors = []; // i used it for doctor list from the model to come
        isLoading = false;
        isDataLoading = false; // for page load
      });
      logger.e('API not found');
      // log(message);
      return;    }

    //Reset page on initial load newly add for page load
    if (!isPaginating) {
      page = 0;
      doctors.clear();
    }

    setState(() {
      if (isPaginating) {
        isDataLoading = true;
      } else {
        isLoading = true;
      }
    });

    try {
      Map<String, dynamic> params = {};

      params["size"] = size;
      params["page"] = page;

      final dio = Dio();
      logger.d('Making GET request to $apiUrl/doctor/available-doctors');
      final response = await dio.get(
        '$apiUrl/doctor/available-doctors',
        queryParameters: params,
      );
      // for parsing json data to doctor model
      final Doctors model = Doctors.fromJson(response.data);

      // Extract hasNextPage from response for page load
      hasNextPage = model.data?.pagination?.hasNext ?? false;
      logger.d('HasNextPage: $hasNextPage, Current Page: $page');

      if (model.statusCode == 200) {
        setState(() {
          // // responseBody = response.data.toString();
          // doctors = model.data?.doctors ?? [];
          // isLoading = false;
          if (isPaginating) {
            // Append new doctors when paginating
            doctors.addAll(model.data?.doctors ?? []);
            isDataLoading = false;
          } else {
            //replace list on initial load
            doctors = model.data?.doctors ?? [];
            isLoading = false;
          }
        });
      } else {
        setState(() {
          // // responseBody = response.data.toString();
          // doctors = [];
          // isLoading = false;
          if (!isPaginating) {
            doctors = [];
          }
          isLoading = false;
          isDataLoading = false;
        });
      }

      // for null safety i am using ?? [
    } catch (e) {
      logger.e('Error making GET request: $e');
      setState(() {
        // //responseBody = 'Error: $e';
        // doctors = [];
        // isLoading = false;
        if (!isPaginating) {
          doctors = [];
        }
        isLoading = false;
        isDataLoading = false;
      });
    }
  }

  void scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent-100) {

      if (!isDataLoading && !isLoading && hasNextPage) {
        logger.d('Scroll reached bottom, fetching next page');
        page++;
        fetchApiData(isPaginating: true); // Pass isPaginating flag
      }

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Doctor List')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('API URL: $apiUrl'),
            //Expanded(child: Text('Respone body: $responseBody')),
            // for doctor list fetching with listview
            isLoading
                ? Center(child: CircularProgressIndicator())
                : (doctors.isEmpty)
                ? Center(child: Text('No doctors found'))
                : Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      controller: _scrollController,
                      itemCount: doctors.length,
                      itemBuilder: (context, index) {
                        final doc = doctors[index];
                        return Card(
                          child: ListTile(
                            leading: SizedBox(
                              height: 20,
                              width: 20,
                              child: Image(
                                  image: NetworkImage(doc.profilePic ?? "", scale: 1),

                              ),
                            ),
                            title: Text(doc.name ?? 'No Name'),
                            subtitle: Text(doc.degrees ?? ''),
                            trailing:
                                doc.specialty != null &&
                                    doc.specialty!.title != null
                                ? Text(doc.specialty!.title!)
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
            isDataLoading == true
                ? Center(child: CircularProgressIndicator())
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
