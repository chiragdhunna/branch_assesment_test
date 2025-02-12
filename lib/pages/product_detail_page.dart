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

  @override
  void initState() {
    super.initState();
  }

  // Function to generate a Branch link
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
        await FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: lp);
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
  }

  // Function to copy the generated link to the clipboard
  void copyLinkToClipboard() {
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

  // Function to track purchase events
  void trackPurchaseEvent(Product product) {
    // Create a BranchEvent for a purchase
    BranchEvent event = BranchEvent.standardEvent(BranchStandardEvent.PURCHASE);

    // Set the necessary data for the event
    event.revenue =
        product.price; // Set the revenue to the price of the product
    event.shipping = 5.0; // Example: Shipping cost
    event.tax = 2.5; // Example: Tax applied
    event.coupon = 'DISCOUNT2025'; // Example: A coupon code used
    event.affiliation = 'MyStore'; // Example: The store name

    // Optionally add more custom data
    event.addCustomData('Product Name', product.name);
    event.addCustomData('Product Price', product.price.toString());

    // Log the event using Branch SDK
    FlutterBranchSdk.trackContentWithoutBuo(branchEvent: event);
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
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Call the purchase function here
                  trackPurchaseEvent(widget.product);
                },
                child: Text('Purchase'),
              ),
            ),
            SizedBox(height: 16), // Add some spacing at the bottom
          ],
        ),
      ),
    );
  }
}
