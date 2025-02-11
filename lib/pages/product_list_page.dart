import 'package:flutter/material.dart';
import '../models/product.dart';
import 'product_detail_page.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:uuid/uuid.dart'; // Import for generating unique identifiers

Logger log = Logger(printer: PrettyPrinter());

class ProductListPage extends StatefulWidget {
  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final List<Product> products = [
    Product(
      name: 'Apple',
      imageUrl: 'assets/apple_fruit.jpg',
      price: 29.99,
    ),
    Product(
      name: 'Avacado',
      imageUrl: 'assets/avacado.png',
      price: 49.99,
    ),
    Product(
      name: 'Dragon Fruit',
      imageUrl: 'assets/dragon_fruit.png',
      price: 19.99,
    ),
  ];

  late BranchUniversalObject buo;
  late BranchLinkProperties lp;

  @override
  void initState() {
    super.initState();
    listenDynamicLinks(); // Start listening for dynamic links
    initDeepLinkData(); // Initialize deep link data
  }

  void listenDynamicLinks() async {
    FlutterBranchSdk.listSession().listen((data) async {
      log.d('listenDynamicLinks - DeepLink Data: $data');

      if (data.containsKey('+clicked_branch_link') &&
          data['+clicked_branch_link'] == true) {
        log.w(data);
        log.d(
            '------------------------------------Link clicked----------------------------------------------');
        log.d('Title: ${data['\$og_title']}');
        log.d('Key: ${data['key']}');
        log.d('Custom string: ${data['custom_string']}');
        log.d('Custom number: ${data['custom_number']}');
        log.d('Custom bool: ${data['custom_bool']}');
        log.d('Custom integer: ${data['custom_integer']}');
        log.d('Custom double: ${data['custom_double']}');
        log.d('Custom date: ${data['custom_date_created']}');
        log.d('Custom list number: ${data['custom_list_number']}');
        log.d('Product name: ${data['product_name']}');
        log.d('Product price: ${data['product_price']}');
        log.d('Product Image: ${data['product_image']}');
        log.d(
            '------------------------------------------------------------------------------------------------');

        if (data['key'] == "1") {
          log.w('Key is 1');
          double productPrice =
              double.tryParse(data['product_price'].toString()) ?? 0.0;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailPage(
                product: Product(
                  name: data['product_name'],
                  imageUrl: data['product_image'],
                  price: productPrice,
                ),
              ),
            ),
          );
        }
      }
    }, onError: (error) {
      log.e('listSession error: ${error.toString()}');
    });
  }

  void initDeepLinkData() {
    String dateString =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    var metadata = BranchContentMetaData()
      ..addCustomMetadata('custom_string', 'abcdefg')
      ..addCustomMetadata('custom_number', 12345)
      ..addCustomMetadata('custom_integer', 0)
      ..addCustomMetadata('custom_double', 0.0)
      ..addCustomMetadata('custom_bool', true)
      ..addCustomMetadata('custom_list_number', [1, 2, 3, 4, 5])
      ..addCustomMetadata('custom_list_string', ['a', 'b', 'c'])
      ..addCustomMetadata('custom_date_created', dateString)
      ..addCustomMetadata('\$og_image_width', 237)
      ..addCustomMetadata('\$og_image_height', 355)
      ..addCustomMetadata('\$og_image_url',
          'https://example.com/image.jpg') // Replace with actual image URL
      ..addCustomMetadata('product_name', 'Sample Product')
      ..addCustomMetadata('product_price', 99.99)
      ..addCustomMetadata('product_type', 'Sample Type');

    final canonicalIdentifier = const Uuid().v4();
    buo = BranchUniversalObject(
      canonicalIdentifier: 'flutter/branch_$canonicalIdentifier',
      title: 'Flutter Branch Plugin - $dateString',
      imageUrl:
          'https://example.com/image.jpg', // Replace with actual image URL
      contentDescription: 'Flutter Branch Description - $dateString',
      contentMetadata: metadata,
      keywords: ['Plugin', 'Branch', 'Flutter'],
      publiclyIndex: true,
      locallyIndex: true,
      expirationDateInMilliSec:
          DateTime.now().add(const Duration(days: 365)).millisecondsSinceEpoch,
    );

    lp = BranchLinkProperties(
      channel: 'share',
      feature: 'sharing',
      stage: 'new share',
      campaign: 'campaign',
      tags: ['one', 'two', 'three'],
    )
      ..addControlParam('\$uri_redirect_mode', '1')
      ..addControlParam('\$ios_nativelink', true)
      ..addControlParam('\$match_duration', 7200);
  }

  void trackProductViewedEvent(Product product) {
    // Create a BranchUniversalObject (BUO) for the product being viewed
    BranchUniversalObject buo = BranchUniversalObject(
      canonicalIdentifier: 'flutter/product/${product.name}',
      title: product.name,
      imageUrl: product.imageUrl,
      contentDescription: 'View the product: ${product.name}',
      contentMetadata: BranchContentMetaData()
        ..addCustomMetadata('product_name', product.name)
        ..addCustomMetadata('product_price', product.price.toString())
        ..addCustomMetadata('product_image', product.imageUrl),
    );

    // Create a BranchEvent for product view
    BranchEvent branchEvent = BranchEvent.standardEvent(
      BranchStandardEvent.VIEW_ITEM,
    );

    // Track the content view event
    FlutterBranchSdk.trackContent(
      buo: [buo],
      branchEvent: branchEvent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product List'),
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ListTile(
            leading: Image.asset(product.imageUrl),
            title: Text(product.name),
            subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
            onTap: () {
              trackProductViewedEvent(product);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailPage(product: product),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
