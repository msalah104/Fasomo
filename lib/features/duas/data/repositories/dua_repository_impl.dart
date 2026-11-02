import 'package:fasomo/features/duas/data/datasources/dua_catalog.dart';
import 'package:fasomo/features/duas/domain/entities/dua.dart';
import 'package:fasomo/features/duas/domain/repositories/dua_repository.dart';

/// Serves the collection compiled into the app, so it works offline.
class DuaRepositoryImpl implements DuaRepository {
  const new({this.catalog = DuaCatalog.all});

  final List<Dua> catalog;

  @override
  List<Dua> getAll() => catalog;
}
