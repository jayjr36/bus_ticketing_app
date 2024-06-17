// lib/screens/register_screen.dart

import 'package:bus_ticketing_app/screens/login.dart';
import 'package:bus_ticketing_app/services.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:loading_overlay/loading_overlay.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isloading = true;
      });
      final response = await http.post(
        Uri.parse(Services().baseUrl + Services().register),
        body: {
          'name': _nameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
          'password_confirmation': _passwordController.text,
          'card_number': _cardNumberController.text,
          'balance': _balanceController.text,
        },
      );

      if (response.statusCode == 201) {
        setState(() {
          isloading = false;
        });
        final data = json.decode(response.body);
        Fluttertoast.showToast(
            msg: 'Registration successful', backgroundColor: Colors.green);
      } else {
        setState(() {
          isloading = false;
        });
        Fluttertoast.showToast(
            msg: 'Registration failed', backgroundColor: Colors.red);
      }
    }
  }

  bool isloading = false;
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: LoadingOverlay(
        isLoading: isloading,
        progressIndicator: const CircularProgressIndicator(),
        child: SingleChildScrollView(
          child: Padding(
            padding:
                EdgeInsets.symmetric(vertical: h * 0.2, horizontal: w * 0.1),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text(
                    'RFID Based Billing System',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: h * 0.1),
                  const Text(
                    'Create an Account',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _cardNumberController,
                    decoration: const InputDecoration(labelText: 'Card Number'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your card number';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _balanceController,
                    decoration: const InputDecoration(labelText: 'Balance'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the balance';
                      }
                      return null;
                    },
                  ),
                  ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange),
                    child: const Text(
                      'Register',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: ((context) => const LoginScreen())));
                      },
                      child: const Text('Login', style: TextStyle(color: Colors.deepOrange),))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
