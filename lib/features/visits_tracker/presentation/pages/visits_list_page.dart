import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rtm_sat/features/visits_tracker/presentation/widgets/customer_name_display.dart';
import '../cubit/visits_cubit.dart';
import '../../domain/entities/visit.dart';
import 'visit_create_page.dart';
import 'visit_details_page.dart';

class VisitsListPage extends StatefulWidget {
  const VisitsListPage({super.key});

  @override
  State<VisitsListPage> createState() => _VisitsListPageState();
}

class _VisitsListPageState extends State<VisitsListPage> {
  @override
  void initState() {
    super.initState();
    context.read<VisitsCubit>().getVisits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () {
              context.read<VisitsCubit>().syncVisits();
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
            // Reload visits after sync
            context.read<VisitsCubit>().getVisits();
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<VisitsCubit>().getVisits();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is VisitsLoaded) {
            if (state.visits.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.event_busy, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'No visits yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tap the + button to create a new visit',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return _buildVisitsList(context, state.visits);
          }

          return const Center(child: Text('No visits available'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const VisitCreatePage()),
          );
          // Refresh list after returning from create page
          if (mounted) {
            context.read<VisitsCubit>().getVisits();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildVisitsList(BuildContext context, List<Visit> visits) {
    // Group visits by date for better organization
    final groupedVisits = <DateTime, List<Visit>>{};

    for (final visit in visits) {
      final date = DateTime(
        visit.visitDate.year,
        visit.visitDate.month,
        visit.visitDate.day,
      );

      if (!groupedVisits.containsKey(date)) {
        groupedVisits[date] = [];
      }

      groupedVisits[date]!.add(visit);
    }

    // Sort dates in descending order (newest first)
    final sortedDates =
        groupedVisits.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final dateVisits = groupedVisits[date]!;

        // Sort visits within the same date by time (newest first)
        dateVisits.sort((a, b) => b.visitDate.compareTo(a.visitDate));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                _formatDateHeader(date),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            ...dateVisits.map((visit) => _buildVisitCard(context, visit)),
          ],
        );
      },
    );
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateFormatted = DateFormat('MMM dd, yyyy').format(date);

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today - $dateFormatted';
    } else if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday - $dateFormatted';
    } else {
      return dateFormatted;
    }
  }

  Widget _buildVisitCard(BuildContext context, Visit visit) {
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
          if (visit.id != null) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VisitDetailsPage(visitId: visit.id!),
              ),
            );
            // Refresh list after returning from details page
            if (mounted) {
              context.read<VisitsCubit>().getVisits();
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cannot open visit: ID is missing')),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Status indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(visit.status),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      visit.status,
                      style: TextStyle(
                        color: _getStatusTextColor(visit.status),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Sync status indicator
                  if (!visit.isSynced)
                    const Icon(Icons.cloud_off, color: Colors.orange, size: 16),
                ],
              ),
              const SizedBox(height: 12),
              // Customer ID and time
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
              // Location
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
                // Notes preview
                Text(
                  visit.notes,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
              const SizedBox(height: 12),
              // Activities
              if (visit.activitiesDone.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children:
                      visit.activitiesDone.take(3).map((activityId) {
                        // Map activity IDs to names - replace with your actual mapping logic
                        final activityMap = {
                          '1': 'Product Demo',
                          '2': 'Sales Presentation',
                          '3': 'Contract Negotiation',
                          '4': 'Customer Support',
                          '5': 'Training Session',
                        };
                        final activityName =
                            activityMap[activityId] ?? 'Activity #$activityId';

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
                            activityName,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        );
                      }).toList() +
                      (visit.activitiesDone.length > 3
                          ? [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '+${visit.activitiesDone.length - 3} more',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ]
                          : []),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
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

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
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
