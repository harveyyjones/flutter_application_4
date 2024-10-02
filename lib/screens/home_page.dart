import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_4/business_logic.dart/models/order_model.dart';
import 'package:flutter_application_4/business_logic.dart/services/service_for_orders.dart';
import 'package:flutter_application_4/screens/order_detail_page.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Order> _orders = [];
  List<Order> _filteredOrders = [];
  bool _isLoading = true;
  String? _errorMessage;
  final OrderService _orderService = OrderService();

  
   final List<Widget> _pages= [const HomeScreen(),];

  int? _selectedOrderStatus;
  int? _selectedPaymentStatus;
  int _currentIndex = 0;

  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final orders = await _orderService.fetchOrders();
      print('Fetched ${orders.length} orders'); // Debug print
      setState(() {
        _orders = orders;
        _filteredOrders = orders;
        _isLoading = false;
      });
      print('Updated state with ${_filteredOrders.length} filtered orders'); // Debug print
    } catch (e) {
      print('Error loading orders: $e'); // Debug print
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
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Orders', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              _loadOrders();
              setState(() {
                
              });
            }, // Call the _loadOrders method to refresh
          ),
        ],
      ),
      body: _buildBody(),
      // bottomNavigationBar: buildBottomNavigationBar(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.tealAccent),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(_errorMessage!, style: const TextStyle(color: Colors.white)),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<int>(
                  value: _selectedOrderStatus,
                  hint: const Text('Order Status', style: TextStyle(color: Colors.white70)),
                  isExpanded: true,
                  dropdownColor: Colors.grey[850],
                  style: const TextStyle(color: Colors.white),
                  underline: Container(),
                  onChanged: (value) {
                    setState(() {
                      _selectedOrderStatus = value;
                    });
                  },
                  items: const [
                    DropdownMenuItem<int>(value: null, child: Text('All')),
                    DropdownMenuItem<int>(value: 0, child: Text('Onay Bekliyor')),
                    DropdownMenuItem<int>(value: 1, child: Text('Siparişi Hazırlayınız')),
                    DropdownMenuItem<int>(value: 2, child: Text('Depoda Hazırlanıyor')),
                    DropdownMenuItem<int>(value: 3, child: Text('Tamamlandı')),
                    DropdownMenuItem<int>(value: 4, child: Text('Iptal Edildi')),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<int>(
                  value: _selectedPaymentStatus,
                  hint: const Text('Payment Status', style: TextStyle(color: Colors.white70)),
                  isExpanded: true,
                  dropdownColor: Colors.grey[850],
                  style: const TextStyle(color: Colors.white),
                  underline: Container(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPaymentStatus = value;
                    });
                  },
                  items: const [
                    DropdownMenuItem<int>(value: null, child: Text('All')),
                    DropdownMenuItem<int>(value: 0, child: Text('All')),
                    DropdownMenuItem<int>(value: 1, child: Text('Ödendi')),
                    DropdownMenuItem<int>(value: 2, child: Text('Tamamlandı')),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black, backgroundColor: Colors.tealAccent,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Filtreyi Uygula', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
        Expanded(
          child: _filteredOrders.isEmpty
              ? const Center(child: Text('No orders found', style: TextStyle(color: Colors.white)))
              : ListView.builder(
                  itemCount: _filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = _filteredOrders[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: Colors.grey[850],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text('Order #${order.id}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text('Created at: ${order.createdAt}',
                                style: TextStyle(color: Colors.grey[400])),
                            // Text('Total Price: ${order.totalPrice}',
                            //     style: TextStyle(color: Colors.grey[400])),
                            Text('Items: ${order.cart.length}',
                                style: TextStyle(color: Colors.grey[400])),
                            Text('Payment Status: ${verbaliseOdemeDurumu(order.odemDurum)}',
                                style: TextStyle(color: Colors.grey[400])),
                            Text('Order User: ${order.orderUser}',
                                style: TextStyle(color: Colors.grey[400])),
                            Text('Order Status: ${verbaliseStatus(order.sipDurum)}',
                                style: TextStyle(color: Colors.grey[400])),
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
                        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.tealAccent),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[850],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => _pages[index]),
          );
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: Colors.tealAccent,
        unselectedItemColor: Colors.grey[400],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
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