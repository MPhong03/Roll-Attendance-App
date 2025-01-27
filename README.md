# Roll Attendance App

## Getting Started
- [Flutter SDK Installation](https://docs.flutter.dev/)
- 
## Run Project
- Application: `flutter pub get` and `flutter run`
- Server: Run with Visual Studio
- But first, you need to configure firebase for flutter application

## Requirements
- **Flutter SDK**
- **Firebase CLI**: `npm install -g firebase-tools` of [Installation](https://firebase.google.com/docs/cli#setup_update_cli)
- **Flutterfire Plugin**

## Configuration
### Server
- Go to [Firebase Console](https://console.firebase.google.com) -> Project Settings -> General ->  Your Apps -> SDK setup and configuration -> Download google-services.json and Paste to source\RollAttendanceServer\AppData
- Configure appsettings.json
- Our production server url: http://mphong-api.ap-southeast-2.elasticbeanstalk.com

### Flutter Application
- Log into Firebase using your Google account by running the following command: `firebase login`
- Install the FlutterFire CLI by running the following command from any directory: `dart pub global activate flutterfire_cli`
- Create .env file in source\RollAttendanceApp base on .env.example

## Backend Migration
- Open **Package Console Management**
- Add new migration to create table: `Add-Migration InitDb`
- Apply migration: `Update-Database`

## AWS Set up (follow these instructions)
- [RDS](https://dev.to/aws-builders/deploy-sql-server-on-amazon-rds-a-step-by-step-guide-457e)
- [Elastic Bean](https://aws.amazon.com/blogs/dotnet/deploy-to-elastic-beanstalk-environment-with-github-actions/)
