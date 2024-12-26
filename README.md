# Roll Attendance App

## Getting Started
- [Flutter SDK Installation](https://docs.flutter.dev/)
## Run Project
- Application: `flutter pub get` and `flutter run`
- Server: Run with Visual Studio

## Requirements
- **Flutter SDK**
- **Firebase CLI**: `npm install -g firebase-tools` of [Installation](https://firebase.google.com/docs/cli#setup_update_cli)
- **Flutterfire Plugin**

## Firebase configuration
- Log into Firebase using your Google account by running the following command: `firebase login`
- Install the FlutterFire CLI by running the following command from any directory: `dart pub global activate flutterfire_cli`

## Backend Migration
- Open **Package Console Management**
- Add new migration to create table: `Add-Migration InitDb`
- Apply migration: `Update-Database`

## AWS Set up (follow these instructions)
- [RDS](https://dev.to/aws-builders/deploy-sql-server-on-amazon-rds-a-step-by-step-guide-457e)
- [Elastic Bean](https://aws.amazon.com/blogs/dotnet/deploy-to-elastic-beanstalk-environment-with-github-actions/)
