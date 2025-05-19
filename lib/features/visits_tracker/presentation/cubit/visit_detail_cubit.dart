import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/visit.dart';
import '../../domain/usecases/update_visit.dart';

part 'visit_detail_state.dart';

// Cubit
class VisitDetailCubit extends Cubit<VisitDetailState> {
  final UpdateVisitUseCase updateVisitUseCase;

  VisitDetailCubit({required this.updateVisitUseCase})
    : super(VisitDetailInitial());

  Future<void> updateVisit(Visit visit) async {
    emit(VisitUpdateLoading());
    try {
      await updateVisitUseCase(visit);
      emit(VisitUpdateSuccess());
      // Reload visit details after updating
    } catch (e) {
      emit(VisitUpdateError(e.toString()));
    }
  }
}
