import 'package:flutter/material.dart';

import '../models/portfolio_model.dart';
import '../services/api_service.dart';

class PortfolioProvider extends ChangeNotifier {

  bool isLoading = false;

  PortfolioModel? portfolio;

  final ApiService apiService = ApiService();

  Future<void> generatePortfolio(
      String username
      ) async {

    isLoading = true;

    notifyListeners();

    try {

      final data = await apiService.generatePortfolio(username);

      portfolio = PortfolioModel.fromJson(data);

    } catch (e) {

      print(e);

    }

    isLoading = false;

    notifyListeners();
  }
}