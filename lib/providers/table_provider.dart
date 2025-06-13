
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_app/models/models.dart';
import '../db/database_helper.dart';

final tablesProvider = StateNotifierProvider<TablesNotifier, List<TableOrder>>((ref) {
  return TablesNotifier();
});

class TablesNotifier extends StateNotifier<List<TableOrder>> {
  TablesNotifier() : super([]) {
    _loadFromDatabase();
  }

  Future<void> _loadFromDatabase() async {
    final data = await DatabaseHelper.instance.fetchAllTableStatuses();
    final loadedTables = List.generate(10, (index) {
      final dbEntry = data.firstWhere(
        (e) => e['table_number'] == index + 1,
        orElse: () => {'status': 'free'},
      );
      return TableOrder(
        tableNumber: index + 1,
        status: TableStatus.values.firstWhere(
          (s) => s.name == dbEntry['status'],
          orElse: () => TableStatus.free,
        ),
        items: [],
      );
    });
    state = loadedTables;
  }

  void _updateStatus(int tableNumber, TableStatus status) async {
    final updatedTables = [...state];
    final index = updatedTables.indexWhere((t) => t.tableNumber == tableNumber);
    if (index != -1) {
      final updatedTable = updatedTables[index].copyWith(status: status);
      updatedTables[index] = updatedTable;
      state = updatedTables;
      await DatabaseHelper.instance.saveTableStatus(tableNumber, status.name);
    }
  }

  void addItem(int tableNumber, MenuItem item) async {
    final updatedTables = [...state];
    final index = updatedTables.indexWhere((t) => t.tableNumber == tableNumber);
    if (index != -1) {
      final table = updatedTables[index];
      final existingIndex = table.items.indexWhere((oi) => oi.item.name == item.name);
      List<OrderItem> newItems = List.from(table.items);

      if (existingIndex != -1) {
        newItems[existingIndex] =
            newItems[existingIndex].copyWith(quantity: newItems[existingIndex].quantity + 1);
      } else {
        newItems.add(OrderItem(item: item, quantity: 1));
      }

      final updatedTable = table.copyWith(items: newItems, status: TableStatus.occupied);
      updatedTables[index] = updatedTable;
      state = updatedTables;

      await DatabaseHelper.instance.saveTableStatus(tableNumber, TableStatus.occupied.name);
    }
  }

  void removeItem(int tableNumber, MenuItem item) async {
    final updatedTables = [...state];
    final index = updatedTables.indexWhere((t) => t.tableNumber == tableNumber);
    if (index != -1) {
      final table = updatedTables[index];
      final existingIndex = table.items.indexWhere((oi) => oi.item.name == item.name);
      List<OrderItem> newItems = List.from(table.items);

      if (existingIndex != -1) {
        if (newItems[existingIndex].quantity > 1) {
          newItems[existingIndex] =
              newItems[existingIndex].copyWith(quantity: newItems[existingIndex].quantity - 1);
        } else {
          newItems.removeAt(existingIndex);
        }
      }

      final newStatus = newItems.isEmpty ? TableStatus.free : table.status;
      final updatedTable = table.copyWith(items: newItems, status: newStatus);
      updatedTables[index] = updatedTable;
      state = updatedTables;

      await DatabaseHelper.instance.saveTableStatus(tableNumber, newStatus.name);
    }
  }

  void requestBill(int tableNumber) => _updateStatus(tableNumber, TableStatus.requestingBill);
  void completeOrder(int tableNumber) => _updateStatus(tableNumber, TableStatus.free);

  TableOrder getTable(int tableNumber) =>
      state.firstWhere((t) => t.tableNumber == tableNumber);
}
