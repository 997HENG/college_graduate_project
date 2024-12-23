import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tutor_app/blocs/oberserver/app_bloc_observer.dart';
import 'package:tutor_app/firebase_options.dart';
import 'package:tutor_app/presentation/my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (WebRTC.platformIsAndroid) {
    startForegroundService();
  }

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //! remove in production
  Bloc.observer = const AppBlocObserver();

  runApp(const MyApp());
}

Future<bool> startForegroundService() async {
  const androidConfig = FlutterBackgroundAndroidConfig(
    notificationTitle: 'Title of the notification',
    notificationText: 'Text of the notification',
    notificationImportance: AndroidNotificationImportance.normal,
    notificationIcon: AndroidResource(
        name: 'background_icon',
        defType: 'drawable'), // Default is ic_launcher from folder mipmap
  );
  await FlutterBackground.initialize(androidConfig: androidConfig);
  return FlutterBackground.enableBackgroundExecution();
}
