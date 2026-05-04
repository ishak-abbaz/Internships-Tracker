import 'package:flutter/material.dart';
import '../models/attendance_model.dart';
import '../services/attendance_service.dart';
import '../services/api_exception.dart';

class AttendanceNotifier extends ChangeNotifier {
  final AttendanceService _service = AttendanceService();

  List<AttendanceModel> _records = [];
  bool _isLoading = false;
  String? _error;

  List<AttendanceModel> get records => _records;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Map<String, dynamic>? _stats;
  Map<String, dynamic>? get stats => _stats;

  void clearStats() {
    _stats = null;
    notifyListeners();
  }

  Future<void> fetchAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _records = await _service.getAllAttendances();
      _stats = null; // Clear stats when viewing all
    } catch (e) {
      _error = 'Failed to load all attendances: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchStats(String internId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _stats = await _service.getAttendanceStats(internId);
    } catch (e) {
      _error = 'Failed to load stats: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchForDate(DateTime date) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final dateIso = date.toIso8601String().split('T')[0];
      _records = await _service.getAttendanceByDate(dateIso);
    } catch (e) {
      if (e is ApiException && e.statusCode == 404) {
        _records = [];
      } else {
        _error = 'Failed to load attendance for date: ${e.toString()}';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchForIntern(String internId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _records = await _service.getInternAttendances(internId);
    } catch (e) {
      if (e is ApiException && e.statusCode == 404) {
        _records = [];
      } else {
        _error = 'Failed to load attendance: ${e.toString()}';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createAttendance(AttendanceModel attendance) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final created = await _service.createAttendance(attendance);
      _records = [created, ..._records];
      return true;
    } catch (e) {
      _error = 'Failed to save attendance: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateAttendance({
    required String attendanceId,
    String? status,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _service.updateAttendance(
        attendanceId: attendanceId,
        status: status,
        notes: notes,
      );
      final index = _records.indexWhere((r) => r.id == attendanceId);
      if (index != -1) {
        _records[index] = updated;
      }
      return true;
    } catch (e) {
      _error = 'Failed to update attendance: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAttendance(String attendanceId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.deleteAttendance(attendanceId);
      _records.removeWhere((r) => r.id == attendanceId);
      return true;
    } catch (e) {
      _error = 'Failed to delete attendance: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
