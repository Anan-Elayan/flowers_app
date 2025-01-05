import 'dart:convert';

import 'package:badges/badges.dart' as badges;
import 'package:flowers_app/components/offers.dart';
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
    setState(() {
      final cartItemIndex =
          cartItems.indexWhere((cartItem) => cartItem['id'] == item['id']);
      if (cartItemIndex >= 0) {
        if (cartItems[cartItemIndex]['quantity'] > 1) {
          cartItems[cartItemIndex]['quantity'] -= 1;
        } else {
          cartItems.removeAt(cartItemIndex);
        }
      }
    });
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
          badges.Badge(
            position: badges.BadgePosition.topEnd(top: 0, end: 3),
            badgeContent: Text(
              '${cartItems.fold<int>(0, (sum, item) => sum + item['quantity'] as int)}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            badgeStyle: badges.BadgeStyle(
              badgeColor: Colors.red,
              padding: const EdgeInsets.all(6),
            ),
            child: IconButton(
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
          ),
        ],
        leading: IconButton(
          onPressed: () async {
            final confirmLogout = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: const Row(
                    children: [
                      Icon(
                        Icons.logout,
                        color: Colors.redAccent,
                        size: 28, // Logout icon
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Confirm Logout",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  content: const Text(
                    "Are you sure you want to log out?",
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  actionsPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  actions: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        backgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      child: const Text("Logout"),
                    ),
                  ],
                );
              },
            );
            if (confirmLogout == true) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            }
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
      body: Column(
        children: [
          const Offers(),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
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
          ),
        ],
      ),
    );
  }
}
