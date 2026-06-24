import 'package:flutter/material.dart';
import 'main.dart';
import 'presentation/onboarding/onboarding_screen.dart';
import 'presentation/splash/splash_screen.dart';
import 'presentation/book_detail/book_detail_screen.dart';
import 'data/models/book_model.dart';
import 'presentation/audio_player/read_along_screen.dart';
import 'presentation/audio_player/audio_player_screen.dart';
import 'presentation/reading_clubs/reading_clubs_screen.dart';
import 'presentation/audiobooks/audiobooks_screen.dart';
import 'presentation/ebooks/ebooks_screen.dart';
import 'presentation/settings/settings_screen.dart';
import 'presentation/help/help_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String home = '/';
  static const String details = '/details';
  static const String reader = '/reader';
  static const String player = '/player';
  static const String readingClubs = '/reading-clubs';
  static const String audiobooks = '/audiobooks';
  static const String ebooks = '/ebooks';
  static const String settings = '/settings';
  static const String help = '/help';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _buildPageRoute(const SplashScreen(), settings);
      case onboarding:
        return _buildPageRoute(const OnboardingScreen(), settings);
      case home:
        return _buildPageRoute(const MyHomePage(title: 'Home'), settings);
      case details:
        final book = settings.arguments as Book;
        return _buildPageRoute(BookDetailScreen(book: book), settings);
      case reader:
        final book = settings.arguments as Book;
        return _buildPageRoute(ReadAlongScreen(book: book), settings);
      case player:
        final book = settings.arguments as Book;
        return _buildPageRoute(AudioPlayerScreen(book: book), settings);
      case readingClubs:
        return _buildPageRoute(const ReadingClubsScreen(), settings);
      case audiobooks:
        return _buildPageRoute(const AudiobooksScreen(), settings);
      case ebooks:
        return _buildPageRoute(const EBooksScreen(), settings);
      case AppRoutes.settings:
        return _buildPageRoute(const SettingsScreen(), settings);
      case help:
        return _buildPageRoute(const HelpScreen(), settings);
      default:
        return _buildPageRoute(
          const Scaffold(
            body: Center(
              child: Text('Route not found!'),
            ),
          ),
          settings,
        );
    }
  }

  static PageRouteBuilder _buildPageRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOut;

        var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: curve),
        );

        var slideAnimation = Tween<Offset>(
          begin: const Offset(0.0, 0.05),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: curve));

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
