import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_local_data_source.dart';
import '../datasources/customer_remote_data_source.dart';
import '../../../../core/network/network_info.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerRemoteDataSource customerRemoteDataSource;
  final CustomerLocalDataSource customerLocalDataSource;
  final NetworkInfo networkInfo;

  CustomerRepositoryImpl({
    required this.customerRemoteDataSource,
    required this.customerLocalDataSource,
    required this.networkInfo,
  });

  @override
  Future<List<Customer>> getCustomers({bool forceRefresh = false}) async {
    // Determine if we should try remote data source
    final shouldFetchRemote =
        forceRefresh || !(await customerLocalDataSource.hasCustomers());

    if (shouldFetchRemote && await networkInfo.isConnected) {
      try {
        // Get from remote and cache locally
        final remoteCustomers = await customerRemoteDataSource.getCustomers();
        await customerLocalDataSource.cacheCustomers(remoteCustomers);
        return remoteCustomers;
      } catch (e) {
        // On error, try local data
        final hasLocalData = await customerLocalDataSource.hasCustomers();
        if (hasLocalData) {
          return customerLocalDataSource.getCustomers();
        } else {
          throw Exception(
            'No internet connection and no cached data available',
          );
        }
      }
    } else {
      // Use local data
      final hasLocalData = await customerLocalDataSource.hasCustomers();
      if (hasLocalData) {
        return customerLocalDataSource.getCustomers();
      } else if (await networkInfo.isConnected) {
        // If no local data but we have internet, try remote as fallback
        final remoteCustomers = await customerRemoteDataSource.getCustomers();
        await customerLocalDataSource.cacheCustomers(remoteCustomers);
        return remoteCustomers;
      } else {
        throw Exception('No internet connection and no cached data available');
      }
    }
  }
}
