import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sample_app/db/database_helper.dart';
import 'package:share_plus/share_plus.dart';

import '../models/models.dart';
import '../providers/table_provider.dart';
import '../utils/pdf_generator.dart';

final menu = [
  // Veg
  MenuItem(name: 'Paneer Butter Masala', price: 150, category: FoodCategory.veg),
  MenuItem(name: 'Veg Biryani', price: 120, category: FoodCategory.veg),
  MenuItem(name: 'Masala Dosa', price: 60, category: FoodCategory.veg),
  MenuItem(name: 'Gobi Manchurian', price: 90, category: FoodCategory.veg),
  MenuItem(name: 'Pasta', price: 100, category: FoodCategory.veg),

  // Non-Veg
  MenuItem(name: 'Chicken Biryani', price: 180, category: FoodCategory.nonVeg),
  MenuItem(name: 'Mutton Curry', price: 220, category: FoodCategory.nonVeg),
  MenuItem(name: 'Egg Fried Rice', price: 110, category: FoodCategory.nonVeg),
  MenuItem(name: 'Grilled Chicken', price: 200, category: FoodCategory.nonVeg),
  MenuItem(name: 'Fish Curry', price: 160, category: FoodCategory.nonVeg),
];

class OrderScreen extends ConsumerWidget {
  final int tableNumber;
  const OrderScreen({super.key, required this.tableNumber});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tables = ref.watch(tablesProvider);
    final table = tables.firstWhere((t) => t.tableNumber == tableNumber);
    final notifier = ref.read(tablesProvider.notifier);

    double total = table.items.fold(0, (sum, oi) => sum + oi.item.price * oi.quantity);

    return Scaffold(
      appBar: AppBar(
        title: Text('Table $tableNumber'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Menu items
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildCategorySection("🥬 Veg Items", Colors.green, menu.where((i) => i.category == FoodCategory.veg).toList(), tableNumber, notifier),
                  _buildCategorySection("🍗 Non-Veg Items", Colors.red, menu.where((i) => i.category == FoodCategory.nonVeg).toList(), tableNumber, notifier),
                ],
              ),
            ),
          ),
          const Divider(thickness: 1),
          // Current order summary
          Expanded(
            flex: 1,
            child: Card(
              margin: const EdgeInsets.all(12),
              elevation: 2,
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: table.items.length,
                separatorBuilder: (_, __) => const Divider(height: 10),
                itemBuilder: (context, index) {
                  final oi = table.items[index];
                  return ListTile(
  title: Text(oi.item.name),
  subtitle: Row(
    children: [
      IconButton(
        icon: const Icon(Icons.remove_circle_outline),
        onPressed: () => notifier.removeItem(tableNumber, oi.item),
      ),
      Text('Qty: ${oi.quantity}', style: const TextStyle(fontSize: 14)),
      IconButton(
        icon: const Icon(Icons.add_circle_outline),
        onPressed: () => notifier.addItem(tableNumber, oi.item),
      ),
    ],
  ),
  trailing: Text('₹${oi.item.price * oi.quantity}'),
);
                },
              ),
            ),
          ),
          // Total + Action buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
  color: Theme.of(context).scaffoldBackgroundColor,
  border: Border(
    top: BorderSide(color: Theme.of(context).dividerColor),
  ),
),
            child: Column(
              children: [
                Text('Total: ₹$total',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          notifier.requestBill(tableNumber);

                          final pdfData = await PdfGenerator.generateBill(table);
                          final dir = await getTemporaryDirectory();
                          final file = File('${dir.path}/bill_table$tableNumber.pdf');
                          await file.writeAsBytes(pdfData);

                          await Printing.layoutPdf(
                              onLayout: (PdfPageFormat format) async => pdfData);

                          await Share.shareXFiles([XFile(file.path)],
                              text: 'Bill for Table $tableNumber');
                        },
                        icon: const Icon(Icons.receipt),
                        label: const Text("Request Bill"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                       onPressed: () async {
  // Save each order item into SQLite
  final currentTable = ref.read(tablesProvider.notifier).getTable(tableNumber);

  for (var order in currentTable.items) {
    await DatabaseHelper.instance.insertOrder(
      currentTable.tableNumber,
      order.item.name,
      order.quantity,
      order.item.price,
      status: "completed",
    );
  }

  // Complete and go back
  ref.read(tablesProvider.notifier).completeOrder(tableNumber);
  Navigator.pop(context);
},

                        icon: const Icon(Icons.done),
                        label: const Text("Complete Order"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

 Widget _buildCategorySection(
  String title,
  Color iconColor,
  List<MenuItem> items,
  int tableNumber,
  TablesNotifier notifier,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: items.map((item) {
          return Card(
            elevation: 2,
            child: SizedBox(
              width: 160,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.circle, color: iconColor, size: 12),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.name,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('₹${item.price}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, size: 20),
                          onPressed: () => notifier.addItem(tableNumber, item),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ],
  );
}
}
