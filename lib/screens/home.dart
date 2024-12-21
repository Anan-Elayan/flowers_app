import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/market_card.dart';
import '../constants/constants.dart';
import 'cart_screen.dart';
import 'login.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<List<dynamic>> listOfAllItemsInMarket;
  List<dynamic> cartItems = [];
  int quantityInCart = 0;

  @override
  void initState() {
    super.initState();
    listOfAllItemsInMarket = _loadMyItems();
  }

  Future<String?> _loadLoginCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('saved_username');
  }

  void refreshItems() {
    setState(() {
      listOfAllItemsInMarket = _loadMyItems();
    });
  }

  Future<List<dynamic>> _loadMyItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedItems = prefs.getString('flower_items');
    if (savedItems != null) {
      List<dynamic> allItems = jsonDecode(savedItems);
      return allItems;
    }
    return [];
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
  }

  void _addToCart(dynamic item) {
    setState(() {
      final cartItemIndex = cartItems.indexWhere((i) => i['id'] == item['id']);
      if (cartItemIndex >= 0) {
        if (cartItems[cartItemIndex]['quantity'] < item['available_quantity']) {
          cartItems[cartItemIndex]['quantity'] += 1;
        } else {
          _showToast("Cannot add more than available quantity.");
        }
      } else {
        if (item['available_quantity'] > 0) {
          cartItems.add({
            ...item,
            'quantity': 1,
          });
        } else {
          _showToast("Item out of stock.");
        }
      }
    });
  }

  void _deleteFromCart(dynamic item) {
    cartItems.removeWhere((cartItem) => cartItem['id'] == item['id']);
  }

  void _purchaseItems() async {
    final marketItems = await listOfAllItemsInMarket;

    setState(() {
      for (var cartItem in cartItems) {
        final marketItemIndex =
            marketItems.indexWhere((item) => item['id'] == cartItem['id']);
        if (marketItemIndex >= 0) {
          marketItems[marketItemIndex]['available_quantity'] -=
              cartItem['quantity'];
        }
      }
      cartItems.clear();
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('flower_items', jsonEncode(marketItems));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartPage(
                    cartItems: cartItems,
                    onDeleteItem: _deleteFromCart,
                    onPurchaseItems: _purchaseItems,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.shopping_cart),
          ),
        ],
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
          icon: const Icon(
            Icons.logout,
            color: Colors.white,
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: thirdColor,
        title: FutureBuilder<String?>(
          future: _loadLoginCredentials(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Welcome ...");
            } else if (snapshot.hasError) {
              return const Text("Welcome Guest");
            } else if (snapshot.hasData && snapshot.data != null) {
              return Text("Welcome ${snapshot.data}");
            } else {
              return const Text("Welcome Guest");
            }
          },
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: listOfAllItemsInMarket,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            List<dynamic> items = snapshot.data!;

            if (items.isEmpty) {
              return const Center(child: Text("No items found."));
            }

            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final cartItemIndex =
                    cartItems.indexWhere((i) => i['id'] == item['id']);
                final quantityInCart = cartItemIndex >= 0
                    ? cartItems[cartItemIndex]['quantity']
                    : 0;

                return MarketCard(
                  item: item,
                  quantityInCart: quantityInCart,
                  onIncrement: () {
                    if (item['available_quantity'] > 0) {
                      _addToCart(item);
                    } else {
                      _showToast("No more items available.");
                    }
                  },
                  onDecrement: () {
                    if (quantityInCart > 0) {
                      _deleteFromCart(item);
                    } else {
                      _showToast("Item not in cart.");
                    }
                  },
                );
              },
            );
          } else {
            return const Center(child: Text("No items found."));
          }
        },
      ),
    );
  }
}
