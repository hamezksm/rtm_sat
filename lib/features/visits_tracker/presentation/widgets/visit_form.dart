import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rtm_sat/core/di/service_locator.dart';
import 'package:rtm_sat/features/customers/domain/entities/customer.dart';
import '../../domain/entities/visit.dart';
import '../cubit/visit_form_cubit.dart';

class VisitForm extends StatelessWidget {
  final Visit? visit;
  final Function(Visit) onSave;
  final bool isLoading;
  final _formKey = GlobalKey<FormState>();

  VisitForm({
    super.key,
    this.visit,
    required this.onSave,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<VisitFormCubit>(param1: visit)..initialize(),
      child: Builder(
        builder: (context) {
          return BlocConsumer<VisitFormCubit, VisitFormState>(
            listener: (context, state) {
              if (state.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${state.error}')),
                );
              }
            },
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return Form(
                key: _formKey,
                child: _buildFormContent(context, state),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFormContent(BuildContext context, VisitFormState state) {
    final cubit = context.read<VisitFormCubit>();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          // Customer dropdown
          _buildCustomerDropdown(context, state, cubit),

          const SizedBox(height: 16),

          // Visit Date
          _buildDateField(context, state, cubit),

          const SizedBox(height: 16),

          // Status dropdown
          _buildStatusDropdown(context, state, cubit),

          const SizedBox(height: 16),

          // Location
          TextFormField(
            initialValue: state.location,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
            decoration: const InputDecoration(
              labelText: 'Location',
              border: OutlineInputBorder(),
            ),
            onChanged: cubit.setLocation,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a location';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Notes
          TextFormField(
            initialValue: state.notes,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
            decoration: const InputDecoration(
              labelText: 'Notes',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            onChanged: cubit.setNotes,
            maxLines: 5,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some notes';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Activities
          _buildActivitiesSection(context, state, cubit),

          const SizedBox(height: 24),

          // Submit button
          ElevatedButton(
            onPressed: isLoading ? null : () => _submitForm(context, cubit),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child:
                isLoading
                    ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                    : Text(
                      visit == null ? 'Create Visit' : 'Update Visit',
                      style: const TextStyle(fontSize: 16),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerDropdown(
    BuildContext context,
    VisitFormState state,
    VisitFormCubit cubit,
  ) {
    return DropdownButtonFormField<Customer>(
      decoration: const InputDecoration(
        labelText: 'Customer',
        border: OutlineInputBorder(),
      ),
      value: state.selectedCustomer,
      items:
          state.customers.map((customer) {
            return DropdownMenuItem(
              value: customer,
              child: Text(
                '${customer.id} - ${customer.name}',
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
          }).toList(),
      onChanged: cubit.setCustomer,
      validator: (value) {
        if (value == null) {
          return 'Please select a customer';
        }
        return null;
      },
    );
  }

  Widget _buildDateField(
    BuildContext context,
    VisitFormState state,
    VisitFormCubit cubit,
  ) {
    return GestureDetector(
      onTap: () => _selectDate(context, state.visitDate, cubit),
      child: AbsorbPointer(
        child: TextFormField(
          style: const TextStyle(fontSize: 16, color: Colors.black54),
          decoration: const InputDecoration(
            labelText: 'Visit Date',
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.calendar_today),
          ),
          controller: TextEditingController(
            text: DateFormat('yyyy-MM-dd').format(state.visitDate),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a date';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildStatusDropdown(
    BuildContext context,
    VisitFormState state,
    VisitFormCubit cubit,
  ) {
    final statusOptions = ['Completed', 'Pending', 'Cancelled'];

    return DropdownButtonFormField<String>(
      style: const TextStyle(fontSize: 16, color: Colors.black54),
      decoration: const InputDecoration(
        labelText: 'Status',
        border: OutlineInputBorder(),
      ),
      value: state.status,
      items:
          statusOptions.map((status) {
            return DropdownMenuItem(value: status, child: Text(status));
          }).toList(),
      onChanged: (value) {
        if (value != null) {
          cubit.setStatus(value);
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a status';
        }
        return null;
      },
    );
  }

  Widget _buildActivitiesSection(
    BuildContext context,
    VisitFormState state,
    VisitFormCubit cubit,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Activities Done',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              state.activities.map((activity) {
                final isSelected = state.selectedActivities.contains(
                  activity.id,
                );
                return FilterChip(
                  label: Text(activity.description),
                  selected: isSelected,
                  onSelected: (_) => cubit.toggleActivity(activity.id),
                  backgroundColor: Colors.grey[200],
                  selectedColor: Colors.blue[100],
                );
              }).toList(),
        ),
      ],
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    DateTime initialDate,
    VisitFormCubit cubit,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != initialDate) {
      cubit.setVisitDate(picked);
    }
  }

  void _submitForm(BuildContext context, VisitFormCubit cubit) {
    if (_formKey.currentState!.validate()) {
      final visit = cubit.buildVisit();
      onSave(visit);
    }
  }
}
