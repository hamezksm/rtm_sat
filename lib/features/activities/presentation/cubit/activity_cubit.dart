import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/activity_repository.dart';
import 'activity_state.dart';

class ActivityCubit extends Cubit<ActivityState> {
  final ActivityRepository repository;

  ActivityCubit({required this.repository}) : super(ActivityInitial());

  Future<void> getActivities() async {
    emit(ActivityLoading());

    try {
      final activities = await repository.getActivities();
      emit(ActivitiesLoaded(activities));
    } catch (e) {
      emit(ActivityError(e.toString()));
    }
  }

  Future<void> refreshActivities() async {
    final currentState = state;

    try {
      // Don't show loading indicator during refresh
      final activities = await repository.getActivities(forceRefresh: true);
      emit(ActivitiesLoaded(activities));
    } catch (e) {
      // If refresh fails, go back to previous state if it was Loaded
      if (currentState is ActivitiesLoaded) {
        emit(currentState);
      } else {
        emit(ActivityError(e.toString()));
      }
    }
  }

  Future<void> getActivityById(String id) async {
    emit(ActivityLoading());

    try {
      final activities = await repository.getActivitiesByIds([id]);
      if (activities.isNotEmpty) {
        emit(ActivitiesLoaded(activities));
      } else {
        emit(const ActivityError('Activity not found'));
      }
    } catch (e) {
      emit(ActivityError(e.toString()));
    }
  }
}
