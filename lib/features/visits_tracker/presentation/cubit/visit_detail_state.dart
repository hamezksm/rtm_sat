part of 'visit_detail_cubit.dart';

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
