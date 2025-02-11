import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:itproject/services/api_service.dart';
import 'package:itproject/themes.dart';
import 'package:itproject/ui/main_view.dart';
import 'package:itproject/ui/screens/events/create_event.dart';
import 'package:itproject/ui/screens/events/edit_event.dart';
import 'package:itproject/ui/screens/events/event_absent_late_request.dart';
import 'package:itproject/ui/screens/events/event_access_list.dart';
import 'package:itproject/ui/screens/events/event_attendance_list.dart';
import 'package:itproject/ui/screens/events/event_check_in_screen.dart';
import 'package:itproject/ui/screens/events/event_detail.dart';
import 'package:itproject/ui/screens/events/event_face_check_in_screen.dart';
import 'package:itproject/ui/screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:itproject/ui/screens/login_screen.dart';
import 'package:itproject/ui/screens/organizations/add_user_to_organization.dart';
import 'package:itproject/ui/screens/organizations/create_organization.dart';
import 'package:itproject/ui/screens/organizations/edit_organization.dart';
import 'package:itproject/ui/screens/organizations/organization_detail.dart';
import 'package:itproject/ui/screens/organizations/organization_invite_requests.dart';
import 'package:itproject/ui/screens/organizations/organization_join_requests.dart';
import 'package:itproject/ui/screens/organizations/organization_list.dart';
import 'package:itproject/ui/screens/organizations/public/organization_public_search.dart';
import 'package:itproject/ui/screens/organizations/public/public_organization_detail.dart';
import 'package:itproject/ui/screens/profile_screen.dart';
import 'package:itproject/ui/screens/edit_profile_screen.dart';
import 'package:itproject/ui/screens/forgot_password_screen.dart';
import 'package:itproject/ui/screens/settings/my_invitation_screen.dart';
import 'package:itproject/ui/screens/settings/my_notifications_screen.dart';
import 'package:itproject/ui/screens/settings/my_request_screen.dart';
import 'package:itproject/ui/screens/settings/update_face_data_screen.dart';
import 'firebase_options.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:itproject/ui/layouts/main_layout.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

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

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.notification?.title}");
}

Future<void> initFCM() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  try {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("Đã cấp quyền nhận thông báo!");
    } else {
      print("Người dùng từ chối nhận thông báo hoặc bị chặn!");
    }
  } catch (e) {
    print("Lỗi khi yêu cầu quyền thông báo: $e");
  }

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("Nhận thông báo khi đang mở: ${message.notification?.title}");
    showLocalNotification(message);
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print("Nhấn vào thông báo khi ứng dụng nền: ${message.notification?.title}");
  });

  const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
  final InitializationSettings settingsInit = InitializationSettings(android: androidSettings);

  await flutterLocalNotificationsPlugin.initialize(settingsInit);
}

void showLocalNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'channel_id',
    'Thông báo',
    importance: Importance.high,
    priority: Priority.high,
  );

  const NotificationDetails details = NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    0,
    message.notification?.title ?? '',
    message.notification?.body ?? '',
    details,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  HttpOverrides.global = MyHttpOverrides();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initFCM();

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
            ShellRoute(
              builder: (context, state, child) => MainLayout(child: child),
              routes: [
                GoRoute(
                  path: '/home',
                  builder: (context, state) => const HomeScreen(),
                ),
                GoRoute(
                  path: '/organization',
                  builder: (context, state) => const OrganizationScreen(),
                ),
                GoRoute(
                  path: '/profile',
                  builder: (context, state) => const ProfileScreen(),
                ),
                GoRoute(
                  path: '/search-organization',
                  builder: (context, state) =>
                      const OrganizationPublicSearchScreen(),
                ),
              ],
            ),
            GoRoute(
              path: '/create-organization',
              builder: (context, state) => const CreateOrganizationScreen(),
            ),
            GoRoute(
              path: '/signin',
              builder: (context, state) => LoginScreen(
                controller: PageController(),
              ),
            ),
            GoRoute(
              path: '/forgot-password',
              builder: (context, state) => ForgotPasswordScreen(
                controller: PageController(),
              ),
            ),
            GoRoute(
              path: '/editprofile',
              builder: (context, state) => const EditProfileScreen(),
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
              path: '/public-organization-detail/:id',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return PublicOrganizationDetailScreen(organizationId: id);
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
              path: '/event-face-check-in/:id/:attempt',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                final attempt = state.pathParameters['attempt']!;
                return EventFaceCheckInScreen(
                    eventId: id, attempt: int.parse(attempt));
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
              path: '/event-history/:id',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return EventAttendanceListScreen(eventId: id);
              },
            ),
            GoRoute(
              path: '/event-permission-request/:id',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return EventAbsentLateRequestScreen(eventId: id);
              },
            ),
            GoRoute(
              path: '/add-to-organization/:id',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return AddUserToOrganizationScreen(organizationId: id);
              },
            ),
            GoRoute(
              path: '/my-requests',
              builder: (context, state) => const MyRequestsScreen(),
            ),
            GoRoute(
              path: '/my-invitations',
              builder: (context, state) => const MyInvitationsScreen(),
            ),
            GoRoute(
              path: '/my-notifications',
              builder: (context, state) => const MyNotificationsScreen(),
            ),
            GoRoute(
              path: '/organization-requests/:id',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return OrganizationJoinRequestsScreen(organizationId: id);
              },
            ),
            GoRoute(
              path: '/organization-invitations/:id',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return OrganizationInviteRequestsScreen(organizationId: id);
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
