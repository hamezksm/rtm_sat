import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/visits_cubit.dart';
import '../widgets/visit_form.dart';

class VisitCreatePage extends StatelessWidget {
  const VisitCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    // This creates a new instance of VisitsCubit just for this page
    return Scaffold(
      appBar: AppBar(title: const Text('Create Visit')),
      body: BlocConsumer<VisitsCubit, VisitsState>(
        listener: (context, state) {
          if (state is VisitCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Visit created successfully')),
            );
            Navigator.pop(context);
          } else if (state is VisitsError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
          }
        },
        builder: (context, state) {
          return VisitForm(
            onSave: (visit) => context.read<VisitsCubit>().createVisit(visit),
            isLoading: state is VisitsLoading,
          );
        },
      ),
    );
  }
}
