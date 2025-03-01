import 'package:html/dom.dart' as dom;
import 'package:sperrstunde/models/helper/link.dart';

class Venue {
  final String name;
  final String address;
  late Link? website;
  late List<Link>? socialMedias;

  Venue({
    required this.name,
    required this.address,
    this.website,
    this.socialMedias,
  });

  factory Venue.fromElement(dom.Element element) {
    // Extract the name
    var nameElement = element.querySelector('.single-venue-name');
    String name = nameElement?.text.trim() ?? 'Unknown Venue';

    // Extract the address
    var addressElement = element.querySelector('.single-venue-meta');
    String address = '';
    if (addressElement != null) {
      var addressLines = addressElement.text
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();
      if (addressLines.length > 1) {
        address = addressLines.sublist(1).join(', ');
      }
    }
    // Extract the website and social media links
    var linkElements = element.querySelectorAll('.single-venue-meta a');
    Link? website;
    List<Link>? socialMedias;
    if (linkElements.isNotEmpty) {
      website = Link.fromElement(linkElements[0]);
      socialMedias =
          linkElements.skip(1).map((e) => Link.fromElement(e)).toList();
    }
    return Venue(
      name: name,
      address: address,
      website: website,
      socialMedias: socialMedias,
    );
  }

  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      name: json['name'],
      address: json['address'],
      website: json['website'] != null ? Link.fromJson(json['website']) : null,
      socialMedias: json['socialMedias'] != null
          ? (json['socialMedias'] as List).map((e) => Link.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'website': website,
      'socialMedias': socialMedias,
    };
  }

  static defaultVenue(String venues) {
    return Venue(name: venues, address: '');
  }
}
