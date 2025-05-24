import 'package:flutter_bloc/flutter_bloc.dart';
import 'visits_list_filter_state.dart';

class VisitsListFilterCubit extends Cubit<VisitsListFilterState> {
  VisitsListFilterCubit() : super(const VisitsListFilterState());

  void setSearchQuery(String query) => emit(state.copyWith(searchQuery: query));

  void setStatusFilter(String? status) =>
      emit(state.copyWith(statusFilter: status));
}
