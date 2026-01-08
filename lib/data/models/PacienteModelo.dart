class PacienteModelo {
  final SerieTemporal signosVitales;
  final SerieTemporal saturacionOxigeno;
  final SerieTemporal temperatura;
  final String triage;

  PacienteModelo({
    required this.signosVitales,
    required this.saturacionOxigeno,
    required this.temperatura,
    required this.triage,
  });

  // Factory para convertir la respuesta de la API (JSON) al modelo
  factory PacienteModelo.fromJson(Map<String, dynamic> json) {
    return PacienteModelo(
      signosVitales: SerieTemporal.fromJson(json['vital_signs']),
      saturacionOxigeno: SerieTemporal.fromJson(json['saturation']),
      temperatura: SerieTemporal.fromJson(json['temperature']),
      triage: json['triage'] ?? 'Sin asignar',
    );
  }
}

class SerieTemporal {
  final List<double> values;
  final List<DateTime> timestamps;

  SerieTemporal({
    required this.values,
    required this.timestamps,
  });

  factory SerieTemporal.fromJson(Map<String, dynamic> json) {
    return SerieTemporal(
      // Convierte la lista de la API a una lista de doubles
      values: List<double>.from(json['values'].map((x) => x.toDouble())),
      // Convierte los strings de tiempo de la API a objetos DateTime de Dart
      timestamps: List<DateTime>.from(
        json['timestamps'].map((x) => DateTime.parse(x)),
      ),
    );
  }
}
