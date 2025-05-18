import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/visit.dart';
import '../../domain/usecases/create_visit.dart';
import '../../domain/usecases/delete_visit.dart';
import '../../domain/usecases/get_visits.dart';
import '../../domain/usecases/sync_visits.dart';
import '../../domain/usecases/update_visit.dart';
import '../../domain/usecases/get_visit_by_id.dart';

part 'visits_state.dart';

class VisitsCubit extends Cubit<VisitsState> {
  final GetVisitsUseCase getVisitsUseCase;
  final CreateVisitUseCase createVisitUseCase;
  final UpdateVisitUseCase updateVisitUseCase;
  final DeleteVisitUseCase deleteVisitUseCase;
  final SyncVisitsUseCase syncVisitsUseCase;
  final GetVisitByIdUseCase getVisitByIdUseCase;

  VisitsCubit({
    required this.getVisitsUseCase,
    required this.createVisitUseCase,
    required this.updateVisitUseCase,
    required this.deleteVisitUseCase,
    required this.syncVisitsUseCase,
    required this.getVisitByIdUseCase,
  }) : super(VisitsInitial());

  Future<void> getVisits() async {
    emit(VisitsLoading());
    try {
      final visits = await getVisitsUseCase();
      emit(VisitsLoaded(visits: visits));
    } catch (e) {
      emit(VisitsError(message: e.toString()));
    }
  }

  Future<void> createVisit(Visit visit) async {
    emit(VisitsLoading());
    try {
      await createVisitUseCase(visit);
      emit(const VisitCreated());
    } catch (e) {
      emit(VisitsError(message: e.toString()));
    }
  }

  Future<void> updateVisit(Visit visit) async {
    emit(VisitsLoading());
    try {
      await updateVisitUseCase(visit);
      emit(const VisitUpdated());
    } catch (e) {
      emit(VisitsError(message: e.toString()));
    }
  }

  Future<void> deleteVisit(int id) async {
    emit(VisitsLoading());
    try {
      await deleteVisitUseCase(id);
      emit(const VisitDeleted());
    } catch (e) {
      emit(VisitsError(message: e.toString()));
    }
  }

  Future<void> syncVisits() async {
    emit(VisitsLoading());
    try {
      // Perform sync operation
      await syncVisitsUseCase();

      // Sync complete, now reload the data
      final visits = await getVisitsUseCase();

      // Emit loaded state with the fresh data
      emit(VisitsLoaded(visits: visits));

      // Also emit sync success for UI feedback
      emit(const VisitsSynced());
    } catch (e) {
      emit(VisitsError(message: e.toString()));
    }
  }

  Future<void> getVisitById(int id) async {
    emit(VisitsLoading());
    try {
      final visit = await getVisitByIdUseCase(id);
      if (visit != null) {
        emit(VisitLoaded(visit: visit));
      } else {
        emit(VisitNotFound(id));
      }
    } catch (e) {
      emit(VisitsError(message: e.toString()));
    }
  }
}
