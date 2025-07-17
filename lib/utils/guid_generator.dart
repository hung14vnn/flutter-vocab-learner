import 'package:uuid/uuid.dart';

/// Utility class for generating UUIDs/GUIDs
class GuidGenerator {
  static const Uuid _uuid = Uuid();

  /// Generates a new version 4 UUID (random)
  /// Returns a string in the format: xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx
  static String generateGuid() {
    return _uuid.v4();
  }

  /// Generates a new version 4 UUID without hyphens
  /// Returns a string in the format: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  static String generateGuidWithoutHyphens() {
    return _uuid.v4().replaceAll('-', '');
  }

  /// Generates a new version 1 UUID (time-based)
  /// Returns a string in the format: xxxxxxxx-xxxx-1xxx-yxxx-xxxxxxxxxxxx
  static String generateTimeBasedGuid() {
    return _uuid.v1();
  }

  /// Generates a short ID (first 8 characters of UUID)
  /// Useful for shorter identifiers when full UUID is not needed
  static String generateShortId() {
    return _uuid.v4().substring(0, 8);
  }

  /// Validates if a string is a valid UUID format
  static bool isValidGuid(String guid) {
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    return uuidRegex.hasMatch(guid);
  }

  /// Validates if a string is a valid UUID format (with or without hyphens)
  static bool isValidGuidAnyFormat(String guid) {
    // Check with hyphens
    if (isValidGuid(guid)) return true;

    // Check without hyphens (32 hex characters)
    final uuidWithoutHyphensRegex = RegExp(r'^[0-9a-fA-F]{32}$');
    return uuidWithoutHyphensRegex.hasMatch(guid);
  }

  /// Formats a UUID string by adding hyphens if they're missing
  static String formatGuid(String guid) {
    if (guid.length == 32 && !guid.contains('-')) {
      return '${guid.substring(0, 8)}-${guid.substring(8, 12)}-${guid.substring(12, 16)}-${guid.substring(16, 20)}-${guid.substring(20)}';
    }
    return guid;
  }

  /// Removes hyphens from a UUID string
  static String removeHyphensFromGuid(String guid) {
    return guid.replaceAll('-', '');
  }
}
