// // lib/screens/qr_scanner_screen.dart

// import 'package:flutter/material.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';
// import 'package:bus_ticketing_app/services.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'user_details_screen.dart';

// class QRScannerScreen extends StatefulWidget {
//   final String token;

//   QRScannerScreen({required this.token});

//   @override
//   _QRScannerScreenState createState() => _QRScannerScreenState();
// }

// class _QRScannerScreenState extends State<QRScannerScreen> {
//   final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
//   QRViewController? controller;

//   void _onQRViewCreated(QRViewController controller) {
//     this.controller = controller;
//     controller.scannedDataStream.listen((scanData) async {
//       controller.pauseCamera();
//       await _handleQRData(scanData.code);
//     });
//   }

//   Future<void> _handleQRData(String? qrData) async {
//     // Simulating the QR data containing route name
//     final routeName = qrData ?? 'Route1';

//     final response = await http.post(
//       Uri.parse(Services().baseUrl + Services().busInfo),
//       body: {'route_name': routeName},
//     );

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       final busName = data['bus_name'];
//       final fare = data['fare'];

//       // Deduct fare
//       await _deductFare(routeName, fare);

//       // Show bus information
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text('Bus Information'),
//           content: Text(
//               'Bus Name: $busName\nRoute Name: $routeName\nFare: \$${fare.toString()}'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 controller.resumeCamera();
//                 Navigator.of(context).pop();
//               },
//               child: Text('OK'),
//             ),
//           ],
//         ),
//       );
//     } else {
//       // Handle error
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to retrieve bus information')),
//       );
//     }
//   }

//   Future<void> _deductFare(String routeName, double fare) async {
//     final response = await http.post(
//       Uri.parse(Services().baseUrl + Services().deductFare),
//       body: {
//         'user_id': 'user-id', // Replace with actual user ID
//         'route_id': 'route-id', // Replace with actual route ID
//         'fare': fare.toString(),
//       },
//     );

//     if (response.statusCode != 200) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to deduct fare')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Scan QR Code')),
//       body: Column(
//         children: <Widget>[
//           Expanded(
//             flex: 5,
//             child: QRView(
//               key: qrKey,
//               onQRViewCreated: _onQRViewCreated,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     controller?.dispose();
//     super.dispose();
//   }
// }
