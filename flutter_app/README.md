# PulseNow Flutter Assessment

This is the Flutter application for the PulseNow assessment. Your task is to implement the missing functionality to create a fully functional crypto trading and analytics mobile app.

## Project Screenshots

### App Gallery

| | | |
| :---: | :---: | :---: |
| ![Market Overview](./screenshots/img01.png)<br>Market Overview | ![Asset Details](./screenshots/img02.png)<br>Asset Details | ![Search & Filter](./screenshots/img03.png)<br>Search & Filter |
| ![Dark Mode](./screenshots/img04.png)<br>Dark Mode | ![Analytics Overview](./screenshots/img05.png)<br>Analytics Overview | ![Market Trends](./screenshots/img06.png)<br>Market Trends |
| ![Sentiment Analysis](./screenshots/img07.png)<br>Sentiment Analysis | | |

## Setup

1. Ensure Flutter is installed (Flutter 3.0+)
2. Install dependencies:
```bash
flutter pub get
```

3. Make sure the backend server is running (see `../backend/README.md`)

4. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
├── services/                 # API, WebSocket, and Cache services
├── providers/                # State management (MarketData, Theme, Analytics)
└── screens/                  # UI screens (Home, MarketData, Detail)
```

## Implemented Features

- **Real-time Market Updates**: Integrated WebSockets for live price movements.
- **Advanced UI**: Animated list transitions, Hero animations, and Material 3 design.
- **Search & Filtering**: Real-time asset filtering with input validation.
- **Sorting**: Multi-criteria sorting (Symbol, Price, Change).
- **Dark Mode**: Support for Light, Dark, and System theme switching.
- **Offline Support**: Local caching for immediate data access without internet.
- **Error Recovery**: Robust error handling with retry mechanisms and timeouts.

## Assessment Requirements

See `ASSESSMENT.md` for detailed requirements.
