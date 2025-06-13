
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
      );
    });
    state = loadedTables;
  }

  void _updateStatus(int tableNumber, TableStatus status) async {
    final updatedTables = [...state];
    final index = updatedTables.indexWhere((t) => t.tableNumber == tableNumber);
    if (index != -1) {
      updatedTables[index] = updatedTables[index].copyWith(status: status);
      state = updatedTables;
      await DatabaseHelper.instance.saveTableStatus(tableNumber, status.name);
    }
  }

  void requestBill(int tableNumber) => _updateStatus(tableNumber, TableStatus.requestingBill);
  void completeOrder(int tableNumber) => _updateStatus(tableNumber, TableStatus.free);

  TableOrder getTable(int tableNumber) =>
      state.firstWhere((t) => t.tableNumber == tableNumber);

  void addItem(int tableNumber, MenuItem item) {
    final updatedTables = [...state];
    final index = updatedTables.indexWhere((t) => t.tableNumber == tableNumber);
    if (index != -1) {
      final currentTable = updatedTables[index];
      final existingItemIndex = currentTable.items.indexWhere((i) => i.item.name == item.name);
      if (existingItemIndex != -1) {
        final updatedItems = [...currentTable.items];
        final existingItem = updatedItems[existingItemIndex];
        updatedItems[existingItemIndex] =
            OrderItem(item: item, quantity: existingItem.quantity + 1);
        updatedTables[index] = currentTable.copyWith(items: updatedItems);
      } else {
        updatedTables[index] = currentTable.copyWith(
          items: [...currentTable.items, OrderItem(item: item, quantity: 1)],
          status: TableStatus.occupied,
        );
      }
      state = updatedTables;
    }
  }

  void removeItem(int tableNumber, MenuItem item) {
    final updatedTables = [...state];
    final index = updatedTables.indexWhere((t) => t.tableNumber == tableNumber);
    if (index != -1) {
      final currentTable = updatedTables[index];
      final updatedItems = [...currentTable.items];
      final existingItemIndex = updatedItems.indexWhere((i) => i.item.name == item.name);

      if (existingItemIndex != -1) {
        final existingItem = updatedItems[existingItemIndex];
        if (existingItem.quantity > 1) {
          updatedItems[existingItemIndex] =
              OrderItem(item: item, quantity: existingItem.quantity - 1);
        } else {
          updatedItems.removeAt(existingItemIndex);
        }

        updatedTables[index] = currentTable.copyWith(
          items: updatedItems,
          status: updatedItems.isEmpty ? TableStatus.free : TableStatus.occupied,
        );
        state = updatedTables;
      }
    }
  }
}
