part of 'analytics_cubit.dart';

abstract class AnalyticsState extends Equatable {
  const AnalyticsState();
  @override
  List<Object?> get props => [];
}

class AnalyticsInitial extends AnalyticsState {
  const AnalyticsInitial();
}

class AnalyticsLoading extends AnalyticsState {
  const AnalyticsLoading();
}

class AnalyticsLoaded extends AnalyticsState {
  final AnalyticsEntity analytics;
  const AnalyticsLoaded({required this.analytics});
  @override
  List<Object?> get props => [analytics];
}

class AnalyticsError extends AnalyticsState {
  final String message;
  const AnalyticsError({required this.message});
  @override
  List<Object?> get props => [message];
}
