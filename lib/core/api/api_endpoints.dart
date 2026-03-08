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
  // static const String baseUrl = "http://10.0.2.2:5000/api";
  static const String baseUrl = "http://192.168.1.69:5000/api";
  // static const String baseUrl = "http://192.168.1.10:5000/api";

  // static const String baseUrl = "http://PC_IP:5000/api";

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Auth Endpoints
  static const String Register = "/auth/signup";
  static const String Login = "/auth/login";
  static const String Me = "/auth/me";
  static const String UploadProfilePicture = "/auth/upload-profile-picture";
  static String updateUser(String id) => "/auth/$id";
  static const String ChangePassword = "/auth/change-password";
  static const String ForgotPassword = "/auth/forgot-password";
  static const String VerifyResetCode = "/auth/verify-reset-code";
  static const String ResetPassword = "/auth/reset-password";

  // Batch Endpoints
  static const String batches = "/batches";
  static String batchById(String id) => "/batches/$id";

  // Cars (User vehicles)
  static const String Cars = "/cars";
  static String carById(String id) => "/cars/$id";

  // Orders (Bookings)
  static const String MyOrders = "/orders/my";
  static const String CreatePaidOrder = "/orders/paid";

  // Public
  static const String PublicPackages = "/packages";
  static const String PublicProviders = "/providers";
  static const String PublicCategories = "/categories";
  static const String EsewaInitiate = "/esewa/initiate";
  static const String OrdersMy = "/orders/my";
  static const String TripSync = "/trips/sync";
  static String tripsByUser(String userId) => "/trips/user/$userId";
}
