# Project README

## Overview

This project is a Flutter application that demonstrates the integration of Branch.io for deep linking and analytics. The application allows users to view product details, generate shareable links for products, and track user interactions with those links. The main features include:

- Displaying product information.
- Generating deep links for sharing products.
- Tracking product views and purchases using Branch.io.

## Features

- **Product Detail Page**: Displays detailed information about a selected product, including its name, price, and image.
- **Link Generation**: Users can generate a unique link for each product, which can be shared with others.
- **Clipboard Functionality**: Users can copy the generated link to their clipboard for easy sharing.
- **Event Tracking**: The application tracks events such as product views and purchases using the Branch SDK.

## Project Structure

- `lib/pages/`: Contains the main pages of the application, including the product detail and product list pages.
- `lib/models/`: Contains the data models used in the application, such as the `Product` model.
- `lib/main.dart`: The entry point of the Flutter application.

## Installation

To run this project locally, follow these steps:

1. **Clone the Repository**:

   ```bash
   git clone git@github.com:chiragdhunna/branch_assesment_test.git
   cd branch_assesment_test
   ```

2. **Install Dependencies**:
   Make sure you have Flutter installed on your machine. Then, run:

   ```bash
   flutter pub get
   ```

3. **Run the Application**:
   You can run the application on an emulator or a physical device:
   ```bash
   flutter run
   ```

## Building the APK

To build the release APK for the application, run the following command:

```bash
flutter build apk --release
```

The built APK can be found at:

```
Built build\app\outputs\flutter-apk\app-release.apk (22.0MB)
```

## Usage

1. Launch the application on your device or emulator.
2. Navigate to the product list to view available products.
3. Tap on a product to view its details.
4. Click the "Generate Link" button to create a shareable link for the product.
5. Use the "Copy Link" button to copy the generated link to your clipboard.
6. Click the "Purchase" button to simulate a purchase event, which will be tracked by Branch.io.

## Conclusion

This project showcases the integration of Branch.io for deep linking and analytics in a Flutter application. It provides a seamless user experience for sharing products and tracking user interactions. Feel free to explore the code and modify it to suit your needs.
