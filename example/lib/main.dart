import 'package:flutter/material.dart';
import 'dart:async';

import 'package:cf_multi_picker/cf_multi_picker.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  List<dynamic> result = [];
  List<int> select = [];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {}

  void onPress(BuildContext context) {
    CfPicker.showMultiPicker(
        context: context,
        data: PickerData,
        onConfirm: (data, _select) {
            setState(() {
              result = data;
              select = _select;
            });
        });
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: const MediaQueryData(
        size: Size(1000, 500),
      ),
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("result: $result"),
              Text("select index: $select"),
              Builder(
                builder: (context) {
                  return ElevatedButton(
                      onPressed: () {
                        onPress(context);
                      },
                      child: const Icon(Icons.add));
                },
              ),
              FutureBuilder<String?>(
                future: CallNativeFlutter.platformVersion,
                builder: (_, snapshoot) {
                  return Text(snapshoot.data ?? '');
                },
              ),
            ],
          )),
        ),
      ),
    );
  }
}

List<dynamic> PickerData = [
  {
    'select': 1,
    'data': [1, 2, 3, 4]
  },
  {
    'select': 1,
    'data': [11, 22, 33, 44]
  },
  {
    'select': 1,
    'data': ["aaa", "bbb", "ccc"]
  }
];
