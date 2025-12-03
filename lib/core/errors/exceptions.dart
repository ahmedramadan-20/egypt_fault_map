// Custom exceptions for better error handling and debugging

/// Base app exception
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  AppException({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() {
    final codeStr = code != null ? ' (code: $code)' : '';
    return '$runtimeType: $message$codeStr';
  }
}

/// Authentication related exceptions
class AuthException extends AppException {
  AuthException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  factory AuthException.fromFirebaseAuthException(
    dynamic error,
    StackTrace stackTrace,
  ) {
    if (error is Exception && error.toString().contains('FirebaseAuthException')) {
      // Extract code and message from FirebaseAuthException
      final errorStr = error.toString();
      String? code;
      String message = 'Authentication failed';

      // Try to extract code
      if (errorStr.contains('[') && errorStr.contains(']')) {
        final start = errorStr.indexOf('[') + 1;
        final end = errorStr.indexOf(']');
        code = errorStr.substring(start, end);
      }

      // Try to extract message
      if (errorStr.contains(']') && errorStr.length > errorStr.indexOf(']') + 2) {
        message = errorStr.substring(errorStr.indexOf(']') + 2).trim();
      }

      return AuthException(
        message: message,
        code: code,
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    return AuthException(
      message: error?.toString() ?? 'Unknown authentication error',
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  // Common auth error messages
  static AuthException invalidCredentials() {
    return AuthException(
      message: 'Invalid email or password',
      code: 'invalid-credentials',
    );
  }

  static AuthException userNotFound() {
    return AuthException(
      message: 'No user found with this email',
      code: 'user-not-found',
    );
  }

  static AuthException emailAlreadyInUse() {
    return AuthException(
      message: 'This email is already registered',
      code: 'email-already-in-use',
    );
  }

  static AuthException weakPassword() {
    return AuthException(
      message: 'Password is too weak',
      code: 'weak-password',
    );
  }

  static AuthException userDisabled() {
    return AuthException(
      message: 'This account has been disabled',
      code: 'user-disabled',
    );
  }
}

/// Database/Firestore related exceptions
class DatabaseException extends AppException {
  DatabaseException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  factory DatabaseException.fromFirebaseException(
    dynamic error,
    StackTrace stackTrace,
  ) {
    return DatabaseException(
      message: error?.toString() ?? 'Database operation failed',
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  static DatabaseException documentNotFound(String docId) {
    return DatabaseException(
      message: 'Document not found: $docId',
      code: 'document-not-found',
    );
  }

  static DatabaseException permissionDenied() {
    return DatabaseException(
      message: 'Permission denied to access this resource',
      code: 'permission-denied',
    );
  }

  static DatabaseException networkError() {
    return DatabaseException(
      message: 'Network error. Please check your connection',
      code: 'network-error',
    );
  }
}

/// Cache/Storage related exceptions
class CacheException extends AppException {
  CacheException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  static CacheException readError(String key) {
    return CacheException(
      message: 'Failed to read from cache: $key',
      code: 'cache-read-error',
    );
  }

  static CacheException writeError(String key) {
    return CacheException(
      message: 'Failed to write to cache: $key',
      code: 'cache-write-error',
    );
  }
}

/// Network/API related exceptions
class NetworkException extends AppException {
  NetworkException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  static NetworkException noConnection() {
    return NetworkException(
      message: 'No internet connection',
      code: 'no-connection',
    );
  }

  static NetworkException timeout() {
    return NetworkException(
      message: 'Request timed out',
      code: 'timeout',
    );
  }
}

/// Validation related exceptions
class ValidationException extends AppException {
  ValidationException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  static ValidationException invalidEmail() {
    return ValidationException(
      message: 'Invalid email address',
      code: 'invalid-email',
    );
  }

  static ValidationException emptyField(String fieldName) {
    return ValidationException(
      message: '$fieldName cannot be empty',
      code: 'empty-field',
    );
  }

  static ValidationException invalidLocation() {
    return ValidationException(
      message: 'Please select a valid location on the map',
      code: 'invalid-location',
    );
  }
}
