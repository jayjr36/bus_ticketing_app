// lib/screens/tickets_screen.dart

import 'package:bus_ticketing_app/services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TicketsScreen extends StatefulWidget {
  final String token;

  const TicketsScreen({super.key, required this.token});

  @override
  TicketsScreenState createState() => TicketsScreenState();
}

class TicketsScreenState extends State<TicketsScreen> {
  List<dynamic> tickets = [];

  @override
  void initState() {
    super.initState();
    _fetchTickets();
  }

  Future<void> _fetchTickets() async {
    final response = await http.get(
      Uri.parse(Services().baseUrl+Services().getTickets),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    if (response.statusCode == 200) {
      setState(() {
        tickets = json.decode(response.body)['tickets'];
      });
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load tickets')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Tickets')),
      body: tickets.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                final ticket = tickets[index];
                return ListTile(
                  title: Text('Route: ${ticket['route']['name']}'),
                  subtitle: Text('Bus: ${ticket['bus']['name']}'),
                  trailing: Text('\$${ticket['fare']}'),
                );
              },
            ),
    );
  }
}
