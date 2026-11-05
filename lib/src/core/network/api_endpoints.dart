/// Paths under `/api/v1`.
class ApiEndpoints {
  static const String signup = "/auth/signup";
  static const String login = "/auth/login";
  static const String google = "/auth/google";
  static const String refresh = "/auth/refresh";
  static const String logout = "/auth/logout";
  static const String logoutAll = "/auth/logout-all";
  static const String verifyEmail = "/auth/verify-email";
  static const String resendVerification = "/auth/verify-email/resend";
  static const String forgotPassword = "/auth/forgot-password";
  static const String resetPassword = "/auth/reset-password";
  static const String changePassword = "/auth/change-password";

  /// Sent without a token: the server rejects an expired one even here.
  static const Set<String> public = {
    signup,
    login,
    google,
    refresh,
    logout,
    verifyEmail,
    forgotPassword,
    resetPassword,
  };

  static String user(String id) => "/users/$id";
  static String patientProfile(String userId) =>
      "/users/$userId/patient-profile";

  static const String providers = "/providers";
  static const String specialties = "/providers/specialties";
  static String provider(String id) => "/providers/$id";
  static String availability(String providerId) =>
      "/providers/$providerId/availability";

  static const String appointments = "/appointments";
  static String userAppointments(String userId) => "/appointments/user/$userId";
  static String appointment(String id) => "/appointments/$id";
  static String cancelAppointment(String id) => "/appointments/$id/cancel";
  static String rescheduleAppointment(String id) =>
      "/appointments/$id/reschedule";
}
