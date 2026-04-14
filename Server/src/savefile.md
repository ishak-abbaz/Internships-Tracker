Step 1 — Admin sends a request
The admin hits an endpoint (e.g. POST /policies) with form-data containing fields like title,
 description, and a PDF file.
Step 2 — upload.js middleware runs first
Multer intercepts the request, reads the PDF file, and stores it temporarily in memory as req.file.buffer.
It also validates that the file is PDF and under 10MB. No Cloudinary yet.
Step 3 — Request reaches the Controller
AdminOfficeController.js receives the request with req.body (text fields) and req.file (the PDF buffer).
Step 4 — Controller validates inputs
It checks required fields like title, confirms the file exists, and validates any IDs (like department_id) are proper MongoDB ObjectIds.
Step 5 — PDF uploads to Cloudinary
The uploadToCloudinary() helper takes req.file.buffer, streams it to Cloudinary under the right folder (internships-tracker/policies or /schedules), and returns back a secure_url and public_id.
Step 6 — Data saves to MongoDB
The controller creates a new document in the Policy or Schedule collection, storing all the fields plus the file_url (the Cloudinary link) and file_public_id (used later for deletion).
Step 7 — Response sent back
A 201 success response is returned with the saved document.