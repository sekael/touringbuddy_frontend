import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:touringbuddy_frontend/core/config/theme.dart';
import 'package:touringbuddy_frontend/features/tours/domain/tour.dart';
import 'package:touringbuddy_frontend/providers/contacts_service.dart';

class TourInfoSheet extends StatelessWidget {
  final Tour tour;

  const TourInfoSheet({super.key, required this.tour});

  @override
  Widget build(BuildContext context) {
    final contactsService = context.watch<ContactsService>();
    final partners = contactsService.contacts
        .where((c) => tour.partnerIds.contains(c.id))
        .toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            tour.name ?? 'Unnamed Tour',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        SizedBox(height: tourenBuddySpacings.sm),
        if (tour.plannedDate != null)
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: tourenBuddyTheme.hintColor,
              ),
              SizedBox(width: tourenBuddySpacings.xs),
              Text(
                'Planned for: ${tour.plannedDate!.toLocal().toString().split(' ')[0]}',
                style: tourenBuddyTheme.textTheme.bodyMedium?.copyWith(
                  color: tourenBuddyTheme.hintColor,
                ),
              ),
            ],
          ),
        Divider(height: tourenBuddySpacings.lg),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const CircleAvatar(child: Icon(Icons.location_on)),
          title: const Text('Coordinates'),
          subtitle: Text(
            '${tour.goal.latitude.toStringAsFixed(5)}, ${tour.goal.longitude.toStringAsFixed(5)}',
          ),
        ),
        Divider(height: tourenBuddySpacings.lg),
        Text(
          'Touring Partners',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: tourenBuddySpacings.xs),
        if (partners.isEmpty)
          const Text(
            'No partners added to this tour.',
            style: TextStyle(fontStyle: FontStyle.italic),
          )
        else
          Wrap(
            spacing: tourenBuddySpacings.xs,
            children: partners
                .map(
                  (p) => Chip(
                    avatar: const CircleAvatar(
                      child: Icon(Icons.person, size: 14),
                    ),
                    label: Text(p.displayName ?? p.firstName),
                    visualDensity: VisualDensity.compact,
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}
