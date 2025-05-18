import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/visit_detail_cubit.dart';
import '../widgets/visit_form.dart';
import '../../domain/entities/visit.dart';

class VisitEditPage extends StatelessWidget {
  final Visit visit;

  const VisitEditPage({super.key, required this.visit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Visit')),
      body: BlocListener<VisitDetailCubit, VisitDetailState>(
        listener: (context, state) {
          if (state is VisitUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Visit updated successfully')),
            );
            Navigator.pop(context);
          } else if (state is VisitUpdateError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
          }
        },
        child: VisitForm(
          visit: visit,
          onSave:
              (updatedVisit) =>
                  context.read<VisitDetailCubit>().updateVisit(updatedVisit),
          isLoading:
              context.watch<VisitDetailCubit>().state is VisitUpdateLoading,
        ),
      ),
    );
  }
}
