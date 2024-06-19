// lib/screens/tickets_screen.dart

import 'package:bus_ticketing_app/services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loading_overlay/loading_overlay.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  TicketsScreenState createState() => TicketsScreenState();
}

class TicketsScreenState extends State<TicketsScreen> {
  List<dynamic> tickets = [];
  String? token;
  String? userId;
  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token');
      userId = prefs.getInt('user_id')?.toString();
    });
    if (token != null && userId != null) {
      _fetchTickets();
    }
  }

  Future<void> _fetchTickets() async {
    setState(() {
      isLoading = true;
    });
    final response = await http.get(
      Uri.parse('${Services().baseUrl}tickets?user_id=$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      setState(() {
        tickets = json.decode(response.body)['tickets'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load tickets'), 
        backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Tickets',
          style:
              TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold),
        ),
      ),
      body: LoadingOverlay(
        isLoading: isLoading,
        child: tickets.isEmpty
            ? const Center(child: Text('You have no tickets to display'))
            : ListView.builder(
                itemCount: tickets.length,
                itemBuilder: (context, index) {
                  final ticket = tickets[index];
                  return ListTile(
                    textColor: Colors.deepOrange,
                    tileColor: Color.fromARGB(255, 242, 233, 219),
                    shape: const RoundedRectangleBorder(
                      side: BorderSide(color: Colors.deepOrange, width: 2),
                       borderRadius:
                                  BorderRadius.all(Radius.circular(10.0))),
                    subtitle: Text('Route: ${ticket['route_name']}'),
                    title: Text('${ticket['bus_name']}'),
                    trailing: Text('Fare: ${ticket['fare']}'),
                  );
                },
              ),
      ),
    );
  }
}
