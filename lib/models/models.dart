class RecomendacaoHorario {
  final int score;
  final String especialidade;
  final String dataHoraConsulta;

  RecomendacaoHorario({
    required this.score,
    required this.especialidade,
    required this.dataHoraConsulta,
  });

  factory RecomendacaoHorario.fromJson(Map<String, dynamic> json) {
    return RecomendacaoHorario(
      score: json['score'],
      especialidade: json['especialidade'],
      dataHoraConsulta: json['dataHoraConsulta'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'especialidade': especialidade,
      'dataHoraConsulta': dataHoraConsulta,
    };
  }
}

class RelatorioSemanal {
  final Paciente? paciente;
  final String faixaDeDatas;
  final String relatorioIA;
  final String observacoes;
  final String recomendacoes;
  final List<RegistroDiario> registrosDiarios;
  final String dataHoraCriacao;
  final int totalPositivos;
  final int totalNegativos;
  final String resumo;

  RelatorioSemanal({
    required this.paciente,
    required this.faixaDeDatas,
    required this.relatorioIA,
    required this.observacoes,
    required this.recomendacoes,
    required this.registrosDiarios,
    required this.dataHoraCriacao,
    required this.totalPositivos,
    required this.totalNegativos,
    required this.resumo,
  });

  factory RelatorioSemanal.fromJson(Map<String, dynamic> json) {
    return RelatorioSemanal(
      paciente: json['paciente'] != null
          ? Paciente.fromJson(json['paciente'])
          : null,
      faixaDeDatas: json['faixaDeDatas'],
      relatorioIA: json['relatorioIA'],
      observacoes: json['observacoes'] ?? '',
      recomendacoes: json['recomendacoes'] ?? '',
      registrosDiarios: (json['registrosDiarios'] as List<dynamic>)
          .map((e) => RegistroDiario.fromJson(e))
          .toList(),
      dataHoraCriacao: json['dataHoraCriacao'],
      totalPositivos: json['totalPositivos'],
      totalNegativos: json['totalNegativos'],
      resumo: json['resumo'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paciente': paciente?.toJson(),
      'faixaDeDatas': faixaDeDatas,
      'relatorioIA': relatorioIA,
      'observacoes': observacoes,
      'recomendacoes': recomendacoes,
      'registrosDiarios': registrosDiarios.map((r) => r.toJson()).toList(),
      'dataHoraCriacao': dataHoraCriacao,
      'totalPositivos': totalPositivos,
      'totalNegativos': totalNegativos,
      'resumo': resumo,
    };
  }
}

class Consulta {
  final Profissional? profissional;
  final Paciente? paciente;
  final bool atendida;
  final bool cancelada;
  String? dataHoraConsulta;

  Consulta({
    required this.profissional,
    required this.paciente,
    required this.atendida,
    required this.cancelada,
    required this.dataHoraConsulta,
  });

  factory Consulta.fromJson(Map<String, dynamic> json) {
    return Consulta(
      profissional: json['profissional'] != null
          ? Profissional.fromJson(json['profissional'])
          : null,
      paciente: json['paciente'] != null
          ? Paciente.fromJson(json['paciente'])
          : null,
      atendida: json['atendida'],
      cancelada: json['cancelada'],
      dataHoraConsulta: json['dataHoraConsulta'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profissional': profissional?.toJson(),
      'paciente': paciente?.toJson(),
      'atendida': atendida,
      'cancelada': cancelada,
      'dataHoraConsulta': dataHoraConsulta,
    };
  }
}

class Paciente {
  final String nomeUsuario;
  final String senha;
  final String nomeCompleto;
  final String dataNascimento;
  final String dataHoraAtivacao;
  final bool ativo;
  final String estadoPaciente;
  final Profissional? profissional;
  final List<Consulta> consultas;

  Paciente({
    required this.nomeUsuario,
    required this.senha,
    required this.nomeCompleto,
    required this.dataNascimento,
    required this.dataHoraAtivacao,
    required this.ativo,
    required this.estadoPaciente,
    required this.profissional,
    required this.consultas,
  });

  factory Paciente.fromJson(Map<String, dynamic> json) {
    return Paciente(
      nomeUsuario: json['nomeUsuario'],
      senha: json['senha'],
      nomeCompleto: json['nomeCompleto'],
      dataNascimento: json['dataNascimento'],
      dataHoraAtivacao: json['dataHoraAtivacao'],
      ativo: json['ativo'],
      estadoPaciente: json['estadoPaciente'],
      profissional: json['profissional'] != null
          ? Profissional.fromJson(json['profissional'])
          : null,
      consultas: (json['consultas'] as List<dynamic>)
          .map((e) => Consulta.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nomeUsuario': nomeUsuario,
      'senha': senha,
      'nomeCompleto': nomeCompleto,
      'dataNascimento': dataNascimento,
      'dataHoraAtivacao': dataHoraAtivacao,
      'ativo': ativo,
      'estadoPaciente': estadoPaciente,
      'profissional': profissional?.toJson(),
      'consultas': consultas.map((c) => c.toJson()).toList(),
    };
  }
}

class Profissional {
  Profissional({
    required this.nomeUsuario,
    required this.senha,
    required this.nomeCompleto,
    required this.dataNascimento,
    required this.dataHoraAtivacao,
    required this.ativo,
    required this.tipoProfissional,
    required this.consultas,
  });

  final String nomeUsuario;
  final String senha;
  final String nomeCompleto;
  final String dataNascimento;
  final String dataHoraAtivacao;
  final bool ativo;
  final String tipoProfissional;
  final List<Consulta> consultas;

  factory Profissional.fromJson(Map<String, dynamic> json) {
    return Profissional(
      nomeUsuario: json['nomeUsuario'],
      senha: json['senha'],
      nomeCompleto: json['nomeCompleto'],
      dataNascimento: json['dataNascimento'],
      dataHoraAtivacao: json['dataHoraAtivacao'],
      ativo: json['ativo'],
      tipoProfissional: json['tipoProfissional'],
      consultas: json['consultas'] != null
          ? (json['consultas'] as List<dynamic>)
                .map((e) => Consulta.fromJson(e))
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nomeUsuario': nomeUsuario,
      'senha': senha,
      'nomeCompleto': nomeCompleto,
      'dataNascimento': dataNascimento,
      'dataHoraAtivacao': dataHoraAtivacao,
      'ativo': ativo,
      'tipoProfissional': tipoProfissional,
      'consultas': consultas.map((c) => c.toJson()).toList(),
    };
  }
}

class RegistroDiario {
  final Paciente? paciente;
  final String nivelHumor;
  final String pontosPositivos;
  final String dificuldadesDesafios;
  final String dataHoraCriacao;

  RegistroDiario({
    required this.paciente,
    required this.nivelHumor,
    required this.pontosPositivos,
    required this.dificuldadesDesafios,
    required this.dataHoraCriacao,
  });

  factory RegistroDiario.fromJson(Map<String, dynamic> json) {
    return RegistroDiario(
      paciente: json['paciente'] != null
          ? Paciente.fromJson(json['paciente'])
          : null,
      nivelHumor: json['nivelHumor'],
      pontosPositivos: json['pontosPositivos'],
      dificuldadesDesafios: json['dificuldadesDesafios'],
      dataHoraCriacao: json['dataHoraCriacao'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paciente': paciente?.toJson(),
      'nivelHumor': nivelHumor,
      'pontosPositivos': pontosPositivos,
      'dificuldadesDesafios': dificuldadesDesafios,
      'dataHoraCriacao': dataHoraCriacao,
    };
  }
}