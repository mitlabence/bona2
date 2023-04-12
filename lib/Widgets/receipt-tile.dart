import 'package:flutter/material.dart';

class ReceiptTile extends StatelessWidget {
  /// Shows a tile (for a ListView) of a Receipt object.
  /// onTap activity brings up a new view, the ListView of the
  /// ReceiptItems making up that Receipt.

  final String title;
  final String subtitle;
  final VoidCallback onTapCallback;
  const ReceiptTile({Key? key, required this.title, required this.subtitle, required this.onTapCallback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: () => onTapCallback(), // TODO: navigate to ReceiptItem ListView
    );
  }
}
