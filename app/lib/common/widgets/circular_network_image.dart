import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CircularNetworkImage extends StatelessWidget {
  const CircularNetworkImage({super.key, required this.imageUrl, this.radius});

  final String imageUrl;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      useOldImageOnUrlChange: true,
      errorWidget: (_, __, ___) => CircleAvatar(
        radius: radius,
        child: const Icon(Icons.warning_rounded, size: 20),
      ),
      errorListener: (value) => debugPrint(value.toString()),
      placeholder: (context, url) => CircleAvatar(
        radius: radius,
        child: const Icon(Icons.person_rounded),
      ),
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: radius,
        backgroundImage: imageProvider,
      ),
    );
  }
}
