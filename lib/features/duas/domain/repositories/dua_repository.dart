import 'package:fasomo/features/duas/domain/entities/dua.dart';

/// The bundled, offline collection of duas and hadith about fasting.
abstract interface class DuaRepository {
  /// Every text, in display order. The collection ships with the app, so
  /// reading it cannot fail.
  List<Dua> getAll();
}
