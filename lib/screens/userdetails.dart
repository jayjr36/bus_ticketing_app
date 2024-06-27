// lib/screens/user_details_screen.dart

import 'package:bus_ticketing_app/screens/login.dart';
import 'package:bus_ticketing_app/screens/scan.dart';
import 'package:bus_ticketing_app/screens/tickets.dart';
import 'package:bus_ticketing_app/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:loading_overlay/loading_overlay.dart';

class UserDetailsScreen extends StatefulWidget {
  final String token;

  const UserDetailsScreen({super.key, required this.token});

  @override
  UserDetailsScreenState createState() => UserDetailsScreenState();
}

class UserDetailsScreenState extends State<UserDetailsScreen> {
  Map<String, dynamic>? user;
  Map<String, dynamic>? card;

  Future<void> _fetchUserDetails() async {
    final response = await http.get(
      Uri.parse(Services().baseUrl + Services().getUserDetails),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        isloading = true;
      });
      final data = json.decode(response.body);
      setState(() {
        user = data['user'];
        card = data['card'];
        isloading = false;
      });
    } else {
      setState(() {
        isloading = false;
      });
      Fluttertoast.showToast(
          msg: 'User not found', backgroundColor: Colors.red);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  bool isloading = false;
  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
          title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: _fetchUserDetails,
            child: const Text(
              'Welcome',
              style: TextStyle(color: Colors.deepOrange, fontSize: 18),
            ),
          ),
          IconButton(
            color: Colors.red,
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: ((context) => const LoginScreen())),
                  (route) => false);
            },
            icon: const Icon(
              Icons.logout_rounded,
            ),
          )
        ],
      )),
      body: LoadingOverlay(
        isLoading: isloading,
        progressIndicator: const CircularProgressIndicator(),
        child: user == null || card == null
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Card(
                        elevation: 5,
                        surfaceTintColor: Colors.deepOrange,
                        shadowColor: Colors.deepOrange,
                        child: SizedBox(
                          width: w * 0.9,
                          child: Column(
                            children: [
                              buildDetailRow(
                                context,
                                'Name',
                                '${user!['name']}',
                              ),
                              buildDetailRow(
                                  context, 'Email', '${user!['email']}'),
                              buildDetailRow(context, 'Card Number',
                                  '${card!['card_number']}'),
                              buildDetailRow(
                                  context, 'Balance', '${card!['balance']}')
                            ],
                          ),
                        )),
                    SizedBox(
                      height: h * 0.5,
                    ),
                    OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: ((context) => const ScanScreen())));
                        },
                        style: OutlinedButton.styleFrom(
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0))),
                            padding: EdgeInsets.symmetric(
                                horizontal: w * 0.3, vertical: h * 0.01),
                            backgroundColor: Colors.deepOrange),
                        child: const Text(
                          'Scanner',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        )),
                    SizedBox(
                      height: h * 0.005,
                    ),
                    OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: ((context) =>
                                      const TicketsScreen())));
                        },
                        style: OutlinedButton.styleFrom(
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0))),
                            padding: EdgeInsets.symmetric(
                                horizontal: w * 0.3, vertical: h * 0.01),
                            backgroundColor: Colors.orange),
                        child: const Text(
                          'Tickets',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ))
                  ],
                ),
              ),
      ),
    );
  }

  Widget buildDetailRow(BuildContext context, String label, String? value) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: h * 0.005, horizontal: w * 0.05),
      child: Row(
        children: [
          SizedBox(
            width: w * 0.4,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '$label:',
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          //SizedBox(width: w * 0.05),
          Expanded(
            child: SizedBox(
              width: w * 0.4,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  value ?? '',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
