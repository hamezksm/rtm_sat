import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rtm_sat/features/activities/domain/entities/activity.dart';
import 'package:rtm_sat/features/activities/domain/repositories/activity_repository.dart';
import 'package:rtm_sat/features/customers/domain/entities/customer.dart';
import 'package:rtm_sat/features/customers/domain/repositories/customer_repository.dart';
import '../../domain/entities/visit.dart';

part 'visit_form_state.dart';

class VisitFormCubit extends Cubit<VisitFormState> {
  final CustomerRepository _customerRepository;
  final ActivityRepository _activityRepository;

  VisitFormCubit({
    required CustomerRepository customerRepository,
    required ActivityRepository activityRepository,
    Visit? initialVisit,
  }) : _customerRepository = customerRepository,
       _activityRepository = activityRepository,
       super(VisitFormState.initial(initialVisit));

  Future<void> initialize() async {
    emit(state.copyWith(isLoading: true));

    try {
      final customers = await _customerRepository.getCustomers();
      final activities = await _activityRepository.getActivities();

      // Find the selected customer more explicitly
      Customer? selectedCustomer;
      if (state.customerId != null) {
        selectedCustomer = customers.firstWhere(
          (c) => c.id == state.customerId,
        );

        log(
          'Debug: Customer ID ${state.customerId}, found: ${selectedCustomer.name}',
        );
      }

      emit(
        state.copyWith(
          customers: customers,
          activities: activities,
          selectedCustomer: selectedCustomer,
          isLoading: false,
        ),
      );
    } catch (e) {
      log('Error initializing form: $e');
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  void setCustomer(Customer? customer) {
    emit(state.copyWith(selectedCustomer: customer, customerId: customer?.id));
  }

  void setVisitDate(DateTime date) {
    emit(state.copyWith(visitDate: date));
  }

  void setStatus(String status) {
    emit(state.copyWith(status: status));
  }

  void setLocation(String location) {
    emit(state.copyWith(location: location));
  }

  void setNotes(String notes) {
    emit(state.copyWith(notes: notes));
  }

  void toggleActivity(String activityId) {
    final selectedActivities = List<String>.from(state.selectedActivities);

    if (selectedActivities.contains(activityId)) {
      selectedActivities.remove(activityId);
    } else {
      selectedActivities.add(activityId);
    }

    emit(state.copyWith(selectedActivities: selectedActivities));
  }

  Visit buildVisit() {
    return Visit(
      id: state.id,
      customerId: state.customerId ?? 0,
      visitDate: state.visitDate,
      status: state.status,
      location: state.location,
      notes: state.notes,
      activitiesDone: state.selectedActivities,
      createdAt: state.createdAt,
      isSynced: state.isSynced,
    );
  }
}
