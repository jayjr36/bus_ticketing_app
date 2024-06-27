// lib/screens/login_screen.dart

// ignore_for_file: use_build_context_synchronously

import 'package:bus_ticketing_app/screens/register.dart';
import 'package:bus_ticketing_app/screens/userdetails.dart';
import 'package:bus_ticketing_app/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:loading_overlay/loading_overlay.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isloading = true;
      });
      final response = await http.post(
        Uri.parse(Services().baseUrl + Services().login),
        body: {
          'email': _emailController.text,
          'password': _passwordController.text,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          isloading = false;
        });
        print(response.body);
        final data = json.decode(response.body);
        final token = data['token'];
        final user = data['user'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', token);
        prefs.setInt('user_id', user['id']);
        prefs.setString('user_name', user['name']);
        prefs.setString('user_email', user['email']);
        Fluttertoast.showToast(
            msg: 'Login successful', backgroundColor: Colors.green);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: ((context) => UserDetailsScreen(token: token))),
            (route) => false);

      } else {
        setState(() {
          isloading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login failed. Please check your credentials.'),
            backgroundColor: Colors.red,
          ),
        );
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
                EdgeInsets.symmetric(horizontal: w * 0.1, vertical: h * 0.15),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'QRidePay',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                      fontSize: 42,
                    ),
                  ),
                 Image.network('https://cdn-icons-png.flaticon.com/512/8792/8792047.png', 
                 height: h*0.1, 
                 width: h*0.1,), 
                  
                 // SizedBox(height: h * 0.1),
                  const Text(
                    'Login To Your Account',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(
                          color: Colors.black), // black label text color
                      // border: OutlineInputBorder(
                      //   borderSide: BorderSide(
                      //       color: Colors.black), // black border color
                      //),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(
                          color: Colors.black), // black label text color
                      // border: OutlineInputBorder(
                      //   borderSide: BorderSide(
                      //       color: Colors.black), // black border color
                      // ),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      _login(context);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.0))),
                      padding: EdgeInsets.symmetric(
                          horizontal: w * 0.33, vertical: h * 0.01),
                      backgroundColor: Colors.deepOrange,
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Center(
                    child: TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: ((context) =>
                                      const RegisterScreen())));
                        },
                        child: const Text(
                          'Create an account',
                          style: TextStyle(color: Colors.deepOrange),
                        )),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
