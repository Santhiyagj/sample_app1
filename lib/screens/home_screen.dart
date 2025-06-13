import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_app/models/models.dart';
import 'package:sample_app/providers/table_provider.dart';
import 'package:sample_app/providers/theme_provider.dart';
import 'package:sample_app/screens/order_screen.dart';
import 'package:sample_app/screens/order_view_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tables = ref.watch(tablesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Tables'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 111, 91, 149),
        actions: [
          IconButton(
            icon: Icon(
              theme.brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              final themeModeNotifier = ref.read(themeModeProvider.notifier);
              themeModeNotifier.state = theme.brightness == Brightness.dark
                  ? ThemeMode.light
                  : ThemeMode.dark;
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OrdersViewScreen()),
              );
            },
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
        ),
        itemCount: tables.length,
        itemBuilder: (context, index) {
          final table = tables[index];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OrderScreen(tableNumber: table.tableNumber),
              ),
            ),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: theme.cardColor,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.table_bar,
                      size: 36,
                      color: Colors.deepPurple,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Table ${table.tableNumber}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(table.status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        table.status.name.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
    );
  }

  Color _getStatusColor(TableStatus status) {
    switch (status) {
      case TableStatus.free:
        return Colors.green;
      case TableStatus.occupied:
        return Colors.orange;
      case TableStatus.requestingBill:
        return Colors.red;
    }
  }
}
