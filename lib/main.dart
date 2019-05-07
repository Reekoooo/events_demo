import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:events/events/event_card.dart';
import 'package:events/week_calender.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/rendering.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//StreamController<int> _position = StreamController.broadcast();
//StreamController<int> _hight = StreamController.broadcast();
StreamController<WeekCalenderIndicator> indexController =
    StreamController.broadcast();

void main() {
  //debugPaintPointersEnabled = true;
  runApp(MyApp());
}

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
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  int sdk = 100;

  @override
  void initState() {
    super.initState();
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

    double sideCalenderRotationFactor = 0.0;

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
                        child: WeekCalender(
                          dateTime: events[0].dayCardViewModel.day,
                          startFrom: StartingDayOfTheWeek.Saturday,
                        ),
                      ),
//                  Transform(
//                    transform: Matrix4.translationValues(
//                        lerpDouble(-30, 0.0, sideCalenderRotationFactor),
//                        0.0,
//                        0.0)
//                      ..rotateY((lerpDouble(
//                          0.0, 3.14 / 2, 1 - sideCalenderRotationFactor))),
//                    child: WeekCalender(
//                      dateTime: DateTime.now(),
//                      startFrom: StartingDayOfTheWeek.Saturday,
//                     // direction: Axis.vertical,
//                    ),
//                  ),
                    ],
                  ),
                ),
                Expanded(
                  child: new EventsList(
                    sdk: sdk,
                    events: events,
                  ),
                ),
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
          onPressed: () {},
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

class EventsList extends StatefulWidget {
  const EventsList({
    Key key,
    @required this.sdk,
    @required this.events,
  }) : super(key: key);

  final int sdk;
  final List<EventCardViewModel> events;

  @override
  _EventsListState createState() => _EventsListState();
}

class _EventsListState extends State<EventsList> {
  ScrollController controller;
  double cardHeight;

  int factor = 0;
  int index = 0;
  DateTime position;
  int span;
  WeekCalenderIndicator indicator;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      indexController.add(_calculateIndicator(index));
    });

    controller = ScrollController()
      ..addListener(() {
        cardHeight = controller.position.viewportDimension / 2.5;
        // print("controller offset = ${controller.offset}");
        // print("Card height = $cardHeight");

        index = ((controller.offset + (cardHeight / 2) + 20.0) /
                (cardHeight + 20.0))
            .floor();

        if (index != factor) {
          print(index);
          factor = index;
          indexController.add(_calculateIndicator(index));
          //_calculateIndicator(index);

        }
      });
  }

  WeekCalenderIndicator _calculateIndicator(int index) {
    position = widget.events[index].dayCardViewModel.day;
    span = widget.events[index + 1].dayCardViewModel.day
        .difference(widget.events[index].dayCardViewModel.day)
        .inDays;

    print("position = $position span = $span");
    indicator = WeekCalenderIndicator(
      position: position,
      span: span,
    );

    return indicator;
  }

  Future getEvents() async{
    var fireStore = Firestore.instance;
    QuerySnapshot qn = await fireStore.collection("events").getDocuments();
    return qn.documents;

  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (BuildContext context, Orientation orientation) => LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) =>
                ListView.builder(
                  scrollDirection: orientation == Orientation.portrait
                      ? Axis.vertical
                      : Axis.horizontal,
                  controller: controller,
                  itemCount: events.length,
                  itemBuilder: (context, index) => GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              transitionDuration:
                                  const Duration(milliseconds: 200),
                              pageBuilder: (BuildContext context,
                                  Animation<double> animation,
                                  Animation<double> secondaryAnimation) {
                                return DetailPage();
                              },
                              settings: RouteSettings(
                                  arguments: ScreenArguments(
                                      index, events, widget.sdk)),
                            ),
                          );
                        },
                        child: EventCard(
                          eventCardHeight: orientation == Orientation.landscape
                              ? constraints.maxHeight
                              : constraints.maxHeight / 2.5,
                          eventCardWidth: orientation == Orientation.landscape
                              ? constraints.maxWidth / 2.5
                              : constraints.maxWidth,
                          viewModel: events[index],
                        ),
                      ),
                ),
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

class PhotoBrowser extends StatefulWidget {
  final List<EventCardViewModel> events;
  final int activePhotoIndex;
  final ValueNotifier<int> controller;

  PhotoBrowser({this.events, this.activePhotoIndex, this.controller});

  @override
  _PhotoBrowserState createState() => _PhotoBrowserState();
}

class _PhotoBrowserState extends State<PhotoBrowser>
    with TickerProviderStateMixin {
  AnimationController _nextCardBackController;
  AnimationController _currentCardBackController;
  AnimationController _nextCardForwardController;
  AnimationController _currentCardForwardController;
  Animation<Offset> _nextCardBackAnimation;
  Animation<Offset> _nextCardForwardAnimation;
  Animation<Offset> _currentCardBackAnimation;
  Animation<Offset> _currentCardForwardAnimation;
  Animation<double> _previousCardScaleAnimation;
  Animation<double> _currentCardScaleAnimation;

  int _currentCardIndex;
  Offset _dragStart;
  Offset _currentCardOffset;
  Offset _nextCardOffset;
  double _previousCardScale;

  double _currentCardScale;

  @override
  void initState() {
    _currentCardOffset = Offset.zero;
    _nextCardOffset = Offset.zero;
    _previousCardScale = 0.8;
    _currentCardScale = 1.0;
    _currentCardIndex = widget.activePhotoIndex;
    widget.controller?.value = _currentCardIndex;

    _nextCardBackController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..addListener(() {
            setState(() {
              print(_nextCardOffset);
              _nextCardOffset = _nextCardBackAnimation.value;
              _currentCardScale = _currentCardScaleAnimation.value;
            });
          });

    _nextCardForwardController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..addListener(() {
            setState(() {
              print(_nextCardOffset);
              _nextCardOffset = _nextCardForwardAnimation.value;
              _currentCardScale = _currentCardScaleAnimation.value;
            });
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              setState(() {
                _currentCardIndex = _currentCardIndex + 1;
                widget.controller?.value = _currentCardIndex;
                _nextCardOffset = Offset.zero;
                _currentCardScale = 1.0;
              });
            }
          });

    _currentCardBackController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..addListener(() {
            setState(() {
              print(_currentCardOffset);
              _currentCardOffset = _currentCardBackAnimation.value;
              _previousCardScale = _previousCardScaleAnimation.value;
            });
          });

    _currentCardForwardController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..addListener(() {
            setState(() {
              print(_currentCardOffset);
              _currentCardOffset = _currentCardForwardAnimation.value;
              _previousCardScale = _previousCardScaleAnimation.value;
            });
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              setState(() {
                _currentCardIndex = _currentCardIndex - 1;
                widget.controller?.value = _currentCardIndex;
                _currentCardOffset = Offset.zero;
                _previousCardScale = 0.8;
              });
            }
          });

    super.initState();
  }

  @override
  void didUpdateWidget(PhotoBrowser oldWidget) {
    if (widget.activePhotoIndex != oldWidget.activePhotoIndex) {
      _currentCardIndex = widget.activePhotoIndex;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _nextCardBackController.dispose();
    _nextCardForwardController.dispose();
    _currentCardBackController.dispose();
    _currentCardForwardController.dispose();
    super.dispose();
  }

  _onPanStart(DragStartDetails details) {
    _dragStart = details.globalPosition;
    _nextCardBackController.stop(canceled: true);
  }

  _onPanUpdate(DragUpdateDetails details) {
    final double maxWidth = context.size.width;
    final _dragPosition = details.globalPosition;
    final swipeDistance = _dragPosition - _dragStart;
    final double swipePercent = swipeDistance.dx / maxWidth;
    final bool swipeLeft = swipeDistance.dx.isNegative;
    print(
        "The drag distance = ${_dragPosition - _dragStart} , Swipepercent = $swipePercent");

    if (swipeLeft) {
      if (_currentCardOffset == Offset.zero) {
        setState(() {
          _nextCardOffset = Offset(swipeDistance.dx, 0.0);
          _currentCardScale = 1 - (1 - 0.8) * swipePercent.abs();
          print("current Card Scale = $_currentCardScale");
        });
      } else {
        setState(() {
          if (swipeDistance.dx < 0.0) {
            _currentCardOffset = Offset.zero;
          } else {
            _currentCardOffset = Offset(swipeDistance.dx, 0.0);
            _previousCardScale = 0.8 + (1 - 0.8) * swipePercent.abs();
          }
//          swipeDistance.dx < 0.0
//              ? _currentCardOffset = Offset.zero
//              : _currentCardOffset = Offset(swipeDistance.dx, 0.0);
        });
      }
    } else {
      //swiping right
      if (_nextCardOffset == Offset.zero) {
        setState(() {
          _currentCardOffset = Offset(swipeDistance.dx, 0.0);
          _previousCardScale = 0.8 + (1 - 0.8) * swipePercent.abs();
        });
      } else {
        swipeDistance.dx > 0.0 //next card offset increasing offscreen
            ? setState(() {
                _nextCardOffset = Offset.zero;
              })
            : setState(() {
                _nextCardOffset = Offset(swipeDistance.dx, 0.0);
                _currentCardScale = 1 - (1 - 0.8) * swipePercent.abs();
              });
      }
    }
  }

  _onPanEnd(DragEndDetails details) {
    final double maxWidth = context.size.width;
    final double thresholdBack = -maxWidth / 2;
    final bool firstCard = _currentCardIndex <= 0;
    final bool lastCard = _currentCardIndex >= events.length - 1;

    if (_nextCardOffset.dx != 0.0 &&
        (_nextCardOffset.dx > thresholdBack || lastCard)) {
      _nextCardBackAnimation =
          Tween<Offset>(begin: _nextCardOffset, end: Offset.zero).animate(
              CurvedAnimation(
                  parent: _nextCardBackController,
                  curve: Curves.fastOutSlowIn));
      _currentCardScaleAnimation =
          Tween<double>(begin: _currentCardScale, end: 1.0).animate(
              CurvedAnimation(
                  parent: _nextCardBackController,
                  curve: Curves.fastOutSlowIn));
      _nextCardBackController.forward(from: 0.0);
    } else if (_nextCardOffset.dx <= thresholdBack) {
      _nextCardForwardAnimation =
          Tween<Offset>(begin: _nextCardOffset, end: Offset(-maxWidth, 0.0))
              .animate(CurvedAnimation(
                  parent: _nextCardForwardController,
                  curve: Curves.fastOutSlowIn));

      _currentCardScaleAnimation =
          Tween<double>(begin: _currentCardScale, end: 0.8).animate(
              CurvedAnimation(
                  parent: _nextCardForwardController,
                  curve: Curves.fastOutSlowIn));

      _nextCardForwardController.forward(from: 0.0);
    }

    if (_currentCardOffset.dx != 0.0 &&
        (_currentCardOffset.dx < -thresholdBack || firstCard)) {
      _currentCardBackAnimation =
          Tween<Offset>(begin: _currentCardOffset, end: Offset.zero).animate(
              CurvedAnimation(
                  parent: _currentCardBackController,
                  curve: Curves.fastOutSlowIn));
      _previousCardScaleAnimation =
          Tween<double>(begin: _previousCardScale, end: 0.8).animate(
              CurvedAnimation(
                  parent: _currentCardBackController,
                  curve: Curves.fastOutSlowIn));
      _currentCardBackController.forward(from: 0.0);
    } else if (_currentCardOffset.dx >= -thresholdBack) {
      _currentCardForwardAnimation =
          Tween<Offset>(begin: _currentCardOffset, end: Offset(maxWidth, 0.0))
              .animate(CurvedAnimation(
                  parent: _currentCardForwardController,
                  curve: Curves.fastOutSlowIn));
      _previousCardScaleAnimation =
          Tween<double>(begin: _previousCardScale, end: 1.0).animate(
              CurvedAnimation(
                  parent: _currentCardForwardController,
                  curve: Curves.fastOutSlowIn));
      _currentCardForwardController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Container(
        color: Colors.transparent,
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            _currentCardIndex < 1
                ? PhotoCard.empty(
                    offset: Offset.zero,
                  )
                : PhotoCard(
                    imageAsset: widget.events[_currentCardIndex - 1].assetPath,
                    offset: Offset.zero,
                    scale: _previousCardScale,
                  ),
            PhotoCard(
              imageAsset: widget.events[_currentCardIndex].assetPath,
              offset: _currentCardOffset,
              scale: _currentCardScale,
            ),
            _currentCardIndex >= widget.events.length - 1
                ? PhotoCard.offScreenEmpty(
                    offset: _nextCardOffset,
                  )
                : PhotoCard.offScreen(
                    imageAsset: widget.events[_currentCardIndex + 1].assetPath,
                    offset: _nextCardOffset,
                  ),
          ],
        ),
      ),
    );
  }
}

class PhotoCard extends StatelessWidget {
  final String imageAsset;
  final Offset offset;
  final bool offScreen;
  final double scale;

  PhotoCard({
    this.imageAsset,
    this.offset,
    this.scale = 1.0,
  }) : offScreen = false;

  PhotoCard.empty({
    this.offset,
    this.scale = 1.0,
  })  : imageAsset = "",
        offScreen = false;

  PhotoCard.offScreen({this.imageAsset, this.offset, this.scale = 1.0})
      : offScreen = true;

  PhotoCard.offScreenEmpty({this.offset, this.scale = 1.0})
      : imageAsset = "",
        offScreen = true;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) => Transform(
            transform: offScreen == true
                ? Matrix4.translationValues(
                    constraints.maxWidth + offset.dx, offset.dy, 0.0)
                : Matrix4.translationValues(offset.dx, offset.dy, 0.0)
              ..scale(scale),
            child: Hero(
              createRectTween: EventCard.createRectTween,
              tag: imageAsset,
              child: Container(
                height: 200.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(0.0),
                  child: imageAsset == ""
                      ? Container(
                          color: Colors.black,
                        )
                      : Image.asset(
                          imageAsset,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
          ),
    );
  }
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
  ValueNotifier<int> indexChanged;
  Offset nextCardOffset = Offset.zero;
  Offset currentCardOffset = Offset.zero;
  Offset dragStart;

  Offset dragPosition;

  Offset swipeOffset;

  bool dragleft;
  bool isPopingRequested = false;
  bool autoAnimate = true;

  @override
  void initState() {
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300))
      ..addStatusListener((status) {
        if (status == AnimationStatus.dismissed) {
          if (isPopingRequested) {
            Navigator.maybePop(context);
          }
        }
      })
      ..addListener(() {
        if (nextCardOffset != Offset.zero) {
          if (-nextCardOffset.dx < context.size.width / 2.0 ||
              index == events.length - 1) {
            setState(() {
              //Tween<Offset>(begin: )
              nextCardOffset =
                  Offset(nextCardOffset.dx * (1 - _controller.value), 0.0);
            });
          } else {
            setState(() {
              nextCardOffset = Tween<Offset>(
                      begin: nextCardOffset,
                      end: Offset(-context.size.width, 0.0))
                  .evaluate(_controller);
            });
          }
        } else {
          if (currentCardOffset.dx < context.size.width / 2.0 || index == 0) {
            setState(() {
              currentCardOffset =
                  Offset(currentCardOffset.dx * (1 - _controller.value), 0.0);
            });
          } else {
            setState(() {
              currentCardOffset = Tween<Offset>(
                      begin: currentCardOffset,
                      end: Offset(context.size.width, 0.0))
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

    indexChanged = ValueNotifier(index)
      ..addListener(() {
        print("IndexCanged ${indexChanged.value}");
      });

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ScreenArguments argemnts = ModalRoute.of(context).settings.arguments;
    events = argemnts.events;
    index = index == null ? argemnts.index : index;
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
    indexChanged.dispose();
    super.dispose();
  }

  Widget _buildAppBar() {
    return SizedBox(
      height: kToolbarHeight,
      child: AppBar(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: <Widget>[
          PhotoBrowser(
            events: events,
            activePhotoIndex: index,
            controller: indexChanged,
          ),
          _buildAppBar()
        ],
      ),
//      body: GestureDetector(
//        onPanStart: (dragDetails) {
//          dragStart = dragDetails.globalPosition;
//        },
//        onPanUpdate: (dragDetails) {
//          dragPosition = dragDetails.globalPosition;
//          swipeOffset = dragPosition - dragStart;
//
//          if (nextCardOffset < Offset.zero ||
//              (swipeOffset.dx)< 0.0 ) {
//              nextCardOffset = swipeOffset;
//              currentCardOffset = Offset.zero;
//          } else if(currentCardOffset > Offset.zero || swipeOffset.dx > 0.0){
//              currentCardOffset = swipeOffset;
//              nextCardOffset = Offset.zero;
//          }
//          _controller.value = 1 -
//              2* (swipeOffset.dx).abs() / context.size.width;
//        },
//        onPanEnd: (dragDeatail) {
//          if (nextCardOffset.dx < 0.0) {
//            if (-nextCardOffset.dx < context.size.width / 2.0 ) {
//              //currentCardOffset = Offset.zero;
//            } else {
//              if(index< events.length-1){
//                index = index + 1;
//                currentCardOffset = nextCardOffset+Offset(context.size.width,0.0);
//                nextCardOffset = Offset.zero;
//              }
//            }
//          } else {
//            if (currentCardOffset.dx < context.size.width / 2.0 ) {
//             // nextCardOffset = Offset.zero;
//
//            } else {
//              if (index > 0) {
//                index = index - 1;
//                nextCardOffset = currentCardOffset-Offset(context.size.width,0.0);
//                currentCardOffset = Offset.zero;
//              }
//            }
//          }
//
//          _controller.animateTo(1.0);
//         // setState(() {
//            dragStart = null;
//            dragPosition = null;
//        //  });
//        },
//        child: Stack(
//          children: <Widget>[
//            Container(
//              height: double.infinity,
//              child: index < 1
//                  ? Container()
//                  : Image.asset(
//                      events[index - 1].assetPath,
//                      fit: BoxFit.cover,
//                    ),
//            ),
//
//            Transform(
//              transform:
//                  Matrix4.translationValues(currentCardOffset.dx, 0.0, 0.0),
//              child: Hero(
//                tag: events[index].assetPath,
//                child: Container(
//                  height: double.infinity,
//                  child: Image.asset(
//                    events[index].assetPath,
//                    fit: BoxFit.cover,
//                  ),
//                ),
//              ),
//            ),
//            LayoutBuilder(
//              builder: (context, constraint) => Transform(
//                    transform: Matrix4.translationValues(
//                        constraint.maxWidth + nextCardOffset.dx, 0.0, 0.0),
//                    child: Container(
//                      height: double.infinity,
//                      child: index == events.length - 1
//                          ? Container()
//                          : Image.asset(
//                              events[index + 1].assetPath,
//                              fit: BoxFit.cover,
//                            ),
//                    ),
//                  ),
//            ),
//
//            AppBar(
//              //primary: false,
//              elevation: 0.0,
//              backgroundColor: Colors.transparent,
//              leading: FadeTransition(
//                opacity: Tween(begin: 0.0, end: 1.0).animate(
//                  CurvedAnimation(
//                    parent: _controller,
//                    curve: Interval(0.0, 1.0, curve: Curves.linear),
//                  ),
//                ),
//                child: IconButton(
//                  icon: const BackButtonIcon(),
//                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
//                  onPressed: () {
//                    isPopingRequested = true;
//                    _controller.reverse();
//                  },
//                ),
//              ),
//              actions: <Widget>[
//                FadeTransition(
//                  opacity: Tween(begin: 0.0, end: 1.0).animate(
//                    CurvedAnimation(
//                      parent: _controller,
//                      curve: Interval(0.8, 1.0, curve: Curves.linear),
//                    ),
//                  ),
//                  child: IconButton(
//                    icon: Icon(
//                      Icons.favorite_border,
//                      color: Colors.white,
//                    ),
//                    onPressed: () {},
//                  ),
//                )
//              ],
//            ),
//            Positioned(
//              bottom: 0.0,
//              right: 0.0,
//              left: 0.0,
//              child: Column(
//                children: <Widget>[
//                  Container(
//                    child: Row(
//                      children: <Widget>[
//                        Padding(
//                          padding: const EdgeInsets.all(16.0),
//                          child: Row(
//                            children: List<String>.generate(
//                                    events[index].title2.length,
//                                    (n) => events[index].title2[n])
//                                .asMap()
//                                .map((i, t) => MapEntry(
//                                      i,
//                                      ScaleTransition(
//                                        scale:
//                                            Tween(begin: 0.5, end: 1.0).animate(
//                                          CurvedAnimation(
//                                            parent: _controller,
//                                            curve: Interval(
//                                                i / events[index].title2.length,
//                                                1.0,
//                                                curve: Curves.elasticInOut),
//                                          ),
//                                        ),
//                                        child: FadeTransition(
//                                          opacity: Tween(begin: 0.0, end: 1.0)
//                                              .animate(
//                                            CurvedAnimation(
//                                              parent: _controller,
//                                              curve: Interval(
//                                                  i /
//                                                      events[index]
//                                                          .title2
//                                                          .length,
//                                                  (i + 1) /
//                                                      events[index]
//                                                          .title2
//                                                          .length,
//                                                  curve: Curves.easeInOutBack),
//                                            ),
//                                          ),
//                                          child: Text(
//                                            t,
//                                            style: TextStyle(
//                                                fontSize: 45,
//                                                backgroundColor: Colors.black
//                                                    .withOpacity(0.2),
//                                                color: Colors.white,
//                                                fontWeight: FontWeight.bold),
//                                          ),
//                                        ),
//                                      ),
//                                    ))
//                                .values
//                                .toList(),
//                          ),
//                        ),
//                      ],
//                    ),
//                  ),
//                  FadeTransition(
//                    opacity: _mainPageTransitionAnimation,
//                    child: Container(
//                      alignment: Alignment.center,
//                      height: 200.0,
//                      //padding: EdgeInsets.all(16.0),
//                      decoration: const BoxDecoration(
//                        color: Colors.white,
//                        borderRadius: const BorderRadius.only(
//                          topLeft: const Radius.circular(30.0),
//                          topRight: const Radius.circular(30.0),
//                        ),
//                      ),
//                      child: Column(
//                        children: <Widget>[
//                          Expanded(
//                            child: Row(
//                              children: <Widget>[
//                                Expanded(
//                                  child: Container(
//                                    decoration: const BoxDecoration(
//                                      border: const Border(
//                                        right: BorderSide(
//                                          width: 1.0,
//                                          color: Colors.black12,
//                                        ),
//                                        bottom: const BorderSide(
//                                          width: 1.0,
//                                          color: Colors.black12,
//                                        ),
//                                      ),
//                                    ),
//                                    child: Padding(
//                                      padding: const EdgeInsets.all(16.0),
//                                      child: Row(
//                                        children: <Widget>[
//                                          const Icon(
//                                            Icons.mic,
//                                            color: Colors.black26,
//                                          ),
//                                          Text(
//                                            events[index].eventType,
//                                            style: const TextStyle(
//                                                color: Colors.black26),
//                                          ),
//                                        ],
//                                      ),
//                                    ),
//                                  ),
//                                ),
//                                Expanded(
//                                  child: Container(
//                                    decoration: BoxDecoration(
//                                      border:  Border(
//                                        right:  BorderSide(
//                                          width: 1.0,
//                                          color: Colors.black12,
//                                        ),
//                                        bottom:  BorderSide(
//                                          width: 1.0,
//                                          color: Colors.black12,
//                                        ),
//                                      ),
//                                    ),
//                                    child: Padding(
//                                      padding:  EdgeInsets.all(16.0),
//                                      child: Row(
//                                        children: <Widget>[
//                                          const Icon(
//                                            Icons.mic,
//                                            color: Colors.black26,
//                                          ),
//                                          Text(
//                                            events[index].eventType,
//                                            style: const TextStyle(
//                                                color: Colors.black26),
//                                          ),
//                                        ],
//                                      ),
//                                    ),
//                                  ),
//                                ),
//                                Expanded(
//                                  child: Container(
//                                    decoration: const BoxDecoration(
//                                      border: const Border(
//                                        right: const BorderSide(
//                                          width: 1.0,
//                                          color: Colors.black12,
//                                        ),
//                                        bottom: const BorderSide(
//                                          width: 1.0,
//                                          color: Colors.black12,
//                                        ),
//                                      ),
//                                    ),
//                                    child: Padding(
//                                      padding: const EdgeInsets.all(16.0),
//                                      child: Row(
//                                        children: <Widget>[
//                                          Icon(
//                                            Icons.mic,
//                                            color: Colors.black26,
//                                          ),
//                                          Text(
//                                            events[index].eventType,
//                                            style: const TextStyle(
//                                                color: Colors.black26),
//                                          ),
//                                        ],
//                                      ),
//                                    ),
//                                  ),
//                                ),
//                              ],
//                            ),
//                          ),
//                          Expanded(
//                            child: Row(
//                              crossAxisAlignment: CrossAxisAlignment.center,
//                              children: <Widget>[
//                                Expanded(
//                                  child: Padding(
//                                    padding: const EdgeInsets.symmetric(
//                                        horizontal: 16.0),
//                                    child: Row(
//                                      crossAxisAlignment:
//                                          CrossAxisAlignment.center,
//                                      children: <Widget>[
//                                        Icon(
//                                          Icons.location_on,
//                                          color: Colors.black26,
//                                        ),
//                                        Text(
//                                          events[index].location,
//                                          style:
//                                              TextStyle(color: Colors.black26),
//                                        ),
//                                      ],
//                                    ),
//                                  ),
//                                ),
//                                Padding(
//                                  padding: const EdgeInsets.symmetric(
//                                      horizontal: 16.0),
//                                  child: IconButton(
//                                    icon: Icon(Icons.unfold_more),
//                                    color: Colors.lightBlue[400],
//                                    onPressed: () {},
//                                  ),
//                                ),
//                              ],
//                            ),
//                          ),
//                          Container(
//                            alignment: Alignment.center,
//                            padding: EdgeInsets.symmetric(vertical: 16.0),
//                            child: RaisedButton(
//                              color: Colors.lightBlue[300],
//                              padding: EdgeInsets.only(
//                                right: 110.0,
//                                left: 110.0,
//                                top: 16.0,
//                                bottom: 16.0,
//                              ),
//                              shape:  RoundedRectangleBorder(
//                                borderRadius:  BorderRadius.circular(20.0),
//                              ),
//                              child: Text(
//                                "Book Now",
//                                style: TextStyle(
//                                  color: Colors.white,
//                                  fontSize: 16.0,
//                                ),
//                              ),
//                              onPressed: () {},
//                            ),
//                          ),
//                        ],
//                      ),
//                    ),
//                  ),
//                ],
//              ),
//            )
//          ],
//        ),
//      ),
    );
  }
}

//class SideCalender extends StatelessWidget {
//  final double hight;
//  final double width;
//
//  const SideCalender({
//    Key key,
//    this.hight = 55.0,
//    this.width = 30.0,
//  }) : super(key: key);
//
//  @override
//  Widget build(BuildContext context) {
//    return Padding(
//      padding: const EdgeInsets.symmetric(horizontal: 10.0),
//      child: Container(
//        width: width,
//        child: Stack(
//          overflow: Overflow.visible,
//          children: <Widget>[
//            StreamBuilder<Object>(
//                stream: _position.stream,
//                initialData: 0.0,
//                builder: (context, snapshot) {
//                  return AnimatedPositioned(
//                    top: hight * (snapshot.data),
//                    duration: Duration(milliseconds: 200),
//                    child: StreamBuilder<Object>(
//                        stream: _hight.stream,
//                        initialData: 1.0,
//                        builder: (context, snapshot) {
//                          return AnimatedContainer(
//                            height: hight * snapshot.data,
//                            width: width,
//                            duration: Duration(milliseconds: 500),
//                            decoration: BoxDecoration(
//                              color: Theme.of(context).primaryColor,
//                              borderRadius: BorderRadius.circular(30.0),
//                            ),
//                            child: SizedBox(
//                              width: width,
//                              height: hight,
//                            ),
//                          );
//                        }),
//                  );
//                }),
//            Positioned(
//              top: 0.0,
//              height: hight,
//              width: width,
//              child: DayCard(
//                viewModel: DayCardViewModel(
//                  dayShortNotation: "Sat",
//                  day: 14,
//                ),
//              ),
//            ),
//            Positioned(
//              top: hight,
//              height: hight,
//              width: width,
//              child: DayCard(
//                viewModel: DayCardViewModel(
//                  dayShortNotation: "Sun",
//                  day: 15,
//                ),
//              ),
//            ),
//            Positioned(
//              top: 2 * hight,
//              height: hight,
//              width: width,
//              child: DayCard(
//                viewModel: DayCardViewModel(
//                  dayShortNotation: "Mon",
//                  day: 16,
//                ),
//              ),
//            ),
//            Positioned(
//              top: 3 * hight,
//              height: hight,
//              width: width,
//              child: DayCard(
//                viewModel: DayCardViewModel(
//                  dayShortNotation: "Tue",
//                  day: 17,
//                ),
//              ),
//            ),
//            Positioned(
//              top: 4 * hight,
//              height: hight,
//              width: width,
//              child: DayCard(
//                viewModel: DayCardViewModel(
//                  dayShortNotation: "Wed",
//                  day: 18,
//                ),
//              ),
//            ),
//            Positioned(
//              top: 5 * hight,
//              height: hight,
//              width: width,
//              child: DayCard(
//                viewModel: DayCardViewModel(
//                  dayShortNotation: "Thr",
//                  day: 19,
//                ),
//              ),
//            ),
//            Positioned(
//              top: 6 * hight,
//              height: hight,
//              width: width,
//              child: DayCard(
//                viewModel: DayCardViewModel(
//                  dayShortNotation: "Fri",
//                  day: 20,
//                ),
//              ),
//            ),
//          ],
//        ),
//      ),
//    );
//  }
//}
