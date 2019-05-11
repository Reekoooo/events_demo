import 'package:events/ui/event_card.dart';

class ScreenArguments {
  final int index;
  final List<EventCardViewModel> events;
  final int sdk;

  ScreenArguments(this.index, this.events, this.sdk);
}