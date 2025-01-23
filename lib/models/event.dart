import 'package:html/dom.dart' as dom;
import 'dart:core';

class Event {
  final String date;
  final String title;
  final String singleEventUrl;
  final String venue;
  final String venueLink;
  final String time;
  final List<String> categories;
  String? longDescription;
  final String? description;
  String? imageUrl;
  final List<String>? eventUrlsTitles;
  final List<String>? eventUrls;
  final String? price;
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
    this.longDescription,
    this.eventUrlsTitles,
    this.eventUrls,
    this.price,
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
    );
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
      );
}
