import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

StreamController<int> _position = StreamController.broadcast();
StreamController<int> _hight = StreamController.broadcast();

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  ScrollController controller;
  int factor = 0;
  int index;

  List<int> dates = [14, 14, 15, 16, 17, 19];

  @override
  void initState() {
    super.initState();
    controller = ScrollController()
      ..addListener(() {
        //print(controller.positions);
        index = ((controller.offset + 50.0) / 218.0).floor();

        if (index != factor) {
          print(index);
          factor = index;

          // _position = factor*65.0;
          _position.add((dates.elementAt(index) - 14));
          _hight.add((dates.elementAt(index + 1) - dates.elementAt(index) + 1));
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    double factor = 0.1;
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
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
            onPressed: () {},
          ),
        ],
      ),
      body: Row(
        children: <Widget>[
          Container(
            width: 50.0,
            child: Stack(
              children: <Widget>[
                Transform(
                  transform: Matrix4.translationValues(lerpDouble(0.0, 30.0, factor),0.0,0.0)
                    ..rotateY((lerpDouble(0.0, 3.14/2, factor))),
                  child: SideCalender(),
                ),
                Transform(
                  transform: Matrix4.translationValues(lerpDouble(-30, 0.0, factor),0.0,0.0)
                    ..rotateY((lerpDouble(0.0, 3.14/2, 1-factor))),
                  child: SideCalender(),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              controller: controller,
              children: <Widget>[
                EventCard(
                  assetPath: "assets/amrdiab.jpg",
                  dayCardhight: 60.0,
                  radius: 50.0,
                  day: 14,
                  dayShortNotation: "Sat",
                  title1: "Alexandria",
                  title2: "Amr Diab",
                  title3: "Alexandria",
                ),
                EventCard(
                  assetPath: "assets/angam.jpg",
                  dayCardhight: 60.0,
                  radius: 50.0,
                  day: 14,
                  dayShortNotation: "Sat",
                  title1: "Alexandria",
                  title2: "Angham",
                  title3: "Alexandria",
                ),
                EventCard(
                  assetPath: "assets/hamaki.jpg",
                  dayCardhight: 60.0,
                  radius: 50.0,
                  day: 15,
                  dayShortNotation: "Sun",
                  title1: "Cairo",
                  title2: "M.Hamaki",
                  title3: "Cairo",
                ),
                EventCard(
                  assetPath: "assets/asala.jpeg",
                  dayCardhight: 60.0,
                  radius: 50.0,
                  day: 16,
                  dayShortNotation: "Mon",
                  title1: "Cairo",
                  title2: "Angham",
                  title3: "Cairo",
                ),
                EventCard(
                  assetPath: "assets/rihanna.jpg",
                  dayCardhight: 60.0,
                  radius: 50.0,
                  day: 17,
                  dayShortNotation: "Tue",
                  title1: "Luxor",
                  title2: "Riyana",
                  title3: "Luxor",
                ),
                EventCard(
                  assetPath: "assets/oka.jpg",
                  dayCardhight: 60.0,
                  radius: 50.0,
                  day: 19,
                  dayShortNotation: "Thu",
                  title1: "Aswan",
                  title2: "Oka & Ortiga",
                  title3: "Aswan",
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0.0,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              title: Text(
                "",
                style: TextStyle(fontSize: 0.0),
              )),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              title: Text(
                "",
                style: TextStyle(fontSize: 0.0),
              )),
          BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz),
              title: Text(
                "",
                style: TextStyle(fontSize: 0.0),
              )),
        ],
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final double hight;
  final double dayCardhight;
  final double radius;
  final String assetPath;
  final int day;
  final String dayShortNotation;
  final String title1;
  final String title2;
  final String title3;

  const EventCard({
    Key key,

    this.hight = 200.0,
    this.dayCardhight,
    this.radius,
    this.assetPath,
    this.day,
    this.dayShortNotation,
    this.title1,
    this.title2,
    this.title3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      child: Container(
        height: hight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(radius)),
          boxShadow: [
            BoxShadow(
              color: Color(0x55000000),
              blurRadius: 5.0,
              spreadRadius: 1.0,
              offset: Offset(0.0, 10.0),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30.0),
          child: Material(
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Image.asset(
                  assetPath,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  left: 0.0,
                  right: 0.0,
                  bottom: 0.0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.5),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            title1,
                            style: TextStyle(color: Colors.white),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Text(
                              title2,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                  letterSpacing: 3.0),
                            ),
                          ),
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.mic,
                                color: Colors.white,
                                size: 20.0,
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              Text(
                                title3,
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 20,
                  right: 20,
                  child: DayCard(
                    width: 40.0,
                    radiius: Radius.circular(30.0),
                    day: day,
                    hight: 60,
                    backgound: Colors.white,
                    dayShortNotation: dayShortNotation,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SideCalender extends StatelessWidget {
  final double hight;
  final double width;

  const SideCalender({
    Key key,
    this.hight = 55.0,
    this.width = 30.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Container(
        width: width,
        child: Transform(
          transform: Matrix4.translationValues(0.0, 0.0, 0.0),
          child: Stack(
            overflow: Overflow.visible,
            children: <Widget>[
              StreamBuilder<Object>(
                  stream: _position.stream,
                  initialData: 0.0,
                  builder: (context, snapshot) {
                    return AnimatedPositioned(
                      top: hight * (snapshot.data),
                      duration: Duration(milliseconds: 200),
                      child: StreamBuilder<Object>(
                          stream: _hight.stream,
                          initialData: 1.0,
                          builder: (context, snapshot) {
                            return AnimatedContainer(
                              height: hight * snapshot.data,
                              width: width,
                              duration: Duration(milliseconds: 500),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              child: SizedBox(
                                width: width,
                                height: hight,
                              ),
                            );
                          }),
                    );
                  }),
              Positioned(
                top: 0.0,
                height: hight,
                width: width,
                child: DayCard(
                  dayShortNotation: "Sat",
                  day: 14,
                ),
              ),
              Positioned(
                top: hight,
                height: hight,
                width: width,
                child: DayCard(
                  dayShortNotation: "Sun",
                  day: 15,
                ),
              ),
              Positioned(
                top: 2 * hight,
                height: hight,
                width: width,
                child: DayCard(
                  dayShortNotation: "Mon",
                  day: 16,
                ),
              ),
              Positioned(
                top: 3 * hight,
                height: hight,
                width: width,
                child: DayCard(
                  dayShortNotation: "Tue",
                  day: 17,
                ),
              ),
              Positioned(
                top: 4 * hight,
                height: hight,
                width: width,
                child: DayCard(
                  dayShortNotation: "Wed",
                  day: 18,
                ),
              ),
              Positioned(
                top: 5 * hight,
                height: hight,
                width: width,
                child: DayCard(
                  dayShortNotation: "Thr",
                  day: 19,
                ),
              ),
              Positioned(
                top: 6 * hight,
                height: hight,
                width: width,
                child: DayCard(
                  dayShortNotation: "Fri",
                  day: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// DayCard to display Day short notation and the current day
class DayCard extends StatelessWidget {
  final String dayShortNotation;
  final TextStyle dayShortNotationTextStyle;
  final int day;
  final TextStyle dayTextStyle;
  final double top;
  final double width;

  final double hight;

  final Radius radiius;
  final Color backgound;

  const DayCard({
    Key key,
    this.dayShortNotation = "Sat",
    this.day = 1,
    this.top = 0.0,
    this.width = 40.0,
    this.hight = 60.0,
    this.radiius,
    this.backgound = Colors.transparent,
    this.dayTextStyle = const TextStyle(fontSize: 16.0),
    this.dayShortNotationTextStyle = const TextStyle(fontSize: 10.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: backgound,
        borderRadius: const BorderRadius.all(Radius.circular(30.0)),
      ),
      child: SizedBox(
        width: width,
        height: hight,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Align(
            alignment: Alignment.center,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "$day",
                  style: dayTextStyle,
                ),
                Text(
                  "$dayShortNotation",
                  style: dayShortNotationTextStyle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
