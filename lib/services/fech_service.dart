import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:sperrstunde/models/date_box.dart';
import 'package:sperrstunde/models/event.dart';

class FetchService {
  Future<List<DateBox>> fetchWebpage() async {
    final response = await http.get(Uri.parse('https://tunde.org/'));
    if (response.statusCode == 200) {
      var document = html_parser.parse(response.body);
      var eventDateBoxesElements =
          document.getElementsByClassName('event-datebox');
      return eventDateBoxesElements
          .map((element) => DateBox.fromElement(element))
          .toList();
    } else {
      throw Exception('Failed to load webpage');
    }
  }

  Future<void> loadSingleEvent(Event event) async {
    final response = await http
        .get(Uri.parse('https://sperrstunde.org/${event.singleEventUrl}'));
    if (response.statusCode == 200) {
      var document = html_parser.parse(response.body);
      var eventElement = document.getElementById('single-event');

      if (eventElement != null) {
        // Extract the image URL
        var imageElement =
            eventElement.querySelector('.single-event-images img');
        if (imageElement != null) {
          event.imageUrl = imageElement.attributes['src'] ?? '';
        }

        // Extract the longer description
        var descriptionElement =
            eventElement.querySelector('.single-event-description p');
        if (descriptionElement != null) {
          event.longDescription = descriptionElement.text;
        }
      }
    } else {
      throw Exception('Failed to load single event');
    }
  }
}
