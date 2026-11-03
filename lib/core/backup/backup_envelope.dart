import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/logging/app_log.dart';

/// The outer shape of a backup file, the only shape a restore accepts.
///
/// The header comes first so a foreign, newer or damaged file is refused by
/// it before any section is read:
///
/// ```json
/// {
///   "format": "fasomo.backup",
///   "formatVersion": 1,
///   "appVersion": "1.0.0",
///   "exportedAtUtc": "2026-11-02T10:15:00.000Z",
///   "sectionsSha256": "…",
///   "sections": { "calendar": { … }, "reminders": { … }, … }
/// }
/// ```
///
/// The checksum is SHA-256 over the UTF-8 of `sections` encoded compactly
/// with every object's keys sorted, so it is independent of indentation.
final class BackupEnvelope {
  const new({
    required this.formatVersion,
    required this.appVersion,
    required this.exportedAtUtc,
    required this.sections,
  });

  /// Marks a file as a Fasomo backup.
  static const String format = 'fasomo.backup';

  /// The envelope shape this app writes and the newest it reads. Bump it when
  /// an older app could no longer read what this one writes.
  static const int currentFormatVersion = 1;

  final int formatVersion;

  /// The app that wrote the file; for support, never a compatibility check.
  final String appVersion;

  final DateTime exportedAtUtc;

  /// Each section's data by section id.
  final Map<String, Object?> sections;

  /// The file's text: indented JSON with sorted section keys, so the same
  /// data always produces the same bytes.
  String encode() {
    final canonical = _canonical(sections);
    final file = {
      'format': format,
      'formatVersion': formatVersion,
      'appVersion': appVersion,
      'exportedAtUtc': exportedAtUtc.toUtc().toIso8601String(),
      'sectionsSha256': checksumOf(canonical),
      'sections': canonical,
    };
    return '${const JsonEncoder.withIndent('  ').convert(file)}\n';
  }

  /// The checksum written for [sections].
  static String checksumOf(Object? sections) =>
      sha256.convert(utf8.encode(jsonEncode(_canonical(sections)))).toString();

  /// Reads [contents], checking the header and then the checksum.
  static Result<BackupEnvelope, BackupFailure> decode(String contents) {
    final Object? json;
    try {
      json = jsonDecode(contents);
    } on FormatException catch (e, st) {
      AppLog.error('backup.decode', e, st);
      return const Err(BackupMalformed());
    }
    switch (json) {
      case {'format': format, 'formatVersion': final int version}
          when version > currentFormatVersion:
        return Err(
          BackupFormatTooNew(found: version, supported: currentFormatVersion),
        );
      case {
            'format': format,
            'formatVersion': final int version,
            'appVersion': final String appVersion,
            'exportedAtUtc': final String exportedAt,
            'sectionsSha256': final String checksum,
            'sections': final Map<String, Object?> sections,
          }
          when version >= 1:
        final exportedAtUtc = DateTime.tryParse(exportedAt);
        if (exportedAtUtc == null || !exportedAtUtc.isUtc) {
          return const Err(BackupMalformed());
        }
        if (checksumOf(sections) != checksum) {
          return const Err(BackupChecksumMismatch());
        }
        return Ok(
          BackupEnvelope(
            formatVersion: version,
            appVersion: appVersion,
            exportedAtUtc: exportedAtUtc,
            sections: sections,
          ),
        );
      default:
        return const Err(BackupMalformed());
    }
  }

  /// [value] with every map's keys sorted, recursively.
  static Object? _canonical(Object? value) => switch (value) {
    final Map<String, Object?> map => {
      for (final key in map.keys.toList()..sort()) key: _canonical(map[key]),
    },
    final List<Object?> list => [for (final item in list) _canonical(item)],
    _ => value,
  };
}
