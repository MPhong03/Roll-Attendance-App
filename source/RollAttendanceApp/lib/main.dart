import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:itproject/themes.dart';
import 'package:itproject/ui/main_view.dart';
import 'package:itproject/ui/screens/events/create_event.dart';
import 'package:itproject/ui/screens/events/edit_event.dart';
import 'package:itproject/ui/screens/events/event_access_list.dart';
import 'package:itproject/ui/screens/events/event_check_in_screen.dart';
import 'package:itproject/ui/screens/events/event_detail.dart';
import 'package:itproject/ui/screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:itproject/ui/screens/login_screen.dart';
import 'package:itproject/ui/screens/organizations/add_user_to_organization.dart';
import 'package:itproject/ui/screens/organizations/create_organization.dart';
import 'package:itproject/ui/screens/organizations/edit_organization.dart';
import 'package:itproject/ui/screens/organizations/organization_detail.dart';
import 'package:itproject/ui/screens/profile_screen.dart';
import 'package:itproject/ui/screens/settings/update_face_data_screen.dart';
import 'firebase_options.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void setupLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
}

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  HttpOverrides.global = MyHttpOverrides();

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  setupLogging();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final isLoggedIn = snapshot.hasData;

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
              path: '/signin',
              builder: (context, state) => LoginScreen(
                controller: PageController(),
              ),
            ),
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
            GoRoute(
              path: '/update-face-data',
              builder: (context, state) => const UpdateFaceDataScreen(),
            ),
            GoRoute(
              path: '/create-organization',
              builder: (context, state) => const CreateOrganizationScreen(),
            ),
            GoRoute(
              path: '/edit-organization/:id',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return EditOrganizationScreen(organizationId: id);
              },
            ),
            GoRoute(
              path: '/organization-detail/:id',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return OrganizationDetailScreen(organizationId: id);
              },
            ),
            GoRoute(
              path: '/create-event/:id',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return CreateEventScreen(organizationId: id);
              },
            ),
            GoRoute(
              path: '/edit-event/:id',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return EditEventScreen(eventId: id);
              },
            ),
            GoRoute(
              path: '/event-detail/:id',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return EventDetailScreen(eventId: id);
              },
            ),
            GoRoute(
              path: '/event-check-in/:id',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return EventCheckInScreen(eventId: id);
              },
            ),
            GoRoute(
              path: '/event-access-list/:id',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return EventAccessListScreen(eventId: id);
              },
            ),
            GoRoute(
              path: '/add-to-organization/:id',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return AddUserToOrganizationScreen(organizationId: id);
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
          theme: customLightTheme,
          darkTheme: customDarkTheme,
          themeMode: ThemeMode.system,
        );
      },
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
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '404 - Page not found',
              style: TextStyle(fontSize: 18),
            )
          ],
        ),
      ),
    );
  }
}
