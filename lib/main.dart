import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const ListScreen());
}

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});
  @override
  State<ListScreen> createState() => ListScreenState();
}

class ListScreenState extends State<ListScreen> {
  List<dynamic> users = [];
  List<ScanResult> results = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_ios_new)),
          title: const Text('Rest API Call')),
      floatingActionButton: FloatingActionButton(
        onPressed: scan,
      ),
      body: ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            // final user = users[index];
            // final email = user['email'];
            final result = results[index];
            return ListTile(
              title: Text('$result.device.name $result.rssi dBm'),
            );
          }),
    ));
  }

  void fetchUsers() async {
    final url = Uri.parse('https://randomuser.me/api/?results=50');
    final response = await http.get(url);
    final body = response.body;
    final json = jsonDecode(body);
    setState(() {
      users = json['results'];
    });
  }

  void scan() async {
    FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
    bool isBluetoothOn = await flutterBlue.isOn;

    if (!isBluetoothOn) {
      return;
    } else {
      print("bluetooth is on");
    }

    // Start scanning
    flutterBlue.startScan(timeout: Duration(seconds: 4));

// Listen to scan results
    var subscription = flutterBlue.scanResults.listen((results) {
      this.setState(() {
        this.results = results;
      });

      // do something with scan results
      for (ScanResult r in results) {
        print('${r.device.name} found! rssi: ${r.rssi}');
      }
    });

// Stop scanning
    flutterBlue.stopScan();
  }
}
