import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:html/dom.dart' as dom;
import 'dart:core';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sperrstunde/services/date_funktions.dart';

class Event {
  final String date;
  final String title;
  final String singleEventUrl;
  final String venue;
  final String venueLink;
  final String time;
  final List<String> categories;
  String longDescription;
  final String description;
  String? imageUrl;
  final List<String>? eventUrlsTitles;
  final List<String>? eventUrls;
  final String? price;
  final DateTime startTime;
  final DateTime? endTime;
  bool liked;

  Event({
    required this.date,
    required this.title,
    required this.singleEventUrl,
    required this.venue,
    required this.venueLink,
    required this.time,
    required this.categories,
    required this.description,
    this.imageUrl,
    this.longDescription = '',
    this.eventUrlsTitles,
    this.eventUrls,
    this.price,
    required this.startTime,
    this.endTime,
    this.liked = false,
  });

  factory Event.fromElement(String date, dom.Element element) {
    var title = element.querySelector('.event-title h2 a')?.text.trim() ?? '';
    var singleEventUrl =
        element.querySelector('.event-title h2 a')?.attributes['href'] ?? '';
    var venue = element.querySelector('.event-venue')?.text.trim() ?? '';
    var venueLink =
        element.querySelector('.event-venue a')?.attributes['href'] ?? '';

    var time = element.querySelector('.event-time')?.text.trim() ?? '';
    var categoriesString =
        element.querySelector('.event-categories a')?.text.trim() ?? '';
    var categories = categoriesString.split(',').map((e) => e.trim()).toList();
    var description = element.querySelector('.event-text p')?.text.trim() ?? '';
    // Extract all event URLs and their titles
    var eventUrlsElements = element.querySelectorAll('.event-link');
    var eventUrls =
        eventUrlsElements.map((e) => e.attributes['href'] ?? '').toList();
    var eventUrlsTitles = eventUrlsElements.map((e) => e.text.trim()).toList();
    var price = element.querySelector('.event-price')?.text.trim();
    var timeSplit = time.replaceAll("\n", "").split('–');
    var startTime = _parseTime(date, timeSplit[0].trim());
    var endTime =
        timeSplit.length > 1 ? _parseEndTime(date, timeSplit[1].trim()) : null;

    return Event(
        date: date,
        title: title,
        singleEventUrl: singleEventUrl,
        venue: venue,
        venueLink: venueLink,
        time: time,
        categories: categories,
        description: description,
        eventUrls: eventUrls,
        eventUrlsTitles: eventUrlsTitles,
        price: price,
        startTime: startTime,
        endTime: endTime,
        longDescription: '');
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'title': title,
        'singleEventUrl': singleEventUrl,
        'venue': venue,
        'venueLink': venueLink,
        'time': time,
        'categories': categories,
        'description': description,
        'longDescription': longDescription,
        'imageUrl': imageUrl,
        'eventUrlsTitles': eventUrlsTitles,
        'eventUrls': eventUrls,
        'price': price,
        'liked': liked,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
      };

  factory Event.fromJson(Map<String, dynamic> json) => Event(
        date: json['date'],
        title: json['title'],
        singleEventUrl: json['singleEventUrl'],
        venue: json['venue'],
        venueLink: json['venueLink'],
        time: json['time'],
        categories: List<String>.from(json['categories']),
        description: json['description'],
        longDescription: json['longDescription'],
        imageUrl: json['imageUrl'],
        eventUrlsTitles: List<String>.from(json['eventUrlsTitles']),
        eventUrls: List<String>.from(json['eventUrls']),
        price: json['price'],
        liked: json['liked'],
        startTime: DateTime.parse(json['startTime']),
        endTime:
            json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      );

  Future<void> createAndOpenIcalFile() async {
    final icalContent = '''
BEGIN:VCALENDAR
VERSION:2.0
BEGIN:VEVENT
SUMMARY:$title
DESCRIPTION:$description \n $longDescription
LOCATION:$venue
DTSTART:${startTime.toUtc().toIso8601String().replaceAll('-', '').replaceAll(':', '').split('.')[0]}
${endTime != null ? 'DTEND:${endTime?.toUtc().toIso8601String().replaceAll('-', '').replaceAll(':', '').split('.')[0]}\n' : ''}
END:VEVENT
END:VCALENDAR
''';

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$title.ics';
    final file = File(filePath);
    await file.writeAsString(icalContent);

    OpenFile.open(filePath, type: 'text/calendar');
  }

  Future<void> shareEvent() async {
    var endString = (endTime != null || endTime == '')
        ? "End: ${DateHelper.getFormattedTime(endTime?.toLocal())}\n"
        : '';
    final eventDetails = '''
Date: ${DateHelper.formatDate(startTime.toLocal())}

${title.toUpperCase()}

Venue: $venue
Description: $description
$longDescription

Start: ${DateHelper.getFormattedTime(startTime.toLocal())}
$endString
Price: $price
sperrstunde.org$singleEventUrl
''';
    if (imageUrl != null || imageUrl != '') {
      final file = await DefaultCacheManager().getSingleFile(imageUrl!);
      await Share.shareXFiles([XFile(file.path)], text: eventDetails);
    } else {
      await Share.share(eventDetails);
    }
  }

  static DateTime _parseTime(String date, String time) {
    // Combine the date and time strings and parse them into a DateTime object
    var dateTrimmed = date.split(",")[1].trim();
    var dateParts = dateTrimmed.split('.');
    var day = int.parse(dateParts[0]);
    var month = int.parse(dateParts[1]);
    var now = DateTime.now();
    //this will lead to truble for evnts more then 1 jear in the future
    var year = now.month <= month ? now.year : now.year + 1;
    var dateTimeString =
        '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')} $time';
    return DateTime.parse(dateTimeString);
  }

  static DateTime _parseEndTime(String startDate, String endTime) {
    // Check if the endTime contains a date
    if (endTime.contains('.')) {
      // Extract day, month, and year from the endTime string
      var dateTimeParts = endTime.split(' ');
      var dateParts = dateTimeParts[0].split('.');
      var day = int.parse(dateParts[0]);
      var month = int.parse(dateParts[1]);
      var year = int.parse(dateParts[2]);
      var time = dateTimeParts[1];

      // Combine the date and time strings and parse them into a DateTime object
      var dateTimeString =
          '20$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')} $time';
      return DateTime.parse(dateTimeString);
    } else {
      // If endTime does not contain a date, use the startDate
      return _parseTime(startDate, endTime);
    }
  }
}
