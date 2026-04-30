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
