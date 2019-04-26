import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:events/events/event_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_info/device_info.dart';

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
      routes: {
        'detailPage': (context) => DetailPage(),
      },
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
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  int sdk = 100;

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

    double factor = 0.0;

    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: SafeArea(
          child: Row(
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
        ),
        actions: <Widget>[
          SafeArea(
            child: IconButton(
              icon: Icon(Icons.search),
              color: Colors.black,
              onPressed: () {},
            ),
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
                  transform: Matrix4.translationValues(
                      lerpDouble(0.0, 30.0, factor), 0.0, 0.0)
                    ..rotateY((lerpDouble(0.0, 3.14 / 2, factor))),
                  child: SideCalender(),
                ),
                Transform(
                  transform: Matrix4.translationValues(
                      lerpDouble(-30, 0.0, factor), 0.0, 0.0)
                    ..rotateY((lerpDouble(0.0, 3.14 / 2, 1 - factor))),
                  child: SideCalender(),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: controller,
              itemCount: events.length,
              itemBuilder: (context, index) => GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          //transitionDuration: const Duration(seconds: 1),
                          pageBuilder: (BuildContext context,
                              Animation<double> animation,
                              Animation<double> secondaryAnimation) {
                            return DetailPage();
                          },
                          settings: RouteSettings(
                              arguments: ScreenArguments(index, events, sdk)),
                        ),
                      );

                    },
                    child: EventCard(
                      viewModel: events[index],
                    ),
                  ),
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
      ),
    );
  }
}

class ScreenArguments {
  final int index;
  final List<EventCardViewModel> events;
  final int sdk;
  ScreenArguments(this.index, this.events, this.sdk);
}

class DetailPage extends StatefulWidget {
  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation _mainPageTransitionAnimation;
  List<EventCardViewModel> events;
  OverlayState state;
  OverlayEntry entry;
  int index;
  int sdk;
  bool showOverlay = false;
  Offset nextCardOffset =  Offset.zero;
  Offset currentCardOffset = Offset.zero;
  Offset dragStart ;
  Offset dragPosition ;
  Offset swipeOffset ;
  bool dragleft;
  bool isPopingRequested = false;
  bool autoAnimate = true;


  @override
  void initState() {

    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 300))
          ..addStatusListener((status) {
            if (status == AnimationStatus.dismissed) {
              if (isPopingRequested) {
                Navigator.maybePop(context);
              }
            }
          })..addListener((){

          if (nextCardOffset != Offset.zero) {
            if (-nextCardOffset.dx < context.size.width / 2.0 || index == events.length-1) {

              setState(() {
                //Tween<Offset>(begin: )
                nextCardOffset = Offset(nextCardOffset.dx*(1-_controller.value),0.0);
              });

            } else {
              setState(() {
                nextCardOffset =
                    Tween<Offset>(begin: nextCardOffset,end: Offset(-context.size.width,0.0)).evaluate(_controller);
              });


            }
          } else {
            if (currentCardOffset.dx < context.size.width / 2.0 || index == 0) {
              setState(() {
                currentCardOffset = Offset(currentCardOffset.dx*(1-_controller.value),0.0);

              });

            } else {
              setState(() {
                currentCardOffset =
                    Tween<Offset>(begin: currentCardOffset,end: Offset(context.size.width,0.0))
                        .evaluate(_controller);

              });

            }
          }

        });
    state = Overlay.of(context);
    entry = OverlayEntry(
        builder: (context) => Positioned(
              bottom: 0.0,
              right: 0.0,
              left: 0.0,
              child: Container(
                height: 200.0,
                alignment: Alignment.bottomCenter,
                //width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(30.0),
                    topRight: const Radius.circular(30.0),
                  ),
                ),
              ),
            ));

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ScreenArguments argemnts = ModalRoute.of(context).settings.arguments;
    events = argemnts.events;
    index = index == null ? argemnts.index :index ;
    sdk = argemnts.sdk;
    if (sdk >= 21) {
      SystemChrome.setEnabledSystemUIOverlays([]);
    }

    if (_mainPageTransitionAnimation == null) {
      _mainPageTransitionAnimation = ModalRoute.of(context).animation
        ..addListener(() {
          print(
              "animating ....... value = ${_mainPageTransitionAnimation.value}");
        })
        ..addStatusListener((status) {
          print("status is ${status.toString()}");

          if (status == AnimationStatus.completed) {
            _controller.forward();
            if (showOverlay) {
              entry.remove();
              showOverlay = false;
              //entry = null;
              print("overlay removed");
            }
          }
          if (status == AnimationStatus.reverse) {
            if (showOverlay) {
              entry.remove();
              showOverlay = false;
              //entry = null;
              print("overlay removed");
            }
          }
        });

      if (state != null &&
          !showOverlay &&
          _mainPageTransitionAnimation.status != AnimationStatus.reverse) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => state.insert(entry));
        showOverlay = true;
        print("Overlay inserted");
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    //print("Hero tage is ${events[index].assetPath}");


    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onPanStart: (dragDetails) {
          dragStart = dragDetails.globalPosition;
        },
        onPanUpdate: (dragDetails) {
          dragPosition = dragDetails.globalPosition;
          swipeOffset = dragPosition - dragStart;

          if (nextCardOffset < Offset.zero ||
              (swipeOffset.dx)< 0.0 ) {
              nextCardOffset = swipeOffset;
              currentCardOffset = Offset.zero;
          } else if(currentCardOffset > Offset.zero || swipeOffset.dx > 0.0){
              currentCardOffset = swipeOffset;
              nextCardOffset = Offset.zero;
          }
          _controller.value = 1 -
              2* (swipeOffset.dx).abs() / context.size.width;
        },
        onPanEnd: (dragDeatail) {
          if (nextCardOffset.dx < 0.0) {
            if (-nextCardOffset.dx < context.size.width / 2.0 ) {
              //currentCardOffset = Offset.zero;
            } else {
              if(index< events.length-1){
                index = index + 1;
                currentCardOffset = nextCardOffset+Offset(context.size.width,0.0);
                nextCardOffset = Offset.zero;
              }
            }
          } else {
            if (currentCardOffset.dx < context.size.width / 2.0 ) {
             // nextCardOffset = Offset.zero;

            } else {
              if (index > 0) {
                index = index - 1;
                nextCardOffset = currentCardOffset-Offset(context.size.width,0.0);
                currentCardOffset = Offset.zero;
              }
            }
          }

          _controller.animateTo(1.0);
         // setState(() {
            dragStart = null;
            dragPosition = null;
        //  });
        },
        child: Stack(
          children: <Widget>[
            Container(
              height: double.infinity,
              child: index < 1
                  ? Container()
                  : Image.asset(
                      events[index - 1].assetPath,
                      fit: BoxFit.cover,
                    ),
            ),

            Transform(
              transform:
                  Matrix4.translationValues(currentCardOffset.dx, 0.0, 0.0),
              child: Hero(
                tag: events[index].assetPath,
                child: Container(
                  height: double.infinity,
                  child: Image.asset(
                    events[index].assetPath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraint) => Transform(
                    transform: Matrix4.translationValues(
                        constraint.maxWidth + nextCardOffset.dx, 0.0, 0.0),
                    child: Container(
                      height: double.infinity,
                      child: index == events.length - 1
                          ? Container()
                          : Image.asset(
                              events[index + 1].assetPath,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
            ),

            AppBar(
              //primary: false,
              elevation: 0.0,
              backgroundColor: Colors.transparent,
              leading: FadeTransition(
                opacity: Tween(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _controller,
                    curve: Interval(0.0, 1.0, curve: Curves.linear),
                  ),
                ),
                child: IconButton(
                  icon: const BackButtonIcon(),
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  onPressed: () {
                    isPopingRequested = true;
                    _controller.reverse();
                  },
                ),
              ),
              actions: <Widget>[
                FadeTransition(
                  opacity: Tween(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _controller,
                      curve: Interval(0.8, 1.0, curve: Curves.linear),
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.favorite_border,
                      color: Colors.white,
                    ),
                    onPressed: () {},
                  ),
                )
              ],
            ),
            Positioned(
              bottom: 0.0,
              right: 0.0,
              left: 0.0,
              child: Column(
                children: <Widget>[
                  Container(
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: List<String>.generate(
                                    events[index].title2.length,
                                    (n) => events[index].title2[n])
                                .asMap()
                                .map((i, t) => MapEntry(
                                      i,
                                      ScaleTransition(
                                        scale:
                                            Tween(begin: 0.5, end: 1.0).animate(
                                          CurvedAnimation(
                                            parent: _controller,
                                            curve: Interval(
                                                i / events[index].title2.length,
                                                1.0,
                                                curve: Curves.elasticInOut),
                                          ),
                                        ),
                                        child: FadeTransition(
                                          opacity: Tween(begin: 0.0, end: 1.0)
                                              .animate(
                                            CurvedAnimation(
                                              parent: _controller,
                                              curve: Interval(
                                                  i /
                                                      events[index]
                                                          .title2
                                                          .length,
                                                  (i + 1) /
                                                      events[index]
                                                          .title2
                                                          .length,
                                                  curve: Curves.easeInOutBack),
                                            ),
                                          ),
                                          child: Text(
                                            t,
                                            style: TextStyle(
                                                fontSize: 45,
                                                backgroundColor: Colors.black
                                                    .withOpacity(0.2),
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ))
                                .values
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  FadeTransition(
                    opacity: _mainPageTransitionAnimation,
                    child: Container(
                      alignment: Alignment.center,
                      height: 200.0,
                      //padding: EdgeInsets.all(16.0),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: const Radius.circular(30.0),
                          topRight: const Radius.circular(30.0),
                        ),
                      ),
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      border: const Border(
                                        right: BorderSide(
                                          width: 1.0,
                                          color: Colors.black12,
                                        ),
                                        bottom: const BorderSide(
                                          width: 1.0,
                                          color: Colors.black12,
                                        ),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        children: <Widget>[
                                          const Icon(
                                            Icons.mic,
                                            color: Colors.black26,
                                          ),
                                          Text(
                                            events[index].eventType,
                                            style: const TextStyle(
                                                color: Colors.black26),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border:  Border(
                                        right:  BorderSide(
                                          width: 1.0,
                                          color: Colors.black12,
                                        ),
                                        bottom:  BorderSide(
                                          width: 1.0,
                                          color: Colors.black12,
                                        ),
                                      ),
                                    ),
                                    child: Padding(
                                      padding:  EdgeInsets.all(16.0),
                                      child: Row(
                                        children: <Widget>[
                                          const Icon(
                                            Icons.mic,
                                            color: Colors.black26,
                                          ),
                                          Text(
                                            events[index].eventType,
                                            style: const TextStyle(
                                                color: Colors.black26),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      border: const Border(
                                        right: const BorderSide(
                                          width: 1.0,
                                          color: Colors.black12,
                                        ),
                                        bottom: const BorderSide(
                                          width: 1.0,
                                          color: Colors.black12,
                                        ),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        children: <Widget>[
                                          Icon(
                                            Icons.mic,
                                            color: Colors.black26,
                                          ),
                                          Text(
                                            events[index].eventType,
                                            style: const TextStyle(
                                                color: Colors.black26),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(
                                          Icons.location_on,
                                          color: Colors.black26,
                                        ),
                                        Text(
                                          events[index].location,
                                          style:
                                              TextStyle(color: Colors.black26),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: IconButton(
                                    icon: Icon(Icons.unfold_more),
                                    color: Colors.lightBlue[400],
                                    onPressed: () {},
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: RaisedButton(
                              color: Colors.lightBlue[300],
                              padding: EdgeInsets.only(
                                right: 110.0,
                                left: 110.0,
                                top: 16.0,
                                bottom: 16.0,
                              ),
                              shape:  RoundedRectangleBorder(
                                borderRadius:  BorderRadius.circular(20.0),
                              ),
                              child: Text(
                                "Book Now",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                ),
                              ),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
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
                  viewModel: DayCardViewModel(
                    dayShortNotation: "Sat",
                    day: 14,
                  ),
                ),
              ),
              Positioned(
                top: hight,
                height: hight,
                width: width,
                child: DayCard(
                  viewModel: DayCardViewModel(
                    dayShortNotation: "Sun",
                    day: 15,
                  ),
                ),
              ),
              Positioned(
                top: 2 * hight,
                height: hight,
                width: width,
                child: DayCard(
                  viewModel: DayCardViewModel(
                    dayShortNotation: "Mon",
                    day: 16,
                  ),
                ),
              ),
              Positioned(
                top: 3 * hight,
                height: hight,
                width: width,
                child: DayCard(
                  viewModel: DayCardViewModel(
                    dayShortNotation: "Tue",
                    day: 17,
                  ),
                ),
              ),
              Positioned(
                top: 4 * hight,
                height: hight,
                width: width,
                child: DayCard(
                  viewModel: DayCardViewModel(
                    dayShortNotation: "Wed",
                    day: 18,
                  ),
                ),
              ),
              Positioned(
                top: 5 * hight,
                height: hight,
                width: width,
                child: DayCard(
                  viewModel: DayCardViewModel(
                    dayShortNotation: "Thr",
                    day: 19,
                  ),
                ),
              ),
              Positioned(
                top: 6 * hight,
                height: hight,
                width: width,
                child: DayCard(
                  viewModel: DayCardViewModel(
                    dayShortNotation: "Fri",
                    day: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
