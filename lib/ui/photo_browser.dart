import 'package:events/ui/event_card.dart';
import 'package:events/ui/photo_card.dart';
import 'package:flutter/material.dart';


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
    final bool lastCard = _currentCardIndex >= widget.events.length - 1;

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
