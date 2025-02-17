FROM ghcr.io/cirruslabs/flutter:latest AS build

WORKDIR /app

COPY . .

RUN flutter pub get

RUN flutter build web --release

RUN flutter build apk --release

FROM nginx:alpine AS runtime

COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
