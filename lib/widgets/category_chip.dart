import 'package:flutter/material.dart';

final Map<String, Color> categoryColors = {
  'Tresen': Color(0xFFFF991C), // Hex #ff991c
  'KüFa': Color(0xFFFFC41C), // Hex #ffc41c
  'Workshop': Color(0xFF38A3C4), // Hex #38a3c4
  'Vortrag': Color(0xFF085985), // Hex #085985
  'Konzert': Color(0xFF61B270), // Hex #61b270
  'Party': Color(0xFF337D61), // Hex #337d61
  'Film': Color(0xFFA6877D), // Hex #a6877d
  'Karaoke': Color(0xFF634F4A), // Hex #634f4a
  'Demo': Color(0xFFFF7A59), // Hex #ff7a59
  'Lesung': Color(0xFFC03530), // Hex #c03530
  'Open-Stage': Color(0xFF8AA3C4), // Hex #8aa3c4
  'Theater': Color(0xFF716E9C), // Hex #716e9c
  'Ausstellung': Color(0xFF716E9C), // Hex #716e9c
};

class CategoryChip extends StatelessWidget {
  final String category;

  CategoryChip({required this.category});

  Color _getTextColor(Color backgroundColor) {
    // Determine if the background color is light or dark
    // and return the appropriate text color
    return backgroundColor.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = categoryColors[category] ?? Colors.grey;
    final textColor = _getTextColor(backgroundColor);
    final textStyle =
        Theme.of(context).textTheme.bodySmall?.copyWith(color: textColor);

    return Chip(
      label: Text(category, style: textStyle),
      backgroundColor: backgroundColor,
      side: BorderSide.none,
    );
  }
}
