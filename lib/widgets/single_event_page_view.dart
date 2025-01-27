import 'package:flutter/material.dart';
import 'package:sperrstunde/models/event.dart';
import 'package:sperrstunde/widgets/single_event.dart';

class SingleEventPageView extends StatefulWidget {
  final List<Event> events;
  final Function(Event) toggleLike;
  final int initialIndex;

  SingleEventPageView({
    required this.events,
    required this.initialIndex,
    required this.toggleLike,
  });

  @override
  _SingleEventPageViewState createState() => _SingleEventPageViewState();
}

class _SingleEventPageViewState extends State<SingleEventPageView> {
  PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _pageController.addListener(_preloadImages);
  }

  @override
  void dispose() {
    _pageController.removeListener(_preloadImages);
    _pageController.dispose();
    super.dispose();
  }

  void _preloadImages() {
    int currentIndex = _pageController.page?.round() ?? 0;
    if (currentIndex < widget.events.length - 1) {
      _precacheImage(widget.events[currentIndex + 1].imageUrl);
    }
    if (currentIndex > 0) {
      _precacheImage(widget.events[currentIndex - 1].imageUrl);
    }
  }

  void _precacheImage(String? imageUrl) {
    if (imageUrl != null) {
      precacheImage(NetworkImage(imageUrl), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.events.length,
      itemBuilder: (context, index) {
        return SingleEvent(
          event: widget.events[index],
          toggleLike: widget.toggleLike,
        );
      },
    );
  }
}
