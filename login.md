Login Feature: Frontend-Backend Link + Manual Testing

1) How the link is built

The login integration is split into 5 layers:

- API endpoint constants:
	- Base URL is defined in [lib/config/api_config.dart](lib/config/api_config.dart#L2).
	- Login endpoint path is defined in [lib/config/api_config.dart](lib/config/api_config.dart#L5).
	- Full login URL becomes:
		https://internships-tracker.onrender.com/api/v1/auth/login

- Generic HTTP service:
	- Request URL is composed in [lib/services/api_service.dart](lib/services/api_service.dart#L9).
	- POST method is implemented in [lib/services/api_service.dart](lib/services/api_service.dart#L19).
	- JSON body encoding happens in [lib/services/api_service.dart](lib/services/api_service.dart#L27).
	- Optional Bearer token header logic is in [lib/services/api_service.dart](lib/services/api_service.dart#L53) and [lib/services/api_service.dart](lib/services/api_service.dart#L59).
	- Success/error decode handling is in [lib/services/api_service.dart](lib/services/api_service.dart#L65).

- Auth-specific service:
	- Login call is made in [lib/services/auth_service.dart](lib/services/auth_service.dart#L14).
	- It calls ApiConfig.login in [lib/services/auth_service.dart](lib/services/auth_service.dart#L19).
	- Sent request body is:
		- email
		- password
	- Response is parsed and token is saved in [lib/services/auth_service.dart](lib/services/auth_service.dart#L27).

- Response parsing models:
	- accessToken and user are read in [lib/models/login_response_model.dart](lib/models/login_response_model.dart#L13).
	- user_role is mapped in [lib/models/user_model.dart](lib/models/user_model.dart#L17).

- Login UI and role routing:
	- UI triggers login call in [lib/main.dart](lib/main.dart#L218).
	- Role is normalized with lowercase in [lib/main.dart](lib/main.dart#L224).
	- Role-to-route mapping:
		- admin -> /admin in [lib/main.dart](lib/main.dart#L227)
		- mentor -> /mentor in [lib/main.dart](lib/main.dart#L229)
		- student or intern -> /intern in [lib/main.dart](lib/main.dart#L231)
	- Navigation is performed in [lib/main.dart](lib/main.dart#L240).
	- Backend errors are surfaced to UI in [lib/main.dart](lib/main.dart#L241).



