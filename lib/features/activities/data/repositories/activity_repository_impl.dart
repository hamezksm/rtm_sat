import '../../domain/entities/activity.dart';
import '../../domain/repositories/activity_repository.dart';
import '../datasources/activity_local_data_source.dart';
import '../datasources/activity_remote_data_source.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/error/failures.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  final ActivityRemoteDataSource remoteDataSource;
  final ActivityLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ActivityRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<List<Activity>> getActivities({bool forceRefresh = false}) async {
    // Check if data should be fetched from remote
    final shouldFetchRemote =
        forceRefresh || !(await localDataSource.hasActivities());

    if (shouldFetchRemote && await networkInfo.isConnected) {
      try {
        // Get from remote and cache locally
        final remoteActivities = await remoteDataSource.getActivities();
        await localDataSource.cacheActivities(remoteActivities);
        return remoteActivities;
      } catch (e) {
        // On error, try local data
        final hasLocalData = await localDataSource.hasActivities();
        if (hasLocalData) {
          return localDataSource.getActivities();
        } else {
          throw ServerFailure(
            'No internet connection and no cached data available',
          );
        }
      }
    } else {
      // Use local data
      final hasLocalData = await localDataSource.hasActivities();
      if (hasLocalData) {
        return localDataSource.getActivities();
      } else if (await networkInfo.isConnected) {
        // If no local data but we have internet, try remote as fallback
        final remoteActivities = await remoteDataSource.getActivities();
        await localDataSource.cacheActivities(remoteActivities);
        return remoteActivities;
      } else {
        throw ServerFailure(
          'No internet connection and no cached data available',
        );
      }
    }
  }

  @override
  Future<List<Activity>> getActivitiesByIds(List<String> ids) async {
    try {
      // Get all activities first
      final allActivities = await getActivities();

      // Filter activities by the provided IDs
      return allActivities
          .where((activity) => ids.contains(activity.id))
          .toList();
    } catch (e) {
      throw ServerFailure('Failed to get activities by IDs: ${e.toString()}');
    }
  }
}
