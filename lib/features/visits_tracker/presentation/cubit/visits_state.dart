part of 'visits_cubit.dart';

abstract class VisitsState extends Equatable {
  const VisitsState();

  @override
  List<Object> get props => [];
}

class VisitsInitial extends VisitsState {}

class VisitsLoading extends VisitsState {}

class VisitsLoaded extends VisitsState {
  final List<Visit> visits;

  const VisitsLoaded({required this.visits});

  @override
  List<Object> get props => [visits];
}

class VisitLoaded extends VisitsState {
  final Visit visit;

  const VisitLoaded({required this.visit});

  @override
  List<Object> get props => [visit];
}

class VisitsError extends VisitsState {
  final String message;

  const VisitsError({required this.message});

  @override
  List<Object> get props => [message];
}

class VisitCreated extends VisitsState {
  const VisitCreated();
}

class VisitUpdated extends VisitsState {
  const VisitUpdated();
}

class VisitDeleted extends VisitsState {
  const VisitDeleted();
}

class VisitsSynced extends VisitsState {
  const VisitsSynced();
}

class VisitNotFound extends VisitsState {
  final int id;

  const VisitNotFound(this.id);

  @override
  List<Object> get props => [id];
}
