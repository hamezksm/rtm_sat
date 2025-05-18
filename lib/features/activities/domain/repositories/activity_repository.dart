import '../entities/activity.dart';

abstract class ActivityRepository {
  /// Get a list of all activities
  Future<List<Activity>> getActivities({bool forceRefresh = false});

  /// Get activities by IDs
  Future<List<Activity>> getActivitiesByIds(List<String> ids);
}
