import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:itproject/services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sidebarx/sidebarx.dart';

class MainLayout extends StatefulWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  OverlayEntry? _overlayEntry;
  final SidebarXController _controller = SidebarXController(selectedIndex: 0);
  final ApiService _apiService = ApiService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _showLoadingOverlay() {
    if (_overlayEntry != null) return;
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Container(
          color: Colors.black.withOpacity(0.3),
          child: const Center(
            child: CircularProgressIndicator(), // Loading Indicator
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideLoadingOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  Future<Map<String, dynamic>> _getUserProfile() async {
    final response = await _apiService.get('api/auth/profile');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load profile');
    }
  }

  Future<void> _logout() async {
    _showLoadingOverlay();

    try {
      await FirebaseAuth.instance.signOut();

      if (mounted) {
        Fluttertoast.showToast(
          msg: "You have been logged out",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.bottomSlide,
          title: 'Error',
          desc: 'Error, $e',
          btnCancelOnPress: () {},
        ).show();
      }
    } finally {
      _hideLoadingOverlay();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      key: _scaffoldKey,
      appBar: isSmallScreen
          ? AppBar(
              backgroundColor: Colors.blueAccent,
              title: const Text('Dashboard'),
              leading: IconButton(
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
                icon: const Icon(Icons.menu),
              ),
            )
          : null,
      drawer: isSmallScreen ? _buildSidebarX() : null,
      body: Row(
        children: [
          if (!isSmallScreen) _buildSidebarX(),
          Expanded(
            child: widget.child,
          ),
        ],
      ),
    );
  }

  SidebarX _buildSidebarX() {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return SidebarX(
      controller: _controller,
      theme: SidebarXTheme(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(10),
        ),
        hoverColor: Colors.blue.withOpacity(0.1),
        textStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        selectedTextStyle: const TextStyle(color: Colors.white),
        itemTextPadding: const EdgeInsets.only(left: 30),
        selectedItemTextPadding: const EdgeInsets.only(left: 30),
        itemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        selectedItemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.blueAccent.withOpacity(0.5)),
        ),
        iconTheme: IconThemeData(
          color: Colors.white.withOpacity(0.7),
          size: 20,
        ),
        selectedIconTheme: const IconThemeData(
          color: Colors.white,
          size: 20,
        ),
      ),
      extendedTheme: const SidebarXTheme(
        width: 200,
        decoration: BoxDecoration(
          color: Colors.blueAccent,
        ),
      ),
      footerDivider: Divider(color: Colors.white.withOpacity(0.3), height: 1),
      headerBuilder: (context, extended) {
        return FutureBuilder<Map<String, dynamic>>(
          future: _getUserProfile(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final user = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(user['photoUrl'] ?? ''),
                    radius: 40,
                  ),
                  if (extended) ...[
                    const SizedBox(height: 8),
                    Text(user['displayName'] ?? 'No Name',
                        style:
                            const TextStyle(fontSize: 18, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(user['email'] ?? 'No Email',
                        style:
                            const TextStyle(fontSize: 14, color: Colors.white)),
                  ],
                ],
              ),
            );
          },
        );
      },
      items: [
        SidebarXItem(
          icon: Icons.home,
          label: 'Home',
          onTap: () {
            context.push('/home');
          },
        ),
        SidebarXItem(
          icon: Icons.account_circle,
          label: 'Profile',
          onTap: () {
            context.push('/profile');
          },
        ),
        SidebarXItem(
          icon: Icons.add,
          label: 'Create Organization',
          onTap: () {
            context.push('/create-organization');
          },
        ),
        SidebarXItem(
          icon: Icons.logout,
          label: 'Logout',
          onTap: _logout,
        ),
      ],
    );
  }
}
