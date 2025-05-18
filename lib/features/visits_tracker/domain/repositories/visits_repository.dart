import '../entities/visit.dart';

abstract class VisitsRepository {
  Future<List<Visit>> getVisits();
  Future<int> createVisit(Visit visit);
  Future<void> updateVisit(Visit visit);
  Future<void> deleteVisit(int id);
  Future<void> syncVisits();
  Future<Visit?> getVisitById(int id);
}
