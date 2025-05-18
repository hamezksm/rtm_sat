import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/visit.dart';
import '../../domain/usecases/update_visit.dart';

// States
abstract class VisitDetailState extends Equatable {
  @override
  List<Object?> get props => [];
}

class VisitDetailInitial extends VisitDetailState {}

class VisitDetailLoading extends VisitDetailState {}

class VisitDetailLoaded extends VisitDetailState {
  final Visit visit;

  VisitDetailLoaded(this.visit);

  @override
  List<Object?> get props => [visit];
}

class VisitDetailError extends VisitDetailState {
  final String message;

  VisitDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

class VisitUpdateLoading extends VisitDetailState {}

class VisitUpdateSuccess extends VisitDetailState {}

class VisitUpdateError extends VisitDetailState {
  final String message;

  VisitUpdateError(this.message);

  @override
  List<Object?> get props => [message];
}

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
