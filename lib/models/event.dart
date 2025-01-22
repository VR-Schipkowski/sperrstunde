import 'package:html/dom.dart' as dom;

class Event {
  final String date;
  final String title;
  final String venue;
  final String time;
  final String category;
  final String description;
  bool liked;

  Event({
    required this.date,
    required this.title,
    required this.venue,
    required this.time,
    required this.category,
    required this.description,
    this.liked = false,
  });

  factory Event.fromElement(dom.Element element) {
    var date = element.querySelector('.event-date')?.text.trim() ?? '';
    var title = element.querySelector('.event-title h2 a')?.text.trim() ?? '';
    var venue = element.querySelector('.event-venue')?.text.trim() ?? '';
    var time = element.querySelector('.event-time')?.text.trim() ?? '';
    var category = element.querySelector('.event-categories a')?.text.trim() ?? '';
    var description = element.querySelector('.event-text p')?.text.trim() ?? '';

    return Event(
      date: date,
      title: title,
      venue: venue,
      time: time,
      category: category,
      description: description,
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date,
    'title': title,
    'venue': venue,
    'time': time,
    'category': category,
    'description': description,
    'liked': liked,
  };

  factory Event.fromJson(Map<String, dynamic> json) => Event(
    date: json['date'],
    title: json['title'],
    venue: json['venue'],
    time: json['time'],
    category: json['category'],
    description: json['description'],
    liked: json['liked'],
  );
}