part of 'check_ride_cubit.dart';

sealed class CheckRideState {
  const CheckRideState();
}

final class CheckRideInitial extends CheckRideState {}

final class StartCheckRide extends CheckRideState {}

final class ErrorCheckRide extends CheckRideState {
  final String message;

  ErrorCheckRide({required this.message});
}

final class CheckRideSuccess extends CheckRideState {
  final String message;

  CheckRideSuccess({required this.message});
}
