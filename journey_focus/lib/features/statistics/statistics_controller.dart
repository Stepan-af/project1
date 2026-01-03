import 'package:flutter/material.dart';
import '../../services/statistics_service.dart';

/// Controller for statistics screen
class StatisticsController extends ChangeNotifier {
  final StatisticsService _statisticsService;

  SessionStatistics _statistics = SessionStatistics.empty;
  bool _isLoading = true;
  String? _error;

  StatisticsController({StatisticsService? statisticsService})
      : _statisticsService = statisticsService ?? StatisticsService();

  // ============================================
  // GETTERS
  // ============================================

  SessionStatistics get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ============================================
  // INITIALIZATION
  // ============================================

  Future<void> loadStatistics() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _statistics = await _statisticsService.getStatistics();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load statistics: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh statistics
  Future<void> refresh() => loadStatistics();
}
