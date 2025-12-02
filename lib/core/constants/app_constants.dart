class AppConstants {
  // Prevent instantiation
  AppConstants._();

  // Default Map Location (Cairo, Egypt)
  static const double defaultLatitude = 30.0444;
  static const double defaultLongitude = 31.2357;
  static const double defaultZoom = 12.0;

  // Asset Paths
  static const String lowSeverityMarker =
      'assets/images/low_severity_marker.png';
  static const String mediumSeverityMarker =
      'assets/images/medium_severity_marker.png';
  static const String highSeverityMarker =
      'assets/images/high_severity_marker.png';
  static const String defaultProfilePic = 'assets/images/default_profile.png';
  static const String appLogo = 'assets/images/app_logo.png';
  static const String loginMapBackground = 'assets/images/login_map_bg.png';

  // Marker Icon Sizes
  static const int markerIconWidth = 100;

  // Cache Keys
  static const String onBoardingCacheKey = 'onBoarding';
  static const String uidCacheKey = 'uid';
}
