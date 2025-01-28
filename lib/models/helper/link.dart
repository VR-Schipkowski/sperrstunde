import 'package:html/dom.dart' as dom;

class Link {
  String title;
  String url;

  Link({required this.title, required this.url});

  factory Link.fromElement(dom.Element element) {
    //check if the element is a link
    if (element.localName != 'a') {
      throw ArgumentError('The element is not a link');
    }
    if (!(element.attributes['href'] == null ||
            element.attributes['href'] == '') &&
        element.text != '') {
      return Link(title: element.text, url: element.attributes['href'] ?? '');
    } else {
      throw ArgumentError('The link does not have a URL or text');
    }
  }

  factory Link.fromJson(Map<String, dynamic> json) {
    return Link(title: json['title'], url: json['url']);
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'url': url};
  }
}
