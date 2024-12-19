part of 'check_ride_cubit.dart';

sealed class CheckRideState {
  const CheckRideState();
}

final class CheckRideInitial extends CheckRideState {}

final class StartCheckRide extends CheckRideState {}

final class ErrorCheckRide extends CheckRideState {}

final class CheckRideSuccess extends CheckRideState {}
