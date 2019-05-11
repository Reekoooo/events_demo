import 'package:events/blocs/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class WeekCalender extends StatefulWidget {
  final DateTime dateTime;
  final Axis direction;
  final StartingDayOfTheWeek startFrom;

  const WeekCalender({
    Key key,
    this.dateTime,
    this.direction, //= Axis.vertical,
    this.startFrom = StartingDayOfTheWeek.Saturday,
  }) : super(key: key);

  @override
  _WeekCalenderState createState() => _WeekCalenderState();
}

class _WeekCalenderState extends State<WeekCalender>  with WidgetsBindingObserver{
  DateTime datetime;
  List<String> _months;

  int weekDay;
  DateTime firstDayOfTheWeek;
  Axis direction;

  List<String> _days;
  int weekDayAdjustingFactor;

  final GlobalKey _keyFirstDayCard = GlobalKey(debugLabel: "first");
  final GlobalKey _keySecondDayCard = GlobalKey(debugLabel: "second");

  Offset firstDayCardOffset = Offset.zero;
  Offset secondDayCardOffset = Offset.zero;
  Offset positionFactor = Offset.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    print("initstate called");
    datetime = widget.dateTime;
    weekDay = widget.dateTime.weekday;
    direction = widget.direction;
    _months = [
      "JAN",
      "FEB",
      "MAR",
      "APR",
      "MAY",
      "JUN",
      "JUL",
      "AUG",
      "OCT",
      "NOV",
      "DEC"
    ];

    switch (widget.startFrom) {
      case StartingDayOfTheWeek.Saturday:
//        print("Case Saturday");
        _days = <String>["SAT", "SUN", "MON", "TUE", "WED", "THU", "FRI"];
        weekDayAdjustingFactor = 2;
        break;

      case StartingDayOfTheWeek.Sunday:
//        print("Case Sunday");
        _days = <String>["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
        weekDayAdjustingFactor = 1;
        break;

      case StartingDayOfTheWeek.Monday:
//        print("Case Mondayday");
        _days = <String>["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"];
        weekDayAdjustingFactor = 0;
    }

    firstDayOfTheWeek = widget.dateTime
        .subtract(Duration(days: weekDay - 1))
        .subtract(Duration(days: weekDayAdjustingFactor));
    SchedulerBinding.instance.addPostFrameCallback(_calculatePositionOffset);

  }

  _calculatePositionOffset(_) {
    //_getSizes();
    firstDayCardOffset = _getPositions(_keyFirstDayCard);
    secondDayCardOffset = _getPositions(_keySecondDayCard);
    positionFactor = secondDayCardOffset - firstDayCardOffset;
    print ("Position factor = $positionFactor");
  }

  Offset _getPositions(_key) {
    final RenderBox renderBoxRed = _key.currentContext.findRenderObject();
    final position =
        renderBoxRed.localToGlobal(Offset.zero); //.localToGlobal(Offset.zero);
    //final pos = renderBoxRed.globalToLocal(Offset.zero);

    //print("POSITION of $_key : $position ");
    return position;
  }

  @override
  void didUpdateWidget(WeekCalender oldWidget) {


    print("didUpdateWidget called");
    SchedulerBinding.instance.addPostFrameCallback(_calculatePositionOffset);

    //positionFactor = secondDayCardOffset - firstDayCardOffset;

//    print(
//        "difference in y = ${firstDayCardOffset.dy - secondDayCardOffset.dy}");
    if (widget.dateTime != oldWidget.dateTime) {
        weekDay = widget.dateTime.weekday;
        firstDayOfTheWeek = widget.dateTime
            .subtract(Duration(days: weekDay - 1))
            .subtract(Duration(days: weekDayAdjustingFactor));
    }
    if (widget.direction != oldWidget.direction) {
        direction = widget.direction;
    }

    // print("Offset from Updated $secondDayCardOffset");

    super.didUpdateWidget(oldWidget);
  }
  @override
  void didChangeMetrics() {
    print("Metrics changed");
    SchedulerBinding.instance.addPostFrameCallback(_calculatePositionOffset);
    super.didChangeMetrics();
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print("did change dependincies called");
  }

  @override
  Widget build(BuildContext context) {
//    print("From Build first Offset = $firstDayCardOffset");
//    print("From Build second Offset = $secondDayCardOffset");
    return OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) => Flex(
              direction: direction == null
                  ? (orientation == Orientation.portrait
                      ? Axis.horizontal
                      : Axis.vertical)
                  : direction,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          width: 1.0,
                          color: Colors.black12,
                        )),
                    child: Text(
                      _months[firstDayOfTheWeek.month - 1],
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                          backgroundColor: Colors.transparent),
                    ),
                  ),
                ),
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      StreamBuilder<WeekCalenderIndicator>(
                          stream: Provider.of(context).indicator,
                          initialData: WeekCalenderIndicator(
                            position: firstDayOfTheWeek,
                            span: 0,
                          ),
                          builder: (context, snapshot) {
                            //if(snapshot.data.position.add(Duration(days: snapshot.data.span))>)

                            datetime = snapshot.data.position
                                .add(Duration(days: /*snapshot.data.span+*/ 2));
                            weekDay = datetime.weekday;

                            firstDayOfTheWeek = datetime
                                .subtract(Duration(days: weekDay - 1))
                                .subtract(
                                    Duration(days: weekDayAdjustingFactor));
                           // print("firstDayOfTheWeek = $firstDayOfTheWeek");
                            print("top = ${(positionFactor.dy - 60.0) +
                                positionFactor.dy *
                                    (snapshot.data.position
                                        .difference(firstDayOfTheWeek)
                                        .inDays)}");
                            print("left = ${ (positionFactor.dx - 40.0) +
                                positionFactor.dx *
                                    (snapshot.data.position
                                        .difference(firstDayOfTheWeek)
                                        .inDays)}");

                            return AnimatedPositioned(
                              top: orientation == Orientation.landscape
                                  ? (positionFactor.dy - 60.0) +
                                      positionFactor.dy *
                                          (snapshot.data.position
                                              .difference(firstDayOfTheWeek)
                                              .inDays)
                                  : 0.0,
                              left: orientation == Orientation.landscape
                                  ? 0.0
                                  : (positionFactor.dx - 40.0) +
                                      positionFactor.dx *
                                          (snapshot.data.position
                                              .difference(firstDayOfTheWeek)
                                              .inDays),
                              //width: 40.0,
                              duration: Duration(milliseconds: 500),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 500),
                                  width: orientation == Orientation.landscape
                                      ? 40.0
                                      : 40 +
                                          positionFactor.dx *
                                              snapshot.data.span,
                                  height: orientation == Orientation.landscape
                                      ? 60.0 +
                                          positionFactor.dy * snapshot.data.span
                                      : 60.0,
                                  decoration: BoxDecoration(
                                    color: Colors.lightBlue,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30.0)),
                                  ),
                                ),
                              ),
                            );
                          }),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Flex(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          direction: direction == null
                              ? (orientation == Orientation.portrait
                                  ? Axis.horizontal
                                  : Axis.vertical)
                              : direction,
                          children: <Widget>[
                            DayCard(
                              key: _keyFirstDayCard,
                              viewModel: DayCardViewModel(
                                day: firstDayOfTheWeek,
                                dayShortNotation: _days[0],
                                //backgound: Colors.yellow,
                              ),
                            ),
                            DayCard(
                              key: _keySecondDayCard,
                              viewModel: DayCardViewModel(
                                day: firstDayOfTheWeek.add(Duration(days: 1)),
                                dayShortNotation: _days[1],
                                // backgound: Colors.yellow,
                              ),
                            ),
                            DayCard(
                              //key: Key("3"),
                              viewModel: DayCardViewModel(
                                day: firstDayOfTheWeek.add(Duration(days: 2)),
                                dayShortNotation: _days[2],
                              ),
                            ),
                            DayCard(
                              //key: Key("4"),
                              viewModel: DayCardViewModel(
                                day: firstDayOfTheWeek.add(Duration(days: 3)),
                                dayShortNotation: _days[3],
                              ),
                            ),
                            DayCard(
                              //key: Key("5"),
                              viewModel: DayCardViewModel(
                                day: firstDayOfTheWeek.add(Duration(days: 4)),
                                dayShortNotation: _days[4],
                              ),
                            ),
                            DayCard(
                              //key: Key("6"),
                              viewModel: DayCardViewModel(
                                day: firstDayOfTheWeek.add(Duration(days: 5)),
                                dayShortNotation: _days[5],
                              ),
                            ),
                            DayCard(
                              // key: Key("7"),
                              viewModel: DayCardViewModel(
                                day: firstDayOfTheWeek.add(Duration(days: 6)),
                                dayShortNotation: _days[6],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ));
  }
}

enum StartingDayOfTheWeek { Saturday, Sunday, Monday }

class WeekCalenderIndicator {
  final DateTime position;
  final int span;

  WeekCalenderIndicator({
    this.position,
    this.span,
  });
}

class DayCard extends StatelessWidget {
  final DayCardViewModel viewModel;

  const DayCard({
    Key key,
    this.viewModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: viewModel.width,
      decoration: BoxDecoration(
        color: viewModel.backgound,
        borderRadius: BorderRadius.all(viewModel.radiius),
      ),
      child: SizedBox(
        width: viewModel.width,
        height: viewModel.hight,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Align(
            alignment: Alignment.center,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "${viewModel.day.day}",
                  style: viewModel.dayTextStyle,
                ),
                Text(
                  "${viewModel.dayShortNotation}",
                  style: viewModel.dayShortNotationTextStyle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DayCardViewModel {
  static List<String> _days = <String>[
    "MON",
    "TUE",
    "WED",
    "THU",
    "FRI",
    "SAT",
    "SUN"
  ];

  /// Usually three letters representation of a day shor name ex. "Fri"
  final String dayShortNotation;

  ///Text style for dayShort notation three letters
  final TextStyle dayShortNotationTextStyle;

  /// tcalendar date  for ex. 12/01/2008
  final DateTime day;

  /// Text style for the day no.
  final TextStyle dayTextStyle;

  /// The total width of the DayCard
  final double width;

  /// The total hight of the DayCard
  final double hight;

  /// the border radis of the card will dictate the card container decoration
  final Radius radiius;

  ///Background color for the card
  final Color backgound;

  DayCardViewModel({
    DateTime day,
    String dayShortNotation,
    // this.day ,
    this.width = 40.0,
    this.hight = 60.0,
    this.radiius = const Radius.circular(30.0),
    this.backgound = Colors.transparent,
    this.dayTextStyle = const TextStyle(fontSize: 16.0),
    this.dayShortNotationTextStyle = const TextStyle(fontSize: 10.0),
  })  : this.day = day ?? DateTime.now(),
        this.dayShortNotation = dayShortNotation ?? _days[day.weekday - 1];
}
