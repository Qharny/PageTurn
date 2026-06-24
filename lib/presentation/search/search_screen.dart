import 'package:flutter/material.dart';
import '../common/placeholder_screen.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Search',
      icon: Icons.search_rounded,
      subtitle: 'Find your next favorite story, author, or publisher.',
    );
  }
}
