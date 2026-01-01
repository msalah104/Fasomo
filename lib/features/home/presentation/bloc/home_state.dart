part of 'home_bloc.dart';

enum HomeStatus { initial, loading, success, error }

class HomeState extends Equatable {
  final HomeStatus status;
  final HijriDateInfo? currentDate;
  final List<FastingDay> upcomingFastingDays;
  final Locale locale;
  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.currentDate,
    this.upcomingFastingDays = const [],
    this.locale = const Locale('en', 'US'),
    this.errorMessage,
  });

  HomeState copyWith({
    HomeStatus? status,
    HijriDateInfo? currentDate,
    List<FastingDay>? upcomingFastingDays,
    Locale? locale,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      currentDate: currentDate ?? this.currentDate,
      upcomingFastingDays: upcomingFastingDays ?? this.upcomingFastingDays,
      locale: locale ?? this.locale,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        currentDate,
        upcomingFastingDays,
        locale,
        errorMessage,
      ];
}
