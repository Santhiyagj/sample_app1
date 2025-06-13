import 'package:flutter/material.dart';
import '../db/database_helper.dart';

class OrdersViewScreen extends StatefulWidget {
  const OrdersViewScreen({super.key});

  @override
  State<OrdersViewScreen> createState() => _OrdersViewScreenState();
}

class _OrdersViewScreenState extends State<OrdersViewScreen> {
  late Future<List<Map<String, dynamic>>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = DatabaseHelper.instance.fetchCompletedOrders();
  }

  void _refreshOrders() {
    setState(() {
      _ordersFuture = DatabaseHelper.instance.fetchCompletedOrders();
    });
  }

  void _confirmClearHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clear History"),
        content: const Text("Are you sure you want to delete all completed orders?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await DatabaseHelper.instance.clearOrders();
              _refreshOrders();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Order history cleared.")),
              );
            },
            child: const Text("Clear", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("🧾 Order History"),
        actions: [
          IconButton(
            onPressed: _confirmClearHistory,
            icon: const Icon(Icons.delete_outline),
            tooltip: "Clear History",
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "No completed orders found.",
                style: theme.textTheme.bodyLarge,
              ),
            );
          }

          final orders = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (_, index) {
              final order = orders[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primary,
                    child: Icon(Icons.restaurant, color: theme.colorScheme.onPrimary),
                  ),
                  title: Text(
                    order['itemName'] ?? '',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Table No: ${order['tableNumber']}', style: theme.textTheme.bodySmall),
                        Text('Quantity: ${order['quantity']}', style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  trailing: Text(
                    '₹${order['price']}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
