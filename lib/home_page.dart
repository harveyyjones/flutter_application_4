import 'package:flutter/material.dart';
import 'package:flutter_application_4/business_logic.dart/order_model.dart';
import 'package:flutter_application_4/order_detail_screen.dart';
import 'package:flutter_application_4/business_logic.dart/service_for_orders.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Order> _orders = [];
  bool _isLoading = true;
  String? _errorMessage;
  final OrderService _orderService = OrderService();

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final orders = await _orderService.fetchOrders();
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading orders: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Orders'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Orders'),
        ),
        body: Center(
          child: Text(_errorMessage!),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
      ),
      body: ListView.builder(
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text('Order #${order.id}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Created at: ${order.createdAt}'),
                  Text('Total Price: ${order.totalPrice}'),
                  Text('Items: ${order.cart.length}'),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderDetailsScreen(order: order),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
