import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:sperrstunde/models/date_box.dart';
import 'package:sperrstunde/widgets/home_page.dart';

class FilterDialogWidget extends StatefulWidget {
  final List<String> filterCategories;
  final FilterOptions filterOptions;
  final String filterVenue;
  final Function(List<String>, String) onApply;
  final Function() onCancel;

  FilterDialogWidget({
    required this.filterOptions,
    required this.filterCategories,
    required this.filterVenue,
    required this.onApply,
    required this.onCancel,
  });

  @override
  _FilterDialogWidgetState createState() => _FilterDialogWidgetState();
}

class _FilterDialogWidgetState extends State<FilterDialogWidget> {
  late List<String> tempCategories;
  late String tempVenue;

  @override
  void initState() {
    super.initState();
    tempCategories = List.from(widget.filterCategories);
    tempVenue = widget.filterVenue;
  }

  @override
  Widget build(BuildContext context) {
    // Extract unique categories and venues from the events
    Set<String> allCategories = widget.filterOptions.categories;
    Set<String> allVenues = widget.filterOptions.venues;

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
            widget.onCancel();
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onApply(tempCategories, tempVenue);
            Navigator.of(context).pop();
          },
          child: Text('Apply'),
        ),
      ],
    );
  }
}
