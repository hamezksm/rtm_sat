import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rtm_sat/features/visits_tracker/domain/entities/visit.dart';
import 'package:rtm_sat/features/visits_tracker/presentation/pages/visit_create_page.dart';
import 'package:rtm_sat/features/visits_tracker/presentation/pages/visit_details_page.dart';
import 'package:rtm_sat/features/visits_tracker/presentation/widgets/customer_name_display.dart';
import '../cubit/visits_cubit.dart';

class VisitsListPage extends StatelessWidget {
  const VisitsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1) Capture the cubit once, at the top of build
    final visitsCubit = context.read<VisitsCubit>();

    // 2) Trigger the initial load exactly once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      visitsCubit.getVisits();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () {
              visitsCubit.syncVisits();
            },
          ),
        ],
      ),
      body: BlocConsumer<VisitsCubit, VisitsState>(
        listener: (context, state) {
          if (state is VisitsSynced) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Visits synced successfully')),
            );
            visitsCubit.getVisits();
          } else if (state is VisitsError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
          }
        },
        builder: (context, state) {
          if (state is VisitsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is VisitsError) {
            return _buildErrorView(state.message, visitsCubit, context);
          }
          if (state is VisitsLoaded) {
            if (state.visits.isEmpty) {
              return _buildEmptyView();
            }
            return _buildVisitsList(state.visits, visitsCubit, context);
          }
          return const Center(child: Text('No visits available'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // capture
          final cubit = visitsCubit;
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const VisitCreatePage()),
          );
          if (!context.mounted) return;
          cubit.getVisits();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildErrorView(
    String message,
    VisitsCubit cubit,
    BuildContext context,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text('Error: $message', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              cubit.getVisits();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.event_busy, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No visits yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tap the + button to create a new visit',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitsList(
    List<Visit> visits,
    VisitsCubit cubit,
    BuildContext context,
  ) {
    // group & sort
    final grouped = <DateTime, List<Visit>>{};
    for (var v in visits) {
      final day = DateTime(
        v.visitDate.year,
        v.visitDate.month,
        v.visitDate.day,
      );
      grouped.putIfAbsent(day, () => []).add(v);
    }
    final sortedDays = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      itemCount: sortedDays.length,
      itemBuilder: (ctx, i) {
        final day = sortedDays[i];
        final dayVisits =
            grouped[day]!..sort((a, b) => b.visitDate.compareTo(a.visitDate));
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                _formatDateHeader(day),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            ...dayVisits.map((v) => _buildVisitCard(v, cubit, context)),
          ],
        );
      },
    );
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final formatted = DateFormat('MMM dd, yyyy').format(date);
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today – $formatted';
    } else if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday – $formatted';
    }
    return formatted;
  }

  Widget _buildVisitCard(Visit visit, VisitsCubit cubit, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: visit.isSynced ? Colors.transparent : Colors.orange.shade300,
          width: visit.isSynced ? 0 : 1,
        ),
      ),
      child: InkWell(
        onTap: () async {
          if (visit.id == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cannot open visit: ID is missing')),
            );
            return;
          }
          // capture cubit reference
          final localCubit = cubit;
          await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => VisitDetailsPage(visitId: visit.id!),
            ),
          );
          // guard
          if (!context.mounted) return;
          localCubit.getVisits();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // status & sync
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor(visit.status),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      visit.status,
                      style: TextStyle(
                        color: _statusTextColor(visit.status),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (!visit.isSynced)
                    const Icon(Icons.cloud_off, color: Colors.orange, size: 16),
                ],
              ),
              const SizedBox(height: 12),
              // customer & time
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  CustomerNameDisplay(customerId: visit.customerId),
                  const Spacer(),
                  Text(
                    DateFormat('h:mm a').format(visit.visitDate),
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // location
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      visit.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade800),
                    ),
                  ),
                ],
              ),
              if (visit.notes.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  visit.notes,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
              if (visit.activitiesDone.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children:
                      visit.activitiesDone.map((id) {
                        // … your chip logic …
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Act $id',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'completed':
        return Colors.green.shade100;
      case 'pending':
        return Colors.amber.shade100;
      case 'cancelled':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _statusTextColor(String s) {
    switch (s.toLowerCase()) {
      case 'completed':
        return Colors.green.shade900;
      case 'pending':
        return Colors.amber.shade900;
      case 'cancelled':
        return Colors.red.shade900;
      default:
        return Colors.grey.shade900;
    }
  }
}
