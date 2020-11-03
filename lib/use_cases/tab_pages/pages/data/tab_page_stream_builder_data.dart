import 'package:flutter/material.dart';

abstract class TabPageStreamBuilderData {
  Function(List<dynamic>) get filter;
  Widget get placeholder;
}
