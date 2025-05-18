import '../models/activity_model.dart';
import '../../../../core/api/api_service.dart';
import '../../../../core/error/exceptions.dart';

abstract class ActivityRemoteDataSource {
  Future<List<ActivityModel>> getActivities();
}

class ActivityRemoteDataSourceImpl implements ActivityRemoteDataSource {
  final ApiService apiService;

  ActivityRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<ActivityModel>> getActivities() async {
    try {
      return await apiService.getActivities();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
