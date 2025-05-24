import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rtm_sat/features/visits_tracker/domain/entities/visit.dart';
import 'package:rtm_sat/features/visits_tracker/domain/usecases/create_visit.dart';
import 'package:rtm_sat/features/visits_tracker/domain/usecases/delete_visit.dart';
import 'package:rtm_sat/features/visits_tracker/domain/usecases/get_visit_by_id.dart';
import 'package:rtm_sat/features/visits_tracker/domain/usecases/get_visits.dart';
import 'package:rtm_sat/features/visits_tracker/domain/usecases/sync_visits.dart';
import 'package:rtm_sat/features/visits_tracker/domain/usecases/update_visit.dart';
import 'package:rtm_sat/features/visits_tracker/presentation/cubit/visits_cubit.dart';

import 'visits_cubit_test.mocks.dart';

@GenerateMocks([
  GetVisitsUseCase,
  CreateVisitUseCase,
  UpdateVisitUseCase,
  DeleteVisitUseCase,
  SyncVisitsUseCase,
  GetVisitByIdUseCase,
])
void main() {
  late VisitsCubit visitsCubit;
  late MockGetVisitsUseCase mockGetVisitsUseCase;
  late MockCreateVisitUseCase mockCreateVisitUseCase;
  late MockUpdateVisitUseCase mockUpdateVisitUseCase;
  late MockDeleteVisitUseCase mockDeleteVisitUseCase;
  late MockSyncVisitsUseCase mockSyncVisitsUseCase;
  late MockGetVisitByIdUseCase mockGetVisitByIdUseCase;

  setUp(() {
    mockGetVisitsUseCase = MockGetVisitsUseCase();
    mockCreateVisitUseCase = MockCreateVisitUseCase();
    mockUpdateVisitUseCase = MockUpdateVisitUseCase();
    mockDeleteVisitUseCase = MockDeleteVisitUseCase();
    mockSyncVisitsUseCase = MockSyncVisitsUseCase();
    mockGetVisitByIdUseCase = MockGetVisitByIdUseCase();

    visitsCubit = VisitsCubit(
      getVisitsUseCase: mockGetVisitsUseCase,
      createVisitUseCase: mockCreateVisitUseCase,
      updateVisitUseCase: mockUpdateVisitUseCase,
      deleteVisitUseCase: mockDeleteVisitUseCase,
      syncVisitsUseCase: mockSyncVisitsUseCase,
      getVisitByIdUseCase: mockGetVisitByIdUseCase,
    );
  });

  tearDown(() {
    visitsCubit.close();
  });

  final tVisits = [
    Visit(
      id: 1,
      customerId: 101,
      visitDate: DateTime(2023, 5, 15),
      status: 'Completed',
      location: 'Test Location',
      notes: 'Test Notes',
      activitiesDone: ['activity1'],
      isSynced: true,
    ),
  ];

  final tVisit = Visit(
    id: 1,
    customerId: 101,
    visitDate: DateTime(2023, 5, 15),
    status: 'Completed',
    location: 'Test Location',
    notes: 'Test Notes',
    activitiesDone: ['activity1'],
    isSynced: true,
  );

  group('VisitsCubit', () {
    test('initial state should be VisitsInitial', () {
      expect(visitsCubit.state, isA<VisitsInitial>());
    });

    group('getVisits', () {
      test(
        'should emit [VisitsLoading, VisitsLoaded] when getVisits is successful',
        () async {
          // arrange
          when(mockGetVisitsUseCase()).thenAnswer((_) async => tVisits);

          // act
          expectLater(
            visitsCubit.stream,
            emitsInOrder([isA<VisitsLoading>(), isA<VisitsLoaded>()]),
          );

          await visitsCubit.getVisits();
        },
      );

      test(
        'should emit [VisitsLoading, VisitsError] when getVisits fails',
        () async {
          // arrange
          when(
            mockGetVisitsUseCase(),
          ).thenThrow(Exception('Failed to get visits'));

          // act
          expectLater(
            visitsCubit.stream,
            emitsInOrder([isA<VisitsLoading>(), isA<VisitsError>()]),
          );

          await visitsCubit.getVisits();
        },
      );
    });

    group('getVisitById', () {
      test(
        'should emit [VisitsLoading, VisitLoaded] when getVisitById is successful',
        () async {
          // arrange
          when(mockGetVisitByIdUseCase(1)).thenAnswer((_) async => tVisit);

          // act
          expectLater(
            visitsCubit.stream,
            emitsInOrder([isA<VisitsLoading>(), isA<VisitLoaded>()]),
          );

          await visitsCubit.getVisitById(1);
        },
      );

      test(
        'should emit [VisitsLoading, VisitsError] when getVisitById fails',
        () async {
          // arrange
          when(
            mockGetVisitByIdUseCase(1),
          ).thenThrow(Exception('Visit not found'));

          // act
          expectLater(
            visitsCubit.stream,
            emitsInOrder([isA<VisitsLoading>(), isA<VisitsError>()]),
          );

          await visitsCubit.getVisitById(1);
        },
      );
    });

    group('syncVisits', () {
      test(
        'should emit [VisitsLoading, VisitsLoaded, VisitsSynced] when sync is successful',
        () async {
          // arrange
          // Stub BOTH use cases that are called in the syncVisits method
          when(mockSyncVisitsUseCase()).thenAnswer((_) async {});
          when(mockGetVisitsUseCase()).thenAnswer((_) async => tVisits);

          // act
          expectLater(
            visitsCubit.stream,
            emitsInOrder([
              isA<VisitsLoading>(),
              isA<VisitsLoaded>(),
              isA<VisitsSynced>(),
            ]),
          );

          await visitsCubit.syncVisits();
        },
      );

      test(
        'should emit [VisitsLoading, VisitsError] when sync fails',
        () async {
          // arrange
          when(
            mockSyncVisitsUseCase(),
          ).thenThrow(Exception('Failed to sync visits'));

          // act
          expectLater(
            visitsCubit.stream,
            emitsInOrder([isA<VisitsLoading>(), isA<VisitsError>()]),
          );

          await visitsCubit.syncVisits();
        },
      );
    });
  });
}
