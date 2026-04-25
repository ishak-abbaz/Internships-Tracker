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

  // Mentor
  static const String mentorAttendance = '/mentors/attendance';
  static const String mentorTrainingModules = '/mentors/training-modules';

  // Intern
  static const String internAssignment = '/intern/assignment';
  static const String internSchedules = '/intern/schedules';
  static const String internTrainingModules = '/intern/training-modules';
  static const String internWorkId = '/intern/work-id';
  static const String internEvaluations = '/intern/evaluations';
}
