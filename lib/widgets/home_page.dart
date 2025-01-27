import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sperrstunde/models/event.dart';
import 'package:sperrstunde/models/helper/filter.dart';
import 'package:sperrstunde/services/date_funktions.dart';
import 'package:sperrstunde/services/fech_service.dart';
import 'package:sperrstunde/widgets/event_list_element.dart';
import 'package:sperrstunde/widgets/filter_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sperrstunde/widgets/loading_screen.dart';
import 'package:sperrstunde/widgets/single_event_page_view.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Event> _events = [];
  List<Event> _eventsToShow = [];
  Filter _filter = Filter(categories: [], venues: '');
  ValueNotifier<bool> _showOnlyLiked = ValueNotifier(false);
  ValueNotifier<bool> _showOnlyFilterd = ValueNotifier(false);
  late Future<void> _fetchFuture;

  @override
  void initState() {
    super.initState();
    _fetchFuture = _fetchWebpage();
    _showOnlyLiked.addListener(_calculateEventsToShow);
    _showOnlyFilterd.addListener(_calculateEventsToShow);
  }

  @override
  void dispose() {
    _showOnlyLiked.removeListener(_calculateEventsToShow);
    _showOnlyFilterd.removeListener(_calculateEventsToShow);
    _showOnlyLiked.dispose();
    _showOnlyFilterd.dispose();
    super.dispose();
  }

  Future<void> _fetchWebpage() async {
    Future<List<Event>> storedEvents = _loadEvents();
    List<Event> events = [];
    try {
      var fetchService = FetchService();
      events = await fetchService.fetchWebpage();
    } catch (e) {
      FlutterError.reportError(FlutterErrorDetails(exception: e));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    }
    if (events.isEmpty) {
      events = await storedEvents;
      //remove all events with date in past
      DateTime currentDate = DateTime.now();
      DateTime today =
          DateTime(currentDate.year, currentDate.month, currentDate.day);
      events.removeWhere((event) {
        DateTime eventStartDate = DateTime(
            event.startTime.year, event.startTime.month, event.startTime.day);
        if (event.endTime != null) {
          DateTime eventEndDate = DateTime(
              event.endTime!.year, event.endTime!.month, event.endTime!.day);
          return eventEndDate.isBefore(today);
        } else {
          return eventStartDate.isBefore(today);
        }
      });
    }
    if (mounted) {
      setState(() {
        _events = events;
      });
    }
    await _saveEvents();
    await _loadLikes();
    _calculateEventsToShow();
    _loadSingleEventDetailsInBackground(events);
  }

  Future<void> _loadSingleEventDetailsInBackground(List<Event> events) async {
    var fetchService = FetchService();
    for (var event in events) {
      await fetchService.loadSingleEvent(event);
      if (mounted) {
        setState(() {});
      }
    }
    _saveEvents();
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsJson =
        jsonEncode(_events.map((event) => event.toJson()).toList());
    await prefs.setString('event', eventsJson);
  }

  Future<List<Event>> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = prefs.getString('event');
    if (eventsJson != null) {
      final List<dynamic> eventList = jsonDecode(eventsJson);
      return eventList.map((json) => Event.fromJson(json)).toList();
    }
    return [];
  }

  Future<void> _loadLikes() async {
    final prefs = await SharedPreferences.getInstance();
    final likedEvents = prefs.getStringList('likedEvents') ?? [];
    List<String> updatedLikedEvents = [];
    setState(() {
      for (var event in _events) {
        event.liked = likedEvents.contains(event.title);
        if (event.liked) {
          updatedLikedEvents.add(event.title);
        }
      }
    });
    await prefs.setStringList('likedEvents', updatedLikedEvents);
  }

  void _calculateEventsToShow() {
    if (!_showOnlyFilterd.value && !_showOnlyLiked.value) {
      setState(() {
        _eventsToShow = _events;
      });
    } else {
      List<Event> filteredEvents = _events.where((event) {
        bool matchesFilter =
            !_showOnlyFilterd.value || _filter.checkEvent(event);
        bool matchesLiked = !_showOnlyLiked.value || event.liked;
        return matchesFilter && matchesLiked;
      }).toList();

      setState(() {
        _eventsToShow = filteredEvents;
      });
    }
  }

  void _toggleShowOnlyLiked() {
    setState(() {
      _showOnlyLiked.value = !_showOnlyLiked.value;
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
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return FutureBuilder(
      future: _fetchFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingScreen();
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error loading data'),
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: SvgPicture.asset(
                'lib/assets/Sperrstunde_Logo-Schriftzug_RGB.svg',
                color: colorScheme.primary,
              ),
              actions: [
                IconButton(
                    onPressed: () {
                      if (_showOnlyFilterd.value) {
                        setState(() {
                          _showOnlyFilterd.value = false;
                        });
                      } else {
                        _showFilterDialog();
                      }
                    },
                    icon: Icon(_showOnlyFilterd.value
                        ? Icons.filter_list_alt
                        : Icons.filter_list_off_outlined),
                    color: colorScheme.secondary),
                IconButton(
                  icon: Icon(_showOnlyLiked.value
                      ? Icons.favorite
                      : Icons.favorite_border),
                  color: colorScheme.error,
                  onPressed: _toggleShowOnlyLiked,
                ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: _fetchWebpage,
              child: _events.isEmpty
                  ? Text('No content found')
                  : ListView.builder(
                      itemCount: _eventsToShow.length,
                      itemBuilder: (context, index) {
                        var event = _eventsToShow[index];
                        var date = DateHelper.formatDate(event.startTime);
                        bool isFirstEventOfDay = index == 0 ||
                            date! !=
                                DateHelper.formatDate(
                                    _eventsToShow[index - 1].startTime);
                        bool isLastEventOfDay =
                            index == _eventsToShow.length - 1 ||
                                date !=
                                    DateHelper.formatDate(
                                        _eventsToShow[index + 1].startTime);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isFirstEventOfDay)
                              Container(
                                width: double.infinity,
                                color: colorScheme.primary,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    DateHelper.formatDate(event.startTime),
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            EventListElement(
                              event: event,
                              toggleLike: _toggleLike,
                              showEventDetails: (context, event) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SingleEventPageView(
                                      events: _eventsToShow,
                                      initialIndex:
                                          _eventsToShow.indexOf(event),
                                      toggleLike: _toggleLike,
                                    ),
                                  ),
                                );
                              },
                            ),
                            if (!isLastEventOfDay)
                              Divider(
                                color: colorScheme.secondary,
                                thickness: 1,
                              )
                          ],
                        );
                      },
                    ),
            ),
          );
        }
      },
    );
  }

  bool checkEvent(Event event) {
    return _filter.checkEvent(event);
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return FilterDialogWidget(
            allEvents: _events,
            onApply: (filter) {
              setState(() {
                if (filter.categories.isEmpty && filter.venues.isEmpty) {
                  _showOnlyFilterd.value = false;
                } else {
                  _filter = filter;
                  _showOnlyFilterd.value = true;
                }
              });
            },
            onCancel: () {
              setState(() {
                _showOnlyFilterd.value = false;
              });
            },
            filter: _filter);
      },
    );
  }
}
