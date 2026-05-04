class ApiConfig {
  static const String baseUrl = 'https://internships-tracker.onrender.com/api/v1';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';

  // Admin
  static const String adminInterns = '/admin/interns';
  static const String adminPendingInterns = '/admin/interns/pending';
  static const String adminMentors = '/admin/mentors';
  static const String adminDepartmentsList = '/admin/departments/getAlldep';
  static const String adminDepartmentsCreate = '/admin/departments/createdep';
  static String adminDepartmentById(String id) => '/admin/departments/$id';
  static String adminDepartmentsUpdate(String id) => '/admin/departments/updatedep/$id';
  static String adminDepartmentsDelete(String id) => '/admin/departments/delete/$id';
  static const String adminInternships = '/admin/internships';
  static const String adminOfficePoliciesCreate = '/admin/office/policy/create';
  static const String adminOfficePoliciesList = '/admin/office/policy/getall';
  static String adminOfficePoliciesUpdate(String id) => '/admin/office/policy/update/$id';
  static String adminOfficePoliciesDelete(String id) => '/admin/office/policy/delete/$id';
  static const String adminOfficeSchedulesCreate = '/admin/office/schedule/create';
  static const String adminOfficeSchedulesList = '/admin/office/schedule/getall';
  static String adminOfficeScheduleById(String id) => '/admin/office/schedule/$id';
  static String adminOfficeSchedulesUpdate(String id) => '/admin/office/schedule/update/$id';
  static String adminOfficeSchedulesDelete(String id) => '/admin/office/schedule/delete/$id';

  // Mentor
  static const String mentorAttendance = '/mentors/attendance';
  static const String mentorTrainingModules = '/mentors/training-modules';

  // Intern
  static const String internAssignment = '/intern/assignment';
  static const String internSchedules = '/intern/schedules';
  static const String internTrainingModules = '/intern/training-modules';
  static String internTrainingModuleDownload(String moduleId) => '/intern/training-modules/$moduleId/download';
  static const String internWorkId = '/intern/work-id';
  static const String internWorkIdPhoto = '/intern/work-id/photo';
  static const String internEvaluations = '/intern/evaluations';
  static const String internProfile = '/intern/profile';
}
