import 'package:hive_flutter/hive_flutter.dart';
import '../models/activity_model.dart';

abstract class ActivityLocalDataSource {
  Future<List<ActivityModel>> getActivities();
  Future<void> cacheActivities(List<ActivityModel> activities);
  Future<bool> hasActivities();
}

class ActivityLocalDataSourceImpl implements ActivityLocalDataSource {
  final Box<ActivityModel> activityBox;

  ActivityLocalDataSourceImpl({required this.activityBox});

  @override
  Future<List<ActivityModel>> getActivities() async {
    return activityBox.values.toList();
  }

  @override
  Future<void> cacheActivities(List<ActivityModel> activities) async {
    // Clear existing data
    await activityBox.clear();

    // Store each activity with its ID as key
    for (final activity in activities) {
      await activityBox.put(activity.id, activity);
    }

    print('📦 Cached ${activities.length} activities in Hive');
  }

  @override
  Future<bool> hasActivities() async {
    return activityBox.isNotEmpty;
  }
}
