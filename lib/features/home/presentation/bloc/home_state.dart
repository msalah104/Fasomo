part of 'home_bloc.dart';

enum HomeStatus { initial, loading, success, error }

class HomeState extends Equatable {
  const new({
    this.status = HomeStatus.initial,
    this.currentDate,
    this.upcomingFastingDays = const [],
    this.failure,
  });

  final HomeStatus status;
  final HijriDateInfo? currentDate;
  final List<FastingDay> upcomingFastingDays;
  final CalendarFailure? failure;

  HomeState copyWith({
    HomeStatus? status,
    HijriDateInfo? currentDate,
    List<FastingDay>? upcomingFastingDays,
    CalendarFailure? failure,
  }) {
    return HomeState(
      status: status ?? this.status,
      currentDate: currentDate ?? this.currentDate,
      upcomingFastingDays: upcomingFastingDays ?? this.upcomingFastingDays,
      failure: status == HomeStatus.error ? failure ?? this.failure : null,
    );
  }

  @override
  List<Object?> get props => [
    status,
    currentDate,
    upcomingFastingDays,
    failure,
  ];
}
