import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rtm_sat/core/init/app_init_state.dart';
import 'package:rtm_sat/core/init/prefetch_init_data.dart';

class AppInitCubit extends Cubit<AppInitState> {
  final PrefetchInitData prefetch;

  AppInitCubit(this.prefetch) : super(AppInitInitial());

  Future<void> initialize() async {
    emit(AppInitLoading());

    try {
      final response = await prefetch.prefetchAll();

      if (!response) {
        emit(AppInitFailure('Failed to prefetch data'));
        return;
      }
      // If prefetching is successful, emit success state
      emit(AppInitSuccess());
    } catch (e) {
      emit(AppInitFailure(e.toString()));
    }
  }
}
