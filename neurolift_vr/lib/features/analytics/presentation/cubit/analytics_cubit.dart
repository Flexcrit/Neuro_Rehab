import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/analytics_entity.dart';
import '../../domain/usecases/get_recovery_trends.dart';

part 'analytics_state.dart';

/// Cubit managing the state of the Analytics page.
class AnalyticsCubit extends Cubit<AnalyticsState> {
  final GetRecoveryTrends getRecoveryTrends;

  AnalyticsCubit({required this.getRecoveryTrends})
      : super(const AnalyticsInitial());

  Future<void> loadAnalytics() async {
    emit(const AnalyticsLoading());

    final result = await getRecoveryTrends(const NoParams());

    result.fold(
      (failure) => emit(AnalyticsError(message: failure.message)),
      (data) => emit(AnalyticsLoaded(analytics: data)),
    );
  }
}
