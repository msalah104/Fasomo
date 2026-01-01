import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/fasting_day.dart';
import '../../domain/entities/hijri_date_info.dart';
import '../../domain/usecases/get_current_hijri_date.dart';
import '../../domain/usecases/get_upcoming_fasting_days.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetCurrentHijriDate getCurrentHijriDate;
  final GetUpcomingFastingDays getUpcomingFastingDays;

  HomeBloc({
    required this.getCurrentHijriDate,
    required this.getUpcomingFastingDays,
  }) : super(const HomeState()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<ToggleLanguage>(_onToggleLanguage);
    on<RefreshHomeData>(_onRefreshHomeData);
  }

  Future<void> _onLoadHomeData(
    LoadHomeData event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(status: HomeStatus.loading));

    try {
      final languageCode = state.locale.languageCode;
      final currentDate = getCurrentHijriDate(languageCode);
      final fastingDays = getUpcomingFastingDays(languageCode);

      emit(state.copyWith(
        status: HomeStatus.success,
        currentDate: currentDate,
        upcomingFastingDays: fastingDays,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HomeStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onToggleLanguage(
    ToggleLanguage event,
    Emitter<HomeState> emit,
  ) async {
    final newLocale = state.locale.languageCode == 'en'
        ? const Locale('ar', 'SA')
        : const Locale('en', 'US');

    emit(state.copyWith(locale: newLocale));

    // Reload data with new language
    add(RefreshHomeData());
  }

  Future<void> _onRefreshHomeData(
    RefreshHomeData event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final languageCode = state.locale.languageCode;
      final currentDate = getCurrentHijriDate(languageCode);
      final fastingDays = getUpcomingFastingDays(languageCode);

      emit(state.copyWith(
        status: HomeStatus.success,
        currentDate: currentDate,
        upcomingFastingDays: fastingDays,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HomeStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
