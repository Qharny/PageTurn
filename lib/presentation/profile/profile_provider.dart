import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  static final ProfileProvider instance = ProfileProvider._internal();
  ProfileProvider._internal();

  String _name = 'Kabutey';
  String _bio = 'Book lover · Gold Member · 28 books read this year';
  final String _avatarAsset = 'assets/images/profile_avatar.png';

  String get name => _name;
  String get bio => _bio;
  String get avatarAsset => _avatarAsset;

  void updateProfile({required String name, required String bio}) {
    _name = name;
    _bio = bio;
    notifyListeners();
  }
}
