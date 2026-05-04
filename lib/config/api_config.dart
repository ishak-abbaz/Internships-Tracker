class ApiConfig {
  static const String baseUrl = 'https://internships-tracker.onrender.com/api/v1';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';

  // Admin
  static const String adminUsers = '/admin/users';
  static const String adminInterns = '/admin/interns';
  static String adminInternsById(String id) => '/admin/interns/$id';
  static String adminInternsByIdApprove(String id) => '/admin/interns/$id/approve';
  static String adminInternsByIdReject(String id) => '/admin/interns/$id/reject';
  static const String adminPendingInterns = '/admin/interns/pending';
  static const String adminMentors = '/admin/mentors';
  static String adminMentorsById(String id) => '/admin/mentors/$id';
  static const String adminDepartmentsList = '/admin/departments/getAlldep';
  static const String adminDepartmentsCreate = '/admin/departments/createdep';
  static String adminDepartmentById(String id) => '/admin/departments/$id';
  static String adminDepartmentsUpdate(String id) => '/admin/departments/updatedep/$id';
  static String adminDepartmentsDelete(String id) => '/admin/departments/delete/$id';
  static const String adminInternships = '/admin/internships';
  static String adminInternshipByInternId(String internId) => '/admin/internships/$internId';
  static String adminInternshipUpdate(String id) => '/admin/internships/update/$id';
  static String adminInternshipDelete(String id) => '/admin/internships/$id';

  // Admin Office (Policies & Schedules)
  static const String adminOfficePolicy = '/admin/office/policy/getall';
  static const String adminOfficePolicyCreate = '/admin/office/policy/create';
  static String adminOfficePolicyUpdate(String id) => '/admin/office/policy/update/$id';
  static String adminOfficePolicyDelete(String id) => '/admin/office/policy/delete/$id';

  static const String adminOfficeSchedule = '/admin/office/schedule/getall';
  static const String adminOfficeScheduleCreate = '/admin/office/schedule/create';
  static String adminOfficeScheduleUpdate(String id) => '/admin/office/schedule/update/$id';
  static String adminOfficeScheduleDelete(String id) => '/admin/office/schedule/delete/$id';

  // Mentor & Training Modules
  static const String mentorAttendance = '/mentors/attendance';
  static String mentorAttendanceById(String id) => '/mentors/attendance/id/$id';
  static String mentorAttendanceByDate(String date) => '/mentors/attendance/date/$date';
  static String mentorAttendanceByIntern(String id) => '/mentors/attendance/intern/$id';
  static String mentorAttendanceStats(String id) => '/mentors/attendance/stats/$id';
  static String mentorAttendanceUpdate(String id) => '/mentors/attendance/$id';
  static String mentorAttendanceDelete(String id) => '/mentors/attendance/$id';
  
  static const String trainingModules = '/mentors/training-modules';
  static String trainingModuleById(String id) => '/mentors/training-modules/$id';
  static String trainingModulesByDepartment(String code) => '/mentors/training-modules/department/$code';
  static String trainingModulesByMentor(String mentorId) => '/mentors/training-modules/mentor/$mentorId';

  // Evaluations & Assignments
  static const String evaluations = '/evaluations';

  // Intern
  static const String internAssignment = '/intern/assignment';
  static const String internSchedules = '/intern/schedules';
  static const String internTrainingModules = '/intern/training-modules';
  static const String internWorkId = '/intern/work-id';
  static const String internEvaluations = '/intern/evaluations';
}
