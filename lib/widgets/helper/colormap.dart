import 'package:flutter/material.dart';

class ColorSchemeDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Color Scheme Display'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildColorTile(
                'Primary', colorScheme.primary, colorScheme.onPrimary),
            _buildColorTile('Primary Container', colorScheme.primaryContainer,
                colorScheme.onPrimaryContainer),
            _buildColorTile(
                'Secondary', colorScheme.secondary, colorScheme.onSecondary),
            _buildColorTile('primarfixed', colorScheme.primaryFixed,
                colorScheme.onPrimaryFixed),
            _buildColorTile(
                'Secondary Container',
                colorScheme.secondaryContainer,
                colorScheme.onSecondaryContainer),
            _buildColorTile(
                'Surface', colorScheme.surface, colorScheme.onSurface),
            _buildColorTile('Error', colorScheme.error, colorScheme.onError),
          ],
        ),
      ),
    );
  }

  Widget _buildColorTile(String name, Color color, Color textColor) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.all(16.0),
      color: color,
      child: Text(
        name,
        style: TextStyle(
            color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
