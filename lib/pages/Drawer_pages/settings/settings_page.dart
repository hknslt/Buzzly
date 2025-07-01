import 'package:flutter/material.dart';
import 'package:firebase_deneme/pages/Drawer_pages/settings/About/account_information_page.dart';
import 'package:firebase_deneme/pages/Drawer_pages/settings/About/legal_policies_page.dart';
import 'package:firebase_deneme/pages/Drawer_pages/settings/Accessibility/accessibility_page.dart';
import 'package:firebase_deneme/pages/Drawer_pages/settings/Accessibility/display_page.dart';
import 'package:firebase_deneme/pages/Drawer_pages/settings/Accessibility/languages_page.dart';
import 'package:firebase_deneme/pages/Drawer_pages/settings/Account/language_region_page.dart';
import 'package:firebase_deneme/pages/Drawer_pages/settings/Account/password_page.dart';
import 'package:firebase_deneme/pages/Drawer_pages/settings/Privacy%20and%20Safety/direct_messages_page.dart';
import 'package:firebase_deneme/pages/Drawer_pages/settings/Privacy%20and%20Safety/muted_blocked_page.dart';
import 'package:firebase_deneme/pages/Drawer_pages/settings/Privacy%20and%20Safety/visibility_page.dart';
import 'package:firebase_deneme/pages/Drawer_pages/settings/Security%20and%20Account%20Access/apps_sessions_page.dart';

import 'Account/email_phone_page.dart';
import 'Account/username_page.dart';
import 'Notifications/notification_preferences_page.dart';
import 'Security and Account Access/security_page.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings and Privacy',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        children: [
          _buildSectionTitle('Account'),
          _buildListTile(
            context,
            title: 'Username',
            subtitle: 'Change your username',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UsernamePage()),
              );
            },
          ),
          _buildListTile(
            context,
            title: 'Email and Phone',
            subtitle: 'Update your contact information',
            onTap: () {
             Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EmailPhonePage()),
              );
            },
          ),
          _buildListTile(
            context,
            title: 'Password',
            subtitle: 'Change your password',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PasswordPage()),
              );
            },
          ),
          _buildListTile(
            context,
            title: 'Language and Region',
            subtitle: 'Adjust your language and regional settings',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LanguageRegionPage()),
              );
            },
          ),
          _buildSectionTitle('Security and Account Access'),
          _buildListTile(
            context,
            title: 'Security',
            subtitle: 'Manage two-factor authentication',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SecurityPage()),
              );
            },
          ),
          _buildListTile(
            context,
            title: 'Apps and Sessions',
            subtitle: 'View and manage connected apps',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AppsSessionsPage()),
              );
            },
          ),
          _buildSectionTitle('Privacy and Safety'),
          _buildListTile(
            context,
            title: 'Visibility',
            subtitle: 'Manage who can see your Tweets',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => VisibilityPage()),
              );
            },
          ),
          _buildListTile(
            context,
            title: 'Direct Messages',
            subtitle: 'Control who can send you messages',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DirectMessagesPage()),
              );
            },
          ),
          _buildListTile(
            context,
            title: 'Muted and Blocked',
            subtitle: 'View muted and blocked accounts',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MutedBlockedPage()),
              );
            },
          ),
          _buildSectionTitle('Notifications'),
          _buildListTile(
            context,
            title: 'Preferences',
            subtitle: 'Adjust your notification preferences',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationPreferencesPage()),
              );
            },
          ),
          _buildSectionTitle('Accessibility, Display, and Languages'),
          _buildListTile(
            context,
            title: 'Accessibility',
            subtitle: 'Adjust accessibility options',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AccessibilityPage()),
              );
            },
          ),
          _buildListTile(
            context,
            title: 'Display',
            subtitle: 'Change display preferences',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DisplayPage()),
              );
            },
          ),
          _buildListTile(
            context,
            title: 'Languages',
            subtitle: 'Set your content and interface language',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LanguagesPage()),
              );
            },
          ),
          _buildSectionTitle('About'),
          _buildListTile(
            context,
            title: 'Account Information',
            subtitle: 'View information about your account',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AccountInformationPage()),
              );
            },
          ),
          _buildListTile(
            context,
            title: 'Legal and Policies',
            subtitle: 'Review terms and policies',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LegalPoliciesPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildListTile(BuildContext context,
      {required String title, String? subtitle, required VoidCallback onTap}) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
