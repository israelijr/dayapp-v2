import 'package:flutter/material.dart';

class ChapterFilterProvider with ChangeNotifier {
  String _sortOrder = 'date'; // 'date' ou 'title'
  int? _itemLimit; // null significa "Ver todos"

  String get sortOrder => _sortOrder;
  int? get itemLimit => _itemLimit;

  void setSortOrder(String order) {
    if (_sortOrder != order) {
      _sortOrder = order;
      notifyListeners();
    }
  }

  void setItemLimit(int? limit) {
    if (_itemLimit != limit) {
      _itemLimit = limit;
      notifyListeners();
    }
  }
}
