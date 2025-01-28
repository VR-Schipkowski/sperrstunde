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

  factory Venue.fromElement(String name, dom.Element element) {
    var columns = element.getElementsByClassName("single-venue-meta");
    var address = columns[0].text.trim();
    var linkElemens = columns[1].querySelectorAll('a');
    Link? website;
    List<Link>? socialMedias;
    if (linkElemens.isNotEmpty) {
      website = Link.fromElement(linkElemens[0]);
      socialMedias =
          linkElemens.skip(1).map((e) => Link.fromElement(e)).toList();
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
      website: json['website'] ?? '',
      socialMedias: json['socialMedias'] ?? '',
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
}
