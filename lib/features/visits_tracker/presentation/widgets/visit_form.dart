import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rtm_sat/core/di/service_locator.dart';
import 'package:rtm_sat/features/activities/domain/entities/activity.dart';
import 'package:rtm_sat/features/activities/domain/repositories/activity_repository.dart';
import 'package:rtm_sat/features/customers/domain/entities/customer.dart';
import 'package:rtm_sat/features/customers/domain/repositories/customer_repository.dart';
import '../../domain/entities/visit.dart';

class VisitForm extends StatefulWidget {
  final Visit? visit;
  final Function(Visit) onSave;
  final bool isLoading;

  const VisitForm({
    super.key,
    this.visit,
    required this.onSave,
    this.isLoading = false,
  });

  @override
  State<VisitForm> createState() => _VisitFormState();
}

class _VisitFormState extends State<VisitForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _customerIdController;
  late DateTime _selectedDate;
  late String _selectedStatus;
  late final TextEditingController _locationController;
  late final TextEditingController _notesController;
  List<String> _selectedActivities = [];

  late Future<List<Customer>> _customersFuture;
  late Future<List<Activity>> _activitiesFuture;
  Customer? _selectedCustomer;

  // Status options
  final List<String> _statusOptions = ['Completed', 'Pending', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _customerIdController = TextEditingController(
      text: widget.visit?.customerId.toString() ?? '',
    );
    _selectedDate = widget.visit?.visitDate ?? DateTime.now();
    _selectedStatus = widget.visit?.status ?? _statusOptions[0];
    _locationController = TextEditingController(
      text: widget.visit?.location ?? '',
    );
    _notesController = TextEditingController(text: widget.visit?.notes ?? '');
    _selectedActivities = widget.visit?.activitiesDone ?? [];

    // Initialize data
    _customersFuture = sl<CustomerRepository>().getCustomers();
    _activitiesFuture = sl<ActivityRepository>().getActivities();

    // Set selected customer if visit exists
    if (widget.visit != null) {
      _fetchAndSetCustomer(widget.visit!.customerId);
    }
  }

  @override
  void dispose() {
    _customerIdController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Fetch and set customer
  void _fetchAndSetCustomer(int customerId) async {
    final customers = await _customersFuture;
    try {
      final customer = customers.firstWhere((c) => c.id == customerId);
      setState(() {
        _selectedCustomer = customer;
      });
    } catch (e) {
      // No customer found with the given ID
    }
  }

  // Date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Toggle activity selection
  void _toggleActivity(String activityId) {
    setState(() {
      if (_selectedActivities.contains(activityId)) {
        _selectedActivities.remove(activityId);
      } else {
        _selectedActivities.add(activityId);
      }
    });
  }

  // Submit form
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final visit = Visit(
        id: widget.visit?.id,
        customerId: int.tryParse(_customerIdController.text) ?? 0,
        visitDate: _selectedDate,
        status: _selectedStatus,
        location: _locationController.text,
        notes: _notesController.text,
        activitiesDone: _selectedActivities,
        createdAt: widget.visit?.createdAt,
        isSynced: widget.visit?.isSynced ?? false,
      );

      widget.onSave(visit);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Customer dropdown
            FutureBuilder<List<Customer>>(
              future: _customersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No customers available');
                } else {
                  return DropdownButtonFormField<Customer>(
                    decoration: const InputDecoration(
                      labelText: 'Customer',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedCustomer,

                    items:
                        snapshot.data!.map((customer) {
                          return DropdownMenuItem(
                            value: customer,
                            child: Text(
                              '${customer.id} - ${customer.name}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCustomer = value;
                        _customerIdController.text = value?.id.toString() ?? '';
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a customer';
                      }
                      return null;
                    },
                  );
                }
              },
            ),

            const SizedBox(height: 16),

            // Visit Date
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: TextFormField(
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                  decoration: const InputDecoration(
                    labelText: 'Visit Date',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  controller: TextEditingController(
                    text: DateFormat('yyyy-MM-dd').format(_selectedDate),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a date';
                    }
                    return null;
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Status dropdown
            DropdownButtonFormField<String>(
              style: const TextStyle(fontSize: 16, color: Colors.black54),
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              value: _selectedStatus,
              items:
                  _statusOptions.map((status) {
                    return DropdownMenuItem(value: status, child: Text(status));
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedStatus = value;
                  });
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a status';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Location
            TextFormField(
              style: const TextStyle(fontSize: 16, color: Colors.black54),
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
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
              style: const TextStyle(fontSize: 16, color: Colors.black54),
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
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
            FutureBuilder<List<Activity>>(
              future: _activitiesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error loading activities: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No activities available');
                } else {
                  final activities = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Activities Done',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            activities.map((activity) {
                              final isSelected = _selectedActivities.contains(
                                activity.id,
                              );
                              return FilterChip(
                                label: Text(activity.description),
                                selected: isSelected,
                                onSelected: (_) => _toggleActivity(activity.id),
                                backgroundColor: Colors.grey[200],
                                selectedColor: Colors.blue[100],
                              );
                            }).toList(),
                      ),
                    ],
                  );
                }
              },
            ),

            const SizedBox(height: 24),

            // Submit button
            ElevatedButton(
              onPressed: widget.isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child:
                  widget.isLoading
                      ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                      : Text(
                        widget.visit == null ? 'Create Visit' : 'Update Visit',
                        style: const TextStyle(fontSize: 16),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
