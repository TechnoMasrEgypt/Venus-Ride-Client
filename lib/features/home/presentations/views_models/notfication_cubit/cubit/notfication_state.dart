part of 'notfication_cubit.dart';

abstract class NotficationState extends Equatable {
  const NotficationState();

  @override
  List<Object> get props => [];
}

class NotficationInitial extends NotficationState {}

class NotficationError extends NotficationState {}

class NotficationSuc extends NotficationState {}
