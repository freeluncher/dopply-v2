import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/offline_service.dart';

// Modified to accept an optional patientId (int?)
// If null: fetches current user's patient ID.
// If provided: uses that ID directly (for Doctors).
final recordsProvider = StreamProvider.family
    .autoDispose<List<Map<String, dynamic>>, int?>((ref, patientId) {
      final offlineService = ref.watch(offlineServiceProvider);
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return Stream.value([]);

      // Helper to generate cache key
      String getCacheKey(int id) => 'records_$id';

      if (patientId != null) {
        // 1. DOCTOR MODE (Specific Patient)
        if (!offlineService.isOnline) {
          final cached = offlineService.getFromCache(getCacheKey(patientId));
          if (cached != null) {
            final List<Map<String, dynamic>> typedCache = (cached as List)
                .cast<Map<String, dynamic>>();
            return Stream.value(typedCache);
          }
          return Stream.value(<Map<String, dynamic>>[]);
        }

        return Supabase.instance.client
            .from('records')
            .stream(primaryKey: ['id'])
            .eq('patient_id', patientId)
            .order('created_at', ascending: false)
            .map((data) {
              offlineService.saveToCache(getCacheKey(patientId), data);
              return data;
            });
      } else {
        // 2. PATIENT MODE (Own Records)
        return Supabase.instance.client
            .from('patients')
            .select('id')
            .eq('user_id', user.id)
            .asStream()
            .asyncExpand((patientDataList) {
              if (patientDataList.isEmpty)
                return Stream.value(<Map<String, dynamic>>[]);
              final myPatientId = patientDataList.first['id'];

              if (!offlineService.isOnline) {
                final cached = offlineService.getFromCache(
                  getCacheKey(myPatientId),
                );
                if (cached != null) {
                  final List<Map<String, dynamic>> typedCache = (cached as List)
                      .cast<Map<String, dynamic>>();
                  return Stream.value(typedCache);
                }
                return Stream.value(<Map<String, dynamic>>[]);
              }

              return Supabase.instance.client
                  .from('records')
                  .stream(primaryKey: ['id'])
                  .eq('patient_id', myPatientId)
                  .order('created_at', ascending: false)
                  .map((data) {
                    offlineService.saveToCache(getCacheKey(myPatientId), data);
                    return data;
                  });
            });
      }
    });

final recordSearchProvider = StateProvider.autoDispose<String>((ref) => '');

enum RecordSortOption { dateDesc, dateAsc, bpmDesc, bpmAsc }

final recordSortProvider = StateProvider.autoDispose<RecordSortOption>(
  (ref) => RecordSortOption.dateDesc,
);

final filteredRecordsProvider = Provider.family
    .autoDispose<AsyncValue<List<Map<String, dynamic>>>, int?>((
      ref,
      patientId,
    ) {
      final recordsAsync = ref.watch(recordsProvider(patientId));
      final searchQuery = ref.watch(recordSearchProvider).toLowerCase();
      final sortOption = ref.watch(recordSortProvider);

      return recordsAsync.whenData((records) {
        var filtered = records;

        // 1. Filter
        if (searchQuery.isNotEmpty) {
          filtered = filtered.where((record) {
            final classification = (record['classification'] ?? '')
                .toString()
                .toLowerCase();
            final notes = (record['notes'] ?? '').toString().toLowerCase();
            return classification.contains(searchQuery) ||
                notes.contains(searchQuery);
          }).toList();
        }

        // 2. Sort
        filtered.sort((a, b) {
          switch (sortOption) {
            case RecordSortOption.dateDesc:
              return b['created_at'].compareTo(a['created_at']);
            case RecordSortOption.dateAsc:
              return a['created_at'].compareTo(b['created_at']);
            case RecordSortOption.bpmDesc:
              return (b['average_bpm'] as num).compareTo(
                a['average_bpm'] as num,
              );
            case RecordSortOption.bpmAsc:
              return (a['average_bpm'] as num).compareTo(
                b['average_bpm'] as num,
              );
          }
        });

        return filtered;
      });
    });

class RecordsScreen extends ConsumerWidget {
  final int? patientId; // Optional: if provided, shows records for this patient

  const RecordsScreen({super.key, this.patientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Pass the patientId (null or value) to the provider
    final recordsAsync = ref.watch(filteredRecordsProvider(patientId));

    return Scaffold(
      appBar: AppBar(
        title: Text(patientId == null ? 'My History' : 'Patient History'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search (e.g. Normal, Notes)',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          ref.read(recordSearchProvider.notifier).state = '';
                        },
                      ),
                    ),
                    onChanged: (value) {
                      ref.read(recordSearchProvider.notifier).state = value;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<RecordSortOption>(
                  icon: const Icon(Icons.sort),
                  onSelected: (option) {
                    ref.read(recordSortProvider.notifier).state = option;
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: RecordSortOption.dateDesc,
                      child: Text('Newest First'),
                    ),
                    const PopupMenuItem(
                      value: RecordSortOption.dateAsc,
                      child: Text('Oldest First'),
                    ),
                    const PopupMenuItem(
                      value: RecordSortOption.bpmDesc,
                      child: Text('BPM (High to Low)'),
                    ),
                    const PopupMenuItem(
                      value: RecordSortOption.bpmAsc,
                      child: Text('BPM (Low to High)'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: recordsAsync.when(
        data: (records) {
          if (records.isEmpty) {
            final isSearching = ref.read(recordSearchProvider).isNotEmpty;
            return Center(
              child: Text(
                isSearching
                    ? 'No records match your search.'
                    : 'No records found.',
              ),
            );
          }
          return ListView.builder(
            itemCount: records.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final record = records[index];
              final date = DateTime.parse(record['start_time']);
              // Handle potential null or int/double differences safely
              final avgBpm = ((record['average_bpm'] ?? 0) as num).toDouble();
              final classification = record['classification'];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getColorForClassification(classification),
                    child: const Icon(Icons.favorite, color: Colors.white),
                  ),
                  title: Text('${avgBpm.toStringAsFixed(1)} BPM'),
                  subtitle: Text(
                    DateFormat('dd MMM yyyy, HH:mm').format(date.toLocal()),
                  ),
                  trailing: Text(
                    classification ?? 'Unknown',
                    style: TextStyle(
                      color: _getColorForClassification(classification),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    context.push('/records/${record['id']}');
                  },
                ),
              );
            },
          );
        },
        error: (err, stack) => Center(child: Text('Error: $err')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Go to monitoring screen
          // If patientId is set (Doctor mode), pass it to query params
          // If null (Patient mode), pass nothing

          final uri = Uri(
            path: '/monitoring',
            queryParameters: patientId != null
                ? {'patientId': patientId.toString()}
                : null,
          );
          context.push(uri.toString());
        },
        label: const Text('New Measurement'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Color _getColorForClassification(String? classification) {
    switch (classification?.toLowerCase()) {
      case 'normal':
        return Colors.green;
      case 'bradycardia':
        return Colors.orange;
      case 'tachycardia':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
