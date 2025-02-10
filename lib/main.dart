import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:logger/logger.dart';
import 'pages/product_list_page.dart'; // Import the product list page
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  final StreamController<String> controllerUrl = StreamController<String>();
  StreamSubscription? streamSubscription;

  @override
  void initState() {
    super.initState();
    listenDynamicLinks(); // Start listening for dynamic links
  }

  void listenDynamicLinks() async {
    streamSubscription = FlutterBranchSdk.listSession().listen((data) async {
      log.d('listenDynamicLinks - DeepLink Data: $data');

      if (data.containsKey('+clicked_branch_link') &&
          data['+clicked_branch_link'] == true) {
        log.d(
            '------------------------------------Link clicked----------------------------------------------');
        log.d('Title: ${data['\$og_title']}');
        log.d('Custom string: ${data['custom_string']}');
        log.d('Custom number: ${data['custom_number']}');
        log.d('Custom bool: ${data['custom_bool']}');
        log.d('Custom integer: ${data['custom_integer']}');
        log.d('Custom double: ${data['custom_double']}');
        log.d('Custom date: ${data['custom_date_created']}');
        log.d('Custom list number: ${data['custom_list_number']}');
        log.d(
            '------------------------------------------------------------------------------------------------');
      }
    }, onError: (error) {
      log.e('listSession error: ${error.toString()}');
    });
  }

  void copyLinkToClipboard(String link) {
    Clipboard.setData(ClipboardData(text: link)).then((_) {
      log.d('Link copied to clipboard: $link');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Link copied to clipboard!')),
      );
    });
  }

  void generateLink(BuildContext context) async {
    // Create a BranchUniversalObject with the required parameters
    BranchUniversalObject buo = BranchUniversalObject(
      canonicalIdentifier: 'flutter/branch_assessment_test',
      title: 'Branch Assessment Test',
      contentDescription: 'This is a test for Branch integration',
    );

    // Create BranchLinkProperties with the required parameters
    BranchLinkProperties lp = BranchLinkProperties(
      channel: 'app',
      feature: 'sharing',
      stage: 'new',
      tags: ['tag1', 'tag2'],
    ); // Create LinkProperties with the required parameters

    lp.addControlParam('\$uri_redirect_mode', '1');

    // Generate a short URL using the Branch SDK
    BranchResponse response =
        await FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: lp);
    if (response.success) {
      controllerUrl.sink.add('${response.result}');
    } else {
      controllerUrl.sink
          .add('Error: ${response.errorCode} - ${response.errorMessage}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Branch Assessment Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            StreamBuilder<String>(
              stream: controllerUrl.stream,
              builder: (context, snapshot) {
                return Column(
                  children: [
                    Text(snapshot.data ?? 'No URL generated'),
                    ElevatedButton(
                      onPressed: () {
                        if (snapshot.data != null) {
                          copyLinkToClipboard(snapshot.data!);
                        }
                      },
                      child: const Text('Copy Link'),
                    ),
                  ],
                );
              },
            ),
            ElevatedButton(
              onPressed: () => generateLink(context),
              child: const Text('Generate Link'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _counter++;
          });
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    controllerUrl.close();
    streamSubscription?.cancel();
  }
}
