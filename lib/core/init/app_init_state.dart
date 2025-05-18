import 'package:equatable/equatable.dart';

abstract class AppInitState extends Equatable {
  const AppInitState();

  @override
  List<Object> get props => [];
}

class AppInitInitial extends AppInitState {}

class AppInitLoading extends AppInitState {}

class AppInitSuccess extends AppInitState {}

class AppInitFailure extends AppInitState {
  final String message;

  const AppInitFailure(this.message);

  @override
  List<Object> get props => [message];
}
