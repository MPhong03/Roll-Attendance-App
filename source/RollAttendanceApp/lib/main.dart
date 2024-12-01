import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:itproject/ui/main_view.dart';
import 'package:itproject/ui/screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:itproject/ui/screens/organizations/modals/create_organization.dart';
import 'package:itproject/ui/screens/organizations/organization_detail.dart';
import 'package:itproject/ui/screens/profile_screen.dart';
import 'firebase_options.dart';
import 'package:go_router/go_router.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  HttpOverrides.global = MyHttpOverrides();

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final user = FirebaseAuth.instance.currentUser;

  runApp(MyApp(isLoggedIn: user != null));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter(
      initialLocation: isLoggedIn ? '/home' : '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const MainView(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/create-organization',
          builder: (context, state) => const CreateOrganizationScreen(),
        ),
        GoRoute(
          path: '/organization-detail/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return OrganizationDetailScreen(organizationId: id);
          },
        ),
      ],
      errorPageBuilder: (context, state) => const MaterialPage(
        child: NotFoundScreen(),
      ),
    );

    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
    );
  }
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page not found'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '404 - Page not found',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Quay lại trang trước đó
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  context.go('/');
                }
              },
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
