import 'package:flutter/material.dart';
import 'package:sperrstunde/models/event.dart';
import 'package:sperrstunde/services/date_funktions.dart';
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
    String formattedTime =
        DateHelper.formatEventTime(event.startTime, event.endTime);

    return ListTile(
      leading: SizedBox(
        width: 70, // Set a fixed width for the leading part
        child: Center(
          child: Text(
            formattedTime,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (event.liked)
                Icon(
                  Icons.favorite,
                  color: colorScheme.error,
                ),
              Expanded(
                child: Wrap(
                  children: event.categories
                      .where((category) => category.isNotEmpty)
                      .map((category) => CategoryChip(category: category))
                      .toList(),
                ),
              ),
            ],
          ),
          Container(
            color: colorScheme.shadow,
            padding: EdgeInsets.symmetric(
                horizontal: 4.0, vertical: 2.0), // Add some padding
            child: Text(
              event.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          Text(event.description,
              style: Theme.of(context).textTheme.bodyMedium),
          Text(event.venue, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
      onLongPress: () => _toggleLike(event),
      onTap: () => _showEventDetails(context, event),
    );
  }
}
