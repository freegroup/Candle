import 'dart:async';
import 'dart:ui';

import 'package:candle/app.dart';
import 'package:candle/services/geocoding.dart';
import 'package:candle/services/location.dart';

import 'package:candle/services/poi_provider.dart';
import 'package:candle/services/recorder.dart';
import 'package:candle/services/router.dart';
import 'package:candle/utils/geo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await RecorderService.initialize();
  await initialService();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GeoServiceProvider()),
        ChangeNotifierProvider(create: (_) => PoiProvider()),
        ChangeNotifierProvider(create: (_) => RoutingProvider()),
      ],
      child: const CandleApp(),
    ));
  });
}

Future<void> initialService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    iosConfiguration: IosConfiguration(),
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: false,
    ),
  );
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      print('setAsForeground');
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) async {
      print('setAsBackground');
      service.setAsBackgroundService();
    });
  }

  service.on('startedService').listen((event) async {
    print('startedService');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('backgroundServicePaused', false);
    Vibration.vibrate(duration: 100);
  });

  service.on('pauseService').listen((event) async {
    print('pauseService');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('backgroundServicePaused', true);
  });

  service.on('resumeService').listen((event) async {
    print('resumeService');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('backgroundServicePaused', false);
  });

  service.on('stopService').listen((event) async {
    print('stopService');
    service.stopSelf();
  });

  // Setup notification periodically
  Timer.periodic(const Duration(seconds: 5), (timer) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool backgroundServicePaused = prefs.getBool('backgroundServicePaused') ?? false;
    if (backgroundServicePaused) {
      print("paused");
      return;
    }

    if (service is AndroidServiceInstance && await service.isForegroundService()) {
      LatLng? loc = await LocationService.instance.location;
      if (loc != null) {
        service.invoke('location', {
          "current_date": DateTime.now().toIso8601String(),
          "location": {
            "latitude": loc.latitude,
            "longitude": loc.longitude,
          },
        });
      }
      Vibration.vibrate(duration: 100);
    }
  });
}
