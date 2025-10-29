// lib/models/ui_helpers.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons, Colors, FontStyle, FontWeight, Image;

Widget buildSectionTitle(BuildContext context, String title) {
  final textColor = CupertinoDynamicColor.resolve(CupertinoColors.label, context);
  return Padding(
    padding: const EdgeInsets.only(bottom: 12.0, top: 12.0),
    child: Text(
      title,
      style: CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(
        color: textColor,
        fontWeight: FontWeight.bold,
        decoration: TextDecoration.none,
      ),
    ),
  );
}

Widget buildSubSectionTitle(BuildContext context, String title) {
  return Padding(
    padding: const EdgeInsets.only(left: 8.0, bottom: 6.0, top: 12.0),
    child: Text(
      title,
      style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
        color: CupertinoColors.secondaryLabel.resolveFrom(context),
        fontSize: 18,
        decoration: TextDecoration.none,
      ),
    ),
  );
}

Widget buildParagraph(BuildContext context, String text) {
  final textColor = CupertinoDynamicColor.resolve(CupertinoColors.label, context);
  return Padding(
    padding: const EdgeInsets.only(bottom: 12.0),
    child: Text(
      text,
      style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
        height: 1.6,
        fontSize: 17,
        color: textColor,
        decoration: TextDecoration.none,
      ),
      textAlign: TextAlign.justify,
    ),
  );
}

Widget buildListItem(BuildContext context, String text) {
  return Padding(
    padding: const EdgeInsets.only(left: 16.0, bottom: 6.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '• ',
          style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            decoration: TextDecoration.none,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
              height: 1.6,
              fontSize: 17,
              decoration: TextDecoration.none,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    ),
  );
}

Widget buildImageWithCaption({
  required String imagePath,
  String? caption,
  required BuildContext context,
}) {
  final screenWidth = MediaQuery.of(context).size.width;
  final imageHeight = (screenWidth * 0.7).clamp(150.0, 400.0);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
            width: screenWidth * 0.85,
            height: imageHeight,
            errorBuilder: (ctx, error, stackTrace) {
              return Container(
                height: imageHeight,
                color: Colors.grey[300],
                child: Center(child: Icon(Icons.broken_image, color: Colors.grey[600], size: 40)),
              );
            },
          ),
        ),
      ),
      if (caption != null && caption.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 0.0, bottom: 8.0, left: 4.0, right: 4.0),
          child: Text(
            caption,
            style: CupertinoTheme.of(context).textTheme.tabLabelTextStyle.copyWith(
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ),
    ],
  );
}

Widget buildSpacer() => const SizedBox(height: 16.0);