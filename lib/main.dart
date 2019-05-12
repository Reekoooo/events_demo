import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:events/screens/details_screen.dart';
import 'package:events/ui/event_card.dart';
import 'package:events/ui/events_list.dart';
import 'package:events/ui/week_calender.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/rendering.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'blocs/provider.dart';

void main() {
  //debugPaintPointersEnabled = true;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Provider(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Home(),
        routes: {
          'detailPage': (context) => DetailPage(),
        },
      ),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  int sdk = 100;
  Stream<QuerySnapshot> eventStream;

  @override
  void initState() {
    super.initState();
    eventStream =
        Firestore.instance.collection("events").orderBy("datetime").snapshots();
    getAndroidVersion();
  }

  Future<void> getAndroidVersion() async {
    AndroidDeviceInfo androidDeviceInfo;
    try {
      if (Platform.isAndroid) {
        androidDeviceInfo = await deviceInfoPlugin.androidInfo;
        print(androidDeviceInfo.version.sdkInt);
      }
    } on PlatformException {
      print("Error:': 'Failed to get platform version.");
    }
    if (!mounted) return;

    setState(() {
      sdk = androidDeviceInfo.version.sdkInt;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (sdk > 21) {
      SystemChrome.setEnabledSystemUIOverlays([]); //SystemUiOverlay.values
    } else {
      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    }

    final double sideCalenderRotationFactor = 0.0;

    final Widget weekCalender = WeekCalender(
      dateTime: DateTime.now(), //events[0].dayCardViewModel.day,
      startFrom: StartingDayOfTheWeek.Saturday,
    );

    return Scaffold(
      appBar: _buildAppBar(),
      body: OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) => Flex(
              direction: orientation == Orientation.portrait
                  ? Axis.horizontal
                  : Axis.vertical,
              children: <Widget>[
                Container(
                  child: Stack(
                    children: <Widget>[
                      Transform(
                        transform: Matrix4.translationValues(
                            lerpDouble(0.0, 30.0, sideCalenderRotationFactor),
                            0.0,
                            0.0)
                          ..rotateY((lerpDouble(
                              0.0, 3.14 / 2, sideCalenderRotationFactor))),
                        child: weekCalender,
                      ),
                    ],
                  ),
                ),
                StreamBuilder(
                    stream: eventStream,
                    builder: (_, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData) {
                        final List<EventCardViewModel> events = snapshot
                            .data.documents
                            .map((event) =>
                                EventCardViewModel.fromSnapShot(event))
                            .toList();
                        return Expanded(
                          child: EventsList(
                            sdk: sdk,
                            events: events,
                          ),
                        );
                      } else {
                        return Expanded(
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                    }),
              ],
            ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      brightness: Brightness.dark,
      backgroundColor: Colors.white,
      elevation: 0.0,
      title: Row(
        children: <Widget>[
          Text(
            "Hot Tickets",
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.black,
            ),
          ),
          Icon(
            Icons.unfold_more,
            color: Colors.black,
          )
        ],
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.search),
          color: Colors.black,
          onPressed: () {
            showSearch(context: context, delegate: EventSearch(sdk));
          },
        ),
      ],
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      elevation: 0.0,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          title: Text(
            "",
            style: TextStyle(fontSize: 0.0),
          ),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          title: Text(
            "",
            style: TextStyle(fontSize: 0.0),
          ),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.more_horiz),
          title: Text(
            "",
            style: TextStyle(fontSize: 0.0),
          ),
        ),
      ],
    );
  }
}

class EventSearch extends SearchDelegate<EventCardViewModel> {
  final int sdk;

  EventSearch(this.sdk);

  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: implement buildActions
    return null;
  }

  @override
  Widget buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    print("sdk from search delegate is $sdk");
    if (sdk > 21) {
      SystemChrome.setEnabledSystemUIOverlays([]); //SystemUiOverlay.values
//       SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
//       statusBarBrightness: Brightness.light,
//       statusBarIconBrightness: Brightness.light,
//         statusBarColor: Colors.transparent,
//      ));
    } else {
      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    }
    // TODO: implement buildSuggestions
    return Container();
  }

}
