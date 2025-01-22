import 'package:html/dom.dart' as dom;
import 'package:sperrstunde/models/event.dart';

class DateBox {
  final String date;
  final List<Event> events;

  DateBox({required this.date, required this.events});

  factory DateBox.fromElement(dom.Element element) {
    var date = element.querySelector('.event-date')?.text.trim() ?? '';
    var eventElements = element.getElementsByClassName('event event-published');
    var events = eventElements
        .map((eventElement) => Event.fromElement(eventElement))
        .toList();

    return DateBox(
      date: date,
      events: events,
    );
  }

  factory DateBox.fromJson(Map<String, dynamic> json) {
    return DateBox(
      date: json['date'],
      events: (json['events'] as List).map((e) => Event.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'events': events.map((e) => e.toJson()).toList(),
    };
  }
}
