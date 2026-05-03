# 🌤 Weather App

A Flutter weather application that displays real-time weather data using the [OpenWeatherMap API](https://openweathermap.org/api). Features a clean dark UI with multi-city support, sunrise/sunset tracking, and live weather conditions.

---

## 📱 Screenshots

> Add your screenshots here

---

## ✨ Features

- **Real-time weather data** — temperature, condition, humidity, wind speed, pressure
- **Feels like temperature** — shows perceived temperature alongside actual
- **Multi-city support** — add any city and view its weather in a card
- **Tap to swap** — tap a city card to make it the main display
- **Long press / Red X to remove** — easily manage your city list
- **Sunrise & Sunset tracker** — live progress bar showing daylight progress
- **Clean dark UI** — blue-gradient cards with a modern dark theme
- **Celsius display** — temperatures converted from Kelvin to °C

---

## 🏗 Project Structure

```
lib/
├── main.dart                  # App entry point
├── secret.dart                # API key (not committed to git)
├── weather_service.dart       # All API/HTTP logic
├── weather_screen.dart        # Main UI screen
├── HourlyForecastItem.dart    # City card widget
└── Additional_Info_item.dart  # Humidity/wind/pressure widget
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK installed — [Install Flutter](https://docs.flutter.dev/get-started/install)
- An OpenWeatherMap API key — [Get one free](https://openweathermap.org/api)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/weather_app.git
   cd weather_app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Create `lib/secret.dart` and add your API key:
   ```dart
   const String APIKEY = 'your_openweathermap_api_key_here';
   ```

4. Run the app:
   ```bash
   flutter run
   ```

---

## 🔑 API Key Setup

This project uses the [OpenWeatherMap Current Weather API](https://openweathermap.org/current).

- Sign up at [openweathermap.org](https://openweathermap.org)
- Go to **API keys** in your account dashboard
- Copy your key into `lib/secret.dart` as shown above

> ⚠️ Never commit `secret.dart` to GitHub. It is already listed in `.gitignore`.

---

## 📦 Dependencies

Add these to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.0
```

Install with:
```bash
flutter pub get
```

---

## 🏠 Building the APK

To build a release APK:

```bash
flutter build apk --release
```

The output will be at:
```
build/app/outputs/flutter-apk/app-release.apk
```

Make sure your `AndroidManifest.xml` includes:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<application android:usesCleartextTraffic="true" ...>
```

---

## 🛠 How It Works

- `WeatherService` fetches data from `api.openweathermap.org/data/2.5/weather`
- Each city fetch returns: city name, temperature, feels like, condition, humidity, wind speed, pressure, sunrise, and sunset
- Tapping a city card **swaps** it with the main card — no re-fetching needed since all data is already stored
- Sunrise/sunset progress is calculated using the current device time vs the Unix timestamps returned by the API

---

## 🔮 Possible Future Improvements

- Persist added cities using `shared_preferences`
- 5-day forecast using the `/forecast` endpoint
- Pull to refresh gesture
- Search bar instead of dialog for adding cities
- Weather-based dynamic backgrounds

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

## 🙋 Author

Built by **Tanzeel Hussain** — FAST NUCES  
Feel free to fork, star, and contribute!
