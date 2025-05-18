import 'dart:developer';

import 'package:rtm_sat/features/customers/domain/repositories/customer_repository.dart';
import 'package:rtm_sat/features/activities/domain/repositories/activity_repository.dart';

class PrefetchInitData {
  final CustomerRepository customerRepo;
  final ActivityRepository activityRepo;

  PrefetchInitData({required this.customerRepo, required this.activityRepo});

  Future<bool> prefetchAll() async {
    try {
      // Execute these in parallel
      await Future.wait([
        customerRepo.getCustomers(),
        activityRepo.getActivities(),
      ]);

      // If both calls are successful, return true
      return true;
    } catch (e) {
      log('Prefetch failed: $e');
      throw Exception('Failed to prefetch data: $e');
    }
  }
}
