part of 'get_direction_cubit.dart';

abstract class GetDirectionState {
  final String travelState;
  const GetDirectionState(this.travelState);
}

final class GetDirectionInitial extends GetDirectionState {
  const GetDirectionInitial() : super("وافق السائق");
}

final class GetDirectionLoading extends GetDirectionState {
  const GetDirectionLoading(String travelState) : super(travelState);
}

final class GetDirectionLoad extends GetDirectionState {
  const GetDirectionLoad(String travelState) : super(travelState);
}

final class GetDirectionFinish extends GetDirectionState {
  const GetDirectionFinish(String travelState) : super(travelState);
}

final class GetDirectionFinish2 extends GetDirectionState {
  const GetDirectionFinish2(String travelState) : super(travelState);
}

final class GetDirectionGetRequest extends GetDirectionState {
  const GetDirectionGetRequest(String travelState) : super(travelState);
}

final class GetDirectionDoneRequest extends GetDirectionState {
  const GetDirectionDoneRequest(String travelState) : super(travelState);
}

final class GetDriverDataLoaded extends GetDirectionState {
  const GetDriverDataLoaded(String travelState) : super(travelState);
}

final class GetDriverDataLoading extends GetDirectionState {
  const GetDriverDataLoading(String travelState) : super(travelState);
}

final class GetDriverDataLoadingDone extends GetDirectionState {
  const GetDriverDataLoadingDone(String travelState) : super(travelState);
}

final class GetDriverDataLoad extends GetDirectionState {
  const GetDriverDataLoad(String travelState) : super(travelState);
}

final class PolyLoaded extends GetDirectionState {
  const PolyLoaded(String travelState) : super(travelState);
}

final class PolyLoading extends GetDirectionState {
  const PolyLoading(String travelState) : super(travelState);
}

final class TestNull extends GetDirectionState {
  const TestNull() : super("No State");
} // class GetDirectionGetRequest extends GetDirectionState {}
// class GetDirectionDoneRequest extends GetDirectionState {}
