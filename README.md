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

## How It Works

### Technical Implementation
The app uses web scraping to fetch bill information directly from the NEA billing website. Here's how it works:

1. **Data Collection**
   - User inputs: SC Number, Customer ID, and NEA Office Location
   - Each NEA office has a unique location code stored in the app

2. **Web Scraping Process**
   ```dart
   // Example of the web scraping implementation
   final url = Uri.parse('https://www.neabilling.com/viewonline/viewonlineresult/');
   
   // Form data preparation
   final formData = {
     'NEA_location': locationCode.toString(),
     'sc_no': scNo,
     'consumer_ID': customerId,
   };

   // Making POST request with appropriate headers
   final response = await http.post(
     url,
     headers: {
       "Content-Type": "application/x-www-form-urlencoded",
       "User-Agent": "Mozilla/5.0",
       "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
     },
     body: formData,
   );
   ```

3. **HTML Parsing**
   - Uses `html` package to parse the response
   - Extracts customer name from Consumer Detail section
   - Extracts bill amount from Bill Detail section
   - Determines payment status based on parsed data

4. **Data Processing**
   ```dart
   // Example of HTML parsing
   document.querySelectorAll('tr').forEach((row) {
     final cells = row.querySelectorAll('td');
     if (cells.length >= 2) {
       final label = cells[0].text.trim();
       if (label == 'Customer Name') {
         name = cells[1].text.trim();
       }
     }
   });
   ```

5. **Error Handling**
   - Validates server response
   - Checks for "No Records" message
   - Handles network errors
   - Provides user-friendly error messages

### Advantages of This Approach
- No API key required
- Real-time data directly from NEA website
- Works with all NEA office locations
- Minimal server dependency
- Fast and efficient

### Note
This implementation uses public web scraping and should be used responsibly. The app respects NEA's website structure and implements appropriate error handling and rate limiting.

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
  http: ^1.1.0  # For making HTTP requests
  html: ^0.15.4 # For parsing HTML responses
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
