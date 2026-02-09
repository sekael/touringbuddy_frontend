import 'package:flutter/material.dart';

class ErrorSnackbar {
  final String message;

  const ErrorSnackbar({required this.message});

  SnackBar build() {
    return SnackBar(content: Text(message), backgroundColor: Colors.red[300]);
  }
}
