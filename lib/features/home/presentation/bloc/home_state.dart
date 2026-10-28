part of 'home_bloc.dart';

enum HomeStatus { initial, loading, success, error }

class HomeState extends Equatable {
  const new({
    this.status = HomeStatus.initial,
    this.currentDate,
    this.upcomingFastingDays = const [],
    this.locale = const Locale('en', 'US'),
    this.failure,
  });

  final HomeStatus status;
  final HijriDateInfo? currentDate;
  final List<FastingDay> upcomingFastingDays;
  final Locale locale;
  final CalendarFailure? failure;

  HomeState copyWith({
    HomeStatus? status,
    HijriDateInfo? currentDate,
    List<FastingDay>? upcomingFastingDays,
    Locale? locale,
    CalendarFailure? failure,
  }) {
    return HomeState(
      status: status ?? this.status,
      currentDate: currentDate ?? this.currentDate,
      upcomingFastingDays: upcomingFastingDays ?? this.upcomingFastingDays,
      locale: locale ?? this.locale,
      failure: status == HomeStatus.error ? failure ?? this.failure : null,
    );
  }

  @override
  List<Object?> get props => [
    status,
    currentDate,
    upcomingFastingDays,
    locale,
    failure,
  ];
}
