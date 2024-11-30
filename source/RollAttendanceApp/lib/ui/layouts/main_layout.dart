import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:itproject/ui/main_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:itproject/ui/screens/organizations/modals/create_organization.dart';
import 'package:itproject/ui/screens/profile_screen.dart';

class MainLayout extends StatefulWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  OverlayEntry? _overlayEntry;

  void _showLoadingOverlay() {
    if (_overlayEntry != null) return; // Nếu overlay đã tồn tại, không tạo lại
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
    _showLoadingOverlay(); // Hiển thị loading

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

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainView()),
        );
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
      _hideLoadingOverlay(); // Ẩn loading
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomAppBar(
        color: Colors.blueAccent,
        child: Row(
          children: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'profile') {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfileScreen()),
                  );
                } else if (value == 'logout') {
                  _logout(); // Gọi logout
                }
              },
              itemBuilder: (context) {
                final iconColor =
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black;
                return [
                  PopupMenuItem<String>(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.account_circle, color: iconColor),
                        const SizedBox(width: 8),
                        const Text('Profile'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: iconColor),
                        const SizedBox(width: 8),
                        const Text('Logout'),
                      ],
                    ),
                  ),
                ];
              },
              icon: const Icon(Icons.more_vert),
            ),
            IconButton(icon: const Icon(Icons.home), onPressed: () {}),
            IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: CreateOrganizationModal(
                onLoadingStateChange: (isLoading) {
                  if (isLoading) {
                    _showLoadingOverlay();
                  } else {
                    _hideLoadingOverlay();
                  }
                },
              ),
            ),
          );
        },
        tooltip: 'Create Organization',
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
    );
  }
}
