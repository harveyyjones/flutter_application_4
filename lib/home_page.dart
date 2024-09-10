import 'package:flutter/material.dart';
import 'package:flutter_application_4/business_logic.dart/models/order_model.dart';
import 'package:flutter_application_4/business_logic.dart/services/service_for_orders.dart';
import 'package:flutter_application_4/order_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Order> _orders = [];
  List<Order> _filteredOrders = [];
  bool _isLoading = true;
  String? _errorMessage;
  final OrderService _orderService = OrderService();

  int? _selectedOrderStatus;
  int? _selectedPaymentStatus;

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
        _filteredOrders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading orders: $e';
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredOrders = _orders.where((order) {
        bool matchesOrderStatus = _selectedOrderStatus == null || order.sipDurum == _selectedOrderStatus;
        bool matchesPaymentStatus = _selectedPaymentStatus == null || order.odemDurum == _selectedPaymentStatus;
        return matchesOrderStatus && matchesPaymentStatus;
      }).toList();
    });
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<int>(
                        value: _selectedOrderStatus,
                        hint: Text('Order Status'),
                        isExpanded: true,
                        onChanged: (value) {
                          setState(() {
                            _selectedOrderStatus = value;
                          });
                        },
                        items: [
                          DropdownMenuItem<int>(child: Text('All'), value: null),
                          DropdownMenuItem<int>(child: Text('Onay Bekliyor'), value: 0),
                          DropdownMenuItem<int>(child: Text('Siparişi Hazırlayınız'), value: 1),
                          DropdownMenuItem<int>(child: Text('Depoda Hazırlanıyor'), value: 2),
                          DropdownMenuItem<int>(child: Text('Tamamlandı'), value: 3),
                          DropdownMenuItem<int>(child: Text('Iptal Edildi'), value: 4),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<int>(
                        value: _selectedPaymentStatus,
                        hint: Text('Payment Status'),
                        isExpanded: true,
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentStatus = value;
                          });
                        },
                        items: [
                          DropdownMenuItem<int>(child: Text('All'), value: null),
                          DropdownMenuItem<int>(child: Text('Bekliyor'), value: 0),
                          DropdownMenuItem<int>(child: Text('Ödendi'), value: 1),
                          DropdownMenuItem<int>(child: Text('Tamamlandı'), value: 2),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _applyFilters,
                  child: Text('Apply Filters'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredOrders.length,
              itemBuilder: (context, index) {
                final order = _filteredOrders[index];
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
                        Text('Odeme durumu: ${verbaliseOdemeDurumu(order.odemDurum)}'),
                        Text('Order User ${order.orderUser}'),
                        Text('Siparis Durumu ${verbaliseStatus(order.sipDurum)}'),
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
          ),
        ],
      ),
    );
  }
}

String verbaliseStatus(int status) {
  switch (status) {
    case 0:
      return 'Onay Bekliyor';
    case 1:
      return 'Siparişi Hazırlayınız';
    case 2:
      return 'Depoda Hazırlanıyor';
    case 3:
      return 'Tamamlandı';
    case 4:
      return 'Iptal Edildi';
    default:
      return 'Bilinmeyen Durum';
  }
}

String verbaliseOdemeDurumu(int status) {
  switch (status) {
    case 0:
      return 'Bekliyor';
    case 1:
      return 'Ödendi';
    case 2:
      return 'Tamamlandı';
    default:
      return 'Bilinmeyen Durum';
  }
}