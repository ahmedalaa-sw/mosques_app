import 'package:flutter/material.dart';

void snackBarMessage({required context, required text}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}
