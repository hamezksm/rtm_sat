import 'package:equatable/equatable.dart';

class VisitsListFilterState extends Equatable {
  final String searchQuery;
  final String? statusFilter;

  const VisitsListFilterState({this.searchQuery = '', this.statusFilter});

  VisitsListFilterState copyWith({String? searchQuery, String? statusFilter}) {
    return VisitsListFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }

  @override
  List<Object?> get props => [searchQuery, statusFilter];
}
