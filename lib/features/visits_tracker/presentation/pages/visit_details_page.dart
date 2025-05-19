import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rtm_sat/features/visits_tracker/domain/entities/visit.dart';
import 'package:rtm_sat/features/visits_tracker/presentation/pages/visit_edit_page.dart';
import '../cubit/visits_cubit.dart';
import '../widgets/customer_name_display.dart';
import '../widgets/activity_name_display.dart';

class VisitDetailsPage extends StatelessWidget {
  final int visitId;

  const VisitDetailsPage({super.key, required this.visitId});

  @override
  Widget build(BuildContext context) {
    // Capture cubit reference immediately
    final visitsCubit = context.read<VisitsCubit>();

    // Load the visit details when the page is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      visitsCubit.getVisitById(visitId);
    });

    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Visit Details'),
          actions: [
            BlocBuilder<VisitsCubit, VisitsState>(
              buildWhen:
                  (previous, current) =>
                      current is VisitLoaded || current is VisitsLoading,
              builder: (context, state) {
                if (state is VisitLoaded) {
                  final visit = state.visit;
                  return Row(
                    children: [
                      // Edit icon
                      IconButton(
                        icon: const Icon(Icons.edit),
                        tooltip: 'Edit Visit',
                        onPressed: () async {
                          if (visit.id != null) {
                            // Use an immediate function to handle edit result
                            final result = await Navigator.of(
                              context,
                            ).push<bool>(
                              MaterialPageRoute(
                                builder:
                                    (context) => VisitEditPage(visit: visit),
                              ),
                            );

                            // Use the captured cubit reference
                            if (result == true) {
                              visitsCubit.getVisitById(visitId);
                            }
                          }
                        },
                      ),
                      // Delete icon
                      IconButton(
                        icon: const Icon(Icons.delete),
                        tooltip: 'Delete Visit',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder:
                                (dialogContext) => AlertDialog(
                                  title: const Text('Confirm Delete'),
                                  content: const Text(
                                    'Are you sure you want to delete this visit? This action cannot be undone.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(dialogContext),
                                      child: const Text('CANCEL'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(
                                          dialogContext,
                                        ); // Close dialog

                                        // Use the captured cubit reference for deletion
                                        visitsCubit.deleteVisit(visit.id!);

                                        // Return to visits list
                                        Navigator.pop(context, true);
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      child: const Text('DELETE'),
                                    ),
                                  ],
                                ),
                          );
                        },
                      ),
                      // Sync icon (if needed)
                      if (!visit.isSynced)
                        IconButton(
                          icon: const Icon(Icons.cloud_upload),
                          tooltip: 'Sync this visit',
                          onPressed: () {
                            // Use the captured cubit reference
                            visitsCubit.syncVisits();
                          },
                        ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocConsumer<VisitsCubit, VisitsState>(
          listener: (context, state) {
            if (state is VisitsSynced) {
              // Use the original listener context for UI updates
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Visit synced successfully')),
              );
              // Use the captured cubit reference for data operations
              visitsCubit.getVisitById(visitId);
            } else if (state is VisitsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.message}')),
              );
            } else if (state is VisitDeleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Visit deleted successfully')),
              );
              if (Navigator.canPop(context)) {
                Navigator.pop(context, true);
              }
            }
          },
          builder: (context, state) {
            if (state is VisitsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is VisitLoaded) {
              return _buildVisitDetails(context, state.visit, visitsCubit);
            } else if (state is VisitsError) {
              return _buildErrorView(context, state.message, visitsCubit);
            }
            return const Center(child: Text('Visit not found'));
          },
        ),
      ),
    );
  }

  Widget _buildVisitDetails(
    BuildContext context,
    Visit visit,
    VisitsCubit cubit,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status and Sync status
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
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
                  ),
                ),
              ),
              const Spacer(),
              // Sync status
              if (!visit.isSynced)
                Row(
                  children: [
                    const Icon(Icons.cloud_off, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      'Not synced',
                      style: TextStyle(color: Colors.orange.shade800),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Visit details
          _buildDetailItem(
            icon: Icons.person,
            title: 'Customer',
            child: CustomerNameDisplay(customerId: visit.customerId),
          ),
          _buildDetailItem(
            icon: Icons.calendar_today,
            title: 'Date',
            text: DateFormat('EEEE, MMM dd, yyyy').format(visit.visitDate),
          ),
          _buildDetailItem(
            icon: Icons.access_time,
            title: 'Time',
            text: DateFormat('h:mm a').format(visit.visitDate),
          ),
          _buildDetailItem(
            icon: Icons.location_on,
            title: 'Location',
            text: visit.location,
          ),

          const SizedBox(height: 16),

          // Notes
          const Text(
            'Notes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              visit.notes.isEmpty ? 'No notes provided' : visit.notes,
              style: TextStyle(
                color: visit.notes.isEmpty ? Colors.grey : Colors.black,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Activities
          const Text(
            'Activities Performed',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          if (visit.activitiesDone.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'No activities recorded',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  visit.activitiesDone
                      .map((activityId) => _buildActivityChip(activityId))
                      .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorView(
    BuildContext context,
    String message,
    VisitsCubit cubit,
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
              // Use the passed cubit reference
              cubit.getVisitById(visitId);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    String? text,
    Widget? child,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 2),
                child ??
                    Text(
                      text ?? '',
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityChip(String activityId) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: ActivityNameDisplay(activityId: activityId),
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
