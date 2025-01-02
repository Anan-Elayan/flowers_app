import 'dart:async';

import 'package:flutter/material.dart';

class Offers extends StatefulWidget {
  const Offers({super.key});

  @override
  _OffersState createState() => _OffersState();
}

class _OffersState extends State<Offers> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> _offerImages = [
    'assets/images/offers/sale_poster.jpg',
    'assets/images/offers/cash_back_offer_banner_2.jpg',
    'assets/images/offers/cash_back_offer_banner.jpg',
  ];

  late Timer _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentPage < _offerImages.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.22,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _offerImages.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Image.asset(
              _offerImages[index],
              fit: BoxFit.fill,
            ),
          );
        },
      ),
    );
  }
}
