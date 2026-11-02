part of 'ramadan_bloc.dart';

class RamadanState extends Equatable {
  const new({
    required this.overview,
    this.checklist,
    this.loadFailure,
    this.saveFailure,
  });

  final RamadanOverview overview;

  /// Today's checklist during Ramadan; `null` before it, or when it could
  /// not be read ([loadFailure]).
  final RamadanChecklist? checklist;

  /// Set when today's checklist could not be read.
  final StorageFailure? loadFailure;

  /// Set on the state right after a checklist change could not be saved
  /// (the change is undone); cleared by the next state.
  final StorageFailure? saveFailure;

  /// A copy with [overview] or [checklist] replaced. [saveFailure] is only
  /// kept when given, so a failure is reported once.
  RamadanState copyWith({
    RamadanOverview? overview,
    RamadanChecklist? checklist,
    StorageFailure? saveFailure,
  }) => RamadanState(
    overview: overview ?? this.overview,
    checklist: checklist ?? this.checklist,
    loadFailure: loadFailure,
    saveFailure: saveFailure,
  );

  @override
  List<Object?> get props => [overview, checklist, loadFailure, saveFailure];
}
