import 'DataStructures/receipt_item.dart';
import 'DataStructures/receipt.dart';

class ReceiptReader {
  /// Interface for reading out json files from various sources that contain
  /// receipt data. For an implementation, see the TaggunReader class
  late Receipt receipt;
  late List<ReceiptItem> receiptItems;

  ReceiptReader({required Map<String, dynamic> json});
}
