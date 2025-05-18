import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/customers/presentation/cubit/customer_cubit.dart';
import '../../../../features/customers/presentation/cubit/customer_state.dart';

class CustomerNameDisplay extends StatelessWidget {
  final int customerId;

  const CustomerNameDisplay({super.key, required this.customerId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerCubit, CustomerState>(
      builder: (context, state) {
        if (state is CustomersLoaded) {
          // Find the customer by ID
          final customer =
              state.customers.where((c) => c.id == customerId).firstOrNull;

          // Display customer name if found, otherwise fall back to ID
          if (customer != null) {
            // Remove Expanded - this is the key fix
            return Text(
              customer.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: Colors.black,
              ),
            );
          }
        }

        // Fallback to showing just the ID when customer data is not available
        return Text(
          'Customer #$customerId',
          style: const TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        );
      },
    );
  }
}
