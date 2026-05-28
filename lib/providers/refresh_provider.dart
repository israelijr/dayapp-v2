import 'package:flutter/foundation.dart';

class RefreshProvider with ChangeNotifier {
  int _refreshCounter = 0;

  int get refreshCounter => _refreshCounter;

  void refresh() {
    _refreshCounter++;
    notifyListeners();
  }
}
