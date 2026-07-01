import 'package:flutter/material.dart';
import '../../theme.dart';
import '../profile/profile_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _notifications = true;
  bool _autoPlay = false;
  bool _offlineMode = true;
  double _fontSize = 16;
  String _selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _darkMode = themeNotifier.value == ThemeMode.dark;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _buildSectionTitle('Appearance'),
                    _buildSettingsCard([
                      _buildToggleRow(
                        'Dark Mode',
                        'Switch to a darker reading theme',
                        Icons.dark_mode_rounded,
                        _darkMode,
                        (v) {
                          setState(() => _darkMode = v);
                          themeNotifier.value = v ? ThemeMode.dark : ThemeMode.light;
                        },
                      ),
                      _buildDivider(),
                      _buildSliderRow(),
                    ]),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Notifications'),
                    _buildSettingsCard([
                      _buildToggleRow('Push Notifications', 'Get alerts on new books and clubs', Icons.notifications_rounded, _notifications,
                          (v) => setState(() => _notifications = v)),
                    ]),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Reading'),
                    _buildSettingsCard([
                      _buildToggleRow('Auto-play Audio', 'Continue to next chapter automatically', Icons.play_circle_rounded, _autoPlay,
                          (v) => setState(() => _autoPlay = v)),
                      _buildDivider(),
                      _buildToggleRow('Offline Mode', 'Download books for offline reading', Icons.download_for_offline_rounded, _offlineMode,
                          (v) => setState(() => _offlineMode = v)),
                    ]),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Language'),
                    _buildSettingsCard([
                      _buildDropdownRow(),
                    ]),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Account'),
                    _buildSettingsCard([
                      _buildActionRow(
                        'Edit Profile',
                        Icons.person_outline_rounded,
                        onTap: () => _showEditProfileSheet(context),
                      ),
                      _buildDivider(),
                      _buildActionRow('Change Password', Icons.lock_outline_rounded),
                      _buildDivider(),
                      _buildActionRow('Privacy Policy', Icons.privacy_tip_outlined),
                      _buildDivider(),
                      _buildActionRow('Sign Out', Icons.logout_rounded, isDestructive: true),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1), width: 1.2),
              ),
              child: Icon(Icons.arrow_back_rounded, color: Theme.of(context).colorScheme.onSurface, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Settings',
            style: TextStyle(
              fontFamily: 'Literata',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Color(0xFF8C481A),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1), width: 1.2),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildToggleRow(String title, String subtitle, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(subtitle, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: Color(0xFF7A6B63))),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  Widget _buildSliderRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.format_size_rounded, color: AppTheme.primary, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Font Size',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text('${_fontSize.round()}px', style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: Color(0xFF7A6B63))),
                  ],
                ),
              ),
            ],
          ),
          Slider(
            value: _fontSize,
            min: 12,
            max: 24,
            divisions: 6,
            activeColor: AppTheme.primary,
            inactiveColor: const Color(0xFFE8DFD3),
            onChanged: (v) => setState(() => _fontSize = v),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.language_rounded, color: AppTheme.primary, size: 18),
          ),
          const SizedBox(width: 14),
          Text(
            'Language',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          DropdownButton<String>(
            value: _selectedLanguage,
            underline: const SizedBox(),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
            dropdownColor: Theme.of(context).colorScheme.surface,
            items: ['English', 'French', 'Spanish', 'Swahili']
                .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                .toList(),
            onChanged: (v) => setState(() => _selectedLanguage = v!),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(String title, IconData icon, {bool isDestructive = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDestructive ? Colors.red.withValues(alpha: 0.08) : AppTheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: isDestructive ? Colors.red : AppTheme.primary, size: 18),
            ),
            const SizedBox(width: 14),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDestructive ? Colors.red : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, color: isDestructive ? Colors.red.withValues(alpha: 0.5) : const Color(0xFFBBAFA8), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(indent: 66, endIndent: 16, color: Theme.of(context).dividerColor.withValues(alpha: 0.1), height: 1);
  }

  void _showEditProfileSheet(BuildContext context) {
    final nameController = TextEditingController(text: ProfileProvider.instance.name);
    final bioController = TextEditingController(text: ProfileProvider.instance.bio);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Profile',
                style: TextStyle(
                  fontFamily: 'Literata',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: const TextStyle(color: Color(0xFF7A6B63)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
                style: TextStyle(fontFamily: 'Inter', color: Theme.of(context).colorScheme.onSurface),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bioController,
                decoration: InputDecoration(
                  labelText: 'Bio / Tagline',
                  labelStyle: const TextStyle(color: Color(0xFF7A6B63)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
                maxLines: 2,
                style: TextStyle(fontFamily: 'Inter', color: Theme.of(context).colorScheme.onSurface),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    ProfileProvider.instance.updateProfile(
                      name: nameController.text.trim(),
                      bio: bioController.text.trim(),
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile updated successfully!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8C481A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
