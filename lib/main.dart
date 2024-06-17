// lib/main.dart

import 'package:bus_ticketing_app/screens/login.dart';
import 'package:bus_ticketing_app/screens/register.dart';
import 'package:bus_ticketing_app/screens/scanner,dart';
import 'package:bus_ticketing_app/screens/tickets.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bus Ticket System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginScreen(),
      routes: {
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => const LoginScreen(),
       // '/qr-scanner': (context) => QRScannerScreen(token: 'your-token'),
        '/tickets': (context) => const TicketsScreen(), 
      },
    );
  }
}
