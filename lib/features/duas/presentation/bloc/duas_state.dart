part of 'duas_bloc.dart';

enum DuasStatus { initial, ready }

/// The texts under one section heading.
class DuaSection extends Equatable {
  const new(this.category, this.duas);

  final DuaCategory category;

  /// Never empty.
  final List<Dua> duas;

  @override
  List<Object> get props => [category, duas];
}

class DuasState extends Equatable {
  const new({
    this.status = DuasStatus.initial,
    this.filter,
    this.duas = const [],
  });

  final DuasStatus status;

  /// The fast the page is narrowed to; `null` shows everything.
  final FastingType? filter;

  /// The texts to show, in display order.
  final List<Dua> duas;

  /// [duas] grouped by category, in category order, skipping empty ones.
  List<DuaSection> get sections => [
    for (final category in DuaCategory.values)
      if (duas.where((dua) => dua.category == category).toList()
          case final inCategory when inCategory.isNotEmpty)
        DuaSection(category, inCategory),
  ];

  DuasState copyWith({
    DuasStatus? status,
    FastingType? Function()? filter,
    List<Dua>? duas,
  }) => DuasState(
    status: status ?? this.status,
    filter: filter != null ? filter() : this.filter,
    duas: duas ?? this.duas,
  );

  @override
  List<Object?> get props => [status, filter, duas];
}
