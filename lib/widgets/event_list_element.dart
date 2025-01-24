import 'package:flutter/material.dart';
import 'package:sperrstunde/models/event.dart';
import 'package:sperrstunde/widgets/category_chip.dart';

class EventListElement extends StatelessWidget {
  final Event event;
  final Function(Event) _toggleLike;
  final Function(BuildContext, Event) _showEventDetails;

  EventListElement({
    required this.event,
    required Function(Event) toggleLike,
    required Function(BuildContext, Event) showEventDetails,
  })  : _toggleLike = toggleLike,
        _showEventDetails = showEventDetails;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      tileColor: event.liked ? colorScheme.error : null,
      leading:
          Text(event.time, style: Theme.of(context).textTheme.headlineMedium),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: event.categories.map((category) {
              return CategoryChip(category: category);
            }).toList(),
          ),
          SizedBox(height: 4),
          Text(event.title, style: Theme.of(context).textTheme.headlineLarge),
          SizedBox(height: 4),
          Text(event.description,
              style: Theme.of(context).textTheme.bodyMedium),
          SizedBox(height: 4),
          Text(event.venue, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
      onLongPress: () => _toggleLike(event),
      onTap: () => _showEventDetails(context, event),
    );
  }
}
