# Internships Tracker Backend API Documentation

Last updated: 2026-04-18

Base URL (production):

https://internships-tracker.onrender.com

API prefix:

/api/v1

-------------------------------------------------------------------------------

## 1. Authentication and Authorization

### Login

- Endpoint URL: https://internships-tracker.onrender.com/api/v1/auth/login
- Method: POST
- Auth required: No
- Request headers:
	- Content-Type: application/json
- Request body example:

```json
{
	"email": "admin@example.com",
	"password": "StrongPass123"
}
```

- Success response (200):

```json
{
	"msg": "Login successful",
	"accessToken": "<JWT_TOKEN>",
	"user": {
		"id": "681f1ef2f03c6be17a6bd001",
		"full_name": "Admin User",
		"email": "admin@example.com",
		"user_role": "Admin"
	}
}
```

- JWT token location in response: accessToken
- Token validity duration: 1 day (expiresIn = "1d")
- Header format for protected routes:

Authorization: Bearer <token>

- Refresh token required: No (not implemented)
- Refresh endpoint: Not available
- Logout endpoint: Not available

### Register

- Endpoint URL: https://internships-tracker.onrender.com/api/v1/auth/register
- Method: POST
- Auth required: No
- Request headers:
	- Content-Type: application/json
- Request body example:

```json
{
	"full_name": "New Student",
	"email": "student@example.com",
	"password": "StrongPass123",
	"passwordConfirm": "StrongPass123"
}
```

- Success response (201):

```json
{
	"msg": "User created successfully.",
	"user": {
		"id": "681f1ef2f03c6be17a6bd123",
		"full_name": "New Student",
		"email": "student@example.com"
	}
}
```

### Authorization Rules

- Middleware protect:
	- Requires Authorization header with Bearer token
	- Returns 401 if token is missing/invalid/expired
- Middleware restrictTo:
	- Enforces role-based access by user_role
	- Returns 403 for insufficient role

-------------------------------------------------------------------------------

## 2. Complete API Endpoints List

Notes:

- Full URL = Base URL + path below
- Auth column values:
	- No = public
	- Yes (Role) = token required and role checked

### 2.1 Health Endpoint

#### GET /

- Full URL: https://internships-tracker.onrender.com/
- Method: GET
- Auth required: No
- Request body: None
- Response 200:

```json
{
	"message": "API is running"
}
```

- Errors: 500 possible if server failure

### 2.2 Auth Endpoints

#### POST /api/v1/auth/login

- Full URL: https://internships-tracker.onrender.com/api/v1/auth/login
- Auth required: No
- Body:

```json
{
	"email": "admin@example.com",
	"password": "StrongPass123"
}
```

- Response 200: see Login section above
- Possible errors:
	- 400: Invalid email
	- 400: Invalid password
	- 500: Login failed

#### POST /api/v1/auth/register

- Full URL: https://internships-tracker.onrender.com/api/v1/auth/register
- Auth required: No
- Body:

```json
{
	"full_name": "New User",
	"email": "new@example.com",
	"password": "StrongPass123",
	"passwordConfirm": "StrongPass123"
}
```

- Response 201: see Register section above
- Possible errors:
	- 400: Invalid email
	- 400: Password too short
	- 400: Passwords do not match
	- 400: Email already exists
	- 500: Signup failed

### 2.3 Admin Endpoints

All endpoints in this group require:

- Auth required: Yes (Admin)

#### POST /api/v1/admin/users

- Full URL: https://internships-tracker.onrender.com/api/v1/admin/users
- Body example:

```json
{
	"full_name": "Mentor User",
	"email": "mentor@example.com",
	"password": "StrongPass123",
	"user_role": "Mentor",
	"department_id": "681f1ef2f03c6be17a6bd777",
	"specialization": "Backend"
}
```

- Response 201:

```json
{
	"success": true,
	"msg": "User created successfully. Verification email sent.",
	"data": {
		"id": "681f1ef2f03c6be17a6bd777",
		"full_name": "Mentor User",
		"email": "mentor@example.com",
		"user_role": "Mentor",
		"account_status": "approved",
		"is_email_verified": false,
		"created_at": "2026-04-18T10:00:00.000Z",
		"updated_at": "2026-04-18T10:00:00.000Z",
		"department_id": "681f1ef2f03c6be17a6bd999",
		"specialization": "Backend"
	}
}
```

- Errors: 400, 409, 500

#### GET /api/v1/admin/interns

- Query parameters:
	- page (default 1)
	- limit (default 10)
	- search (optional)
- Response 200:

```json
{
	"success": true,
	"msg": "Interns fetched successfully.",
	"data": [
		{
			"id": "681f1ef2f03c6be17a6bd123",
			"full_name": "Intern User",
			"email": "intern@example.com",
			"user_role": "Student",
			"account_status": "pending",
			"is_email_verified": false,
			"created_at": "2026-04-18T10:00:00.000Z",
			"updated_at": "2026-04-18T10:00:00.000Z",
			"university_id": null,
			"department_id": null,
			"mentor_id": null,
			"is_validated_by_admin": false,
			"work_id": null,
			"id_photo_url": null
		}
	],
	"pagination": {
		"total": 1,
		"page": 1,
		"limit": 10,
		"totalPages": 1
	}
}
```

- Errors: 500

#### GET /api/v1/admin/interns/pending

- Response 200:

```json
{
	"msg": "Pending registrations fetched successfully",
	"count": 2,
	"users": [
		{
			"_id": "681f1ef2f03c6be17a6bd123",
			"full_name": "Intern Pending",
			"email": "intern.pending@example.com",
			"user_role": "Student",
			"account_status": "pending",
			"created_at": "2026-04-18T10:00:00.000Z",
			"updated_at": "2026-04-18T10:00:00.000Z"
		}
	]
}
```

- Errors: 500

#### GET /api/v1/admin/interns/:internId

- Response 200:

```json
{
	"success": true,
	"msg": "Intern fetched successfully.",
	"data": {
		"id": "681f1ef2f03c6be17a6bd123",
		"full_name": "Intern User",
		"email": "intern@example.com",
		"user_role": "Student",
		"account_status": "approved",
		"is_email_verified": false,
		"created_at": "2026-04-18T10:00:00.000Z",
		"updated_at": "2026-04-18T10:00:00.000Z",
		"university_id": "U2026001",
		"department_id": "681f1ef2f03c6be17a6bd999",
		"mentor_id": "681f1ef2f03c6be17a6bd888",
		"is_validated_by_admin": true,
		"work_id": 100001,
		"id_photo_url": "https://res.cloudinary.com/.../id.jpg"
	}
}
```

- Errors: 400 invalid ID, 404 not found, 500

#### PATCH /api/v1/admin/interns/:internId

- Body example:

```json
{
	"full_name": "Updated Intern",
	"account_status": "approved",
	"department_id": "681f1ef2f03c6be17a6bd999",
	"mentor_id": "681f1ef2f03c6be17a6bd888"
}
```

- Response 200: same shape as GET intern by id
- Errors: 400, 404, 409, 500

#### POST /api/v1/admin/interns/:internId/approve

- Body: none
- Response 200:

```json
{
	"success": true,
	"msg": "Intern approved successfully.",
	"data": {
		"id": "681f1ef2f03c6be17a6bd123",
		"account_status": "approved"
	}
}
```

- Errors: 400, 404, 500

#### POST /api/v1/admin/interns/:internId/reject

- Body: none
- Response 200:

```json
{
	"success": true,
	"msg": "Intern rejected successfully.",
	"data": {
		"id": "681f1ef2f03c6be17a6bd123",
		"account_status": "declined"
	}
}
```

- Errors: 400, 404, 500

#### DELETE /api/v1/admin/interns/:internId

- Response 200:

```json
{
	"success": true,
	"msg": "Intern deleted successfully.",
	"data": {
		"id": "681f1ef2f03c6be17a6bd123",
		"full_name": "Deleted Intern",
		"email": "deleted@example.com",
		"user_role": "Student"
	}
}
```

- Errors: 400, 404, 500

#### GET /api/v1/admin/mentors

- Query parameters:
	- page, limit, search
- Response 200:

```json
{
	"success": true,
	"msg": "Mentors fetched successfully.",
	"data": [
		{
			"id": "681f1ef2f03c6be17a6bd888",
			"full_name": "Mentor User",
			"email": "mentor@example.com",
			"user_role": "Mentor",
			"account_status": "approved",
			"is_email_verified": false,
			"created_at": "2026-04-18T10:00:00.000Z",
			"updated_at": "2026-04-18T10:00:00.000Z",
			"department_id": "681f1ef2f03c6be17a6bd999",
			"specialization": "Backend"
		}
	],
	"pagination": {
		"total": 1,
		"page": 1,
		"limit": 10,
		"totalPages": 1
	}
}
```

- Errors: 500

#### GET /api/v1/admin/mentors/:mentorId

- Response 200: same mentor object shape as above
- Errors: 400, 404, 500

#### PATCH /api/v1/admin/mentors/:mentorId

- Body example:

```json
{
	"full_name": "Updated Mentor",
	"specialization": "AI"
}
```

- Response 200: updated mentor object
- Errors: 400, 404, 409, 500

#### DELETE /api/v1/admin/mentors/:mentorId

- Response 200: deleted mentor object
- Errors: 400, 404, 500

#### GET /api/v1/admin/registrations/pending

- Response 200:

```json
{
	"msg": "Pending registrations fetched successfully",
	"count": 2,
	"users": [
		{
			"_id": "681f1ef2f03c6be17a6bd123",
			"full_name": "Pending Student",
			"email": "pending@example.com",
			"user_role": "Student",
			"account_status": "pending",
			"created_at": "2026-04-18T10:00:00.000Z",
			"updated_at": "2026-04-18T10:00:00.000Z"
		}
	]
}
```

- Errors: 500

#### GET /api/v1/admin/registrations/:id

- Response 200:

```json
{
	"msg": "User fetched successfully",
	"user": {
		"_id": "681f1ef2f03c6be17a6bd123",
		"full_name": "Pending Student",
		"email": "pending@example.com",
		"user_role": "Student",
		"account_status": "pending",
		"created_at": "2026-04-18T10:00:00.000Z",
		"updated_at": "2026-04-18T10:00:00.000Z"
	}
}
```

- Errors: 400, 404, 500

### 2.4 Department Management Endpoints

All require Auth: Yes (Admin)

#### POST /api/v1/admin/departments/createdep

- Body:

```json
{
	"name": "Development",
	"code": "DEV",
	"description": "Software engineering department"
}
```

- Response 201:

```json
{
	"msg": "Department created successfully",
	"department": {
		"_id": "681f1ef2f03c6be17a6bd999",
		"name": "Development",
		"code": "DEV",
		"description": "Software engineering department",
		"created_by_admin_id": null,
		"is_active": true,
		"created_at": "2026-04-18T10:00:00.000Z",
		"updated_at": "2026-04-18T10:00:00.000Z"
	}
}
```

- Errors: 400 duplicate/missing fields, 500

#### GET /api/v1/admin/departments/getAlldep

- Response 200:

```json
{
	"msg": "Departments fetched successfully",
	"count": 1,
	"departments": [
		{
			"_id": "681f1ef2f03c6be17a6bd999",
			"name": "Development",
			"code": "DEV",
			"description": "Software engineering department",
			"created_by_admin_id": null,
			"is_active": true,
			"created_at": "2026-04-18T10:00:00.000Z",
			"updated_at": "2026-04-18T10:00:00.000Z"
		}
	]
}
```

- Errors: 500

#### GET /api/v1/admin/departments/:id

- Response 200: one department object
- Errors: 400 invalid id, 404 not found, 500

#### PATCH /api/v1/admin/departments/updatedep/:id

- Body:

```json
{
	"name": "Engineering",
	"description": "Updated description"
}
```

- Response 200: updated department
- Errors: 400, 404, 500

#### DELETE /api/v1/admin/departments/delete/:id

- Response 200: deleted department
- Errors: 400, 404, 500

### 2.5 Admin Office Endpoints (Policy and Schedule)

All require Auth: Yes (Admin)

#### Policy Handbook

- POST /api/v1/admin/office/policy/create
	- multipart/form-data fields:
		- title (required)
		- description (optional)
		- department_code (optional)
		- target_role (optional, default All)
		- version (optional, default 1)
		- file (required PDF)
	- Success: 201 with policy object
	- Errors: 400, 404, 500

- GET /api/v1/admin/office/policy/getall
	- Success: 200 with count + policies[]
	- Errors: 500

- GET /api/v1/admin/office/policy/:id
	- Success: 200 with policy
	- Errors: 400, 404, 500

- PATCH /api/v1/admin/office/policy/update/:id
	- multipart/form-data, any fields above optional + optional new file
	- Success: 200 with updated policy
	- Errors: 400, 404, 500

- DELETE /api/v1/admin/office/policy/delete/:id
	- Success: 200 with deleted policy
	- Errors: 400, 404, 500

#### Office Schedule

- POST /api/v1/admin/office/schedule/create
	- multipart/form-data fields:
		- title (required)
		- department_id (optional)
		- intern_id (optional)
		- mentor_id (optional)
		- weekday (optional)
		- schedule_date (optional)
		- start_time (required)
		- end_time (required)
		- file (required PDF)
	- Success: 201 with schedule object
	- Errors: 400, 500

- GET /api/v1/admin/office/schedule/getall
	- Success: 200 with count + schedules[]
	- Errors: 500

- GET /api/v1/admin/office/schedule/:id
	- Success: 200 with schedule
	- Errors: 400, 404, 500

- PATCH /api/v1/admin/office/schedule/update/:id
	- multipart/form-data, any schedule fields optional + optional file
	- Success: 200 with updated schedule
	- Errors: 400, 404, 500

- DELETE /api/v1/admin/office/schedule/delete/:id
	- Success: 200 with deleted schedule
	- Errors: 400, 404, 500

### 2.6 Internship Assignment Endpoints

All require Auth: Yes (Admin)

#### POST /api/v1/admin/internships/:intern_id

- Body:

```json
{
	"mentor_name": "Mentor User",
	"department_code": "DEV"
}
```

- Response 201:

```json
{
	"msg": "Internship assignment created successfully",
	"assignment": {
		"_id": "681f1ef2f03c6be17a6bd555",
		"intern_id": "681f1ef2f03c6be17a6bd123",
		"mentor_id": "681f1ef2f03c6be17a6bd888",
		"department_id": "681f1ef2f03c6be17a6bd999",
		"assigned_by_admin_id": "681f1ef2f03c6be17a6bd001",
		"created_at": "2026-04-18T10:00:00.000Z",
		"updated_at": "2026-04-18T10:00:00.000Z"
	}
}
```

- Errors: 400, 404, 500

#### GET /api/v1/admin/internships

- Query parameters (optional):
	- mentor_id
	- department_id
- Response 200: count + assignments[]
- Errors: 500

#### GET /api/v1/admin/internships/:id

- Response 200: one assignment
- Errors: 400, 404, 500

#### PATCH /api/v1/admin/internships/update/:id

- Body:

```json
{
	"mentor_name": "Updated Mentor",
	"department_code": "ENG"
}
```

- Response 200: updated assignment
- Errors: 400, 404, 500

#### DELETE /api/v1/admin/internships/:id

- Response 200: deleted assignment
- Errors: 400, 404, 500

### 2.7 Mentor Attendance Endpoints

All require Auth: Yes (Mentor)

#### POST /api/v1/mentors/attendance

- Body:

```json
{
	"internId": "681f1ef2f03c6be17a6bd123",
	"mentorId": "681f1ef2f03c6be17a6bd888",
	"attendanceDate": "2026-04-18",
	"status": "present",
	"notes": "Student attended on time"
}
```

- Response 201:

```json
{
	"msg": "Attendance marked successfully",
	"data": {
		"id": "681f1ef2f03c6be17a6bd444",
		"intern_id": "681f1ef2f03c6be17a6bd123",
		"mentor_id": "681f1ef2f03c6be17a6bd888",
		"attendance_date": "2026-04-18T00:00:00.000Z",
		"status": "present",
		"notes": "Student attended on time",
		"marked_by_mentor_id": "681f1ef2f03c6be17a6bd888",
		"created_at": "2026-04-18T10:00:00.000Z",
		"updated_at": "2026-04-18T10:00:00.000Z"
	}
}
```

- Errors: 400, 404, 409, 500

#### GET /api/v1/mentors/attendance/id/:attendanceId

- Response 200: attendance object with populated intern/mentor
- Errors: 400, 404, 500

#### GET /api/v1/mentors/attendance/date/:attendanceDate

- Response 200: array of attendance records for date
- Errors: 404 none found, 500

#### GET /api/v1/mentors/attendance/intern/:internId

- Query parameters:
	- limit (default 50)
	- page (default 1)
- Response 200:

```json
{
	"msg": "Intern attendance records retrieved successfully",
	"data": {
		"data": [
			{
				"_id": "681f1ef2f03c6be17a6bd444",
				"intern_id": "681f1ef2f03c6be17a6bd123",
				"mentor_id": "681f1ef2f03c6be17a6bd888",
				"attendance_date": "2026-04-18T00:00:00.000Z",
				"status": "present",
				"notes": "Student attended on time",
				"marked_by_mentor_id": "681f1ef2f03c6be17a6bd888",
				"created_at": "2026-04-18T10:00:00.000Z",
				"updated_at": "2026-04-18T10:00:00.000Z"
			}
		],
		"total": 1,
		"page": 1,
		"limit": 50,
		"pages": 1
	}
}
```

- Errors: 400, 404, 500

#### GET /api/v1/mentors/attendance/stats/:internId

- Response 200:

```json
{
	"msg": "Attendance statistics retrieved successfully",
	"data": {
		"total": 10,
		"byStatus": [
			{
				"status": "present",
				"count": 8,
				"percentage": 80
			},
			{
				"status": "late",
				"count": 2,
				"percentage": 20
			}
		],
		"generatedAt": "2026-04-18T10:00:00.000Z"
	}
}
```

- Errors: 400, 404, 500

#### PATCH /api/v1/mentors/attendance/:attendanceId

- Body:

```json
{
	"status": "excused",
	"notes": "Medical reason"
}
```

- Response 200: updated attendance
- Errors: 400, 404, 500

#### DELETE /api/v1/mentors/attendance/:attendanceId

- Response 200:

```json
{
	"msg": "Attendance record deleted successfully",
	"data": {
		"msg": "Attendance record deleted successfully",
		"deletedRecordId": "681f1ef2f03c6be17a6bd444",
		"deletedAt": "2026-04-18T10:00:00.000Z"
	}
}
```

- Errors: 400, 404, 500

### 2.8 Evaluation Endpoints

Auth required: No route-level auth middleware currently applied in code (important security note).

#### POST /api/v1/evaluations

- Body:

```json
{
	"internId": "681f1ef2f03c6be17a6bd123",
	"mentorId": "681f1ef2f03c6be17a6bd888",
	"weekLabel": "Week 1",
	"overallMark": 88,
	"feedback": "Good progress"
}
```

- Response 201:

```json
{
	"msg": "Evaluation created successfully",
	"data": {
		"id": "681f1ef2f03c6be17a6bd222",
		"intern_id": "681f1ef2f03c6be17a6bd123",
		"mentor_id": "681f1ef2f03c6be17a6bd888",
		"week_label": "Week 1",
		"overall_mark": 88,
		"feedback": "Good progress",
		"evaluated_at": "2026-04-18T10:00:00.000Z",
		"created_at": "2026-04-18T10:00:00.000Z",
		"updated_at": "2026-04-18T10:00:00.000Z"
	}
}
```

- Errors: 400, 404, 500

#### GET /api/v1/evaluations

- Query parameters: limit, page
- Response 200:

```json
{
	"msg": "All evaluations retrieved successfully",
	"data": {
		"data": [
			{
				"_id": "681f1ef2f03c6be17a6bd222",
				"intern_id": {
					"_id": "681f1ef2f03c6be17a6bd123",
					"full_name": "Intern User",
					"email": "intern@example.com"
				},
				"mentor_id": {
					"_id": "681f1ef2f03c6be17a6bd888",
					"full_name": "Mentor User",
					"email": "mentor@example.com"
				},
				"week_label": "Week 1",
				"overall_mark": 88,
				"feedback": "Good progress",
				"evaluated_at": "2026-04-18T10:00:00.000Z",
				"created_at": "2026-04-18T10:00:00.000Z",
				"updated_at": "2026-04-18T10:00:00.000Z"
			}
		],
		"total": 1,
		"page": 1,
		"limit": 50,
		"pages": 1
	}
}
```

- Errors: 404 none found, 500

#### GET /api/v1/evaluations/id/:evaluationId

- Response 200: one evaluation
- Errors: 400, 404, 500

#### GET /api/v1/evaluations/intern/:internId

- Query parameters: limit, page
- Response 200: paginated evaluations for intern
- Errors: 400, 404, 500

#### GET /api/v1/evaluations/mentor/:mentorId

- Query parameters: limit, page
- Response 200: paginated evaluations by mentor
- Errors: 400, 404, 500

#### GET /api/v1/evaluations/stats/:internId

- Response 200:

```json
{
	"msg": "Evaluation statistics retrieved successfully",
	"data": {
		"averageMark": 88,
		"highestMark": 95,
		"lowestMark": 80,
		"totalEvaluations": 3
	}
}
```

- Errors: 400, 404, 500

#### PATCH /api/v1/evaluations/:evaluationId

- Body:

```json
{
	"weekLabel": "Week 2",
	"overallMark": 90,
	"feedback": "Improved"
}
```

- Response 200: updated evaluation
- Errors: 400, 404, 500

#### DELETE /api/v1/evaluations/:evaluationId

- Response 200:

```json
{
	"msg": "Evaluation record deleted successfully",
	"data": {
		"msg": "Evaluation record deleted successfully"
	}
}
```

- Errors: 400, 404, 500

### 2.9 Intern Self-Service Endpoints

All endpoints require Auth: Yes (Student)

#### GET /api/v1/intern/assignment

- Response 200:

```json
{
	"msg": "Fetched successfully",
	"assignment": {
		"_id": "681f1ef2f03c6be17a6bd555",
		"intern_id": "681f1ef2f03c6be17a6bd123",
		"mentor_id": {
			"_id": "681f1ef2f03c6be17a6bd888",
			"full_name": "Mentor User",
			"email": "mentor@example.com"
		},
		"department_id": {
			"_id": "681f1ef2f03c6be17a6bd999",
			"name": "Development",
			"code": "DEV"
		},
		"assigned_by_admin_id": "681f1ef2f03c6be17a6bd001",
		"created_at": "2026-04-18T10:00:00.000Z",
		"updated_at": "2026-04-18T10:00:00.000Z"
	}
}
```

- Errors: 401, 404, 500

#### GET /api/v1/intern/schedules

- Response 200:

```json
{
	"msg": "Fetched successfully",
	"count": 1,
	"schedules": [
		{
			"_id": "681f1ef2f03c6be17a6bd666",
			"title": "Office Hours",
			"department_id": {
				"_id": "681f1ef2f03c6be17a6bd999",
				"name": "Development",
				"code": "DEV"
			},
			"intern_id": "681f1ef2f03c6be17a6bd123",
			"mentor_id": {
				"_id": "681f1ef2f03c6be17a6bd888",
				"full_name": "Mentor User",
				"email": "mentor@example.com"
			},
			"weekday": "Monday",
			"schedule_date": "2026-04-18T00:00:00.000Z",
			"start_time": "09:00",
			"end_time": "13:00",
			"notes": null,
			"uploaded_by_admin_id": null,
			"is_active": true,
			"created_at": "2026-04-18T10:00:00.000Z",
			"updated_at": "2026-04-18T10:00:00.000Z"
		}
	]
}
```

- Errors: 401, 500

#### GET /api/v1/intern/training-modules

- Response 200:

```json
{
	"msg": "Fetched successfully",
	"count": 1,
	"trainingModules": [
		{
			"_id": "681f1ef2f03c6be17a6bdabc",
			"title": "Intern Guide",
			"description": "Orientation module",
			"department_id": "681f1ef2f03c6be17a6bd999",
			"target_role": "student",
			"file_url": "https://res.cloudinary.com/.../module.pdf",
			"uploaded_by_admin_id": "681f1ef2f03c6be17a6bd001",
			"version": 1,
			"is_active": true,
			"created_at": "2026-04-18T10:00:00.000Z",
			"updated_at": "2026-04-18T10:00:00.000Z"
		}
	]
}
```

- Errors: 401, 500

#### GET /api/v1/intern/training-modules/:moduleId/download

- Behavior: Redirects to file URL if authorized
- Success: HTTP redirect (302)
- Errors: 400, 401, 403, 404, 500

#### GET /api/v1/intern/work-id

- Response 200:

```json
{
	"msg": "Fetched successfully",
	"work_card": {
		"work_id_card": {
			"work_id": 100001,
			"id_photo_url": "https://res.cloudinary.com/.../photo.jpg"
		},
		"intern_profile": {
			"id": "681f1ef2f03c6be17a6bd123",
			"full_name": "Intern User",
			"user_role": "Student",
			"department": {
				"name": "Development",
				"code": "DEV"
			}
		}
	}
}
```

- Errors: 401, 404, 500

#### POST /api/v1/intern/work-id/photo

- Content-Type: multipart/form-data
- Field:
	- file (required image, max 5MB)
- Response 200:

```json
{
	"msg": "Work ID photo uploaded successfully",
	"id_photo_url": "https://res.cloudinary.com/.../photo.jpg"
}
```

- Errors: 400, 401, 404, 500

#### GET /api/v1/intern/evaluations

- Response 200:

```json
{
	"msg": "Fetched successfully",
	"count": 2,
	"average_mark": 86.5,
	"evaluations": [
		{
			"_id": "681f1ef2f03c6be17a6bd222",
			"intern_id": "681f1ef2f03c6be17a6bd123",
			"mentor_id": {
				"_id": "681f1ef2f03c6be17a6bd888",
				"full_name": "Mentor User",
				"email": "mentor@example.com"
			},
			"week_label": "Week 1",
			"overall_mark": 88,
			"feedback": "Good progress",
			"evaluated_at": "2026-04-18T10:00:00.000Z",
			"created_at": "2026-04-18T10:00:00.000Z",
			"updated_at": "2026-04-18T10:00:00.000Z"
		}
	]
}
```

- Errors: 401, 500

### 2.10 Mentor Training Module Endpoints

All endpoints require Auth: Yes (Admin or Mentor unless stated)

#### GET /api/v1/mentors/training-modules

- Auth role: Admin only
- Query params: activeOnly=true|false
- Response 200:

```json
{
	"msg": "All training modules retrieved successfully",
	"count": 1,
	"data": [
		{
			"_id": "681f1ef2f03c6be17a6bdabc",
			"title": "Node Basics",
			"description": "Intro module",
			"url": "https://example.com/module",
			"department_code": "DEV",
			"created_by_mentor_id": "681f1ef2f03c6be17a6bd888",
			"is_active": true,
			"created_at": "2026-04-18T10:00:00.000Z",
			"updated_at": "2026-04-18T10:00:00.000Z"
		}
	]
}
```

- Errors: 401, 403, 500

#### GET /api/v1/mentors/training-modules/:moduleId

- Auth role: Admin or Mentor
- Response 200: one training module
- Errors: 400, 401, 403, 404, 500

#### GET /api/v1/mentors/training-modules/department/:departmentCode

- Auth role: Admin or Mentor
- Query params: activeOnly=true|false
- Response 200: department module list
- Errors: 400, 401, 403, 404, 500

#### POST /api/v1/mentors/training-modules

- Auth role: Admin or Mentor
- Body:

```json
{
	"title": "Node Basics",
	"description": "Intro module",
	"url": "https://example.com/module",
	"departmentCode": "DEV"
}
```

- Response 201: created training module
- Errors: 400, 401, 403, 404, 409, 500

#### GET /api/v1/mentors/training-modules/mentor/:mentorId

- Auth role: Admin or Mentor
- Query params: activeOnly=true|false
- Response 200: mentor module list
- Errors: 400, 401, 403, 404, 500

#### PATCH /api/v1/mentors/training-modules/:moduleId

- Auth role: Admin or Mentor
- Body example:

```json
{
	"title": "Updated Module",
	"description": "Updated",
	"url": "https://example.com/new",
	"is_active": true
}
```

- Response 200: updated module
- Errors: 400, 401, 403, 404, 500

#### DELETE /api/v1/mentors/training-modules/:moduleId

- Auth role: Admin or Mentor
- Response 200:

```json
{
	"msg": "Training module deleted successfully",
	"data": {
		"deletedModuleId": "681f1ef2f03c6be17a6bdabc",
		"title": "Node Basics"
	}
}
```

- Errors: 400, 401, 403, 404, 500

-------------------------------------------------------------------------------

## 3. Requested Dashboard and Role Endpoints

### Admin Dashboard Data

No dedicated single dashboard endpoint currently exists.

Use these endpoints to compose admin dashboard:

- /api/v1/admin/registrations/pending
- /api/v1/admin/interns/pending
- /api/v1/admin/interns
- /api/v1/admin/mentors
- /api/v1/admin/internships

### Mentor Dashboard Data

No dedicated mentor dashboard endpoint currently exists.

Use these endpoints:

- /api/v1/mentors/attendance/*
- /api/v1/mentors/training-modules/*

### Intern Dashboard Data

Use these endpoints:

- /api/v1/intern/assignment
- /api/v1/intern/schedules
- /api/v1/intern/work-id
- /api/v1/intern/evaluations
- /api/v1/intern/training-modules

### User Role Endpoints (get role, validate permissions)

No dedicated get-role endpoint exists.

Current role flow:

- Role is returned in login response as user.user_role
- Role is embedded in JWT payload
- Route authorization is enforced by restrictTo middleware

-------------------------------------------------------------------------------

## 4. Sample JSON Objects (All Fields)

### User Object (base)

```json
{
	"_id": "681f1ef2f03c6be17a6bd001",
	"full_name": "User Name",
	"email": "user@example.com",
	"password": "<hashed_password>",
	"user_role": "Student",
	"account_status": "pending",
	"account_reviewed_at": null,
	"account_reviewed_by": null,
	"created_at": "2026-04-18T10:00:00.000Z",
	"updated_at": "2026-04-18T10:00:00.000Z"
}
```

### Intern Object (discriminator)

```json
{
	"_id": "681f1ef2f03c6be17a6bd123",
	"full_name": "Intern User",
	"email": "intern@example.com",
	"password": "<hashed_password>",
	"user_role": "Student",
	"account_status": "approved",
	"account_reviewed_at": "2026-04-18T10:00:00.000Z",
	"account_reviewed_by": "681f1ef2f03c6be17a6bd001",
	"university_id": "U2026001",
	"department_id": "681f1ef2f03c6be17a6bd999",
	"mentor_id": "681f1ef2f03c6be17a6bd888",
	"is_validated_by_admin": true,
	"work_id": 100001,
	"id_photo_url": "https://res.cloudinary.com/.../photo.jpg",
	"id_photo_public_id": "internships-tracker/work-id-photos/x1",
	"created_at": "2026-04-18T10:00:00.000Z",
	"updated_at": "2026-04-18T10:00:00.000Z"
}
```

### Mentor Object (discriminator)

```json
{
	"_id": "681f1ef2f03c6be17a6bd888",
	"full_name": "Mentor User",
	"email": "mentor@example.com",
	"password": "<hashed_password>",
	"user_role": "Mentor",
	"account_status": "approved",
	"account_reviewed_at": "2026-04-18T10:00:00.000Z",
	"account_reviewed_by": "681f1ef2f03c6be17a6bd001",
	"department_id": "681f1ef2f03c6be17a6bd999",
	"specialization": "Backend",
	"created_at": "2026-04-18T10:00:00.000Z",
	"updated_at": "2026-04-18T10:00:00.000Z"
}
```

### Admin Object (discriminator)

```json
{
	"_id": "681f1ef2f03c6be17a6bd001",
	"full_name": "Admin User",
	"email": "admin@example.com",
	"password": "<hashed_password>",
	"user_role": "Admin",
	"account_status": "approved",
	"account_reviewed_at": "2026-04-18T10:00:00.000Z",
	"account_reviewed_by": null,
	"admin_scope": "hr",
	"created_at": "2026-04-18T10:00:00.000Z",
	"updated_at": "2026-04-18T10:00:00.000Z"
}
```

### Department Object

```json
{
	"_id": "681f1ef2f03c6be17a6bd999",
	"name": "Development",
	"code": "DEV",
	"description": "Software engineering department",
	"created_by_admin_id": "681f1ef2f03c6be17a6bd001",
	"is_active": true,
	"created_at": "2026-04-18T10:00:00.000Z",
	"updated_at": "2026-04-18T10:00:00.000Z"
}
```

### Schedule/Event Object

```json
{
	"_id": "681f1ef2f03c6be17a6bd666",
	"title": "Office Hours",
	"department_id": "681f1ef2f03c6be17a6bd999",
	"intern_id": "681f1ef2f03c6be17a6bd123",
	"mentor_id": "681f1ef2f03c6be17a6bd888",
	"weekday": "Monday",
	"schedule_date": "2026-04-18T00:00:00.000Z",
	"start_time": "09:00",
	"end_time": "13:00",
	"notes": "Bring laptop",
	"uploaded_by_admin_id": "681f1ef2f03c6be17a6bd001",
	"is_active": true,
	"created_at": "2026-04-18T10:00:00.000Z",
	"updated_at": "2026-04-18T10:00:00.000Z"
}
```

### Approval Request Object

Approval queue currently uses User records with account_status = pending.

```json
{
	"_id": "681f1ef2f03c6be17a6bd123",
	"full_name": "Pending User",
	"email": "pending@example.com",
	"user_role": "Student",
	"account_status": "pending",
	"account_reviewed_at": null,
	"account_reviewed_by": null,
	"created_at": "2026-04-18T10:00:00.000Z",
	"updated_at": "2026-04-18T10:00:00.000Z"
}
```

-------------------------------------------------------------------------------

## 5. CORS and Security

Based on current server code and live checks against Render:

- Is CORS enabled: Not effectively enabled in runtime response headers
- Allowed origins: Not explicitly configured in server.js
- Access-Control-Allow-Origin header: Not returned in tested requests
- Access-Control-Allow-Headers header: Not returned in tested requests
- Access-Control-Allow-Methods header: Not returned in tested requests

Required request headers:

- Content-Type: application/json for JSON routes
- Authorization: Bearer <token> for protected routes
- multipart/form-data for file upload routes

Rate limiting details:

- express-rate-limit dependency exists in package.json
- No active rate-limit middleware is mounted in server.js

API key needed:

- No API key mechanism implemented

-------------------------------------------------------------------------------

## 6. Error Handling

Common error response format:

```json
{
	"msg": "Error message",
	"error": "Detailed error (often present in many routes)"
}
```

Observed/used HTTP status codes:

- 200: Success (read, update, delete)
- 201: Created
- 302: Redirect (training module download)
- 400: Bad request or validation failure
- 401: Unauthorized (missing/invalid token)
- 403: Forbidden (insufficient role or denied resource)
- 404: Resource not found
- 409: Conflict (duplicates, already exists)
- 500: Internal server error

Examples:

```json
{
	"msg": "Invalid email"
}
```

```json
{
	"msg": "Access denied. No token provided."
}
```

```json
{
	"msg": "Invalid or expired token",
	"error": "jwt expired"
}
```

-------------------------------------------------------------------------------

## 7. Special Requirements and Query Conventions

### Required Headers

- JSON endpoints:
	- Content-Type: application/json
- Protected endpoints:
	- Authorization: Bearer <JWT>
- File upload endpoints:
	- Content-Type: multipart/form-data
	- file field required for upload routes

### Pagination Format

Admin intern/mentor list format:

```json
{
	"pagination": {
		"total": 100,
		"page": 1,
		"limit": 10,
		"totalPages": 10
	}
}
```

Attendance/Evaluation list format:

```json
{
	"data": {
		"data": [],
		"total": 100,
		"page": 1,
		"limit": 50,
		"pages": 2
	}
}
```

### Filtering and Search

- /api/v1/admin/interns?search=<text>&page=1&limit=10
- /api/v1/admin/mentors?search=<text>&page=1&limit=10
- /api/v1/admin/internships?mentor_id=<id>&department_id=<id>
- /api/v1/evaluations?limit=50&page=1
- /api/v1/evaluations/intern/:internId?limit=50&page=1
- /api/v1/evaluations/mentor/:mentorId?limit=50&page=1
- /api/v1/mentors/attendance/intern/:internId?limit=50&page=1
- /api/v1/mentors/training-modules?activeOnly=true
- /api/v1/mentors/training-modules/department/:departmentCode?activeOnly=true
- /api/v1/mentors/training-modules/mentor/:mentorId?activeOnly=false

### Sorting

No client-provided sort parameter is implemented.

Default sorts in code:

- Many list endpoints sort by created_at descending
- Attendance/evaluation list endpoints sort by date fields descending

### Middleware and Special Auth Flows

- protect middleware verifies JWT and attaches req.user
- restrictTo middleware enforces role checks
- upload middleware for PDF files on admin office routes (10MB)
- image upload middleware on intern photo route (5MB, image/*)
- training module download endpoint uses redirect to file URL

-------------------------------------------------------------------------------

## 8. Important Implementation Notes

1. There are no dedicated dashboard endpoints (admin/mentor/intern). Dashboards are composed from multiple endpoints.
2. No refresh-token and no logout endpoint are currently implemented.
3. CORS headers are not currently emitted by runtime responses in tested requests.
4. Evaluation routes currently have no route-level auth middleware in the route file.
5. Route order in training module routes may affect specific paths:
	 - /:moduleId is declared before /department/:departmentCode and /mentor/:mentorId.
6. This document reflects deployed behavior and codebase state on 2026-04-18.