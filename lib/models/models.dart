enum FoodCategory { veg, nonVeg }
class MenuItem {
  final String name;
  final double price;
  final FoodCategory category;
  MenuItem({required this.name, required this.price,required this.category});
}

class OrderItem {
  final MenuItem item;
  final int quantity;
  final String? note;

  OrderItem({required this.item, required this.quantity, this.note});

  OrderItem copyWith({
    MenuItem? item,
    int? quantity,
    String? note,
  }) {
    return OrderItem(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
    );
  }
}
enum TableStatus { free, occupied, requestingBill }

class TableOrder {
  final int tableNumber;
  final TableStatus status;
  final List<OrderItem> items;
  final DateTime? startTime;
  final bool completed;

  TableOrder({
    required this.tableNumber,
    this.status = TableStatus.free,
    this.items = const [],
    this.startTime,
    this.completed = false,
  });

  TableOrder copyWith({
    int? tableNumber,
    TableStatus? status,
    List<OrderItem>? items,
    DateTime? startTime,
    bool? completed,
  }) {
    return TableOrder(
      tableNumber: tableNumber ?? this.tableNumber,
      status: status ?? this.status,
      items: items ?? this.items,
      startTime: startTime ?? this.startTime,
      completed: completed ?? this.completed,
    );
  }
}


// providers.dart
