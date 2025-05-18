import 'dart:developer';

import 'package:hive/hive.dart';
import '../models/visit_model.dart';

abstract class VisitsLocalDataSource {
  Future<List<VisitModel>> getVisits();
  Future<int> createVisitFromRemote(VisitModel visit);
  Future<int> createVisitFromLocal(VisitModel visit);
  Future<void> updateVisit(VisitModel visit);
  Future<void> deleteVisit(int id);
  Future<void> markAsSynced(int id);

  Future<List<VisitModel>> getUnsyncedVisits();
  Future<bool> hasUnsyncedVisits();
  Future<void> clearAllVisits();
  Future<void> saveAllVisits(List<VisitModel> visits);

  Future<VisitModel?> getVisitById(int id);
}

class VisitsLocalDataSourceImpl implements VisitsLocalDataSource {
  final Box<VisitModel> visitsBox;

  VisitsLocalDataSourceImpl(this.visitsBox);

  @override
  Future<List<VisitModel>> getVisits() async {
    return visitsBox.values.toList();
  }

  @override
  Future<int> createVisitFromLocal(VisitModel visit) async {
    final localId = -DateTime.now().millisecondsSinceEpoch;

    final newVisit = VisitModel(
      id: localId,
      customerId: visit.customerId,
      visitDate: visit.visitDate,
      status: visit.status,
      location: visit.location,
      notes: visit.notes,
      activitiesDone: visit.activitiesDone,
      createdAt: DateTime.now(),
      isSynced: false,
    );

    await visitsBox.put(localId, newVisit);
    return localId;
  }

  @override
  Future<int> createVisitFromRemote(VisitModel visit) async {
    final newVisit = VisitModel(
      id: visit.id,
      customerId: visit.customerId,
      visitDate: visit.visitDate,
      status: visit.status,
      location: visit.location,
      notes: visit.notes,
      activitiesDone: visit.activitiesDone,
      createdAt: visit.createdAt ?? DateTime.now(),
      isSynced: visit.isSynced,
    );

    await visitsBox.put(visit.id, newVisit);
    return visit.id!;
  }

  @override
  Future<void> updateVisit(VisitModel visit) async {
    if (visit.id == null) throw Exception('Visit ID cannot be null');

    try {
      final key = visitsBox.keys.firstWhere(
        (k) => visitsBox.get(k)?.id == visit.id,
        orElse: () => null,
      );

      if (key == null) {
        await visitsBox.put(visit.id, visit);
        log('Visit not found, added as new: ${visit.id}');
      } else {
        await visitsBox.put(key, visit);
        log('Updated existing visit: ${visit.id}');
      }
    } catch (e) {
      log('Error updating visit: $e');
      throw Exception('Failed to update visit: $e');
    }
  }

  @override
  Future<void> deleteVisit(int id) async {
    await visitsBox.delete(id);
  }

  @override
  Future<void> markAsSynced(int id) async {
    final visit = visitsBox.get(id);
    if (visit == null) throw Exception('Visit not found');

    final syncedVisit = VisitModel(
      id: visit.id,
      customerId: visit.customerId,
      visitDate: visit.visitDate,
      status: visit.status,
      location: visit.location,
      notes: visit.notes,
      activitiesDone: visit.activitiesDone,
      createdAt: visit.createdAt,
      isSynced: true,
    );
    await visitsBox.put(id, syncedVisit);
  }

  @override
  Future<List<VisitModel>> getUnsyncedVisits() async {
    return visitsBox.values.where((visit) => !visit.isSynced).toList();
  }

  @override
  Future<bool> hasUnsyncedVisits() async {
    return visitsBox.values.any((visit) => !visit.isSynced);
  }

  @override
  Future<void> clearAllVisits() async {
    await visitsBox.clear();
  }

  @override
  Future<void> saveAllVisits(List<VisitModel> visits) async {
    for (var visit in visits) {
      await visitsBox.put(visit.id, visit);
    }
  }

  @override
  Future<VisitModel?> getVisitById(int id) async {
    try {
      if (visitsBox.containsKey(id)) {
        return visitsBox.get(id);
      }

      for (final key in visitsBox.keys) {
        final visit = visitsBox.get(key);
        if (visit?.id == id) {
          return visit;
        }
      }

      return null;
    } catch (e) {
      log('Error fetching visit by ID: $e');
      return null;
    }
  }
}
