import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_workmanger/post_model.dart';
import 'package:http/http.dart' as http;
import 'package:workmanager/workmanager.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == 'uniqueKey') {
      PostModel? postModelObj = await fetchPostModel();
      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
          'Test Task', 'Task name test',
          importance: Importance.max, priority: Priority.high, showWhen: false);
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(0, postModelObj.title.toString(), postModelObj.body.toString(), platformChannelSpecifics,
          payload: 'Loading Finish!!');
    }
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  IOSInitializationSettings initializationSettingsIOS = const IOSInitializationSettings();
  MacOSInitializationSettings initializationSettingsMacOS = const MacOSInitializationSettings();
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS, macOS: initializationSettingsMacOS);
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onSelectNotification: (payload) {
      if (payload != null) {
        debugPrint('notification payload: $payload');
      }
    },
  );

  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

  Workmanager().registerPeriodicTask(
    "Work Manager Register",
    "uniqueKey",
    frequency: const Duration(minutes: 15), //
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Testing Notification in Background'),
      ),
    );
  }
}

Future<PostModel> fetchPostModel() async {
  final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts/1'));
  print('get data from server');
  if (response.statusCode == 200) {
    print('get data from server finish!');
    return PostModel.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load PostModel');
  }
}
