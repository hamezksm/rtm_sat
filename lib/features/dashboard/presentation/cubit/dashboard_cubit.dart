import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rtm_sat/features/dashboard/domain/entities/dashboard_item.dart';
import 'package:rtm_sat/features/dashboard/domain/usecases/get_dashboard_data_use_case.dart';

// State
abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final List<DashboardItem> items;

  const DashboardLoaded(this.items);

  @override
  List<Object> get props => [items];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object> get props => [message];
}

// Cubit
class DashboardCubit extends Cubit<DashboardState> {
  final GetDashboardDataUseCase getDashboardDataUseCase;

  DashboardCubit(this.getDashboardDataUseCase) : super(DashboardInitial());

  Future<void> loadDashboardItems() async {
    emit(DashboardLoading());
    try {
      final items = await getDashboardDataUseCase();
      emit(DashboardLoaded(items));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}
