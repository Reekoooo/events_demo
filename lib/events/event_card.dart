import 'package:flutter/material.dart';

List events = <EventCardViewModel>[
  EventCardViewModel(
    assetPath: "assets/amrdiab.jpg",
    title1: "Alexandria",
    title2: "Amr Diab",
    title3: "Alexandria",
    dayCardViewModel: DayCardViewModel(
      day: 14,
      dayShortNotation: "Sat",
      backgound: Colors.white,
      dayShortNotationTextStyle: TextStyle(fontSize: 12.0),
    ),
  ),
  EventCardViewModel(
    assetPath: "assets/angam.jpg",
    title1: "Alexandria",
    title2: "Angham",
    title3: "Alexandria",
    dayCardViewModel: DayCardViewModel(
      day: 14,
      dayShortNotation: "Sat",
      backgound: Colors.white,
      dayShortNotationTextStyle: TextStyle(fontSize: 12.0),
    ),
  ),
  EventCardViewModel(
    assetPath: "assets/hamaki.jpg",
    title1: "Cairo",
    title2: "M.Hamaki",
    title3: "Cairo",
    dayCardViewModel: DayCardViewModel(
      day: 15,
      dayShortNotation: "Sun",
      backgound: Colors.white,
      dayShortNotationTextStyle: TextStyle(fontSize: 12.0),
    ),
  ),
  EventCardViewModel(
    assetPath: "assets/asala.jpeg",
    title1: "Cairo",
    title2: "Asala",
    title3: "Cairo",
    dayCardViewModel: DayCardViewModel(
      day: 15,
      dayShortNotation: "Sun",
      backgound: Colors.white,
      dayShortNotationTextStyle: TextStyle(fontSize: 12.0),
    ),
  ),
  EventCardViewModel(
    assetPath: "assets/rihanna.jpg",
    title1: "Luxor",
    title2: "Rihanna",
    title3: "Luxor",
    location: 'Hatshipsute Temple',
    eventType: "Music",
    dayCardViewModel: DayCardViewModel(
      day: 16,
      dayShortNotation: "Tue",
      backgound: Colors.white,
      dayShortNotationTextStyle: TextStyle(fontSize: 12.0),
    ),
  ),
  EventCardViewModel(
    assetPath: "assets/oka.jpg",
    title1: "Aswan",
    title2: "Oka & Ortiga",
    title3: "Aswan",
    dayCardViewModel: DayCardViewModel(
      day: 19,
      dayShortNotation: "Thr",
      backgound: Colors.white,
      dayShortNotationTextStyle: TextStyle(fontSize: 12.0),
    ),
  ),
];

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
}

class EventCard extends StatelessWidget {
  final EventCardViewModel viewModel;

  const EventCard({
    Key key,
    this.viewModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      child: Container(
        height: viewModel.hight,
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
                  transitionOnUserGestures: true,
                  child: Container(
                    child: Image.asset(
                      viewModel.assetPath,
                      fit: BoxFit.cover,
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
                  "${viewModel.day}",
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
  /// Usually three letters representation of a day shor name ex. "Fri"
  final String dayShortNotation;

  ///Text style for dayShort notation three letters
  final TextStyle dayShortNotationTextStyle;

  /// the day of the month in the calendar date if date is for ex. 12/01/2008
  /// then day will be 12.
  final int day;

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
    this.dayShortNotation = "Sat",
    this.day = 1,
    this.width = 40.0,
    this.hight = 60.0,
    this.radiius = const Radius.circular(30.0),
    this.backgound = Colors.transparent,
    this.dayTextStyle = const TextStyle(fontSize: 16.0),
    this.dayShortNotationTextStyle = const TextStyle(fontSize: 10.0),
  });
}
