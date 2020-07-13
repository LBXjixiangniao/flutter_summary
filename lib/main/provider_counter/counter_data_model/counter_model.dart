import 'package:flutter/material.dart';

class CounterModel extends ChangeNotifier {
  int _countOne = 0;
  int get countOne => _countOne;
  int _countTwo = 0;
  int get countTwo => _countTwo;
  int _countThree = 0;
  int get countThree => _countThree;

  Future<bool> requestNetworkData() {
    return Future.delayed(Duration(seconds: 2), () {
      notifyListeners();
      return true;
    });
  }

  void addCountOne() {
    _countOne++;
    notifyListeners();
  }

  void deleteCountOne() {
    _countOne--;
    notifyListeners();
  }

  void addCountTwo() {
    _countTwo++;
    notifyListeners();
  }

  void deleteCountTwo() {
    _countTwo--;
    notifyListeners();
  }

  void addCountThree() {
    _countThree++;
    notifyListeners();
  }

  void deleteCountThree() {
    _countThree--;
    notifyListeners();
  }
}
