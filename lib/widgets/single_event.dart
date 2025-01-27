import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
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
  final double iconSize = 32.0;

  @override
  void initState() {
    super.initState();
    _event = widget.event;
  }

  Future<void> _shareEvent() async {
    final imageProvider = CachedNetworkImageProvider(_event.imageUrl!);
    final key = await imageProvider.obtainKey(const ImageConfiguration());
    final file = await imageProvider.cacheManager!.getSingleFile(key.url);
    await _event.shareEvent(file);
  }

  void _showFullScreenImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: PhotoView(
            imageProvider: CachedNetworkImageProvider(imageUrl),
            backgroundDecoration: BoxDecoration(color: Colors.black),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    var textTheme = Theme.of(context).textTheme;
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_event.imageUrl != null)
              GestureDetector(
                onTap: () => _showFullScreenImage(_event.imageUrl!),
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl: _event.imageUrl!,
                    width: MediaQuery.of(context).size.width *
                        1, // Set image width relative to screen width
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
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
                  SizedBox(height: 8),
                  Container(
                    color: colorScheme.shadow,
                    padding: EdgeInsets.symmetric(
                        horizontal: 2.0, vertical: 2.0), // Add some padding
                    child: Text(
                      _event.title,
                      style: textTheme.headlineMedium,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "${DateHelper.getFormattedDate(_event.startTime)} - ${DateHelper.getFormattedTime(_event.startTime)}-${DateHelper.getFormattedTime(_event.endTime)}",
                    style: textTheme.bodyMedium,
                  ),
                  SizedBox(height: 8),
                  Text(
                    _event.venue,
                    style: textTheme.bodySmall,
                  ),
                  SizedBox(height: 8),
                  Text(
                    _event.description,
                    style: textTheme.bodyMedium,
                  ),
                  SizedBox(height: 8),
                  Text(_event.longDescription ?? ''),
                  if (_event.price != null && _event.price != '')
                    Text(
                      'Price: ${_event.price}',
                      style: textTheme.headlineMedium,
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
          iconSize: iconSize,
        ),
        IconButton(
          icon: Icon(Icons.download),
          onPressed: () {
            _event.createAndOpenIcalFile();
          },
          iconSize: iconSize,
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
          iconSize: iconSize,
        ),
        IconButton(
            icon: Icon(Icons.share),
            onPressed: () => _shareEvent(),
            iconSize: iconSize),
      ],
    );
  }
}
