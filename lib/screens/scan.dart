// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:ffi';

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:bus_ticketing_app/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({Key? key}) : super(key: key);

  @override
  ScanState createState() => ScanState();
}

class ScanState extends State<ScanScreen> {
  String barcode = "";
  var parsedJson;
  String busName = "";
  String routeName = "";
  double fare = 0.0;
  String? routeId;
  int? user_Id;
  String? token;

  @override
  void initState() {
    super.initState();
    loadprefernces();
  }

  loadprefernces() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      user_Id = prefs.getInt('user_id');
      token = prefs.getString('token');
      print(user_Id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Scanner'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ElevatedButton(
                onPressed: scan,
                child: const Text('START CAMERA SCAN'),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                barcode.isEmpty
                    ? 'Scan a QR code'
                    : 'Scanned QR Code: \n$parsedJson',
                textAlign: TextAlign.center,
              ),
            ),
            if (busName.isNotEmpty &&
                routeName.isNotEmpty &&
                fare > 0) // Show button only when bardoce is scanned
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    processTicket();
                  },
                  child: const Text('Process Ticket'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future scan() async {
    try {
      var result = await BarcodeScanner.scan();
      setState(() {
        barcode = result.rawContent ?? "Failed to get the QR code content!";
      });

      if (barcode.isNotEmpty) {
        parsedJson = json.decode(barcode);
        setState(() {
          busName = parsedJson['bus_name'];
          routeName = parsedJson['route_name'];
          double.parse(parsedJson['fare']);
        });
        await fetchBusInfo();
      }
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          barcode = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() {
          barcode = 'Unknown error: $e';
        });
      }
    } on FormatException {
      setState(() {
        barcode =
            'null (User returned using the "back"-button before scanning anything. Result)';
      });
    } catch (e) {
      setState(() {
        barcode = 'Unknown error: $e';
      });
    }
  }

  Future<void> fetchBusInfo() async {
    try {
      final response = await http.post(
          Uri.parse(Services().baseUrl + Services().busInfo),
          body: jsonDecode(barcode));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          busName = data['bus_name'];
          routeName = data['route_name'];
          routeId = data['route_id'].toString();
          fare = double.parse(data['fare'].toString());
        });
      } else {
        throw Exception('Failed to fetch bus info');
      }
    } catch (e) {
      print('Error fetching bus info: $e');
      // Handle error accordingly
    }
  }

  void processTicket() async {
    try {
      final response = await http.post(
        Uri.parse(Services().baseUrl + Services().deductFare),
        body: {
          'user_id': user_Id.toString(),
          'route_id': routeId,
          'bus_name': busName,
          'route_name': routeName,
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        print(data);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message']),
            duration: const Duration(seconds: 3),
          ),
        );
        // Optionally, reset scanned data after successful processing
        setState(() {
          barcode = "";
          busName = "";
          routeName = "";
          fare = 0.0;
        });
      } else {
        print('Response status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to deduct fare: ${response.body}');
      }
    } catch (e) {
      print('Error processing ticket: $e');
      // Handle error accordingly
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error processing ticket. Please try again.'),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
