// class ApiEndpoints {
//   ApiEndpoints._();

//   // Base URL
//   static const String baseUrl = "http://10.0.2.2:5000/api";

//   // Timeouts
//   static const Duration connectionTimeout = Duration(seconds: 30);
//   static const Duration receiveTimeout = Duration(seconds: 30);

//   // Student Endpoints (Users)
//   static const String Register = "/auth/signup";
//   static const String Login = "/auth/login";

//   // Batch Endpoints
//   static const String batches = "/batches";
//   static String batchById(String id) => '/batches/$id';
// }

class ApiEndpoints {
  ApiEndpoints._();

  // Base URL
  static const String baseUrl = "http://10.0.2.2:5000/api";

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Auth Endpoints
  static const String Register = "/auth/signup";
  static const String Login = "/auth/login";
  static const String Me = "/auth/me";
  static const String UploadProfilePicture = "/auth/upload-profile-picture";

  // Batch Endpoints
  static const String batches = "/batches";
  static String batchById(String id) => "/batches/$id";
}
