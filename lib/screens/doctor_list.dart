
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

  int? size = 15;
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

      // Extracting hasNextPage from response for page load
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
      appBar: AppBar(title: Text('Doctor List'), backgroundColor: Colors.grey, centerTitle: true, actions: [
        IconButton(onPressed: (){}, icon: Icon(Icons.search))]),
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
                            onTap: (){
                              showDialog(context: context, builder: (context) {
                                return AlertDialog(
                                  title: Text(doc.name ?? 'No Name'),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Image(image: NetworkImage(doc.profilePic ?? "", scale: 1)),
                                        Text('ID: ${doc.id}'),
                                        Text('Degrees: ${doc.degrees}'),
                                        Text('Experience: ${doc.experience}'),
                                        Text('Working At: ${doc.workingAt}'),
                                        Text('Fee: ${doc.fee}'),
                                        Text('Biography: ${doc.biography}'),
                                        Text('Patient Checked: ${doc.patientChecked}'),
                                        Text('Followup Fee: ${doc.followupFee}'),
                                        Text('Followup Day: ${doc.followupDay}'),
                                        Text('Specialty: ${doc.specialty?.title}'),
                                        Text('Specialty Name: ${doc.specialty?.name?.en}'),
                                        Text('Specialty Name: ${doc.specialty?.name?.bn}'),
                                        // Text('Profile Pic: ${doc.profilePic}'),
                                      ],

                                    ),
                                  ),
                                  actions: [
                                    TextButton(onPressed: (){
                                      Navigator.pop(context);
                                    }, child: Text('Close')),
                                  ],
                                  backgroundColor: Colors.grey,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 10,
                                );
                              } );
                            },
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
