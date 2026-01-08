import 'dart:async';
import 'dart:convert';
import 'package:app_rense/data/models/PacienteModelo.dart';
import 'package:http/http.dart' as http;

class PacienteService {
  final String baseUrl = "http://72.60.172.55:3000/api";

  Future<PacienteModelo> fetchPacienteCompleto(int pacienteId) async {
    // Por el momento no usamos pacienteID ni triage
    try {
      // Definimos todas las peticiones simultáneas
      final respuestas = await Future.wait([
        http.get(Uri.parse('$baseUrl/historial_completo/signos_vitales')),
        http.get(Uri.parse('$baseUrl/historial_completo/saturacion_oxigeno')),
        http.get(Uri.parse('$baseUrl/historial_completo/temperatura')),
        // http.get(Uri.parse('$baseUrl/triage/$pacienteId')), // El triage todavia no es parte de la API
      ]).timeout(const Duration(seconds: 10));

      // Validamos que todas las respuestas sean exitosas (status 200)
      for (var respuesta in respuestas) {
        print("STATUS CODE: ${respuesta.statusCode}");
        print("BODY: ${respuesta.body}");
        if (respuesta.statusCode != 200) {
          throw Exception('Error al cargar datos: ${respuesta.reasonPhrase}');
        }
      }

      // Extraemos los cuerpos de las respuestas
      List dataVitalesRaw = json.decode(respuestas[0].body);
      List dataSaturacionRaw = json.decode(respuestas[1].body);
      List dataTemperaturaRaw = json.decode(respuestas[2].body);
      // List dataTriageRaw = json.decode(respuestas[3].body);
      final dataTriage =
          "Sin asignar"; // El triage todavia no es parte de la API

      // Instanciamos las SerieTemporal a partir de los datos crudos
      final dataVitales = SerieTemporal(
        values:
            dataVitalesRaw.map((e) => (e['pulso'] as num).toDouble()).toList(),
        timestamps:
            dataVitalesRaw.map((e) => DateTime.parse(e['timestamp'])).toList(),
      );

      final dataSaturacion = SerieTemporal(
        values: dataSaturacionRaw
            .map((e) => (e['valor'] as num).toDouble())
            .toList(),
        timestamps: dataSaturacionRaw
            .map((e) => DateTime.parse(e['timestamp']))
            .toList(),
      );

      final dataTemperatura = SerieTemporal(
        values: dataTemperaturaRaw
            .map((e) => (e['valor'] as num).toDouble())
            .toList(),
        timestamps: dataTemperaturaRaw
            .map((e) => DateTime.parse(e['timestamp']))
            .toList(),
      );

      // Combinamos todo en tu modelo
      return PacienteModelo(
        signosVitales: dataVitales,
        saturacionOxigeno: dataSaturacion,
        temperatura: dataTemperatura,
        triage: dataTriage,
      );
    } catch (e) {
      if (e is TimeoutException) {
        throw TimeoutException("Tiempo de conexión agotado (10s)");
      }
      throw Exception("Error de conexión: $e");
    }
  }
}
