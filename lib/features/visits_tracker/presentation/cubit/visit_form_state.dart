part of 'visit_form_cubit.dart';

class VisitFormState extends Equatable {
  final int? id;
  final int? customerId;
  final DateTime visitDate;
  final String status;
  final String location;
  final String notes;
  final List<String> selectedActivities;
  final DateTime? createdAt;
  final bool isSynced;
  
  // Form state
  final Customer? selectedCustomer;
  final List<Customer> customers;
  final List<Activity> activities;
  final bool isLoading;
  final String? error;

  const VisitFormState({
    this.id,
    this.customerId,
    required this.visitDate,
    required this.status,
    required this.location,
    required this.notes,
    required this.selectedActivities,
    this.createdAt,
    required this.isSynced,
    this.selectedCustomer,
    required this.customers,
    required this.activities,
    required this.isLoading,
    this.error,
  });

  factory VisitFormState.initial(Visit? visit) {
    return VisitFormState(
      id: visit?.id,
      customerId: visit?.customerId,
      visitDate: visit?.visitDate ?? DateTime.now(),
      status: visit?.status ?? 'Pending',
      location: visit?.location ?? '',
      notes: visit?.notes ?? '',
      selectedActivities: visit?.activitiesDone ?? [],
      createdAt: visit?.createdAt,
      isSynced: visit?.isSynced ?? false,
      selectedCustomer: null,
      customers: [],
      activities: [],
      isLoading: false,
      error: null,
    );
  }

  VisitFormState copyWith({
    int? id,
    int? customerId,
    DateTime? visitDate,
    String? status,
    String? location,
    String? notes,
    List<String>? selectedActivities,
    DateTime? createdAt,
    bool? isSynced,
    Customer? selectedCustomer,
    List<Customer>? customers,
    List<Activity>? activities,
    bool? isLoading,
    String? error,
  }) {
    return VisitFormState(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      visitDate: visitDate ?? this.visitDate,
      status: status ?? this.status,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      selectedActivities: selectedActivities ?? this.selectedActivities,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
      selectedCustomer: selectedCustomer ?? this.selectedCustomer,
      customers: customers ?? this.customers,
      activities: activities ?? this.activities,
      isLoading: isLoading ?? this.isLoading,
      error: error,  // Null means no error
    );
  }

  @override
  List<Object?> get props => [
    id,
    customerId,
    visitDate,
    status,
    location,
    notes,
    selectedActivities,
    createdAt,
    isSynced,
    selectedCustomer,
    customers,
    activities,
    isLoading,
    error,
  ];
}