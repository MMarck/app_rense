// Este archivo contiene datos simulados para pruebas y desarrollo.

import 'package:app_rense/data/models/PacienteModelo.dart';

class MockData {
  // El JSON crudo (Map)
  static const Map<String, dynamic> patientJsonExample = {
    "vital_signs": {
      "values": [72.5, 75.0, 74.2, 78.1, 73.5, 76.0, 75.5],
      "timestamps": [
        "2024-05-20T10:00:00Z",
        "2024-05-20T10:05:00Z",
        "2024-05-20T10:10:00Z",
        "2024-05-20T10:15:00Z",
        "2024-05-20T10:20:00Z",
        "2024-05-20T10:25:00Z",
        "2024-05-20T10:30:00Z"
      ]
    },
    "saturation": {
      "values": [98.0, 97.5, 99.0, 96.5, 98.2, 97.8, 98.5],
      "timestamps": [
        "2024-05-20T10:00:00Z",
        "2024-05-20T10:05:00Z",
        "2024-05-20T10:10:00Z",
        "2024-05-20T10:15:00Z",
        "2024-05-20T10:20:00Z",
        "2024-05-20T10:25:00Z",
        "2024-05-20T10:30:00Z"
      ]
    },
    "temperature": {
      "values": [36.5, 36.6, 36.8, 37.0, 36.9, 36.7, 36.6],
      "timestamps": [
        "2024-05-20T10:00:00Z",
        "2024-05-20T10:05:00Z",
        "2024-05-20T10:10:00Z",
        "2024-05-20T10:15:00Z",
        "2024-05-20T10:20:00Z",
        "2024-05-20T10:25:00Z",
        "2024-05-20T10:30:00Z"
      ]
    },
    "triage": "Urgencia Menor"
  };

  // Una instancia ya convertida al modelo para uso directo
  static PacienteModelo get mockPatient =>
      PacienteModelo.fromJson(patientJsonExample);
}
