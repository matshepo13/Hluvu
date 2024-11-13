import 'package:flutter/material.dart';
import './chat_with_mom_page.dart';
import './chat_with_bot_page.dart';
import './alert_ahead_page.dart';
import './anonymous_reporting_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Title
              const Text(
                'Hluvukiso',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 159, 109, 168),
                ),
              ),
              const SizedBox(height: 16),
              
              // Search Bar with Gradient
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 159, 109, 168),
                      Color.fromARGB(255, 182, 146, 189),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Color.fromARGB(255, 159, 109, 168)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Type to search resources',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        style: const TextStyle(color: Color.fromARGB(255, 159, 109, 168)),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Horizontal scroll for contacts
              SizedBox(
                height: 90,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildCircleAvatar(icon: Icons.add, label: 'New'),
                    _buildCircleAvatar(imagePath: 'assets/images/mom.png', label: 'Mom'),
                    _buildCircleAvatar(imagePath: 'assets/images/sister.png', label: 'Sister'),
                    _buildCircleAvatar(imagePath: 'assets/images/bot.png', label: 'Evibot'),
                    _buildCircleAvatar(imagePath: 'assets/images/united.png', label: 'Group'),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Replace the old toggle buttons with the new ToggleButtonGroup
              ToggleButtonGroup(),

              const SizedBox(height: 24),

              // Updated Action Cards
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  children: [
                    _buildActionCard(
                      'Join our',
                      'Anonymous Reporting',
                      'Get help',
                      Icons.group_outlined,
                      true,
                    ),
                    const SizedBox(height: 8),
                    _buildActionCard(
                      'Seek',
                      'Legal Advice and Support',
                      'Get Advice',
                      Icons.gavel_outlined,
                      false,
                    ),
                    const SizedBox(height: 8),
                    _buildActionCard(
                      'Share your',
                      'AlertAhead',
                      'Help Others',
                      Icons.people_outline,
                      false,
                    ),
                    const SizedBox(height: 8),
                    _buildActionCard(
                      '24/7',
                      'Suicide Support',
                      'Save A Life',
                      Icons.favorite_outline,
                      false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleAvatar({String? imagePath, IconData? icon, required String label}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GestureDetector(
        onTap: () {
          if (label == 'Mom') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChatWithMomPage()),
            );
          } else if (label == 'Evibot') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChatWithBotPage()),
            );
          }
        },
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: const Color.fromARGB(255, 159, 109, 168).withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: icon != null
                  ? Icon(icon, color: const Color.fromARGB(255, 159, 109, 168), size: 32)
                  : ClipOval(child: Image.asset(imagePath!, fit: BoxFit.cover, width: 70, height: 70)),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(String title, String subtitle, String action, IconData icon, bool hasQuestion) {
    return GestureDetector(
      onTap: () {
        if (subtitle == 'AlertAhead') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AlertAheadPage()),
          );
        } else if (subtitle == 'Anonymous Reporting') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AnonymousReportingPage()),
          );
        }
      },
      child: Container(
        height: 100,
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color.fromARGB(255, 159, 109, 168).withOpacity(0.3),
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          leading: Icon(
            icon,
            color: const Color.fromARGB(255, 159, 109, 168),
            size: 32,
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              action,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ),
          trailing: hasQuestion 
              ? Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 159, 109, 168).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '?',
                    style: TextStyle(
                      color: Color.fromARGB(255, 159, 109, 168),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

// Add the ToggleButtonGroup class in the same file
class ToggleButtonGroup extends StatefulWidget {
  @override
  State<ToggleButtonGroup> createState() => _ToggleButtonGroupState();
}

class _ToggleButtonGroupState extends State<ToggleButtonGroup> {
  bool isReportSelected = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: const Color.fromARGB(255, 159, 109, 168),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isReportSelected = true),
              child: Container(
                decoration: BoxDecoration(
                  color: isReportSelected ? Colors.white : Colors.transparent,
                ),
                child: Center(
                  child: Text(
                    'Report',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: const Color.fromARGB(255, 159, 109, 168),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isReportSelected = false),
              child: Container(
                decoration: BoxDecoration(
                  color: !isReportSelected 
                      ? const Color.fromARGB(255, 159, 109, 168)
                      : Colors.transparent,
                ),
                child: Center(
                  child: Text(
                    'Connect',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: !isReportSelected ? Colors.white : const Color.fromARGB(255, 159, 109, 168),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
