import 'package:flutter/foundation.dart';

import '../models/intern_models.dart';
import '../services/api_exception.dart';
import '../services/intern_service.dart';

class InternProvider extends ChangeNotifier {
  final InternService _internService;

  InternProvider({InternService? internService}) : _internService = internService ?? InternService();

  InternAssignmentModel? _assignment;
  List<InternScheduleModel> _schedules = [];
  List<InternTrainingModuleModel> _trainingModules = [];
  InternWorkCardModel? _workCard;
  List<InternEvaluationModel> _evaluations = [];
  InternProfileModel? _profile;

  bool _isAssignmentLoading = false;
  bool _isSchedulesLoading = false;
  bool _isTrainingModulesLoading = false;
  bool _isWorkCardLoading = false;
  bool _isEvaluationsLoading = false;
  bool _isUploadingWorkIdPhoto = false;
  bool _isProfileLoading = false;

  String? _assignmentError;
  String? _schedulesError;
  String? _trainingModulesError;
  String? _workCardError;
  String? _evaluationsError;
  String? _uploadWorkIdPhotoError;
  String? _profileError;

  InternAssignmentModel? get assignment => _assignment;
  List<InternScheduleModel> get schedules => _schedules;
  List<InternTrainingModuleModel> get trainingModules => _trainingModules;
  InternWorkCardModel? get workCard => _workCard;
  List<InternEvaluationModel> get evaluations => _evaluations;
  InternProfileModel? get profile => _profile;

  bool get isAssignmentLoading => _isAssignmentLoading;
  bool get isSchedulesLoading => _isSchedulesLoading;
  bool get isTrainingModulesLoading => _isTrainingModulesLoading;
  bool get isWorkCardLoading => _isWorkCardLoading;
  bool get isEvaluationsLoading => _isEvaluationsLoading;
  bool get isUploadingWorkIdPhoto => _isUploadingWorkIdPhoto;
  bool get isProfileLoading => _isProfileLoading;

  String? get assignmentError => _assignmentError;
  String? get schedulesError => _schedulesError;
  String? get trainingModulesError => _trainingModulesError;
  String? get workCardError => _workCardError;
  String? get evaluationsError => _evaluationsError;
  String? get uploadWorkIdPhotoError => _uploadWorkIdPhotoError;
  String? get profileError => _profileError;

  bool get hasAnyError =>
      _assignmentError != null ||
      _schedulesError != null ||
      _trainingModulesError != null ||
      _workCardError != null ||
      _evaluationsError != null ||
      _profileError != null;

  Future<void> loadDashboardData() async {
    await Future.wait([
      loadAssignment(),
      loadSchedules(),
      loadTrainingModules(),
      loadWorkCard(),
      loadEvaluations(),
      loadProfile(),
    ]);
  }

  Future<void> loadAssignment() async {
    _isAssignmentLoading = true;
    _assignmentError = null;
    notifyListeners();

    try {
      _assignment = await _internService.fetchAssignment();
    } on ApiException catch (e) {
      _assignmentError = e.message;
    } catch (_) {
      _assignmentError = 'Unable to load internship assignment.';
    } finally {
      _isAssignmentLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSchedules() async {
    _isSchedulesLoading = true;
    _schedulesError = null;
    notifyListeners();

    try {
      _schedules = await _internService.fetchSchedules();
    } on ApiException catch (e) {
      _schedulesError = e.message;
    } catch (_) {
      _schedulesError = 'Unable to load schedules.';
    } finally {
      _isSchedulesLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTrainingModules() async {
    _isTrainingModulesLoading = true;
    _trainingModulesError = null;
    notifyListeners();

    try {
      _trainingModules = await _internService.fetchTrainingModules();
    } on ApiException catch (e) {
      _trainingModulesError = e.message;
    } catch (_) {
      _trainingModulesError = 'Unable to load training modules.';
    } finally {
      _isTrainingModulesLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadWorkCard() async {
    _isWorkCardLoading = true;
    _workCardError = null;
    notifyListeners();

    try {
      _workCard = await _internService.fetchWorkCard();
    } on ApiException catch (e) {
      _workCardError = e.message;
    } catch (_) {
      _workCardError = 'Unable to load work ID details.';
    } finally {
      _isWorkCardLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadEvaluations() async {
    _isEvaluationsLoading = true;
    _evaluationsError = null;
    notifyListeners();

    try {
      _evaluations = await _internService.fetchEvaluations();
    } on ApiException catch (e) {
      _evaluationsError = e.message;
    } catch (_) {
      _evaluationsError = 'Unable to load evaluations.';
    } finally {
      _isEvaluationsLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProfile() async {
    _isProfileLoading = true;
    _profileError = null;
    notifyListeners();

    try {
      _profile = await _internService.fetchProfile();
    } on ApiException catch (e) {
      _profileError = e.message;
    } catch (_) {
      _profileError = 'Unable to load profile details.';
    } finally {
      _isProfileLoading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadWorkIdPhoto({
    required List<int> fileBytes,
    required String fileName,
  }) async {
    _isUploadingWorkIdPhoto = true;
    _uploadWorkIdPhotoError = null;
    notifyListeners();

    try {
      final uploadedUrl = await _internService.uploadWorkIdPhoto(
        fileBytes: fileBytes,
        fileName: fileName,
      );

      final currentWorkCard = _workCard;
      if (currentWorkCard != null) {
        _workCard = currentWorkCard.copyWith(
          idPhotoUrl: uploadedUrl,
          profile: currentWorkCard.profile.copyWith(idPhotoUrl: uploadedUrl),
        );
      } else {
        await loadWorkCard();
        if (_workCard != null) {
          _workCard = _workCard!.copyWith(
            idPhotoUrl: uploadedUrl,
            profile: _workCard!.profile.copyWith(idPhotoUrl: uploadedUrl),
          );
        }
      }

      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _uploadWorkIdPhotoError = e.message;
      return false;
    } catch (_) {
      _uploadWorkIdPhotoError = 'Unable to upload work ID photo.';
      return false;
    } finally {
      _isUploadingWorkIdPhoto = false;
      notifyListeners();
    }
  }

  void clearErrors() {
    _assignmentError = null;
    _schedulesError = null;
    _trainingModulesError = null;
    _workCardError = null;
    _evaluationsError = null;
    _uploadWorkIdPhotoError = null;
    _profileError = null;
    notifyListeners();
  }
}