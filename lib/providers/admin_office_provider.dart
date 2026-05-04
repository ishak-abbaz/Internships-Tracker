import 'package:flutter/foundation.dart';

import '../models/office_schedule_model.dart';
import '../models/policy_document_model.dart';
import '../services/admin_office_service.dart';
import '../services/api_exception.dart';

class AdminOfficeProvider extends ChangeNotifier {
  final AdminOfficeService _officeService;

  AdminOfficeProvider({AdminOfficeService? officeService})
      : _officeService = officeService ?? AdminOfficeService();

  List<PolicyDocumentModel> _policies = [];
  List<OfficeScheduleModel> _schedules = [];
  bool _isPoliciesLoading = false;
  bool _isSchedulesLoading = false;
  bool _isSubmitting = false;
  String? _error;

  List<PolicyDocumentModel> get policies => _policies;
  List<OfficeScheduleModel> get schedules => _schedules;
  bool get isPoliciesLoading => _isPoliciesLoading;
  bool get isSchedulesLoading => _isSchedulesLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;

  Future<void> loadPolicies() async {
    _isPoliciesLoading = true;
    _error = null;
    notifyListeners();

    try {
      _policies = await _officeService.fetchPolicies();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Unable to load policy handbooks.';
    } finally {
      _isPoliciesLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSchedules() async {
    _isSchedulesLoading = true;
    _error = null;
    notifyListeners();

    try {
      _schedules = await _officeService.fetchSchedules();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Unable to load schedules.';
    } finally {
      _isSchedulesLoading = false;
      notifyListeners();
    }
  }

  Future<OfficeScheduleModel?> getScheduleById(String id) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      return await _officeService.getScheduleById(id);
    } on ApiException catch (e) {
      _error = e.message;
      return null;
    } catch (_) {
      _error = 'Unable to fetch schedule details.';
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> uploadPolicy({
    required String title,
    required List<int> fileBytes,
    required String fileName,
    String? description,
    String? departmentCode,
    String? targetRole,
    int? version,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      final policy = await _officeService.uploadPolicy(
        title: title,
        fileBytes: fileBytes,
        fileName: fileName,
        description: description,
        departmentCode: departmentCode,
        targetRole: targetRole,
        version: version,
      );
      _policies = [policy, ..._policies.where((item) => item.id != policy.id)];
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'Unable to upload policy handbook.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> updatePolicy({
    required String id,
    String? title,
    String? description,
    String? departmentCode,
    String? targetRole,
    int? version,
    List<int>? fileBytes,
    String? fileName,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _officeService.updatePolicy(
        id: id,
        title: title,
        description: description,
        departmentCode: departmentCode,
        targetRole: targetRole,
        version: version,
        fileBytes: fileBytes,
        fileName: fileName,
      );
      _policies = _policies.map((item) => item.id == updated.id ? updated : item).toList();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'Unable to update policy handbook.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> deletePolicy(String id) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      await _officeService.deletePolicy(id);
      _policies = _policies.where((item) => item.id != id).toList();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'Unable to delete policy handbook.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> uploadSchedule({
    String? title,
    required List<int> fileBytes,
    required String fileName,
    String? description,
    String? departmentCode,
    int? version,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      final schedule = await _officeService.uploadSchedule(
        title: title,
        fileBytes: fileBytes,
        fileName: fileName,
        description: description,
        departmentCode: departmentCode,
        version: version,
      );
      _schedules = [schedule, ..._schedules.where((item) => item.id != schedule.id)];
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'Unable to upload schedule.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> updateSchedule({
    required String id,
    String? title,
    String? description,
    String? departmentCode,
    int? version,
    List<int>? fileBytes,
    String? fileName,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _officeService.updateSchedule(
        id: id,
        title: title,
        description: description,
        departmentCode: departmentCode,
        version: version,
        fileBytes: fileBytes,
        fileName: fileName,
      );

      _schedules = _schedules
          .map((item) => item.id == updated.id ? updated : item)
          .toList();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'Unable to update schedule.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> deleteSchedule(String id) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      await _officeService.deleteSchedule(id);
      _schedules = _schedules.where((item) => item.id != id).toList();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'Unable to delete schedule.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
