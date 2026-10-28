part of 'home_bloc.dart';

enum HomeStatus { initial, loading, success, error }

class HomeState extends Equatable {
  const new({
    this.status = HomeStatus.initial,
    this.currentDate,
    this.upcomingFastingDays = const [],
    this.selectedDate,
    this.failure,
  });

  final HomeStatus status;
  final HijriDateInfo? currentDate;
  final List<FastingDay> upcomingFastingDays;

  /// The day picked in the week strip, which [upcomingFastingDays] starts
  /// from. Today after every load.
  final DateTime? selectedDate;
  final CalendarFailure? failure;

  HomeState copyWith({
    HomeStatus? status,
    HijriDateInfo? currentDate,
    List<FastingDay>? upcomingFastingDays,
    DateTime? selectedDate,
    CalendarFailure? failure,
  }) {
    return HomeState(
      status: status ?? this.status,
      currentDate: currentDate ?? this.currentDate,
      upcomingFastingDays: upcomingFastingDays ?? this.upcomingFastingDays,
      selectedDate: selectedDate ?? this.selectedDate,
      failure: status == HomeStatus.error ? failure ?? this.failure : null,
    );
  }

  @override
  List<Object?> get props => [
    status,
    currentDate,
    upcomingFastingDays,
    selectedDate,
    failure,
  ];
}
