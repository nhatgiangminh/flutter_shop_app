import 'package:flutter/material.dart';
import 'package:flutter_shop_app/models/cart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Order {
  final String id;
  final List<CartItem> products;
  final DateTime date;
  final String amount;

  Order(
      {required this.id,
      required this.date,
      required this.products,
      required this.amount});
}

class OrderProvider with ChangeNotifier {
  List<Order> _items = [];

  List<Order> get items {
    return [..._items];
  }

  Future<void> addOrder(List<CartItem> products, String total) async {
    final url = Uri.parse(
        'https://flutter-shop-app-20e7e-default-rtdb.firebaseio.com/orders.json');
    final dateTime = DateTime.now();
    final response = await http.post(url,
        body: json.encode({
          'amount': total,
          'date': dateTime.toIso8601String(),
          'products': products
              .map((cartProd) => {
                    'id': cartProd.id,
                    'title': cartProd.title,
                    'price': cartProd.price,
                    'quantity': cartProd.quantity,
                    'img': cartProd.img,
                  })
              .toList(),
        }));
    _items.insert(
        0,
        Order(
            id: json.decode(response.body)['name'],
            date: DateTime.now(),
            products: products,
            amount: total));
    notifyListeners();
  }

  Future<void> fetchAndSet() async {
    final url = Uri.parse(
        'https://flutter-shop-app-20e7e-default-rtdb.firebaseio.com/orders.json');
    final response = await http.get(url);
    final data = json.decode(response.body) as Map<String, dynamic>;
    final List<Order> loadedOrder = [];
    data.forEach((orderId, orderData) {
      loadedOrder.add(Order(
          id: orderId,
          date: orderData['date'],
          products: (orderData['products'] as List<Map>)
              .map((cart) => CartItem(
                  id: cart['id'],
                  price: cart['price'],
                  quantity: cart['quantity'],
                  title: cart['title'],
                  img: cart['img']))
              .toList(),
          amount: orderData['amount']));
    });
    _items = loadedOrder;
    notifyListeners();
  }
}
