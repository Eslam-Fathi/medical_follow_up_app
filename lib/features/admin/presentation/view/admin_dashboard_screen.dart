import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medical_follow_up_app/core/network/api_providers.dart';
import 'package:medical_follow_up_app/features/auth/presentation/manager/state/auth_notifier.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  List<dynamic> _pendingDoctors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPendingDoctors();
  }

  Future<void> _fetchPendingDoctors() async {
    setState(() => _isLoading = true);
    try {
      final docApi = ref.read(doctorApiProvider);
      final docs = await docApi.getPendingDoctors();
      if (mounted) {
        setState(() {
          _pendingDoctors = docs;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load doctors: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(String doctorId, String status) async {
    try {
      final docApi = ref.read(doctorApiProvider);
      await docApi.updateDoctorStatus(doctorId, status);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile $status!')));
        _fetchPendingDoctors(); // Refresh list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authNotifierProvider.notifier).logout();
              Navigator.of(context).pushReplacementNamed('/auth');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingDoctors.isEmpty
              ? const Center(child: Text('No pending doctor applications.'))
              : RefreshIndicator(
                  onRefresh: _fetchPendingDoctors,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _pendingDoctors.length,
                    itemBuilder: (context, index) {
                      final doc = _pendingDoctors[index];
                      // Fallbacks if data structure varies slightly
                      final docId = doc['_id'] ?? '';
                      // User detail could be nested inside "user" or "userId"
                      final userName = doc['userId'] is Map ? doc['userId']['name'] : 'Unknown User';
                      final specialization = doc['specialization'] ?? 'Unknown';
                      final experience = doc['yearsOfExperience'] ?? '?';
                      final license = doc['licenseNumber'] ?? '?';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                    child: const Icon(Icons.medical_information),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        Text(specialization, style: TextStyle(color: Colors.grey[600])),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text('PENDING', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              Text('License: $license'),
                              const SizedBox(height: 4),
                              Text('Experience: $experience years'),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                                    onPressed: () => _updateStatus(docId, 'REJECTED'),
                                    icon: const Icon(Icons.close),
                                    label: const Text('Reject'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                    onPressed: () => _updateStatus(docId, 'APPROVED'),
                                    icon: const Icon(Icons.check),
                                    label: const Text('Approve'),
                                  ),
                                ],
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
