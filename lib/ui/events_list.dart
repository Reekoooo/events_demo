import 'package:events/blocs/bloc.dart';
import 'package:events/blocs/provider.dart';
import 'package:events/models/details_screen_arguments.dart';
import 'package:events/screens/details_screen.dart';
import 'package:events/ui/event_card.dart';
import 'package:events/ui/week_calender.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

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
  Bloc bloc;

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      bloc = Provider.of(context);
      bloc.updateIndicator(_calculateIndicator(index));
    });

    controller = ScrollController()
      ..addListener(() {
        cardHeight = controller.position.viewportDimension / 2.5;
        index = ((controller.offset + (cardHeight / 2) + 20.0) /
            (cardHeight + 20.0))
            .floor();

        if (index != factor) {
          print(index);
          factor = index;
          bloc.updateIndicator(_calculateIndicator(index));
        }
      });
  }

  WeekCalenderIndicator _calculateIndicator(int index) {
    position = widget.events[index].dayCardViewModel.day;
    span = (widget.events[index + 1].dayCardViewModel.day
        .difference(widget.events[index].dayCardViewModel.day)
        .inMilliseconds/Duration.millisecondsPerDay).floor();
    indicator = WeekCalenderIndicator(
      position: position,
      span: span,
    );

    return indicator;
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) =>
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) =>
                  ListView.builder(
                    controller: controller,
                    itemCount: widget.events.length,

                    scrollDirection: orientation == Orientation.portrait
                        ? Axis.vertical
                        : Axis.horizontal,

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
                                      index, widget.events, widget.sdk)),
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
                          viewModel: widget.events[index],
                        )),
                  ),
            ));
  }
}