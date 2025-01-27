import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sperrstunde/models/event.dart';
import 'package:sperrstunde/services/date_funktions.dart';
import 'package:sperrstunde/widgets/category_chip.dart';

class SingleEvent extends StatefulWidget {
  final Event event;
  final Function toggleLike;

  SingleEvent({required this.event, required this.toggleLike});

  @override
  _SingleEventState createState() => _SingleEventState();
}

class _SingleEventState extends State<SingleEvent> {
  late Event _event;

  @override
  void initState() {
    super.initState();
    _event = widget.event;
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_event.imageUrl != null)
              Center(
                child: CachedNetworkImage(
                  imageUrl: _event.imageUrl!,
                  width: MediaQuery.of(context).size.width *
                      0.8, // Set image width relative to screen width
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: _event.categories.map((category) {
                      return CategoryChip(category: category);
                    }).toList(),
                  ),
                  Text(
                    _event.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "${DateHelper.getFormattedDate(_event.startTime)} - ${DateHelper.getFormattedTime(_event.startTime)}-${DateHelper.getFormattedTime(_event.endTime)}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _event.venue,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _event.description,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(_event.longDescription ?? ''),
                  if (_event.price != null && _event.price != '')
                    Text(
                      'Price: ${_event.price}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        IconButton(
          icon: Icon(Icons.download),
          onPressed: () {
            _event.createAndOpenIcalFile();
          },
        ),
        IconButton(
          icon: Icon(
            _event.liked ? Icons.favorite : Icons.favorite_border,
            color: colorScheme.error,
          ),
          onPressed: () {
            widget.toggleLike(_event);
            setState(() {});
          },
        ),
      ],
    );
  }
}
