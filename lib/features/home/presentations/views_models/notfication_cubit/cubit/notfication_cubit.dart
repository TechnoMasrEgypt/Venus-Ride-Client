import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taxi/core/utils/print_helper.dart';
import '../../../../data/repos/notfication_repo.dart';
part 'notfication_state.dart';

class NotficationCubit extends Cubit<NotficationState> {
  NotficationCubit() : super(NotficationInitial());
  static NotficationCubit of(context) => BlocProvider.of(context);
  final notficationRepo = NotficationRepo();

  Future sendNotfication() async {
    emit(NotficationInitial());
    final res = await notficationRepo.notficationRepo();
    res.fold(
      (err) {
        PrintHalper.printError('Error');
        emit(NotficationError());
      },
      (res) async {
        emit(NotficationSuc());
        PrintHalper.printSuccess('Sucess');
      },
    );
  }
}
