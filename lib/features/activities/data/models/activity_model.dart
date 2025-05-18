import 'package:hive/hive.dart';
import '../../domain/entities/activity.dart';

part 'activity_model.g.dart';

@HiveType(typeId: 3) // Use a unique type ID
class ActivityModel extends Activity {
  @HiveField(0)
  @override
  final String id;

  @HiveField(1)
  @override
  final String description;

  @HiveField(2)
  @override
  final DateTime createdAt;

  const ActivityModel({
    required this.id,

    required this.description,
    required this.createdAt,
  }) : super(id: id, description: description, createdAt: createdAt);

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'].toString(),

      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
