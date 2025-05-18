import '../entities/customer.dart';

abstract class CustomerRepository {
  /// Get a list of all customers
  Future<List<Customer>> getCustomers({bool forceRefresh});
}
