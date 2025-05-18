import 'package:hive/hive.dart';
import '../../domain/entities/visit.dart';

part 'visit_model.g.dart';

@HiveType(typeId: 1)
class VisitModel extends Visit {
  @HiveField(0)
  final int? id;

  @HiveField(1)
  final int customerId;

  @HiveField(2)
  final DateTime visitDate;

  @HiveField(3)
  final String status;

  @HiveField(4)
  final String location;

  @HiveField(5)
  final String notes;

  @HiveField(6)
  final List<String> activitiesDone;

  @HiveField(7)
  final DateTime? createdAt;

  @HiveField(8)
  final bool isSynced;

  const VisitModel({
    this.id,
    required this.customerId,
    required this.visitDate,
    required this.status,
    required this.location,
    required this.notes,
    required this.activitiesDone,
    this.createdAt,
    this.isSynced = false,
  }) : super(
         id: id,
         customerId: customerId,
         visitDate: visitDate,
         status: status,
         location: location,
         notes: notes,
         activitiesDone: activitiesDone,
         createdAt: createdAt,
         isSynced: isSynced,
       );

  factory VisitModel.fromJson(Map<String, dynamic> json) {
    return VisitModel(
      id: json['id'],
      customerId: json['customer_id'],
      visitDate: DateTime.parse(json['visit_date']),
      status: json['status'],
      location: json['location'],
      notes: json['notes'],
      activitiesDone: List<String>.from(json['activities_done'] ?? []),
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      isSynced: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'customer_id': customerId,
      'visit_date': visitDate.toIso8601String(),
      'status': status,
      'location': location,
      'notes': notes,
      'activities_done': activitiesDone,
      if (createdAt != null) 'created_at': createdAt?.toIso8601String(),
    };
  }

  factory VisitModel.fromEntity(Visit visit) {
    return VisitModel(
      id: visit.id,
      customerId: visit.customerId,
      visitDate: visit.visitDate,
      status: visit.status,
      location: visit.location,
      notes: visit.notes,
      activitiesDone: visit.activitiesDone,
      createdAt: visit.createdAt,
      isSynced: visit.isSynced,
    );
  }
}
