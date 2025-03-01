import 'package:sperrstunde/models/event.dart';

class Filter {
  List<String> categories = [];
  String venues = '';
  DateTime? startDate;
  DateTime? endDate;
  Filter(
      {required this.categories,
      required this.venues,
      this.startDate,
      this.endDate});

  bool checkEvent(Event event) {
    bool matchesCategory = categories.isEmpty ||
        event.categories.any((category) => categories.contains(category));
    bool matchesVenue = venues.isEmpty || event.venue == venues;
    bool matchesDate =
        (startDate == null || event.startTime.isAfter(startDate!)) &&
            (endDate == null || (event.startTime.isBefore(endDate!)));
    return matchesCategory && matchesVenue && matchesDate;
  }

  bool isFilterActive() {
    return categories.isNotEmpty ||
        venues.isNotEmpty ||
        startDate != null ||
        endDate != null;
  }
}
