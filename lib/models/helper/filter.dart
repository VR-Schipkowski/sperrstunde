import 'package:sperrstunde/models/event.dart';

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
