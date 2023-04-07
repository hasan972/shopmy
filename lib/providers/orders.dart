// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_complete_guide/providers/product.dart';
// import 'package:http/http.dart' as http;

// import './cart.dart';

// class OrderItem {
//   final String id;
//   final double amount;
//   final List<CartItem> products;
//   final DateTime dateTime;

//   OrderItem({
//     @required this.id,
//     @required this.amount,
//     @required this.products,
//     @required this.dateTime,
//   });
// }

// class Orders with ChangeNotifier {
//   List<OrderItem> _orders = [];

//   List<OrderItem> get orders {
//     return [..._orders];
//   }

//   Future<void> fetchAndSetProducts() async {
//     final url = Uri.parse(
//         'https://flutter-update-fa50d-default-rtdb.firebaseio.com/orders.json');
//     final response = await http.get(url);
//     //print(json.decode(response.body));
//    final List<OrderItem> loadedOrders = [];
//     final extractedData = json.decode(response.body) as Map<String, dynamic>;
//     if (extractedData == null) {
//       return;
//     }
//     extractedData.forEach((orderId, orderData) {
//       loadedOrders.add(
//         OrderItem(
//           id: orderId,
//           amount: orderData['amount'],
//           dateTime: DateTime.parse(orderData['dateTime']),
//           products: (orderData['products'] as List<dynamic>)
//               .map(
//                 (item) => CartItem(
//                   id: item['id'],
//                   price: item['price'],
//                   quantity: item['quantity'],
//                   title: item['title'],
//                 ),
//               )
//               .toList(),
//         ),
//       );
//     });
//     _orders = loadedOrders.reversed.toList();
//     notifyListeners();
//   }

//   Future<void> addOrder(List<CartItem> cartProducts, double total) async {
//     final url = Uri.parse(
//         'https://flutter-update-fa50d-default-rtdb.firebaseio.com/orders.json');
//     final timestamp = DateTime.now();
//     final response = await http.post(url,
//         body: json.encode({
//           'amount': total,
//           'dateTime': timestamp.toIso8601String(),
//           'products': cartProducts
//               .map((cp) => {
//                     'id': cp.id,
//                     'title': cp.title,
//                     'quantity': cp.quantity,
//                     'price': cp.price,
//                   })
//               .toString(),
//         }));

//     _orders.insert(
//       0,
//       OrderItem(
//         id: json.decode(response.body)['name'],
//         amount: total,
//         dateTime: timestamp,
//         products: cartProducts,
//       ),
//     );
//     notifyListeners();
//   }
// }
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken;
  final String userId;

  Orders(this.authToken, this.userId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.parse(
        'https://flutter-update-fa50d-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
    final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return;
    }
    extractedData.forEach((orderId, orderData) {
      if (orderData['products'] != null &&
          orderData['products'] is List<dynamic>) {
        final products = orderData['products'] as List<dynamic>;
        final cartItems = products
            .map((item) => CartItem(
                  id: item['id'],
                  price: item['price'],
                  quantity: item['quantity'],
                  title: item['title'],
                ))
            .toList();
        loadedOrders.add(OrderItem(
          id: orderId,
          amount: orderData['amount'],
          dateTime: DateTime.parse(orderData['dateTime']),
          products: cartItems,
        ));
      } else {
        // handle the case where products is not a list
      }
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.parse(
        'https://flutter-update-fa50d-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
    final timestamp = DateTime.now();
    final response = await http.post(
      url,
      body: json.encode({
        'amount': total,
        'dateTime': timestamp.toIso8601String(),
        'products': cartProducts
            .map((cp) => {
                  'id': cp.id,
                  'title': cp.title,
                  'quantity': cp.quantity,
                  'price': cp.price,
                })
            .toList(),
      }),
    );
    _orders.insert(
      0,
      OrderItem(
        id: json.decode(response.body)['name'],
        amount: total,
        dateTime: timestamp,
        products: cartProducts,
      ),
    );
    notifyListeners();
  }
}
