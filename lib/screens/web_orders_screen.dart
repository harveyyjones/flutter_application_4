import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_4/business_logic.dart/models%20web/orders_model_web.dart';
import 'package:flutter_application_4/business_logic.dart/services%20for%20web/web_order_service.dart';
import 'package:flutter_application_4/screens/web_order_details_details_screen.dart';

class BaselinkerPage extends StatefulWidget {
  const BaselinkerPage({super.key});

  @override
  _BaselinkerPageState createState() => _BaselinkerPageState();
}

class _BaselinkerPageState extends State<BaselinkerPage> {
  List<WebOrder> _orders = []; // Changed type to BaselinkerOrder
  List<WebOrder> _filteredOrders = []; // Changed type to BaselinkerOrder
  bool _isLoading = true;
  String? _errorMessage;
  final WebOrderService _orderService = WebOrderService();
  final Map<String, int> _productCounts = {}; // New field for product counts
  List<WebOrderBasketItemForOrders> _products = [];

  //  final List<Widget> _pages= [const HomeScreen(),];

  int? _selectedOrderStatus;
  String? _selectedPaymentStatus; // Changed to String to match payment_id

  late Timer _timer; // Keep this if you plan to use it

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _timer = Timer.periodic(Duration(seconds: 100), (timer) {
      _loadOrders(); // Example usage of the timer
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Ensure this is called only if _timer is initialized
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final orders =
          await _orderService.fetchOrders(); // Removed cast to List<Order>
      print('Fetched ${orders.length} orders'); // Debug print

      setState(() {
        _orders = orders;
        _filteredOrders = orders;
        _isLoading = false;
      });
      print(
          'Updated state with ${_filteredOrders.length} filtered orders'); // Debug print
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
        bool matchesOrderStatus = _selectedOrderStatus == null ||
            order.orderStatus == _selectedOrderStatus;
        bool matchesPaymentStatus = _selectedPaymentStatus == null ||
            order.paymentId == _selectedPaymentStatus;
        return matchesOrderStatus && matchesPaymentStatus;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Web Toptan Siparişleri',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              _loadOrders();
              setState(() {});
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
        child:
            Text(_errorMessage!, style: const TextStyle(color: Colors.white)),
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
                  hint: const Text('Order Status',
                      style: TextStyle(color: Colors.white70)),
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
                    DropdownMenuItem<int>(
                        value: 0, child: Text('Onay Bekliyor')),
                    DropdownMenuItem<int>(
                        value: 1, child: Text('Siparişi Hazırlayınız')),
                    DropdownMenuItem<int>(
                        value: 2, child: Text('Kargoya Verilecek')),
                    DropdownMenuItem<int>(
                        value: 3, child: Text('Kargoya Verildi')),
                    DropdownMenuItem<int>(value: 4, child: Text('Tamamlandı')),
                    DropdownMenuItem<int>(
                        value: 5, child: Text('Müşteri Alacak')),
                    DropdownMenuItem<int>(
                        value: 6, child: Text('Müşteri Teslim Aldı')),
                    DropdownMenuItem<int>(
                        value: 7, child: Text('Ödeme Bekleniyor')),
                    DropdownMenuItem<int>(
                        value: -1, child: Text('Sipariş Iptal')),
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
                child: DropdownButton<String>(
                  value: _selectedPaymentStatus,
                  hint: const Text('Payment Status',
                      style: TextStyle(color: Colors.white70)),
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
                    DropdownMenuItem<String>(value: null, child: Text('All')),
                    DropdownMenuItem<String>(
                        value: "Kapıda Ödeme", child: Text('Kapıda Ödeme')),
                    DropdownMenuItem<String>(
                        value: "Banka Transferi",
                        child: Text('Banka Transferi')),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.tealAccent,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Filtreyi Uygula',
                    style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
        Expanded(
          child: _filteredOrders.isEmpty
              ? const Center(
                  child: Text('No orders found',
                      style: TextStyle(color: Colors.white)))
              : ListView.builder(
                  itemCount: _filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = _filteredOrders[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      color: Colors.grey[850],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text('Order #${order.id}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text('Created at: ${order.createdAt}',
                                style: TextStyle(color: Colors.grey[400])),
                            Text('Items: ${order.baskets.length}',
                                style: TextStyle(color: Colors.grey[400])),
                            Text(
                                'Siparis durumu: ${verbaliseStatus(order.orderStatus)}',
                                style: TextStyle(color: Colors.grey[400])),
                            Text('Odeme durumu: ${order.paymentId}',
                                style: TextStyle(color: Colors.grey[400])),
                            Text(
                                'USTLENEN DEPO SORUMLUSU: ${verbaliseDepoSorumlusu(order.depoUserId)}',
                                style: TextStyle(color: Colors.grey[400])),
                            Text(
                                'Bu siparis ${getTimeAgo(order.updatedAt.toString().toLowerCase())} guncellendi.',
                                style: TextStyle(color: Colors.grey[400])),
                            // Add more fields as needed
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  WebOrderDetailsScreen(order: order),
                            ),
                          );
                        },
                        trailing: const Icon(Icons.arrow_forward_ios,
                            color: Colors.tealAccent),
                      ),
                    );
                  },
                ),
        ),
      ],
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
      return 'Kargoya Verilecek';
    case 3:
      return 'Kargoya Verildi';
    case 4:
      return 'Tamamlandı';
    case 5:
      return 'Müşteri Alacak';
    case 6:
      return 'Müşteri Teslim Aldı';
    case 7:
      return 'Ödeme Bekleniyor';
    case -1:
      return 'Sipariş Iptal';
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

String verbaliseDepoSorumlusu(int depoUserId) {
  switch (depoUserId) {
    case null:
      return 'Henuz kimse ustlenmedi.';
    case 1055:
      return 'Mehmet Ali';

    default:
      return 'Bilinmeyen Durum';
  }
}

String getTimeAgo(String timestamp) {
  try {
    final DateTime updateTime = DateTime.parse(timestamp);
    final Duration difference = DateTime.now().difference(updateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'yıl' : 'yıl'} önce';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'ay' : 'ay'} önce';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'gün' : 'gün'} önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'saat' : 'saat'} önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'dakika' : 'dakika'} önce';
    } else {
      return 'şimdi';
    }
  } catch (e) {
    return 'invalid date';
  }
}
