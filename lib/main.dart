import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:logger/logger.dart';
import 'pages/product_list_page.dart'; // Import the product list page

Logger log = Logger(printer: PrettyPrinter());

void main() async {
  // Ensure Widgets are bound before initializing
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the Branch SDK before running the app
  await FlutterBranchSdk.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: ProductListPage(), // Set the home to ProductListPage
    );
  }
}
