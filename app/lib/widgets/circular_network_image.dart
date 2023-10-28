import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CircularNetworkImage extends StatelessWidget {
  const CircularNetworkImage({super.key, required this.imageUrl, this.radius});

  final String? imageUrl;
  final double? radius;

  Widget _placeholder(BuildContext context) => CircleAvatar(
        radius: radius,
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      );

  @override
  Widget build(BuildContext context) {
    return imageUrl == null
        ? _placeholder(context)
        : CachedNetworkImage(
            imageUrl: imageUrl!,
            useOldImageOnUrlChange: true,
            fadeInDuration: const Duration(milliseconds: 200),
            errorWidget: (_, __, ___) => _placeholder(context),
            errorListener: (value) => debugPrint(value.toString()),
            placeholder: (context, url) => _placeholder(context),
            imageBuilder: (context, imageProvider) => CircleAvatar(
              radius: radius,
              backgroundImage: imageProvider,
            ),
          );
  }
}
