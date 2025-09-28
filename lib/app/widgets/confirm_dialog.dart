import 'package:flutter/material.dart';

Future<bool?> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String content,
}) async {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}
