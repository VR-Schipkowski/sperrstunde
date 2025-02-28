import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:sperrstunde/models/event.dart';
import 'package:sperrstunde/models/helper/filter.dart';

class FilterDialogWidget extends StatefulWidget {
  final List<Event> allEvents;
  final Function(Filter) onApply;
  final Function() onCancel;
  final Filter filter;

  FilterDialogWidget({
    required this.allEvents,
    required this.onApply,
    required this.onCancel,
    required this.filter,
  });

  @override
  _FilterDialogWidgetState createState() => _FilterDialogWidgetState();
}

class _FilterDialogWidgetState extends State<FilterDialogWidget> {
  late List<String> tempCategories;
  late String tempVenue;
  DateTime? tempStartDate;
  DateTime? tempEndDate;

  @override
  void initState() {
    super.initState();
    tempCategories = List.from(widget.filter.categories);
    tempVenue = widget.filter.venues;
    tempStartDate = widget.filter.startDate;
    tempEndDate = widget.filter.endDate;
  }

  void resetFilters() {
    setState(() {
      tempCategories = [];
      tempVenue = '';
      tempStartDate = null;
      tempEndDate = null;
      widget.filter.categories = [];
      widget.filter.venues = '';
      widget.filter.startDate = null;
      widget.filter.endDate = null;
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      initialDateRange: tempStartDate != null && tempEndDate != null
          ? DateTimeRange(start: tempStartDate!, end: tempEndDate!)
          : null,
    );
    if (picked != null &&
        picked !=
            DateTimeRange(
                start: tempStartDate ?? DateTime.now(),
                end: tempEndDate ?? DateTime.now())) {
      setState(() {
        tempStartDate = picked.start;
        tempEndDate = picked.end;
        widget.filter.startDate = tempStartDate;
        widget.filter.endDate = tempEndDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract unique categories and venues from the events
    Set<String> allCategories = {};
    Set<String> allVenues = {};
    for (var event in widget.allEvents) {
      allCategories.addAll(event.categories);
      allVenues.add(event.venue);
    }
    allCategories.removeWhere((element) => element.isEmpty);
    List<String> sortedCategories = allCategories.toList()..sort();
    allVenues.removeWhere((element) => element.isEmpty);
    List<String> sortedVenues = allVenues.toList()..sort();

    return AlertDialog(
      title: Text('Filter Events'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MultiSelectDialogField(
            items: sortedCategories
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
              widget.filter.categories = tempCategories;
            },
            initialValue: tempCategories,
          ),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: 'Venue'),
            value: tempVenue.isNotEmpty ? tempVenue : null,
            isExpanded: true,
            items: sortedVenues.map((venue) {
              return DropdownMenuItem<String>(
                value: venue,
                child: Text(
                  venue,
                  overflow: TextOverflow.ellipsis, // Handle long text
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                tempVenue = value;
                widget.filter.venues = tempVenue;
              }
            },
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _selectDateRange(context),
            child: Text(
              tempStartDate != null && tempEndDate != null
                  ? '${DateFormat('dd.MM.yy').format(tempStartDate!)} - ${DateFormat('dd.MM.yy').format(tempEndDate!)}'
                  : 'Select Date Range',
            ),
          ),
        ],
      ),
      actions: [
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: IconButton(
                  onPressed: () {
                    resetFilters();
                  },
                  icon: Icon(Icons.refresh),
                  tooltip: 'Reset',
                ),
              ),
              Flexible(
                child: IconButton(
                  onPressed: () {
                    widget.onCancel();
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.cancel),
                  tooltip: 'Cancel',
                ),
              ),
              Flexible(
                child: IconButton(
                  onPressed: () {
                    List<Event> filteredEvents = [];
                    filteredEvents.addAll(widget.allEvents
                        .where((e) => widget.filter.checkEvent(e)));

                    if (filteredEvents.isEmpty) {
                      // Show warning if no events match the selected filters
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('No events match the selected filters.'),
                        ),
                      );
                    } else {
                      widget.onApply(widget.filter);
                      Navigator.of(context).pop();
                    }
                  },
                  icon: Icon(Icons.check),
                  tooltip: 'Apply',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
