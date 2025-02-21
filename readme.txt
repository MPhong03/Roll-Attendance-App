HƯỚNG DẪN DỰ ÁN CNTT

1. Thành viên:
- Đặng Minh Phong_52100988
- Lê Gia Huy_52100033

2. Thông tin nhanh
- Source dự án này đã có chứa sẵn key nhóm cấu hình, nên chỉ cần cài đặt thư viện và chạy dự án (folder em nộp trên elit có chứa tất cả key, cấu hình flutter)
- Phiên bản các thư viện, công nghệ có trong dự án:
	+ Flutter 3.27.4
	+ Dart 3.6.2
	+ Android SDK version 35.0.1
	+ Android Studio (version 2023.3) - Jellyfish PATCH 2
	+ ASP.NET Core 6
- Server domain đã hosting bằng AWS: http://mphong-api-2.ap-southeast-2.elasticbeanstalk.com
- Tài khoản vào app: 
	+ Email: user@example.com, Pass: 123456
	+ Email: user1@example.com, Pass: 123456
	+ Email: test@example.com, Pass: 123456
	+ Email: test2@example.com, Pass: 123456
	+ Email: test3@example.com, Pass: 123456
	+ Email: test5@example.com, Pass: 123456
- Tài khoản vào server:
	+ Email: admin@gmail.com, Pass: admin

3. Set up
3.1. API Server
	Bước 1: Mở dự án RollAttendanceServer bằng Visual Studio
	Bước 2: Thay đổi file appsettings.json (ConnectionString, key...)
	Bước 3: Mở Package Manager Console và nhập lệnh "Update-Database"
	Bước 4: Chạy Server

3.2. Ứng dụng Flutter
	Bước 1: Mở file .env, chỉnh sửa SERVER_URL bằng domain của API Server đã chạy (hoặc dùng domain có sẵn)
	Bước 2: Mở Terminal và nhập lệnh "flutter pub get"
	Bước 3: Để chạy ứng dụng Android, cần kết nối với máy thông qua debugging (dùng adb để kết nối), nhập lệnh "flutter devices để kiểm tra thiết bị đang kết nối"
	Bước 4: Nhập lệnh "flutter run" để build và chạy ứng dụng
- Đối với bản web, ta cần nhập các lệnh:
	+ Kích hoạt nền tảng web: "flutter config --enable-web"
	+ Chạy ứng dụng web: "flutter run -d [chrome, edge...]"

4. Docker
4.1. Server
	Bước 1: Di chuyển vào RollAttendanceServer, mở Terminal tại đây.
	Bước 2: Xây dựng Docker Image, gõ "docker build -t rollattendance-server ."
	Bước 3: Chạy Container, gõ "docker run -d -p 5000:5000 --name rollattendance-server rollattendance-server"
	Bước 4: Kiểm tra truy cập "http://localhost:5000" (đảm bảo có database, setup appsetting.json, AppData/firebase-service-account.json)

4.2. App bản web (bản android hãy copy .apk từ container)
	Bước 1: Di chuyển vào RollAttendanceApp, mở Terminal tại đây.
	Bước 2: Xây dựng Docker Image, gõ "docker build -t flutter-multi-build ."
	Bước 3: 
	+ WEB: Chạy Container, gõ "docker run -d -p 5000:5000 --name flutter-web flutter-multi-build" - Kiểm tra: http://localhost:5000
	+ APK:
		Bước 1: Xác định ID/Tên Container, gõ "docker ps"
		Bước 2: Chép file APK từ container ra ngoài, gõ "docker cp <container_id_or_name>:/app/build/app/outputs/flutter-apk/app-release.apk ./app-release.apk"

*Dừng Container: 
+ "docker stop rollattendance-server" - Dành cho Server
+ "docker stop flutter-web" - Dành cho flutter web

*Xóa Container:
+ "docker rm rollattendance-server" - Dành cho Server
+ "docker rm flutter-web" - Dành cho flutter web
