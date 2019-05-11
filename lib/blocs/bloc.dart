import 'dart:async';

import 'package:events/ui/week_calender.dart';

class Bloc{
  StreamController<WeekCalenderIndicator> _indexController =
  StreamController.broadcast();

  Function(WeekCalenderIndicator) get updateIndicator => _indexController.sink.add;

  Stream<WeekCalenderIndicator> get indicator => _indexController.stream;

  dispose(){
    _indexController.close();
  }
}