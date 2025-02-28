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
  Set<String> _cachedImages = <String>{};
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _preloadImages(widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _preloadImages(index) {
    int currentIndex = index;
    for (int i = 1; i <= 10; i++) {
      if (currentIndex + i < widget.events.length) {
        _precacheImage(widget.events[currentIndex + i].imageUrl);
      }
    }
  }

  void _precacheImage(String? imageUrl) {
    if (imageUrl != null && !_cachedImages.contains(imageUrl)) {
      precacheImage(NetworkImage(imageUrl), context);
      _cachedImages.add(imageUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.events.length,
      onPageChanged: (index) {
        _preloadImages(index);
      },
      itemBuilder: (context, index) {
        return SingleEvent(
          event: widget.events[index],
          toggleLike: widget.toggleLike,
        );
      },
    );
  }
}
