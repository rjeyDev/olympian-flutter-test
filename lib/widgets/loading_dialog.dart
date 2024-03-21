import 'package:flutter/material.dart';

typedef CloseDialog = void Function();

CloseDialog showLoadingScreen({
  required BuildContext context,
}) {
  showDialog(
    barrierColor: Colors.black38,
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(
      child: CircularProgressIndicator(color: Colors.white,),
    ),
  );

  return () => Navigator.of(context).pop();
}