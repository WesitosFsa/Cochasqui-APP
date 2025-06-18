import 'package:cochasqui_park/features/stats/models/Users.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart'; 



class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key}); 

  @override
  // ignore: library_private_types_in_public_api
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  DateTime fechaInicio = DateTime.now().subtract(const Duration(days: 7));
  DateTime fechaFin = DateTime.now();

  Map<String, int> puntosVisitados = {};
  Map<String, int> modelosVistos = {};

  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    cargarEstadisticas();
  }

  Future<void> cargarEstadisticas() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final List<Pin> allPins = await _getPinDetails();
      final Map<int, Pin> pinMap = {for (var pin in allPins) pin.id: pin};

      final List<VisitedPin> visitedPinsData = await _getVisitedPinsFilteredByDate();

      final Map<String, int> tempPuntosVisitados = {};
      for (var visitedPin in visitedPinsData) {
        final pinDetail = pinMap[visitedPin.pinId];
        if (pinDetail != null) {
          tempPuntosVisitados.update(
            pinDetail.title,
            (value) => value + 1,
            ifAbsent: () => 1,
          );
        }
      }

      final Map<String, int> tempModelosVistos = {};
      for (var visitedPin in visitedPinsData) {
        final pinDetail = pinMap[visitedPin.pinId];
        if (pinDetail != null) {
          tempModelosVistos.update(
            pinDetail.type, 
            (value) => value + 1,
            ifAbsent: () => 1,
          );
        }
      }

      setState(() {
        puntosVisitados = tempPuntosVisitados;
        modelosVistos = tempModelosVistos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar estadísticas: $e';
        _isLoading = false;
      });
      debugPrint('Error loading statistics: $e');
    }
  }

  Future<List<Pin>> _getPinDetails() async {
    final List<dynamic> data = await supabase.from('map_pins').select();

    return data.map((json) => Pin.fromJson(json)).toList();
  }

  Future<List<VisitedPin>> _getVisitedPinsFilteredByDate() async {
    final String startDateISO = DateFormat('yyyy-MM-ddTHH:mm:ss').format(fechaInicio.toUtc());
    final String endDateISO = DateFormat('yyyy-MM-ddTHH:mm:ss')
        .format(fechaFin.toUtc().add(const Duration(hours: 23, minutes: 59, seconds: 59, milliseconds: 999)));

    final List<dynamic> data = await supabase
        .from('visited_pins')
        .select()
        .gte('visited_at', startDateISO)
        .lte('visited_at', endDateISO);

    return data.map((json) => VisitedPin.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: Column(
        children: [
          _buildDatePickers(),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_errorMessage.isNotEmpty)
            Expanded(child: Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red))))
          else
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('🏞️ Puntos más visitados (Barras)', style: _titulo()),
                    SizedBox(
                      height: 220,
                      child: puntosVisitados.isEmpty
                          ? const Center(child: Text('No hay datos de puntos visitados en este rango.'))
                          : _buildBarChart(puntosVisitados),
                    ),
                    const SizedBox(height: 30),
                    Text('Puntos mas vistos(Pastel)', style: _titulo()),
                    SizedBox(
                      height: 220,
                      child: modelosVistos.isEmpty
                          ? const Center(child: Text('No hay datos de modelos AR vistos en este rango.'))
                          : _buildPieChart(modelosVistos),
                    ),
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
          child: Text('Desde: ${DateFormat('yyyy-MM-dd').format(fechaInicio)}'),
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
          child: Text('Hasta: ${DateFormat('yyyy-MM-dd').format(fechaFin)}'),
        ),
      ],
    );
  }

  Widget _buildBarChart(Map<String, int> data) {
    final sorted = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sorted.isEmpty) {
      return const Center(child: Text("No hay datos para mostrar en el gráfico de barras."));
    }

    double maxYValue = (sorted.first.value + (sorted.first.value * 0.1)).toDouble(); 

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxYValue,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${sorted[group.x.toInt()].key}\n',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                children: <TextSpan>[
                  TextSpan(
                    text: rod.toY.toInt().toString(),
                    style: const TextStyle(
                      color: Colors.yellow,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: (maxYValue / 5).roundToDouble().clamp(1.0, double.infinity), 
              getTitlesWidget: (value, meta) {
                return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10));
              },
              reservedSize: 28,
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) {
                int index = val.toInt();
                if (index >= 0 && index < sorted.length) {
                  return RotatedBox(
                    quarterTurns: 3, 
                    child: Text(sorted[index].key, style: const TextStyle(fontSize: 10)),
                  );
                }
                return const Text('');
              },
              reservedSize: 80, 
              interval: 1,
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1),
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
    final colors = [
      Colors.red.shade400, Colors.green.shade400, Colors.orange.shade400,
      Colors.purple.shade400, Colors.blue.shade400, Colors.teal.shade400,
      Colors.amber.shade400, Colors.indigo.shade400, Colors.pink.shade400,
    ]; 

    final entries = data.entries.toList();

    if (entries.isEmpty) {
      return const Center(child: Text("No hay datos para mostrar en el gráfico de pastel."));
    }

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
            title: '$percent%',
            radius: 60,
            titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
            badgeWidget: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(e.key, style: const TextStyle(fontSize: 10)),
            ),
            badgePositionPercentageOffset: 1.2,
          );
        }),
      ),
    );
  }

  TextStyle _titulo() => const TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
}