import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sperrstunde/models/date_box.dart';
import 'package:sperrstunde/models/event.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sperrstunde',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<DateBox> _dateBoxes = [];
  bool _showOnlyLiked = false;

  @override
  void initState() {
    super.initState();
    _fetchWebpage();
  }

  Future<void> _fetchWebpage() async {
    final response = await http.get(Uri.parse('https://sperrstunde.org/'));
    if (response.statusCode == 200) {
      var document = html_parser.parse(response.body);
      var eventDateBoxesElements = document.getElementsByClassName('event-datebox');
      var dateBoxes = eventDateBoxesElements.map((element) => DateBox.fromElement(element)).toList();
      setState(() {
        _dateBoxes = dateBoxes;
      });
      _loadLikes();
      // Debugging: Print the parsed data
      for (var dateBox in _dateBoxes) {
        print('Date: ${dateBox.date}');
        for (var event in dateBox.events) {
          print('Event: ${event.title}, Venue: ${event.venue}, Time: ${event.time}');
        }
      }
    } else {
      setState(() {
        _dateBoxes = [];
      });
    }
  }
    Future<void> _loadLikes() async {
    final prefs = await SharedPreferences.getInstance();
    final likedEvents = prefs.getStringList('likedEvents') ?? [];
    setState(() {
      for (var dateBox in _dateBoxes) {
        for (var event in dateBox.events) {
          event.liked = likedEvents.contains(event.title);
        }
      }
    });
  }
  void _toggleShowOnlyLiked() {
    setState(() {
      _showOnlyLiked = !_showOnlyLiked;
    });
  }

  Future<void> _toggleLike(Event event) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      event.liked = !event.liked;
    });
    final likedEvents = prefs.getStringList('likedEvents') ?? [];
    if (event.liked) {
      likedEvents.add(event.title);
    } else {
      likedEvents.remove(event.title);
    }
    await prefs.setStringList('likedEvents', likedEvents);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sperrstunde'),
        actions: [
          IconButton(
            icon: Icon(_showOnlyLiked ? Icons.favorite : Icons.favorite_border),
            onPressed: _toggleShowOnlyLiked,
          ),
        ],
      ),
      body: Center(
        child: _dateBoxes.isEmpty
            ? Text('No content found')
            : RefreshIndicator(
                onRefresh: _fetchWebpage,
                child: ListView.builder(
                  itemCount: _dateBoxes.length,
                  itemBuilder: (context, index) {
                    var dateBox = _dateBoxes[index];
                    if (_showOnlyLiked && dateBox.events.every((event) => !event.liked)) {
                      return SizedBox.shrink();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            dateBox.date,
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Divider(),
                         ...dateBox.events.where((event) => !_showOnlyLiked || event.liked).map((event) {
                          return ListTile(
                            tileColor: event.liked ? Colors.red : null,
                            leading: Text(event.time),
                            title: Text(event.title),
                            subtitle: Text(event.venue),
                            onLongPress: () => _toggleLike(event),
                            onTap: () => _showEventDetails(context, event),
                          );
                        })
                      ],
                    );
                  },
                ),
              ),
      ),
      
    );
  }

  void _showEventDetails(BuildContext context, Event event) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(event.title),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Date: ${event.date}'),
              Text('Time: ${event.time}'),
              Text('Venue: ${event.venue}'),
              Text('Category: ${event.category}'),
              Text('Description: ${event.description}'),
            ],
          ),
          actions: 
            [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Close'),
              ),
              TextButton(
                onPressed: () {
                  _toggleLike(event);
                  print('Liked ${event.title}');
                  Navigator.of(context).pop();
                },
                child: Text('Like'),
              ),
            ]
        );
      },
    );
  }
}



