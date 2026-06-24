import 'package:flutter/material.dart';
import '../../theme.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.neutral,
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
                      _buildToggleRow('Dark Mode', 'Switch to a darker reading theme', Icons.dark_mode_rounded, _darkMode,
                          (v) => setState(() => _darkMode = v)),
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
                      _buildActionRow('Edit Profile', Icons.person_outline_rounded),
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF2ECE4), width: 1.2),
              ),
              child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF5C3826), size: 20),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Settings',
            style: TextStyle(
              fontFamily: 'Literata',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5C3826),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF2ECE4), width: 1.2),
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
                Text(title, style: const TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1E1E1E))),
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
                    const Text('Font Size', style: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1E1E1E))),
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
          const Text('Language', style: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1E1E1E))),
          const Spacer(),
          DropdownButton<String>(
            value: _selectedLanguage,
            underline: const SizedBox(),
            style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Color(0xFF5C3826), fontWeight: FontWeight.w600),
            items: ['English', 'French', 'Spanish', 'Swahili']
                .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                .toList(),
            onChanged: (v) => setState(() => _selectedLanguage = v!),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(String title, IconData icon, {bool isDestructive = false}) {
    return InkWell(
      onTap: () {},
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
                color: isDestructive ? Colors.red : const Color(0xFF1E1E1E),
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
    return const Divider(indent: 66, endIndent: 16, color: Color(0xFFF2ECE4), height: 1);
  }
}
