import 'dart:async';

import 'package:flutter/material.dart';
import '../models/product.dart';
import 'package:flutter/services.dart'; // Import for Clipboard
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart'; // Import Branch SDK
import 'package:logger/logger.dart'; // Import logger for logging
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:uuid/uuid.dart'; // Import for generating unique identifiers

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
  late StreamSubscription streamSubscription;

  @override
  void initState() {
    super.initState();
  }

  void generateLink() async {
    setState(() {
      isLoading = true; // Set loading state to true
    });

    // Create a unique canonical identifier each time the link is generated
    final canonicalIdentifier = const Uuid().v4();

    // Create metadata for the BranchUniversalObject
    var metadata = BranchContentMetaData()
      ..addCustomMetadata('product_name', widget.product.name) // Product name
      ..addCustomMetadata(
          'product_price', widget.product.price.toString()) // Product price
      ..addCustomMetadata(
          'product_image', widget.product.imageUrl) // Product type (example)
      ..addCustomMetadata('key', "1")
      ..addCustomMetadata('custom_string', 'abcdefg')
      ..addCustomMetadata('custom_number', 12345)
      ..addCustomMetadata('custom_bool', true)
      ..addCustomMetadata('custom_date_created',
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()));

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
        await FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: lp);
    setState(() {
      isLoading = false; // Set loading state to false
    });

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
  }

  void copyLinkToClipboard() {
    if (generatedUrl != null) {
      Clipboard.setData(ClipboardData(text: generatedUrl!)).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Link copied to clipboard!')),
        );
      });
    }
  }

  @override
  void dispose() {
    streamSubscription.cancel(); // Cancel the stream subscription
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
          ],
        ),
      ),
    );
  }
}
