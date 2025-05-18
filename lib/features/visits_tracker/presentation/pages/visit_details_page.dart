import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../cubit/visits_cubit.dart';
import '../widgets/customer_name_display.dart';
import '../widgets/activity_name_display.dart';

class VisitDetailsPage extends StatefulWidget {
  final int visitId;

  const VisitDetailsPage({super.key, required this.visitId});

  @override
  State<VisitDetailsPage> createState() => _VisitDetailsPageState();
}

class _VisitDetailsPageState extends State<VisitDetailsPage> {
  late VisitsCubit _visitsCubit;
  bool _isDisposed = false; // Add this flag

  @override
  void initState() {
    super.initState();
    _visitsCubit = context.read<VisitsCubit>();
    _visitsCubit.getVisitById(widget.visitId);
  }

  @override
  void dispose() {
    _isDisposed = true; // Set flag before disposal
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true, // Let Flutter handle pop navigation normally
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Visit Details'),
          actions: [
            BlocBuilder<VisitsCubit, VisitsState>(
              buildWhen:
                  (previous, current) =>
                      current is VisitLoaded || current is VisitsLoading,
              builder: (context, state) {
                if (state is VisitLoaded && !state.visit.isSynced) {
                  return IconButton(
                    icon: const Icon(Icons.cloud_upload),
                    tooltip: 'Sync this visit',
                    onPressed: () {
                      _visitsCubit.syncVisits();
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocConsumer<VisitsCubit, VisitsState>(
          listener: (context, state) {
            if (_isDisposed) return; // Skip any callbacks if widget is disposed

            if (state is VisitsSynced) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Visit synced successfully')),
              );
              if (!_isDisposed) {
                _visitsCubit.getVisitById(widget.visitId);
              }
            } else if (state is VisitsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.message}')),
              );
            }
          },
          builder: (context, state) {
            if (state is VisitsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is VisitLoaded) {
              final visit = state.visit;
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
                      text: DateFormat(
                        'EEEE, MMM dd, yyyy',
                      ).format(visit.visitDate),
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
                          color:
                              visit.notes.isEmpty ? Colors.grey : Colors.black,
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
                                .map(
                                  (activityId) =>
                                      _buildActivityChip(activityId),
                                )
                                .toList(),
                      ),
                  ],
                ),
              );
            } else if (state is VisitsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${state.message}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<VisitsCubit>().getVisitById(
                          widget.visitId,
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            return const Center(child: Text('Visit not found'));
          },
        ),
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
          // Ensure the child content can flex but not expand unbounded
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
