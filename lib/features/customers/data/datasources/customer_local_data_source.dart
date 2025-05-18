import 'package:hive_flutter/hive_flutter.dart';
import '../models/customer_model.dart';

abstract class CustomerLocalDataSource {
  Future<List<CustomerModel>> getCustomers();
  Future<void> cacheCustomers(List<CustomerModel> customers);
  Future<bool> hasCustomers();
}

class CustomerLocalDataSourceImpl implements CustomerLocalDataSource {
  final Box<CustomerModel> customerBox;

  CustomerLocalDataSourceImpl({required this.customerBox});

  @override
  Future<List<CustomerModel>> getCustomers() async {
    return customerBox.values.toList();
  }

  @override
  Future<void> cacheCustomers(List<CustomerModel> customers) async {
    // Clear existing data
    await customerBox.clear();

    // Add new data
    for (final customer in customers) {
      await customerBox.put(customer.id.toString(), customer);
    }
  }

  @override
  Future<bool> hasCustomers() async {
    return customerBox.isNotEmpty;
  }
}
