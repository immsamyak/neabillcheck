# NEA Bill Check

A Flutter application to check Nepal Electricity Authority (NEA) electricity bills easily.

## Developer
- **Name:** Samyk Chaudhary
- **GitHub:** [@immsamyak](https://github.com/immsamyak/neabillcheck)

## Features
- Beautiful splash screen with animations
- Easy-to-use bill checking interface
- Support for all NEA office locations
- Real-time bill status checking
- Detailed bill information display
- Modern and responsive UI design

## Project Structure
```
neabillcheck/
├── lib/
│   ├── main.dart                 # App entry point and splash screen
│   ├── screens/
│   │   └── owner/
│   │       └── bill_check_screen.dart  # Main bill checking screen
│   └── utils/
│       └── colors.dart           # App color constants
├── test/
│   └── widget_test.dart          # Widget tests
├── android/                      # Android specific files
├── ios/                         # iOS specific files
├── web/                         # Web specific files
├── pubspec.yaml                 # Project dependencies
└── README.md                    # Project documentation
```

## Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  http: ^1.1.0
  html: ^0.15.4
```

## Getting Started

### Prerequisites
- Flutter SDK
- Dart SDK
- Android Studio / VS Code
- Git

### Installation
1. Clone the repository
```bash
git clone https://github.com/immsamyak/neabillcheck.git
```

2. Navigate to project directory
```bash
cd neabillcheck
```

3. Install dependencies
```bash
flutter pub get
```

4. Run the app
```bash
flutter run
```

## Usage
1. Launch the app
2. Enter your SC Number
3. Enter your Customer ID
4. Select your NEA office location
5. Click "Check Bill" to view your bill details

## Screenshots
- Splash Screen
- Bill Check Form
- Bill Details View
(Add actual screenshots once available)

## Contributing
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License
This project is licensed under the MIT License - see the LICENSE file for details

## Contact
Samyk Chaudhary - [@immsamyak](https://github.com/immsamyak/neabillcheck)

Project Link: [https://github.com/immsamyak/neabillcheck](https://github.com/immsamyak/neabillcheck)
