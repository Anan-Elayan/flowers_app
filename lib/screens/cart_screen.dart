import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../constants/constants.dart';

class CartPage extends StatefulWidget {
  final List<dynamic> cartItems;
  final Function onDeleteItem;
  final VoidCallback onPurchaseItems;

  const CartPage({
    super.key,
    required this.cartItems,
    required this.onDeleteItem,
    required this.onPurchaseItems,
  });

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  double _calculateTotalPrice() {
    return widget.cartItems.fold<double>(
      0.0,
      (sum, item) =>
          sum + (double.parse(item['price'].toString()) * item['quantity']),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cart"),
        backgroundColor: thirdColor,
      ),
      body: widget.cartItems.isEmpty
          ? const Center(
              child: Text("Your cart is empty."),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.cartItems.length,
                    itemBuilder: (context, index) {
                      final item = widget.cartItems[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              item['photo'] != null && item['photo'] != ""
                                  ? FileImage(File(item['photo']))
                                  : null,
                          backgroundColor: Colors.grey[200],
                        ),
                        title: Text(item['name']),
                        subtitle: Text(
                            "Price: \$${item['price']} x ${item['quantity']}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Total: \$${(double.parse(item['price'].toString()) * item['quantity']).toStringAsFixed(2)}",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  widget.onDeleteItem(item);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total Price: \$${_calculateTotalPrice().toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(thirdColor),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                            ),
                          ),
                        ),
                        onPressed: () {
                          if (widget.cartItems.isNotEmpty) {
                            widget.onPurchaseItems();
                            Navigator.pop(context);
                          } else {
                            Fluttertoast.showToast(
                              msg: "Your cart is empty.",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.black,
                              textColor: Colors.white,
                            );
                          }
                        },
                        child: const Text("Buy Now"),
                      )
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
