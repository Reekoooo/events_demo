import 'package:events/models/details_screen_arguments.dart';
import 'package:events/ui/event_card.dart';
import 'package:events/ui/photo_browser.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  bool isPopingRequested = false;

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

        ..addStatusListener((status) {

          if (status == AnimationStatus.completed) {
            _controller.forward();
            if (showOverlay) {
              entry.remove();
              showOverlay = false;
            }
          }
          if (status == AnimationStatus.reverse) {
            if (showOverlay) {
              entry.remove();
              showOverlay = false;
            }
          }
        });

      if (state != null &&
          !showOverlay &&
          _mainPageTransitionAnimation.status != AnimationStatus.reverse) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => state.insert(entry));
        showOverlay = true;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    indexChanged.dispose();
    super.dispose();
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
    );
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
}
