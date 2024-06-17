// lib/screens/user_details_screen.dart

import 'package:bus_ticketing_app/screens/scan.dart';
import 'package:bus_ticketing_app/screens/tickets.dart';
import 'package:bus_ticketing_app/services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
      final data = json.decode(response.body);
      setState(() {
        user = data['user'];
        card = data['card'];
      });
    } else {
      // Handle error
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
          title: const Text(
        'Welcome',
        style: TextStyle(color: Colors.deepOrange),
      )),
      body: user == null || card == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Card(
                    elevation: 5,
                    surfaceTintColor: Colors.deepOrange,
                    shadowColor: Colors.deepOrange,
                      child: SizedBox(
                    width: w * 0.8,
                    child: Column(
                      children: [
                        Text(' ${user!['name']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                        Text(' ${user!['email']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                         const Text('Card Number', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                        Text(' ${card!['card_number']}'),
                         const Text('Balance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                        Text(' ${card!['balance']}'),
                      ],
                    ),
                  )),
                  SizedBox(
                    height: h * 0.1,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: ((context) => const ScanScreen())));
                      },
                      child: const Text('Scanner')),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: ((context) =>
                                    const TicketsScreen())));
                      },
                      child: const Text('Tickets'))
                ],
              ),
            ),
    );
  }
}
