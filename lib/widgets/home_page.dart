import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:sperrstunde/models/date_box.dart';
import 'package:sperrstunde/models/event.dart';
import 'package:sperrstunde/services/fech_service.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<DateBox> _dateBoxes = [];
  Filter _filter = Filter(categories: [], venues: '');
  bool _showOnlyLiked = false;
  bool _showOnlyFilterd = false;
  FilterOptions _filterOptions = FilterOptions(categories: {}, venues: {});

  @override
  void initState() {
    super.initState();
    _fetchWebpage();
  }

  Future<void> _fetchWebpage() async {
    List<DateBox> dateBoxes = [];
    try {
      var fetch_service = FetchService();
      dateBoxes = await fetch_service.fetchWebpage();
      _saveDateBoxes();
    } catch (e) {
      print(e);
    }
    if (dateBoxes.isEmpty) {
      dateBoxes = await loadDateBoxes();
    }
    setState(() {
      _dateBoxes = dateBoxes;
    });
    _loadLikes();
    setState(() {
      _filterOptions = getFilterOptions();
    });
  }

  FilterOptions getFilterOptions() {
    Set<String> allCategories = {};
    Set<String> allVenues = {};
    for (var dateBox in _dateBoxes) {
      for (var event in dateBox.events) {
        allCategories.addAll(event.categories);
        allVenues.add(event.venue);
      }
    }
    allCategories;
    allVenues;
    return FilterOptions(categories: allCategories, venues: allVenues);
  }

  Future<void> _saveDateBoxes() async {
    final prefs = await SharedPreferences.getInstance();
    final dateBoxesJson =
        jsonEncode(_dateBoxes.map((dateBox) => dateBox.toJson()).toList());
    await prefs.setString('dateBoxes', dateBoxesJson);
  }

  Future<List<DateBox>> loadDateBoxes() async {
    final prefs = await SharedPreferences.getInstance();
    final dateBoxesJson = prefs.getString('dateBoxes');
    if (dateBoxesJson != null) {
      final List<dynamic> dateBoxesList = jsonDecode(dateBoxesJson);
      return dateBoxesList.map((json) => DateBox.fromJson(json)).toList();
    }
    return [];
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
              onPressed: _showFilterDialog, icon: Icon(Icons.filter_list)),
          IconButton(
            icon: Icon(_showOnlyLiked ? Icons.favorite : Icons.favorite_border),
            onPressed: _toggleShowOnlyLiked,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchWebpage,
        child: _dateBoxes.isEmpty
            ? Text('No content found')
            : ListView.builder(
                itemCount: _dateBoxes.length,
                itemBuilder: (context, index) {
                  var dateBox = _dateBoxes[index];
                  if ((_showOnlyLiked &&
                          dateBox.events.every((event) => !event.liked)) ||
                      (_showOnlyFilterd &&
                          dateBox.events
                              .every((event) => !checkEvent(event)))) {
                    return SizedBox.shrink();
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          dateBox.date,
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Divider(),
                      ...dateBox.events
                          .where((event) => ((!_showOnlyLiked || event.liked) &&
                              (!_showOnlyFilterd || checkEvent(event))))
                          .map((event) {
                        return ListTile(
                          tileColor: event.liked ? Colors.red : null,
                          leading: Text(event.time),
                          title: Text(event.title),
                          subtitle: Text(
                              '${event.categories.join(', ')} - ${event.venue}'),
                          onLongPress: () => _toggleLike(event),
                          onTap: () => _showEventDetails(context, event),
                        );
                      })
                    ],
                  );
                },
              ),
      ),
    );
  }

  bool checkEvent(Event event) {
    return _filter.checkEvent(event);
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
                Text('Categories: ${event.categories.join(', ')}'),
                Text('Description: ${event.description}'),
              ],
            ),
            actions: [
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
            ]);
      },
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        List<String> tempCategories = List.from(_filter.categories);
        String tempVenue = _filter.venues;

        // Extract unique categories and venues from the events
        Set<String> allCategories = {};
        Set<String> allVenues = {};
        for (var dateBox in _dateBoxes) {
          for (var event in dateBox.events) {
            allCategories.addAll(event.categories);
            allVenues.add(event.venue);
          }
        }

        return AlertDialog(
          title: Text('Filter Events'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MultiSelectDialogField(
                items: allCategories
                    .map((category) => MultiSelectItem(category, category))
                    .toList(),
                title: Text('Categories'),
                selectedColor: Colors.blue,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  border: Border.all(
                    color: Colors.grey,
                    width: 1,
                  ),
                ),
                buttonIcon: Icon(
                  Icons.category,
                  color: Colors.blue,
                ),
                buttonText: Text(
                  'Select Categories',
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontSize: 16,
                  ),
                ),
                onConfirm: (results) {
                  tempCategories = results.cast<String>();
                },
                initialValue: tempCategories,
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Venue'),
                value: tempVenue.isNotEmpty ? tempVenue : null,
                items: allVenues.map((venue) {
                  return DropdownMenuItem<String>(
                    value: venue,
                    child: Text(venue),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    tempVenue = value;
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _filter.categories = tempCategories;
                  _filter.venues = tempVenue;
                  _showOnlyFilterd;
                });
                Navigator.of(context).pop();
              },
              child: Text('Apply'),
            ),
            TextButton(
              onPressed: () {
                _showOnlyFilterd = false;
                Navigator.of(context).pop();
              },
              child: Text('Reset'),
            ),
          ],
        );
      },
    );
  }
}

class Filter {
  List<String> categories = [];
  String venues = '';
  Filter({required this.categories, required this.venues});

  bool checkEvent(Event event) {
    bool matchesCategory = categories.isEmpty ||
        event.categories.any((category) => categories.contains(category));
    bool matchesVenue = venues.isEmpty || event.venue == venues;
    return matchesCategory && matchesVenue;
  }
}

class FilterOptions {
  Set<String> categories = {};
  Set<String> venues = {};

  FilterOptions({required this.categories, required this.venues});
}
