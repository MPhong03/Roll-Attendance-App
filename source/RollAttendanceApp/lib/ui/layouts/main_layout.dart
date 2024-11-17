import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:flutter/material.dart';
import 'package:itproject/ui/main_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainLayout extends StatefulWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  bool _isLoading = false;

  Future<void> _logout(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    // Clear the access token from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');

    // Check if the widget is still mounted before navigating
    if (context.mounted) {
      setState(() {
        _isLoading = false; // Hide loading backdrop after logout
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlurryModalProgressHUD(
      inAsyncCall: _isLoading,
      opacity: 0.3,
      blurEffectIntensity: 5,
      child: Scaffold(
        body: widget.child, // The current screen will be placed here
        bottomNavigationBar: BottomAppBar(
          color: Colors.blueAccent,
          child: Row(
            children: [
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'profile') {
                    // Navigate to the profile page
                  } else if (value == 'logout') {
                    _logout(context); // Trigger logout
                  }
                },
                itemBuilder: (BuildContext context) {
                  final iconColor =
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.white // White icon for dark theme
                          : Colors.black;

                  return [
                    PopupMenuItem<String>(
                      value: 'profile',
                      child: Row(
                        children: [
                          Icon(
                            Icons.account_circle,
                            color: iconColor,
                          ),
                          const SizedBox(width: 8),
                          const Text('Profile'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(
                            Icons.logout,
                            color: iconColor,
                          ),
                          const SizedBox(width: 8),
                          const Text('Logout'),
                        ],
                      ),
                    ),
                  ];
                },
                icon: const Icon(Icons.more_vert),
              ),
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: () {},
              ),
              // IconButton(
              //   icon: const Icon(Icons.search),
              //   onPressed: () {},
              // ),
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {},
              ),
              // IconButton(
              //   icon: const Icon(Icons.account_circle),
              //   onPressed: () {},
              // ),
              // Popup menu button with Profile and Logout options
            ],
          ),
        ),
        floatingActionButton: const FloatingActionButton(
          onPressed: null,
          tooltip: 'Create',
          child: Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      ),
    );
  }
}
