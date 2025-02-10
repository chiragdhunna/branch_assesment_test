import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:logger/logger.dart';

Logger log = Logger(printer: PrettyPrinter());

class StorePage extends StatelessWidget {
  const StorePage(
      {super.key, this.title, this.category, this.image, this.price});

  final category;
  final title;
  final image;
  final price;

  void generateLink(BranchUniversalObject buo, BranchLinkProperties lp) async {
    BranchResponse response =
        await FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: lp);
    if (response.success) {
      log.d('${response.result}');
    } else {
      log.e('Error : ${response.errorCode} - ${response.errorMessage}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(category),
        leading: IconButton(
          iconSize: 40.0,
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_left,
          ), // Icon
        ),
      ), // AppBar
      body: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 250,
            width: double.infinity,
            child: Image.network(image),
          ), // Container
          SizedBox(height: 10.0),
          Text(title, style: TextStyle(fontSize: 20.0)),
          SizedBox(height: 10.0),
          Text(price, style: TextStyle(fontSize: 20.0)),
          SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () {},
            child: Text('Buy', style: TextStyle(fontSize: 20.0)),
          ), // ElevatedButton
          SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () {},
            child: Text('Buy', style: TextStyle(fontSize: 20.0)),
          ), // ElevatedButton
          SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () {
              BranchLinkProperties lp = BranchLinkProperties(
                  channel: 'share',
                  feature: 'sharing',
                  stage: 'new share',
                  campaign: 'campaign',
                  tags: ['one', 'two', 'three']);
              lp.addControlParam('\$uri_redirect_mode', '1');

              return generateLink(
                  BranchUniversalObject(
                      canonicalIdentifier: 'flutter/branch',
                      canonicalUrl: '',
                      title: 'Flutter Branch Plugin',
                      imageUrl:
                          'https://flutter.dev/assets/flutter-lockup-4cb0ee072ab312e59784d9fbf4fb7ad42688a7fdaea1270ccfbbf4f34b7e03f.svg',
                      contentDescription: 'Flutter Branch Description',
                      contentMetadata: BranchContentMetaData()
                        ..addCustomMetadata('title', title)
                        ..addCustomMetadata('price', price)
                        ..addCustomMetadata('imageUrl', image)
                        ..addCustomMetadata('category', category),
                      keywords: ['Plugin', 'Branch', 'Flutter'],
                      publiclyIndex: true,
                      locallyIndex: true,
                      expirationDateInMilliSec: DateTime.now()
                          .add(const Duration(days: 365))
                          .millisecondsSinceEpoch),
                  lp);
            },
            child: Text('generate Link', style: TextStyle(fontSize: 20.0)),
          ), // ElevatedButton
        ],
      ), // Column
    );
  }
}
