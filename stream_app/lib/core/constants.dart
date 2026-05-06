class ApiConstants {
  static const String admin = "/admin/users";
  static const String users = "/users";
  static const String login = "/auth/login";
  static const String register = "/auth/register";
  static const String refresh = "/auth/refresh";
  static const String notifications = "/notifications";
  static const String streams = "/streams";

  static const String baseUrl = "http://192.168.1.107:8000/api";
  static const String wsBaseUrl = "ws://192.168.1.107:8000/api/websocket";
  static const String liveKitBaseUrl = "ws://192.168.1.107:7880";
}
