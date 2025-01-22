import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:sperrstunde/models/date_box.dart';

class FetchService {
  Future<List<DateBox>> fetchWebpage() async {
    final response = await http.get(Uri.parse('https://sperrstunde.org/'));
    if (response.statusCode == 200) {
      var document = html_parser.parse(response.body);
      var eventDateBoxesElements = document.getElementsByClassName('event-datebox');
      return eventDateBoxesElements.map((element) => DateBox.fromElement(element)).toList();
    } else {
      throw Exception('Failed to load webpage');
    }
  }
}