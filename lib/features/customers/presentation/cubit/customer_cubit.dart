import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/customer_repository.dart';
import 'customer_state.dart';

class CustomerCubit extends Cubit<CustomerState> {
  final CustomerRepository repository;
  
  CustomerCubit({required this.repository}) : super(CustomerInitial());
  
  Future<void> getCustomers() async {
    emit(CustomerLoading());
    
    try {
      final customers = await repository.getCustomers();
      emit(CustomersLoaded(customers));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }
  
  Future<void> refreshCustomers() async {
    try {
      // Don't show loading indicator during refresh
      final customers = await repository.getCustomers(forceRefresh: true);
      emit(CustomersLoaded(customers));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }
}