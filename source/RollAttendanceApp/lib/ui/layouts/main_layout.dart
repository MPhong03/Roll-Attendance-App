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
  int _selectedIndex = 0;

  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;

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

  Future<void> _loadUserProfile() async {
    try {
      final response = await _apiService.get('api/auth/profile');
      if (response.statusCode == 200) {
        setState(() {
          _userProfile = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load profile');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Fluttertoast.showToast(msg: 'Error loading profile');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        context.push('/home');
        break;
      case 1:
      case 2:
        context.push('/organization');
        break;
      case 3:
        context.push('/profile');
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
Widget build(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
  final Color selectedBackgroundColor = const Color(0xFF1E8925);
  final Color selectedTextColor = Colors.white;
  final Color unselectedBackgroundColor =
      isDarkMode ? const Color(0xFF121212) : Colors.white;
  final Color unselectedTextColor = const Color(0xFF1E8925);
  final Color borderColor =
      isDarkMode ? Colors.white : Colors.black.withOpacity(0.1);

  double getResponsiveFontSize(double baseFontSize) {
    if (screenWidth > 480) {
      return baseFontSize * 1.25;
    } else {
      return baseFontSize;
    }
  }

  return Scaffold(
    key: _scaffoldKey,
    body: widget.child,
    bottomNavigationBar: Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 90, 90, 90),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.2),
            spreadRadius: 3,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildNavButton(
            context,
            iconPath: 'assets/icons/home_icon.png',
            label: 'HOME',
            isSelected: _selectedIndex == 0,
            selectedBackgroundColor: selectedBackgroundColor,
            selectedTextColor: selectedTextColor,
            unselectedBackgroundColor: unselectedBackgroundColor,
            unselectedTextColor: unselectedTextColor,
            onTap: () => _onItemTapped(0),
            getResponsiveFontSize: getResponsiveFontSize,
          ),
          _buildNavButton(
            context,
            iconPath: 'assets/icons/join_icon.png',
            label: 'JOIN',
            isSelected: _selectedIndex == 1,
            selectedBackgroundColor: selectedBackgroundColor,
            selectedTextColor: selectedTextColor,
            unselectedBackgroundColor: unselectedBackgroundColor,
            unselectedTextColor: unselectedTextColor,
            onTap: () => _onItemTapped(1),
            getResponsiveFontSize: getResponsiveFontSize,
          ),
          _buildNavButton(
            context,
            iconPath: 'assets/icons/organization_icon.png',
            label: 'ORGANIZATION',
            isSelected: _selectedIndex == 2,
            selectedBackgroundColor: selectedBackgroundColor,
            selectedTextColor: selectedTextColor,
            unselectedBackgroundColor: unselectedBackgroundColor,
            unselectedTextColor: unselectedTextColor,
            onTap: () => _onItemTapped(2),
            getResponsiveFontSize: getResponsiveFontSize,
          ),
          _buildNavButton(
            context,
            iconPath: 'assets/icons/profile_icon.png',
            label: 'PROFILE',
            isSelected: _selectedIndex == 3,
            selectedBackgroundColor: selectedBackgroundColor,
            selectedTextColor: selectedTextColor,
            unselectedBackgroundColor: unselectedBackgroundColor,
            unselectedTextColor: unselectedTextColor,
            onTap: () => _onItemTapped(3),
            getResponsiveFontSize: getResponsiveFontSize,
          ),
        ],
      ),
    ),
  );
}

  Widget _buildNavButton(
    BuildContext context, {
    required String iconPath,
    required String label,
    required bool isSelected,
    required Color selectedBackgroundColor,
    required Color selectedTextColor,
    required Color unselectedBackgroundColor,
    required Color unselectedTextColor,
    required VoidCallback onTap,
    required double Function(double) getResponsiveFontSize,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected
                ? selectedBackgroundColor
                : unselectedBackgroundColor,
            border: Border(
              right: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                iconPath, // Sử dụng icon từ assets
                color: isSelected ? selectedTextColor : unselectedTextColor,
                height: getResponsiveFontSize(20),
                width: getResponsiveFontSize(20),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: getResponsiveFontSize(12),
                  color: isSelected ? selectedTextColor : unselectedTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   final isSmallScreen = MediaQuery.of(context).size.width < 600;
  //   final theme = Theme.of(context);

  //   return Scaffold(
  //     key: _scaffoldKey,
  //     appBar: isSmallScreen
  //         ? AppBar(
  //             backgroundColor: theme.primaryColor,
  //             title: const Text('ITP'),
  //             leading: IconButton(
  //               onPressed: () {
  //                 _scaffoldKey.currentState?.openDrawer();
  //               },
  //               icon: Icon(Icons.menu, color: theme.iconTheme.color),
  //             ),
  //           )
  //         : null,
  //     drawer: isSmallScreen ? _buildSidebarX() : null,
  //     body: Row(
  //       children: [
  //         if (!isSmallScreen) _buildSidebarX(),
  //         Expanded(
  //           child: widget.child,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // SidebarX _buildSidebarX() {
  //   return SidebarX(
  //     controller: _controller,
  //     theme: SidebarXTheme(
  //       margin: const EdgeInsets.all(10),
  //       decoration: BoxDecoration(
  //         color: Theme.of(context).primaryColor,
  //         borderRadius: BorderRadius.circular(10),
  //       ),
  //       hoverColor: Theme.of(context).primaryColor.withOpacity(0.1),
  //       textStyle: TextStyle(color: Colors.black.withOpacity(0.7)),
  //       selectedTextStyle: const TextStyle(color: Colors.white),
  //       itemTextPadding: const EdgeInsets.only(left: 30),
  //       selectedItemTextPadding: const EdgeInsets.only(left: 30),
  //       itemDecoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(10),
  //       ),
  //       selectedItemDecoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(10),
  //         border: Border.all(
  //             color: Theme.of(context).primaryColor.withOpacity(0.5)),
  //       ),
  //       iconTheme: IconThemeData(
  //         color: Colors.white.withOpacity(0.7),
  //         size: 20,
  //       ),
  //       selectedIconTheme: const IconThemeData(
  //         color: Colors.white,
  //         size: 20,
  //       ),
  //     ),
  //     extendedTheme: const SidebarXTheme(
  //       width: 200,
  //     ),
  //     footerDivider: Divider(color: Colors.white.withOpacity(0.3), height: 1),
  //     headerBuilder: (context, extended) {
  //       if (_isLoading) {
  //         return const Center(child: CircularProgressIndicator());
  //       }

  //       if (_userProfile == null) {
  //         return const Center(child: Text('Error loading profile'));
  //       }

  //       final user = _userProfile!;
  //       return Padding(
  //         padding: const EdgeInsets.all(16.0),
  //         child: Column(
  //           children: [
  //             CircleAvatar(
  //               backgroundImage: NetworkImage(user['photoUrl'] ?? ''),
  //               radius: 40,
  //             ),
  //             if (extended) ...[
  //               const SizedBox(height: 8),
  //               Text(user['displayName'] ?? 'No Name',
  //                   style: const TextStyle(fontSize: 18, color: Colors.white)),
  //               const SizedBox(height: 4),
  //               Text(user['email'] ?? 'No Email',
  //                   style: const TextStyle(fontSize: 14, color: Colors.white)),
  //             ],
  //           ],
  //         ),
  //       );
  //     },
  //     items: [
  //       SidebarXItem(
  //         icon: Icons.home,
  //         label: 'Home',
  //         onTap: () {
  //           context.push('/home');
  //         },
  //       ),
  //       SidebarXItem(
  //         icon: Icons.account_circle,
  //         label: 'Profile',
  //         onTap: () {
  //           context.push('/profile');
  //         },
  //       ),
  //       SidebarXItem(
  //         icon: Icons.add,
  //         label: 'Create Organization',
  //         onTap: () {
  //           context.push('/create-organization');
  //         },
  //       ),
  //       SidebarXItem(
  //         icon: Icons.logout,
  //         label: 'Logout',
  //         onTap: _logout,
  //       ),
  //       SidebarXItem(
  //         icon: Icons.logout,
  //         label: 'Logout',
  //         onTap: _logout,
  //       ),
  //     ],
  //   );
  // }
}
