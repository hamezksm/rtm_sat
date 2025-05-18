import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Class to access API-related constants from .env file
class Api {
  const Api._(); // Private constructor to prevent instantiation

  /// Base URL for API requests
  static String get baseUrl => dotenv.env['BASE_URL'] ?? '';

  /// Primary API key
  static String get apiKey => dotenv.env['API_KEY'] ?? '';

  // Add additional API-related constants as needed
}
