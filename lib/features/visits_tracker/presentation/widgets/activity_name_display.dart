import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/activities/presentation/cubit/activity_cubit.dart';
import '../../../../features/activities/presentation/cubit/activity_state.dart';

class ActivityNameDisplay extends StatelessWidget {
  final String activityId;

  const ActivityNameDisplay({super.key, required this.activityId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActivityCubit, ActivityState>(
      builder: (context, state) {
        if (state is ActivitiesLoaded) {
          final activity =
              state.activities.where((a) => a.id == activityId).firstOrNull;

          if (activity != null) {
            return Text(
              activity.description,
              style: TextStyle(color: Colors.black45),
            );
          }
        }

        return Text('Activity #$activityId');
      },
    );
  }
}
