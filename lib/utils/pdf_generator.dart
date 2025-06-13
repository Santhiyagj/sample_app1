import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import '../models/models.dart';

class PdfGenerator {
  static Future<Uint8List> generateBill(TableOrder order) async {
    final pdf = pw.Document();

    double total = order.items.fold(0, (sum, oi) => sum + oi.item.price * oi.quantity);

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Restaurant Bill',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 16),
            pw.Text('Table: ${order.tableNumber}'),
            pw.Text('Started: ${order.startTime}'),
            pw.Divider(),
            ...order.items.map(
              (oi) => pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('${oi.item.name} x${oi.quantity}'),
                  pw.Text('₹${oi.item.price * oi.quantity}'),
                ],
              ),
            ),
            pw.Divider(),
            pw.Text('Total: ₹$total', style: pw.TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );

    return pdf.save();
  }
}
