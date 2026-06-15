import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;


import 'package:mindcare/models/models.dart';

class ApiService {
  Future<List<RegistroDiario>> carregarRegistrosDiarios(
    String nomeUsuario,
  ) async {
    final response = await http.get(
      Uri.parse('http://localhost:8080/registrosDiarios/$nomeUsuario'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);

      return jsonList.map((json) => RegistroDiario.fromJson(json)).toList();
    }

    throw Exception(
      'Falha ao carregar os registros diários do usuário $nomeUsuario',
    );
  }

  Future<List<RelatorioSemanal>> carregarRelatoriosSemanais(
    String nomeUsuario,
  ) async {
    final response = await http.get(
      Uri.parse('http://localhost:8080/relatoriosSemanais/$nomeUsuario'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);

      return jsonList.map((json) => RelatorioSemanal.fromJson(json)).toList();
    }

    throw Exception(
      'Falha ao carregar os relatórios semanais do usuário $nomeUsuario',
    );
  }

  Future salvarRegistroDiario(
    RegistroDiario registro,
    String nomeUsuario,
  ) async {
    final response = await http.post(
      Uri.parse(
        'http://localhost:8080/registrosDiarios/cadastrarRegistroDiario/$nomeUsuario',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(registro.toJson()),
    );

    if (response.statusCode == 200) {
      developer.log(
        'Registro diário salvo com sucesso para o usuário $nomeUsuario',
      );
    } else {
      throw Exception(
        'Falha ao salvar registro diário do usuário $nomeUsuario',
      );
    }
  }

  Future<List<Profissional>> carregarProfissionais(
    String tipoProfissional,
  ) async {
    final response = await http.get(
      Uri.parse(
        'http://localhost:8080/profissionais/tipoProfissional/$tipoProfissional',
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);

      return jsonList.map((json) => Profissional.fromJson(json)).toList();
    }

    throw Exception(
      'Falha ao carregar os profissionais do tipo $tipoProfissional',
    );
  }

  Future<List<RecomendacaoHorario>> carregarHorariosDisponiveis(
    String dataInformada,
    String nomeUsuario,
  ) async {
    final response = await http.get(
      Uri.parse(
        'http://localhost:8080/agendamentos/recomendarHorarios/$dataInformada/profissional/$nomeUsuario',
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);

      return jsonList
          .map((json) => RecomendacaoHorario.fromJson(json))
          .toList();
    }

    throw Exception(
      'Falha ao carregar os horários disponíveis para a data $dataInformada e profissional $nomeUsuario',
    );
  }

  Future salvarAgendamento(Consulta? consulta) async {
    final response = await http.post(
      Uri.parse('http://localhost:8080/agendamentos'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(consulta?.toJson()),
    );

    if (response.statusCode == 200) {
      developer.log('Agendamento salvo com sucesso');
    } else {
      throw Exception('Falha ao salvar agendamento');
    }
  }

  Future<Paciente> carregarPaciente(String nomeUsuario) async {
    final response = await http.get(
      Uri.parse('http://localhost:8080/pacientes/$nomeUsuario'),
    );

    if (response.statusCode == 200) {
      developer.log('Paciente carregado com sucesso');
      return Paciente.fromJson(jsonDecode(response.body));
    }
    throw Exception('Falha ao carregar paciente');
  }

  Future<void> salvarToken(String email, String? token) async {
    final response = await http.post(
      Uri.parse('http://localhost:8080/usuarios/token/$email?token=$token'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      developer.log('Token salvo com sucesso');
    } else {
      throw Exception('Falha ao salvar token');
    }
  }
}