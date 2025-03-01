import 'package:flutter/material.dart';
import 'package:sperrstunde/models/venue.dart';
import 'package:url_launcher/url_launcher.dart';

class VenueWidget extends StatelessWidget {
  final Venue venue;

  VenueWidget({required this.venue});

  void _launchMaps(String address) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}';
    _launchUrl(url);
  }

  void _launchUrl(String url) async {
    await launchUrl(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10.0),
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              venue.name,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () => _launchMaps(venue.address),
              child: Text(
                venue.address,
                style: TextStyle(fontSize: 16, color: Colors.blue),
              ),
            ),
            SizedBox(height: 10),
            if (venue.website != null)
              TextButton(
                onPressed: () => _launchUrl(venue.website!.url),
                child: Text('Website'),
              ),
            if (venue.socialMedias != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: venue.socialMedias!.map((link) {
                  return TextButton(
                    onPressed: () => _launchUrl(link.url),
                    child: Text(link.url),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
