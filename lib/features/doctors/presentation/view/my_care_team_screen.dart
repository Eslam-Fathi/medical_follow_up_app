import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medical_follow_up_app/core/theme/app_icons.dart';
import 'package:medical_follow_up_app/features/doctors/presentation/manager/care_team_provider.dart';
import 'package:medical_follow_up_app/features/doctors/presentation/view/care_team_detail_screen.dart';
import 'package:medical_follow_up_app/features/profile/presentation/manager/profile.provider.dart';
import 'package:medical_follow_up_app/core/utils/responsive_wrapper.dart';

/// A screen displaying the user's personalized list of healthcare providers.
/// 
/// It allows users to quickly access the profiles of doctors they have 
/// added to their care team or remove them if no longer needed.
class MyCareTeamScreen extends ConsumerWidget {
  const MyCareTeamScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final careTeamDoctors = ref.watch(careTeamProvider);
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Care Team'),
      ),
      body: careTeamDoctors.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    AppIcons.heart,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No doctors in your care team yet.',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Search for doctors and add them to easily access them here.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade500,
                        ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/doctors_list');
                    },
                    icon: const Icon(Icons.search),
                    label: const Text('Find Doctors'),
                  ),
                ],
              ),
            )
          : ResponsiveWrapper(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: careTeamDoctors.length,
                itemBuilder: (context, index) {
                  final doc = careTeamDoctors[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        radius: 28,
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        child: const Icon(Icons.person, size: 32),
                      ),
                      title: Text(
                        'Dr. ${doc.name}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            doc.specialty,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                            tooltip: 'Remove from Care Team',
                            onPressed: () {
                              ref.read(careTeamProvider.notifier).removeDoctor(doc.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Removed Dr. ${doc.name} from Care Team')),
                              );
                            },
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () {
                              profileAsync.whenData((profile) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => CareTeamDetailScreen(doctor: doc, profile: profile),
                                  ),
                                );
                              });
                            },
                            child: const Text('View'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
