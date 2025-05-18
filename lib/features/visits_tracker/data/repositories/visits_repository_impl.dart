import 'dart:developer';
import 'dart:io';
import 'package:rtm_sat/core/network/network_info.dart';

import '../../domain/entities/visit.dart';
import '../../domain/repositories/visits_repository.dart';
import '../datasources/visits_local_data_source.dart';
import '../datasources/visits_remote_data_source.dart';
import '../models/visit_model.dart';

class VisitsRepositoryImpl implements VisitsRepository {
  final VisitsLocalDataSource localDataSource;
  final VisitsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  VisitsRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<List<Visit>> getVisits() async {
    try {
      // Try to get visits from remote source first
      final remoteVisits = await remoteDataSource.getVisits();

      // Store them locally to keep local DB updated
      for (final visit in remoteVisits) {
        try {
          await localDataSource.updateVisit(visit);
        } catch (e) {
          // If the visit doesn't exist locally, create it
          await localDataSource.createVisitFromRemote(visit);
        }
      }

      return remoteVisits;
    } on SocketException {
      // If there's no internet connection, return local data
      return localDataSource.getVisits();
    } catch (e) {
      // For any other error, fall back to local data
      return localDataSource.getVisits();
    }
  }

  @override
  Future<int> createVisit(Visit visit) async {
    final visitModel = VisitModel.fromEntity(visit);

    try {
      // Try to create on remote first (if we have internet)
      log('📤 Creating visit on remote server');
      final remoteId = await remoteDataSource.createVisit(visitModel);

      // After successful remote creation, sync all data to ensure consistency
      log('🔄 Auto-syncing after successful visit creation');
      await syncVisits(); // Will clear DB and fetch fresh data including our new visit

      return remoteId;
    } catch (e) {
      // If remote fails, create locally only with a temporary ID
      log('📱 Creating visit locally (offline mode)');
      final localId = await localDataSource.createVisitFromLocal(visitModel);

      log('💾 Visit saved locally with ID: $localId');
      return localId;
    }
  }

  @override
  Future<void> updateVisit(Visit visit) async {
    final visitModel = VisitModel.fromEntity(visit);

    // Always update locally first
    await localDataSource.updateVisit(visitModel);

    try {
      // Then try to update remotely
      await remoteDataSource.updateVisit(visitModel);
      await localDataSource.markAsSynced(visit.id!);
    } catch (e) {
      // If remote update fails, the local version will remain marked as not synced
    }
  }

  @override
  Future<void> deleteVisit(int id) async {
    try {
      // Try to delete remotely first
      await remoteDataSource.deleteVisit(id);
    } finally {
      // Always delete locally, regardless of remote success
      await localDataSource.deleteVisit(id);
    }
  }

  @override
  Future<void> syncVisits() async {
    try {
      // 1. Check if there are any unsynced visits
      final hasUnsynced = await localDataSource.hasUnsyncedVisits();

      if (hasUnsynced) {
        // 2. Get unsynced visits
        final unsyncedVisits = await localDataSource.getUnsyncedVisits();

        // 3. Log for debugging
        log('📤 Found ${unsyncedVisits.length} unsynced visits to sync');

        // 4. Sync each unsynced visit
        for (final visit in unsyncedVisits) {
          try {
            if (visit.id != null && visit.id! < 0) {
              // This is a locally created visit (negative ID) - create on server
              log('📤 Creating local visit on server: ${visit.id}');
              await remoteDataSource.createVisit(visit);
            } else if (visit.id != null) {
              // This is a server visit that was modified locally - update on server
              log('📤 Updating visit on server: ${visit.id}');
              await remoteDataSource.updateVisit(visit);
            }
          } catch (e) {
            log('❌ Failed to sync visit ${visit.id}: $e');
            // Continue with other visits even if one fails
          }
        }
      }

      // 5. Clear local database to prepare for fresh data
      log('🗑️ Clearing local visit database');
      await localDataSource.clearAllVisits();

      // 6. Fetch all visits from server
      log('📥 Fetching fresh visits from server');
      final remoteVisits = await remoteDataSource.getVisits();

      // 7. Save all remote visits locally
      log('💾 Saving ${remoteVisits.length} visits to local database');
      await localDataSource.saveAllVisits(remoteVisits);

      log('✅ Sync complete: local database now matches server');
    } catch (e) {
      log('❌ Sync failed: $e');
      throw Exception('Failed to sync visits: $e');
    }
  }

  @override
  Future<Visit?> getVisitById(int id) async {
    try {
      // Try local first
      final localVisit = await localDataSource.getVisitById(id);

      if (localVisit != null) {
        return localVisit;
      }

      // If not in local storage and we're connected, try remote
      if (await networkInfo.isConnected) {
        try {
          final remoteVisit = await remoteDataSource.getVisitById(id);

          if (remoteVisit != null) {
            // Cache for future use
            await localDataSource.createVisitFromRemote(remoteVisit);
            return remoteVisit;
          }
        } catch (e) {
          log('Error fetching visit $id from remote: $e');
        }
      }

      // Not found
      return null;
    } catch (e) {
      log('Error in getVisitById: $e');
      throw Exception('Failed to get visit: $e');
    }
  }
}
