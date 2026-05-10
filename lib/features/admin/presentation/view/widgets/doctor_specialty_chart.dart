import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// A pie chart displaying the distribution of doctors across different specialties.
/// 
/// Uses [fl_chart] to render the data and includes a color-coded legend.
class DoctorSpecialtyChart extends StatelessWidget {
  final Map<String, int> specialtyDistribution;

  const DoctorSpecialtyChart({super.key, required this.specialtyDistribution});

  @override
  Widget build(BuildContext context) {
    if (specialtyDistribution.isEmpty) {
      return const Center(child: Text('No data for specialty distribution'));
    }

    final List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.amber,
    ];

    int i = 0;
    final sections = specialtyDistribution.entries.map((entry) {
      final color = colors[i % colors.length];
      i++;
      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: '${entry.value}',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Doctor Specialties',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildLegend(colors),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(List<Color> colors) {
    int i = 0;
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: specialtyDistribution.keys.map((specialty) {
        final color = colors[i % colors.length];
        i++;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(specialty, style: const TextStyle(fontSize: 12)),
          ],
        );
      }).toList(),
    );
  }
}
