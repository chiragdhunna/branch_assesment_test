import 'package:flutter/material.dart';
import '../models/product.dart';
import 'product_detail_page.dart';

class ProductListPage extends StatelessWidget {
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
