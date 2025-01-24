import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sperrstunde/models/date_box.dart';
import 'package:sperrstunde/models/event.dart';
import 'package:sperrstunde/models/helper/filter.dart';
import 'package:sperrstunde/services/fech_service.dart';
import 'package:sperrstunde/widgets/category_chip.dart';
import 'package:sperrstunde/widgets/event_list_element.dart';
import 'package:sperrstunde/widgets/filter_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sperrstunde/widgets/helper/colormap.dart';
import 'package:sperrstunde/widgets/loading_screen.dart';
import 'package:sperrstunde/widgets/single_event.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<DateBox> _dateBoxes = [];
  List<DateBox> _dateBoxesToShow = [];
  Filter _filter = Filter(categories: [], venues: '');
  ValueNotifier<bool> _showOnlyLiked = ValueNotifier(false);
  ValueNotifier<bool> _showOnlyFilterd = ValueNotifier(false);
  late Future<void> _fetchFuture;

  @override
  void initState() {
    super.initState();
    _fetchFuture = _fetchWebpage();
    _showOnlyLiked.addListener(_calculateDateBoxesToShow);
    _showOnlyFilterd.addListener(_calculateDateBoxesToShow);
  }

  @override
  void dispose() {
    _showOnlyLiked.removeListener(_calculateDateBoxesToShow);
    _showOnlyFilterd.removeListener(_calculateDateBoxesToShow);
    _showOnlyLiked.dispose();
    _showOnlyFilterd.dispose();
    super.dispose();
  }

  Future<void> _fetchWebpage() async {
    List<DateBox> dateBoxes = [];
    try {
      var fetchService = FetchService();
      dateBoxes = await fetchService.fetchWebpage();
    } catch (e) {
      FlutterError.reportError(FlutterErrorDetails(exception: e));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    }
    if (dateBoxes.isEmpty) {
      dateBoxes = await loadDateBoxes();
    }
    if (mounted) {
      setState(() {
        _dateBoxes = dateBoxes;
      });
    }
    await _saveDateBoxes();
    await _loadLikes();
    _calculateDateBoxesToShow();
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

  void _calculateDateBoxesToShow() {
    if (!_showOnlyFilterd.value && !_showOnlyLiked.value) {
      setState(() {
        _dateBoxesToShow = _dateBoxes;
      });
    } else {
      List<DateBox> dateBoxesToShow = [];
      for (var dateBox in _dateBoxes) {
        var filteredEvents = dateBox.events.where((event) {
          bool matchesFilter =
              !_showOnlyFilterd.value || _filter.checkEvent(event);
          bool matchesLiked = !_showOnlyLiked.value || event.liked;
          return matchesFilter && matchesLiked;
        }).toList();
        if (filteredEvents.isNotEmpty) {
          dateBoxesToShow
              .add(DateBox(date: dateBox.date, events: filteredEvents));
        }
      }
      setState(() {
        _dateBoxesToShow = dateBoxesToShow;
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
                child: _dateBoxesToShow.isEmpty
                    ? Text('No content found')
                    : ListView.builder(
                        itemCount: _dateBoxesToShow.length,
                        itemBuilder: (context, index) {
                          var dateBox = _dateBoxesToShow[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                color: colorScheme.primary,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    dateBox.date,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onPrimary,
                                    ),
                                  ),
                                ),
                              ),
                              ...dateBox.events.map((event) {
                                return Column(
                                  children: [
                                    Divider(
                                      color: colorScheme.secondary,
                                      thickness: 2,
                                    ),
                                    EventListElement(
                                        event: event,
                                        toggleLike: _toggleLike,
                                        showEventDetails: _showEventDetails),
                                  ],
                                );
                              })
                            ],
                          );
                        },
                      ),
              ),
            );
          }
        });
  }

  bool checkEvent(Event event) {
    return _filter.checkEvent(event);
  }

  void _showEventDetails(BuildContext context, Event event) {
    showDialog(
      context: context,
      builder: (context) {
        return SingleEvent(event: event, toggleLike: _toggleLike);
      },
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return FilterDialogWidget(
            allDateBoxes: _dateBoxes,
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
