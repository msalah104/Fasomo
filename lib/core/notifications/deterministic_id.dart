import 'dart:convert';

/// Stable 31-bit notification ids.
///
/// The id folds in the reminder, the occurrence, the resolved fire time and
/// the content, so unchanged input maps to the same id (reconcile is a no-op)
/// while an edited time or text yields a new id (old one cancelled, new one
/// scheduled). FNV-1a is used because `String.hashCode` is not guaranteed to
/// be stable across runs.
abstract final class DeterministicId {
  static const int _fnvOffset = 0x811c9dc5;
  static const int _fnvPrime = 0x01000193;

  static int of(List<Object> parts) {
    var hash = _fnvOffset;
    for (final byte in utf8.encode(parts.join('\u0000'))) {
      hash ^= byte;
      hash = (hash * _fnvPrime) & 0xffffffff;
    }
    // Android and iOS both accept a positive 32-bit signed int.
    return hash & 0x7fffffff;
  }
}
