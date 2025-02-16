import 'package:branch_assesment_test/constants/secrets.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';
import 'package:flutter/services.dart'; // Import for Clipboard
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart'; // Import Branch SDK
import 'package:logger/logger.dart'; // Import logger for logging
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:uuid/uuid.dart'; // Import for generating unique identifiers
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_base.dart';

Logger log = Logger(printer: PrettyPrinter());

class ProductDetailPage extends StatefulWidget {
  final Product product;

  ProductDetailPage({required this.product});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  String? generatedUrl; // Variable to hold the generated URL
  bool isLoading = false; // Variable to track loading state
  bool isPurchaseLoading = false; // Loader for Purchase Event

  @override
  void initState() {
    super.initState();
  }

  // Function to generate a Branch link
  void generateLink() async {
    setState(() {
      isLoading = true; // Set loading state to true
    });

    try {
      // Create a unique canonical identifier each time the link is generated
      final canonicalIdentifier = const Uuid().v4();

      // Create metadata for the BranchUniversalObject
      var metadata = BranchContentMetaData()
        ..addCustomMetadata('product_name', widget.product.name) // Product name
        ..addCustomMetadata(
            'product_price', widget.product.price.toString()) // Product price
        ..addCustomMetadata(
            'product_image', widget.product.imageUrl) // Product image URL
        ..addCustomMetadata('key', "1") // Custom key for identification
        ..addCustomMetadata('custom_string', 'abcdefg') // Example custom string
        ..addCustomMetadata('custom_number', 12345) // Example custom number
        ..addCustomMetadata('custom_bool', true) // Example custom boolean
        ..addCustomMetadata(
            'custom_date_created',
            DateFormat('yyyy-MM-dd HH:mm:ss')
                .format(DateTime.now())); // Current date

      // Create a BranchUniversalObject with the required parameters
      BranchUniversalObject buo = BranchUniversalObject(
        canonicalIdentifier: 'flutter/branch_$canonicalIdentifier',
        title: widget.product.name,
        imageUrl: widget.product.imageUrl,
        contentDescription: 'Check out this product: ${widget.product.name}',
        contentMetadata: metadata,
      );

      // Create BranchLinkProperties with the required parameters
      BranchLinkProperties lp = BranchLinkProperties(
        channel: 'app',
        feature: 'sharing',
        stage: 'new',
        tags: ['tag1', 'tag2'],
      );

      // Generate a short URL using the Branch SDK
      BranchResponse response =
          await FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: lp)
              .timeout(Duration(seconds: 10), onTimeout: () {
        throw Exception("Branch link generation timed out!");
      });
      setState(() {
        isLoading = false; // Set loading state to false
      });

      // Check if the link generation was successful
      if (response.success) {
        setState(() {
          generatedUrl = response.result; // Set the generated URL
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Link generated for ${widget.product.name}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error generating link: ${response.errorMessage}')),
        );
      }
    } catch (e) {
      log.e('Error generating link : $e');
    } finally {
      setState(() {
        isLoading = false; // Set loading state to false
      });
    }
  }

  // Function to copy the generated link to the clipboard
  void copyLinkToClipboard() {
    if (generatedUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please generate a link first!')),
      );
      return;
    }

    if (generatedUrl != null) {
      Clipboard.setData(ClipboardData(text: generatedUrl!)).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Link copied to clipboard!')),
        );
        trackProductViewedEvent(
            widget.product); // Track the event when the link is copied
      });
    }
  }

  // Function to track the product viewed event
  void trackProductViewedEvent(Product product) {
    // Create event
    BranchEvent event = BranchEvent.customEvent('Copied Link Event');

    // Define event data
    event.eventDescription = "Product Share";
    event.addCustomData('Product Name', widget.product.name);
    event.addCustomData('Product Price', widget.product.price.toString());

    // Log event
    FlutterBranchSdk.trackContentWithoutBuo(branchEvent: event);
  }

  Future<void> trackPurchaseEvent(Product product) async {
    setState(() {
      isPurchaseLoading = true; // Start loading
    });

    // Branch’s v2 event endpoint for standard events (PURCHASE, ADD_TO_CART, etc.).

    // Be sure to replace with your own live/test Branch key
    // const String branchKey = 'key_live_eCk7PGw7TOwRA4Y18pSO2odlrFcxPeQO';

    final Map<String, dynamic> requestBody = {
      'branch_key': branchKey,
      'name': 'PURCHASE',
      'user_data': {
        'developer_identity': 'user123',
        'os': 'Android',
        'environment': 'FULL_APP',
        'aaid': '4ffff466-67b4-4131-b48e-4cdc5ad0369a',
        'android_id': '5d25f62595d6d638',
      },
      'event_data': {
        'transaction_id': 'tx_${DateTime.now().millisecondsSinceEpoch}',
        'currency': 'USD',
        'revenue': product.price,
        'shipping': 5.0,
        'tax': 2.5,
        'coupon': 'DISCOUNT2025',
        'affiliation': 'MyStore',
      },
      'custom_data': {
        'Product Name': product.name,
        'Product Price': product.price.toString(),
      }
    };

    try {
      final response = await http
          .post(
        Uri.parse(endPoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      )
          .timeout(Duration(seconds: 10), onTimeout: () {
        throw Exception("Branch API request timed out!");
      });

      log.d('🔍 SENT DATA: ${jsonEncode(requestBody)}');

      if (response.statusCode == 200) {
        log.d('✅ PURCHASE event logged successfully!');
        log.d('🔍 API RESPONSE: ${response.body}');
      } else {
        log.e('⛔ Failed to log PURCHASE event. Status: ${response.statusCode}');
        log.e('🔍 API RESPONSE: ${response.body}');
      }
    } catch (e) {
      log.e('⛔ Error logging PURCHASE event: $e');
    } finally {
      setState(() {
        isPurchaseLoading = false; // Stop loading
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(widget.product.imageUrl),
            SizedBox(height: 16),
            Text(
              widget.product.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '\$${widget.product.price.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20, color: Colors.green),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: generateLink, // Call generateLink on button press
              child: Text('Generate Link'),
            ),
            SizedBox(height: 16),
            if (isLoading) ...[
              Center(child: CircularProgressIndicator()), // Show loader
            ] else if (generatedUrl != null) ...[
              Text(
                  'Generated URL: ${generatedUrl!}'), // Display the generated URL
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: copyLinkToClipboard, // Copy URL to clipboard
                child: Text('Copy Link'),
              ),
            ],
            Spacer(), // Pushes the button to the bottom
            // Purchase Button with Loader
            Center(
              child: ElevatedButton(
                onPressed: isPurchaseLoading
                    ? null
                    : () => trackPurchaseEvent(widget.product),
                child: isPurchaseLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Purchase'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
