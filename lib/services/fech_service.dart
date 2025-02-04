import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:sperrstunde/models/event.dart';

class FetchService {
  Future<List<Event>> fetchWebpage() async {
    final response = await http.get(Uri.parse('https://sperrstunde.org/'));
    if (response.statusCode == 200) {
      List<Event> events = [];
      var document = html_parser.parse(response.body);
      var eventDateBoxesElements =
          document.getElementsByClassName('event-datebox');
      for (var element in eventDateBoxesElements) {
        var date = element.querySelector('.event-date')?.text.trim() ?? '';
        date = _removeParagraphs(date);
        var eventElements =
            element.getElementsByClassName('event event-published');
        events.addAll(eventElements
            .map((eventElement) => Event.fromElement(date, eventElement))
            .toList());
      }
      return events;
    } else {
      throw Exception('Failed to load webpage');
    }
  }

  static String _removeParagraphs(String input) {
    return input.replaceAll('\n', ', ').replaceAll('\r', '');
  }

  Future<void> loadSingleEvent(Event event) async {
    final response = await http
        .get(Uri.parse('https://sperrstunde.org/${event.singleEventUrl}'));
    if (response.statusCode == 200) {
      var document = html_parser.parse(response.body);
      var eventElements = document.getElementsByClassName('single-event');
      if (eventElements.isNotEmpty) {
        // Extract the image URL
        var eventElement = eventElements.first;
        var imageElement =
            eventElement.querySelector('.single-event-images img');
        if (imageElement != null) {
          event.imageUrl = imageElement.attributes['src'] ?? '';
        }

        // Extract the longer description
        var descriptionElement =
            eventElement.querySelector('.single-event-description p');
        if (descriptionElement != null) {
          event.longDescription = descriptionElement.text.trim();
        }
      } else {
        throw Exception('Failed to load single event');
      }
    }
  }
}
