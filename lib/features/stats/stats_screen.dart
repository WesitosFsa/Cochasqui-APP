import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class EstadisticasScreen extends StatefulWidget {
  @override
  _EstadisticasScreenState createState() => _EstadisticasScreenState();
}

class _EstadisticasScreenState extends State<EstadisticasScreen> {
  DateTime fechaInicio = DateTime.now().subtract(Duration(days: 7));
  DateTime fechaFin = DateTime.now();

  Map<String, int> puntosVisitados = {
    'Templo del Sol': 34,
    'Pirámide 3': 22,
    'Plaza Ceremonial': 15,
    'Museo': 12,
  };

  Map<String, int> modelosVistos = {
    'modelovacija': 40,
    'modeloinca': 25,
    'modelototem': 10,
  };

  Future<void> cargarEstadisticas() async {
    await Future.delayed(Duration(milliseconds: 300));
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    cargarEstadisticas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Estadísticas')),
      body: Column(
        children: [
          _buildDatePickers(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('🏞️ Puntos más visitados (Barras)', style: _titulo()),
                  SizedBox(height: 220, child: _buildBarChart(puntosVisitados)),
                  SizedBox(height: 30),
                  Text('🕶️ Modelos AR más vistos (Pastel)', style: _titulo()),
                  SizedBox(height: 220, child: _buildPieChart(modelosVistos)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickers() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        TextButton(
          onPressed: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: fechaInicio,
              firstDate: DateTime(2024),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              setState(() => fechaInicio = picked);
              await cargarEstadisticas();
            }
          },
          child: Text('Desde: ${fechaInicio.toLocal().toString().split(' ')[0]}'),
        ),
        TextButton(
          onPressed: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: fechaFin,
              firstDate: DateTime(2024),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              setState(() => fechaFin = picked);
              await cargarEstadisticas();
            }
          },
          child: Text('Hasta: ${fechaFin.toLocal().toString().split(' ')[0]}'),
        ),
      ],
    );
  }

  Widget _buildBarChart(Map<String, int> data) {
    final sorted = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (sorted.first.value + 10).toDouble(),
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(),
          topTitles: AxisTitles(),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) {
                int index = val.toInt();
                if (index >= 0 && index < sorted.length) {
                  return Text(sorted[index].key, style: TextStyle(fontSize: 10));
                }
                return Text('');
              },
              reservedSize: 60,
              interval: 1,
            ),
          ),
          rightTitles: AxisTitles(),
        ),
        barGroups: List.generate(sorted.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: sorted[i].value.toDouble(),
                color: Colors.blue,
                width: 20,
                borderRadius: BorderRadius.circular(6),
              )
            ],
          );
        }),
      ),
    );
  }

  Widget _buildPieChart(Map<String, int> data) {
    final total = data.values.fold(0, (a, b) => a + b);
    final colors = [Colors.red, Colors.green, Colors.orange, Colors.purple, Colors.blue];

    final entries = data.entries.toList();

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: List.generate(entries.length, (i) {
          final e = entries[i];
          final percent = (e.value / total * 100).toStringAsFixed(1);
          return PieChartSectionData(
            color: colors[i % colors.length],
            value: e.value.toDouble(),
            title: '${percent}%',
            radius: 60,
            titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
            badgeWidget: Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: Text(e.key, style: TextStyle(fontSize: 10)),
            ),
            badgePositionPercentageOffset: 1.2,
          );
        }),
      ),
    );
  }

  TextStyle _titulo() => TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
}
