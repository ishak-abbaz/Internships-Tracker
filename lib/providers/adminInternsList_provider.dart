import 'package:flutter/material.dart';
import '../models/department_model.dart';
import '../models/intern_model.dart';
import '../models/mentor_model.dart';
import '../services/adminInterns_service.dart';
import '../services/api_exception.dart';

class AdminInternsListNotifier extends ChangeNotifier {
  final AdminInternsService _service = AdminInternsService();

  List<InternModel> _interns = [];
  List<InternModel> _filteredInterns = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  // Caches for department and mentor data
  final Map<String, DepartmentModel> _departmentCache = {};
  final Map<String, MentorModel> _mentorCache = {};
  bool _loadingDepartment = false;
  bool _loadingMentor = false;

  // Getters
  List<InternModel> get interns => _filteredInterns.isEmpty && _searchQuery.isEmpty ? _interns : _filteredInterns;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalInterns => _interns.length;
  int get activeInterns => _interns.where((i) => i.account_status == 'approved').length;
  int get pendingInterns => _interns.where((i) => i.account_status == 'pending').length;
  int get unassignedInterns => _interns.where((i) => i.mentorId == null || i.mentorId!.isEmpty).length;
  bool get loadingDepartment => _loadingDepartment;
  bool get loadingMentor => _loadingMentor;

  Future<void> fetchInterns() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _interns = await _service.fetchInterns();
      _filteredInterns = _interns;
      print('✅ Successfully fetched ${_interns.length} interns');
    } catch (e) {
      if (e is ApiException && e.statusCode == 404) {
        _interns = [];
        _filteredInterns = [];
      } else {
        _error = 'Failed to load interns: ${e.toString()}';
      }
      print('❌ ERROR: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchInterns(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredInterns = _interns;
    } else {
      _filteredInterns = _interns
          .where((intern) =>
              intern.fullName.toLowerCase().contains(query.toLowerCase()) ||
              intern.email.toLowerCase().contains(query.toLowerCase()) ||
              intern.registrationNr.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  Future<bool> deleteIntern(String internId) async {
    try {
      await _service.deleteIntern(internId);
      _interns.removeWhere((i) => i.id == internId);
      _filteredInterns.removeWhere((i) => i.id == internId);
      print('✅ Intern deleted successfully');
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete intern: ${e.toString()}';
      print('❌ ERROR: $_error');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateIntern(String internId, Map<String, dynamic> updateData) async {
    try {
      final updatedIntern = await _service.updateIntern(internId, updateData);
      final index = _interns.indexWhere((i) => i.id == internId);
      if (index != -1) {
        _interns[index] = updatedIntern;
        final filteredIndex = _filteredInterns.indexWhere((i) => i.id == internId);
        if (filteredIndex != -1) {
          _filteredInterns[filteredIndex] = updatedIntern;
        }
      }
      print('✅ Intern updated successfully');
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update intern: ${e.toString()}';
      print('❌ ERROR: $_error');
      notifyListeners();
      return false;
    }
  }

  Future<bool> approveIntern(String internId) async {
    try {
      await _service.approveIntern(internId);
      final index = _interns.indexWhere((i) => i.id == internId);
      if (index != -1) {
        final updated = InternModel(
          id: _interns[index].id,
          fullName: _interns[index].fullName,
          email: _interns[index].email,
          registrationNr: _interns[index].registrationNr,
          department: _interns[index].department,
          departmentId: _interns[index].departmentId,
          mentor: _interns[index].mentor,
          mentorId: _interns[index].mentorId,
          account_status: 'approved',
          userRole: _interns[index].userRole,
        );
        _interns[index] = updated;
        final filteredIndex = _filteredInterns.indexWhere((i) => i.id == internId);
        if (filteredIndex != -1) {
          _filteredInterns[filteredIndex] = updated;
        }
      }
      print('✅ Intern approved successfully');
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to approve intern: ${e.toString()}';
      print('❌ ERROR: $_error');
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectIntern(String internId) async {
    try {
      await _service.rejectIntern(internId);
      final index = _interns.indexWhere((i) => i.id == internId);
      if (index != -1) {
        final updated = InternModel(
          id: _interns[index].id,
          fullName: _interns[index].fullName,
          email: _interns[index].email,
          registrationNr: _interns[index].registrationNr,
          department: _interns[index].department,
          departmentId: _interns[index].departmentId,
          mentor: _interns[index].mentor,
          mentorId: _interns[index].mentorId,
          account_status: 'rejected',
          userRole: _interns[index].userRole,
        );
        _interns[index] = updated;
        final filteredIndex = _filteredInterns.indexWhere((i) => i.id == internId);
        if (filteredIndex != -1) {
          _filteredInterns[filteredIndex] = updated;
        }
      }
      print('✅ Intern rejected successfully');
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to reject intern: ${e.toString()}';
      print('❌ ERROR: $_error');
      notifyListeners();
      return false;
    }
  }

  List<InternModel> _pendingInterns = [];
  bool _pendingLoading = false;

  List<InternModel> get pendingInternsList => _pendingInterns;
  bool get pendingLoading => _pendingLoading;

  Future<void> fetchPendingInterns() async {
    _pendingLoading = true;
    _error = null;
    notifyListeners();

    try {
      _pendingInterns = await _service.fetchPendingInterns();
      print('✅ Successfully fetched ${_pendingInterns.length} pending interns');
    } catch (e) {
      if (e is ApiException && e.statusCode == 404) {
        _pendingInterns = [];
      } else {
        _error = 'Failed to load pending interns: ${e.toString()}';
      }
      print('❌ ERROR: $_error');
    } finally {
      _pendingLoading = false;
      notifyListeners();
    }
  }

  void resetState() {
    _interns = [];
    _filteredInterns = [];
    _isLoading = false;
    _error = null;
    _searchQuery = '';
    notifyListeners();
  }

  Future<DepartmentModel?> fetchDepartmentById(String departmentId) async {
    // Check cache first
    if (_departmentCache.containsKey(departmentId)) {
      return _departmentCache[departmentId];
    }

    _loadingDepartment = true;
    notifyListeners();

    try {
      final department = await _service.fetchDepartmentById(departmentId);
      _departmentCache[departmentId] = department;
      _loadingDepartment = false;
      notifyListeners();
      return department;
    } catch (e) {
      print('❌ ERROR fetching department: $e');
      _loadingDepartment = false;
      notifyListeners();
      return null;
    }
  }

  Future<MentorModel?> fetchMentorById(String mentorId) async {
    // Check cache first
    if (_mentorCache.containsKey(mentorId)) {
      return _mentorCache[mentorId];
    }

    _loadingMentor = true;
    notifyListeners();

    try {
      final mentor = await _service.fetchMentorById(mentorId);
      _mentorCache[mentorId] = mentor;
      _loadingMentor = false;
      notifyListeners();
      return mentor;
    } catch (e) {
      print('❌ ERROR fetching mentor: $e');
      _loadingMentor = false;
      notifyListeners();
      return null;
    }
  }
}
