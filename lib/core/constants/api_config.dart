class ApiConfig {
  static const String baseUrl = 'https://bible-api.com';
  
  // No API Key needed for bible-api.com
  // Using KJV (King James Version)
  static const String translation = 'kjv';

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
  };
}
