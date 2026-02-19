import 'package:flutter/material.dart';
import 'package:touringbuddy_frontend/features/tours/domain/tour.dart';

class TourInfoSheet extends StatelessWidget {
  final Tour tour;

  const TourInfoSheet({super.key, required this.tour});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.2,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.1)),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            children: [
              // Handle for dragging
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                tour.name ?? 'Unnamed Tour',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (tour.plannedDate != null)
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: theme.hintColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Planned for: ${tour.plannedDate!.toLocal().toString().split(' ')[0]}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              const Divider(height: 32),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(child: Icon(Icons.location_on)),
                title: const Text('Coordinates'),
                subtitle: Text(
                  '${tour.goal.latitude.toStringAsFixed(5)}, ${tour.goal.longitude.toStringAsFixed(5)}',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  // Add logic for navigation or editing
                },
                icon: const Icon(Icons.directions),
                label: const Text('Start Navigation'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
