import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'event_card.dart';

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
                  : CachedNetworkImage(
                imageUrl: imageAsset,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}