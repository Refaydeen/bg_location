import 'dart:async';

import 'package:bg_location/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const MyHomePage(title: 'Background Geolocation'),
      routes: routes,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _location ="getting location";
  String? currentAddress;
  Timer? timer;

//  Position? currentPosition;

  @override
  void initState() {

    super.initState();
    timer = Timer.periodic(Duration(seconds: 60), (Timer t) => printAddress());

  }
  void printAddress(){
    bg.BackgroundGeolocation.onLocation((bg.Location location) {
      setState(() {
        _location="lat:"+location.coords.latitude.toString() +"|"+"long:"+
            location.coords.longitude.toString();

      });
      Fluttertoast.showToast(
          msg: "[location]=$_location",
          toastLength: Toast.LENGTH_SHORT,
          fontSize: 16.0
      );
      placemarkFromCoordinates(
          location.coords.latitude, location.coords.longitude)
          .then((List<Placemark> placemarks) {
        Placemark place = placemarks[0];

        currentAddress =
        '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
        print(currentAddress);
      });
    });

    bg.BackgroundGeolocation.onMotionChange((bg.Location location) {
      //bg.Notification notification=bg.Notification(text:_location,title:'Bg Location App');
      setState(() {
        _location="lat:"+location.coords.latitude.toString() +"|"+"long"+
            location.coords.longitude.toString();
      });
      Fluttertoast.showToast(
          msg: "[motionChange]=$_location",
          toastLength: Toast.LENGTH_SHORT,
          fontSize: 16.0
      );
    });

    bg.BackgroundGeolocation.onProviderChange((bg.ProviderChangeEvent event) {

      Fluttertoast.showToast(
          msg: "[event]=$event",
          toastLength: Toast.LENGTH_SHORT,
          fontSize: 16.0
      );
    });
    bg.BackgroundGeolocation.ready(bg.Config(
        notification:bg.Notification(
          title: 'Bg Location App',
          text: 'running',
        ) ,

        desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
        distanceFilter: 10.0,
        stopOnTerminate:false,
        startOnBoot: true,
        debug: true,
        logLevel: bg.Config.LOG_LEVEL_VERBOSE))
        .then((bg.State state) {
      if (!state.enabled) {
        bg.BackgroundGeolocation.start();
      }
    });
      print("Address:"+currentAddress!);
  }
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(_location,style: TextStyle(fontSize: 18.0,),),
              Text('ADDRESS: ${currentAddress ?? ""}'),

            ],
          ),
        ),
      ),
    );
  }

}

