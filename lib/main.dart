import 'dart:async';

import 'package:app_rense/data/datasources/PacienteService.dart';
import 'package:app_rense/data/datasources/mock_data.dart.dart';
import 'package:app_rense/data/models/PacienteModelo.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

void main() {
  runApp(const DashboardApp());
}

class DashboardApp extends StatelessWidget {
  const DashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        scaffoldBackgroundColor:
            const Color(0xFFF5F7FA), // Color de fondo suave
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // 1. Declaramos el futuro como una variable de estado para evitar
  // que la petición se repita innecesariamente si el widget se redibuja.
  late Future<PacienteModelo> _pacienteFuture;
  final PacienteService _service = PacienteService();

  @override
  void initState() {
    super.initState();
    // 2. Inicializamos la llamada al servicio (ID de ejemplo: 1)
    try {
      _pacienteFuture = _service.fetchPacienteCompleto(1);
    } catch (e) {
      if (e is TimeoutException) {
        throw TimeoutException(
            "Tiempo de conexión agotado (10s) ======= MOSTRANDO MOCK DATA =======");
      }
      print("ERROR EN MAIN DART");
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Monitor de Paciente"),
        actions: [
          // Botón opcional para refrescar datos
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {
              _pacienteFuture = _service.fetchPacienteCompleto(1);
            }),
          )
        ],
      ),
      // 3. Usamos FutureBuilder para escuchar el estado de la petición
      body: FutureBuilder<PacienteModelo>(
        future: _pacienteFuture,
        builder: (context, snapshot) {
          // CASO A: Cargando
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // CASO B: Error
          if (snapshot.hasError) {
            // Verificamos si el error es un TimeoutException
            if (snapshot.error.toString().contains("TimeoutException")) {
              // Usar datos mock en caso de timeout
              final mockData = MockData.mockPatient;
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // aviso de datos simulados
                  _buildMockDataBanner(),
                  _buildTriageHeader(mockData.triage),
                  const SizedBox(height: 16),

                  StatCard(
                    title: "Signos Vitales (BPM)",
                    value: "${mockData.signosVitales.values.last}",
                    trend: "Real-time",
                    isPositive: true,
                    chartColor: Colors.blue,
                    data: mockData.signosVitales.values,
                  ),
                  const SizedBox(height: 12),

                  StatCard(
                    title: "Saturación O2",
                    value: "${mockData.saturacionOxigeno.values.last}%",
                    trend: "Estable",
                    isPositive: true,
                    chartColor: Colors.orange,
                    data: mockData.saturacionOxigeno.values,
                  ),
                  const SizedBox(height: 12),

                  StatCard(
                    title: "Temperatura",
                    value: "${mockData.temperatura.values.last}°C",
                    trend: "Monitorizado",
                    isPositive: true,
                    chartColor: Colors.redAccent,
                    data: mockData.temperatura.values,
                  ),
                ],
              );
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text("Error: ${snapshot.error}."),
                  ElevatedButton(
                    onPressed: () => setState(() {
                      _pacienteFuture = _service.fetchPacienteCompleto(1);
                    }),
                    child: const Text("Reintentar"),
                  )
                ],
              ),
            );
          }

          // CASO C: Éxito (Tenemos datos)
          if (snapshot.hasData) {
            final patientData = snapshot.data!;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildTriageHeader(patientData.triage),
                const SizedBox(height: 16),
                StatCard(
                  title: "Signos Vitales (BPM)",
                  value: "${patientData.signosVitales.values.last}",
                  trend: "Real-time",
                  isPositive: true,
                  chartColor: Colors.blue,
                  data: patientData.signosVitales.values,
                ),
                const SizedBox(height: 12),
                StatCard(
                  title: "Saturación O2",
                  value: "${patientData.saturacionOxigeno.values.last}%",
                  trend: "Estable",
                  isPositive: true,
                  chartColor: Colors.orange,
                  data: patientData.saturacionOxigeno.values,
                ),
                const SizedBox(height: 12),
                StatCard(
                  title: "Temperatura",
                  value: "${patientData.temperatura.values.last}°C",
                  trend: "Monitorizado",
                  isPositive: true,
                  chartColor: Colors.redAccent,
                  data: patientData.temperatura.values,
                ),
              ],
            );
          }

          return const Center(child: Text("No se encontraron datos"));
        },
      ),
    );
  }

  // Widget auxiliar para el encabezado de Triage
  Widget _buildTriageHeader(String triage) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.person, color: Colors.blue),
          const SizedBox(width: 8),
          Text(
            "Triage: $triage",
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.blue),
          ),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String trend;
  final bool isPositive;
  final List<double> data;
  final Color chartColor;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.trend,
    required this.isPositive,
    required this.data,
    required this.chartColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            // Sección de Información
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        isPositive ? Icons.trending_up : Icons.trending_down,
                        color: isPositive ? Colors.green : Colors.red,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        trend,
                        style: TextStyle(
                          color: isPositive ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Last month",
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Sección del Gráfico Sparkline
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 60,
                child: SfSparkLineChart(
                  color: chartColor,
                  width: 2.5,
                  axisLineWidth: 0,
                  data: data,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// aviso de datos simulados
Widget _buildMockDataBanner() {
  return Container(
    padding: const EdgeInsets.all(8),
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: Colors.yellow[100],
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.yellow[700]!),
    ),
    child: Row(
      children: const [
        Icon(Icons.warning, color: Colors.orange),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            "No se pudo conectar al servidor. Mostrando datos simulados.",
            style: TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}
