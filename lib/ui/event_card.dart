import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:events/ui/week_calender.dart';
import 'package:cached_network_image/cached_network_image.dart';

//List<EventCardViewModel> events = [
//  EventCardViewModel(
//    assetPath: "assets/amrdiab.jpg",
//    title1: "Alexandria",
//    title2: "Amr Diab",
//    title3: "Alexandria",
//    dayCardViewModel: DayCardViewModel(
//      day: DateTime.now().subtract(Duration(days: 4)),
//      //dayShortNotation: "Sat",
//      backgound: Colors.white,
//      dayShortNotationTextStyle: TextStyle(fontSize: 12.0),
//    ),
//  ),
//  EventCardViewModel(
//    assetPath: "assets/angam.jpg",
//    title1: "Alexandria",
//    title2: "Angham",
//    title3: "Alexandria",
//    dayCardViewModel: DayCardViewModel(
//      day: DateTime.now().subtract(Duration(days: 4)),
//      //dayShortNotation: "Sat",
//      backgound: Colors.white,
//      dayShortNotationTextStyle: TextStyle(fontSize: 12.0),
//    ),
//  ),
//  EventCardViewModel(
//    assetPath: "assets/hamaki.jpg",
//    title1: "Cairo",
//    title2: "M.Hamaki",
//    title3: "Cairo",
//    dayCardViewModel: DayCardViewModel(
//      day: DateTime.now().subtract(Duration(days: 3)),
//      //dayShortNotation: "Sun",
//      backgound: Colors.white,
//      dayShortNotationTextStyle: TextStyle(fontSize: 12.0),
//    ),
//  ),
//  EventCardViewModel(
//    assetPath: "assets/asala.jpeg",
//    title1: "Cairo",
//    title2: "Asala",
//    title3: "Cairo",
//    dayCardViewModel: DayCardViewModel(
//      day: DateTime.now().subtract(Duration(days: 3)),
//      //dayShortNotation: "Sun",
//      backgound: Colors.white,
//      dayShortNotationTextStyle: TextStyle(fontSize: 12.0),
//    ),
//  ),
//  EventCardViewModel(
//    assetPath: "assets/rihanna.jpg",
//    title1: "Luxor",
//    title2: "Rihanna",
//    title3: "Luxor",
//    location: 'Hatshipsute Temple',
//    eventType: "Music",
//    dayCardViewModel: DayCardViewModel(
//      day: DateTime.now().subtract(Duration(days: 2)),
//      //dayShortNotation: "Tue",
//      backgound: Colors.white,
//      dayShortNotationTextStyle: TextStyle(fontSize: 12.0),
//    ),
//  ),
//  EventCardViewModel(
//    assetPath: "assets/oka.jpg",
//    title1: "Aswan",
//    title2: "Oka & Ortiga",
//    title3: "Aswan",
//    dayCardViewModel: DayCardViewModel(
//      day: DateTime.now().subtract(Duration(days: 0)),
//      //dayShortNotation: "Thr",
//      backgound: Colors.white,
//      dayShortNotationTextStyle: TextStyle(fontSize: 12.0),
//    ),
//  ),
//  EventCardViewModel(
//    assetPath: "assets/nancy.jpg",
//    title1: "Alexandria",
//    title2: "Nancy Ajram",
//    title3: "Mansoura",
//    dayCardViewModel: DayCardViewModel(
//      day: DateTime.now().add(Duration(days: 1)),
//      //dayShortNotation: "Sat",
//      backgound: Colors.white,
//      dayShortNotationTextStyle: TextStyle(fontSize: 12.0),
//    ),
//  ),
//  EventCardViewModel(
//    assetPath: "assets/tamer.jpg",
//    title1: "Alexandria",
//    title2: "Tamer Hosney",
//    title3: "Giza",
//    dayCardViewModel: DayCardViewModel(
//      day: DateTime.now().add(Duration(days: 2)),
//      //dayShortNotation: "Sat",
//      backgound: Colors.white,
//      dayShortNotationTextStyle: TextStyle(fontSize: 12.0),
//    ),
//  ),
//  EventCardViewModel(
//    assetPath: "assets/sherine.jpg",
//    title1: "Alexandria",
//    title2: "Sherine",
//    title3: "PortSaid",
//    dayCardViewModel: DayCardViewModel(
//      day: DateTime.now().add(Duration(days: 4)),
//      //dayShortNotation: "Sat",
//      backgound: Colors.white,
//      dayShortNotationTextStyle: TextStyle(fontSize: 12.0),
//    ),
//  ),
//];

class EventCardViewModel {
  /// hight of the EventCard.
  final double hight;

  /// Border Radius of the Container of the EventCard.
  final double radius;

  /// The asset path for the image representing the EventCard.
  final String assetPath;

  /// the first line of the Text of the Title.
  final String title1;

  /// the second line of the Text of the Title.
  final String title2;

  /// the third line of the Text of the Title.
  final String title3;

  /// Event Location.
  final String location;

  /// Event type.
  final String eventType;

  /// properties of the DayCard Containing the Day And the DayNotation see[DayCardViewModel]
  final DayCardViewModel dayCardViewModel;


  EventCardViewModel(
      {this.hight = 200.0,
      this.radius = 50.0,
      this.assetPath,
      this.title1,
      this.title2,
      this.title3,
      this.location = "",
      this.eventType ="",
      this.dayCardViewModel});

  factory EventCardViewModel.fromSnapShot(DocumentSnapshot event){
    return EventCardViewModel(
      assetPath: event["assetPath"],
      title1: event["title1"],
      title2: event["title2"],
      title3: event["title3"],
      dayCardViewModel: DayCardViewModel(
        day:  DateTime.fromMillisecondsSinceEpoch(event["datetime"].millisecondsSinceEpoch),
        backgound: Colors.white,
        dayShortNotationTextStyle: TextStyle(fontSize: 12.0),
      ),
    );
  }
}
class QuadraticOffsetTween extends Tween<Offset> {

  QuadraticOffsetTween({
    Offset begin,
    Offset end,
  }) : super(begin: begin, end: end);


  @override
  Offset lerp(double t) {
    double py = math.pi;
    if (t == 0.0)
      return begin;
    if (t == 1.0)
      return end;
    final double x = begin.dx+ (end.dx-begin.dx) * (math.sin(t*t*t*t*t*t*(py/2)));
    final double y = begin.dy+ (end.dy-begin.dy) *math.pow(t, 2);
    return Offset(x, y);
  }
}
class QuadraticRectTween extends RectTween {
  /// Creates a [Tween] for animating [Rect]s along a circular arc.
  ///
  /// The [begin] and [end] properties must be non-null before the tween is
  /// first used, but the arguments can be null if the values are going to be
  /// filled in later.
  QuadraticRectTween({
    Rect begin,
    Rect end,
  }) : super(begin: begin, end: end);

  bool _dirty = true;

  void _initialize() {
    assert(begin != null);
    assert(end != null);
    _centerArc = QuadraticOffsetTween(
      begin: begin.center,
      end: end.center,
    );
    _dirty = false;
  }

  /// If [begin] and [end] are non-null, returns a tween that interpolates along
  /// a circular arc between [begin]'s [Rect.center] and [end]'s [Rect.center].
  QuadraticOffsetTween get centerArc {
    if (begin == null || end == null)
      return null;
    if (_dirty)
      _initialize();
    return _centerArc;
  }
  QuadraticOffsetTween _centerArc;

  @override
  set begin(Rect value) {
    if (value != begin) {
      super.begin = value;
      _dirty = true;
    }
  }

  @override
  set end(Rect value) {
    if (value != end) {
      super.end = value;
      _dirty = true;
    }
  }

  @override
  Rect lerp(double t) {
    if (_dirty)
      _initialize();
    if (t == 0.0)
      return begin;
    if (t == 1.0)
      return end;
    final Offset center = _centerArc.lerp(t);
    final double width = lerpDouble(begin.width, end.width, t);
    final double height = lerpDouble(begin.height, end.height, t);
    return Rect.fromLTWH(center.dx - width / 2.0, center.dy - height / 2.0, width, height);
  }

  @override
  String toString() {
    return '$runtimeType($begin \u2192 $end; centerArc=$centerArc)';
  }
}
class EventCard extends StatelessWidget {
  static RectTween createRectTween(Rect begin, Rect end) {
    return QuadraticRectTween(begin: begin, end: end) ;
  }
  final EventCardViewModel viewModel;
  final double eventCardHeight;
  final double eventCardWidth;

  const EventCard({
    Key key,
    this.viewModel,
    this.eventCardHeight = 200.0,
    this.eventCardWidth = 200.0
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      child: Container(
        height: eventCardHeight,
        width: eventCardWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(viewModel.radius)),
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
                Hero(
                  tag: viewModel.assetPath,
                  createRectTween: createRectTween,
                  transitionOnUserGestures: true,
                  child: Container(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30.0),
                      child: CachedNetworkImage(
                        imageUrl: viewModel.assetPath,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
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
                            viewModel.title1,
                            style: TextStyle(color: Colors.white),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Text(
                              viewModel.title2,
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
                                viewModel.title3,
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
                    viewModel: viewModel.dayCardViewModel,
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

