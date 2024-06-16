// lib/screens/user_details_screen.dart

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
      Uri.parse(Services().baseUrl+Services().getUserDetails),
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
    return Scaffold(
      appBar: AppBar(title: const Text('User Details')),
      body: user == null || card == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name: ${user!['name']}'),
                  Text('Email: ${user!['email']}'),
                  Text('Card Number: ${card!['card_number']}'),
                  Text('Balance: ${card!['balance']}'),
                ],
              ),
            ),
    );
  }
}
