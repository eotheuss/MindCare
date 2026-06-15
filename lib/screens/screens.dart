import 'dart:math' as developer;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mindcare/main.dart';
import 'package:mindcare/models/models.dart';
import 'package:mindcare/services/services.dart';
import 'package:mindcare/widgets/map.dart';
import 'package:mindcare/widgets/widgets.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({required this.onStart, super.key});

  final VoidCallback onStart;

  void goToMap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const Spacer(),
              const Text(
                'Bem Vindo!',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              const MindCareLogo(size: 34),
              const SizedBox(height: 52),
              PrimaryButton(
                text: 'Começar',
                icon: Icons.arrow_forward,
                onPressed: onStart,
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                text: 'Localização da Clínica',
                icon: Icons.arrow_forward,
                onPressed: () => goToMap(context),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class RoleScreen extends StatelessWidget {
  const RoleScreen({required this.onRoleSelected, super.key});

  final ValueChanged<UserRole> onRoleSelected;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const MindCareLogo(size: 34),
              const SizedBox(height: 96),
              const Text(
                'Cuidando da sua saúde com carinho',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Entrar',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      text: 'Paciente',
                      icon: Icons.favorite_border,
                      onPressed: () => onRoleSelected(UserRole.patient),
                    ),
                    const SizedBox(height: 10),
                    PrimaryButton(
                      text: 'Profissional',
                      icon: Icons.medical_services_outlined,
                      color: AppColors.blue,
                      onPressed: () => onRoleSelected(UserRole.professional),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    required this.role,
    required this.onBack,
    required this.onLogin,
    super.key,
  });

  final UserRole role;
  final VoidCallback onBack;
  final VoidCallback onLogin;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool hidePassword = true;

  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 72, 28, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back),
                color: AppColors.navy,
              ),
              const SizedBox(height: 8),
              const Center(child: MindCareLogo(size: 34)),
              const SizedBox(height: 84),
              const FieldLabel('Email'),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                decoration: appInputDecoration('name@example.com'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              const FieldLabel('Senha'),
              const SizedBox(height: 8),
              TextField(
                obscureText: hidePassword,
                decoration: appInputDecoration('************').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      hidePassword ? Icons.visibility : Icons.visibility_off,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() => hidePassword = !hidePassword);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 26),
              PrimaryButton(
                text: 'Entrar',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PatientHomeScreen(
                        email: emailController.text,
                        onDiary: () {},
                        onSchedule: () {},
                        onLogout: () {},
                        onNav: (int value) {},
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              const Center(child: Text('ou', style: TextStyle(fontSize: 12))),
              const SizedBox(height: 8),
              Center(
                child: SizedBox(
                  width: 170,
                  child: PrimaryButton(
                    text: 'Google',
                    color: AppColors.blue,
                    onPressed: widget.onLogin,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Center(
                child: Text(
                  'Esqueceu a senha?',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    fontSize: 12,
                    color: AppColors.navy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 36),
              const Center(
                child: Text(
                  'Criar conta',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    fontSize: 11,
                    color: AppColors.navy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PatientHomeScreen extends StatefulWidget {
  PatientHomeScreen({
    required this.onDiary,
    required this.onSchedule,
    required this.onLogout,
    required this.onNav,
    required this.email,
    super.key,
  });

  final String email;

  final VoidCallback onDiary;
  final VoidCallback onSchedule;
  final VoidCallback onLogout;
  final ValueChanged<int> onNav;

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  final ApiService service = ApiService();

  String converteParaEmoji(String nivelHumor) {
    switch (nivelHumor) {
      case 'OTIMO':
        return '😄';
      case 'BOM':
        return '🙂';
      case 'NEUTRO':
        return '😐';
      case 'MAL':
        return '☹️';
      case 'PESSIMO':
        return '😭';
      default:
        return '-';
    }
  }

  Future<void> loginUser() async {
    String? token = await FirebaseMessaging.instance.getToken();

    await service.salvarToken(widget.email, token);
  }

  @override
  void initState() {
    super.initState();
    loginUser();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      bottomNavigationBar: MindBottomNav(
        selectedIndex: 0,
        onTap: widget.onNav,
        email: widget.email,
      ),
      child: Column(
        children: [
          AppHeader(
            color: AppColors.patientHeader,
            avatarEmoji: '👩',
            onLogout: widget.onLogout,
            child: Text(
              'Olá ${widget.email},\ncomo você está se sentindo hoje?',
              style: TextStyle(
                color: AppColors.navy,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
              children: [
                PrimaryButton(
                  text: '+ Escrever no Diário',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PatientDiaryScreen(
                          onBack: () {
                            Navigator.pop(context);
                          },
                          onLogout: widget.onLogout,
                          onNav: widget.onNav,
                          email: widget.email,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  text: 'Agendar Consulta',
                  color: AppColors.purple,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AppointmentScreen(
                          onBack: () {
                            Navigator.pop(context);
                          },
                          onLogout: widget.onLogout,
                          onConfirm: () {},
                          onNav: widget.onNav,
                          email: widget.email,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                const SectionTitle(
                  icon: Icons.calendar_month,
                  text: 'Recentes',
                ),
                const SizedBox(height: 8),
                FutureBuilder<List<RegistroDiario>>(
                  future: service.carregarRegistrosDiarios(widget.email),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    final diaries = snapshot.data ?? [];

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: diaries.length,
                      itemBuilder: (context, index) {
                        final diary = diaries[index];
                        return DiaryPreview(
                          emoji: converteParaEmoji(diary.nivelHumor),
                          title: diary.dataHoraCriacao.substring(0, 10),
                          subtitle: 'Diário Completo',
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PatientDiaryScreenState extends State<PatientDiaryScreen> {
  final ApiService service = ApiService();

  final positivosController = TextEditingController();
  final desafiosController = TextEditingController();

  @override
  void dispose() {
    positivosController.dispose();
    desafiosController.dispose();
    super.dispose();
  }

  String nivelHumor = '';

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      bottomNavigationBar: MindBottomNav(
        selectedIndex: 1,
        onTap: widget.onNav,
        email: widget.email,
      ),
      child: Column(
        children: [
          AppHeader(
            title: 'Meu Diário',
            color: AppColors.patientHeader,
            avatarEmoji: '👩',
            onBack: widget.onBack,
            onLogout: widget.onLogout,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Como você se sentiu hoje?',
                        style: TextStyle(
                          color: AppColors.navy,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MoodItem(
                            emoji: '😁',
                            label: 'OTIMO',
                            onTap: () {
                              setState(() {
                                nivelHumor = 'OTIMO';
                              });
                            },
                          ),
                          MoodItem(
                            emoji: '🙂',
                            label: 'BOM',
                            onTap: () {
                              setState(() {
                                nivelHumor = 'BOM';
                              });
                            },
                          ),
                          MoodItem(
                            emoji: '😐',
                            label: 'NEUTRO',
                            onTap: () {
                              setState(() {
                                nivelHumor = 'NEUTRO';
                              });
                            },
                          ),
                          MoodItem(
                            emoji: '🙁',
                            label: 'MAL',
                            onTap: () {
                              setState(() {
                                nivelHumor = 'MAL';
                              });
                            },
                          ),
                          MoodItem(
                            emoji: '😭',
                            label: 'PESSIMO',
                            onTap: () {
                              setState(() {
                                nivelHumor = 'PESSIMO';
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                JournalBox(
                  icon: Icons.add_circle_outline,
                  title: 'Pontos Positivos do Dia',
                  titleColor: AppColors.green,
                  hint:
                      'O que aconteceu de bom hoje? Quais momentos te deixaram feliz?',
                  controller: positivosController,
                ),
                const SizedBox(height: 18),
                JournalBox(
                  icon: Icons.sentiment_dissatisfied,
                  title: 'Dificuldades e Desafios',
                  titleColor: AppColors.red,
                  hint: 'O que te incomodou hoje? Houve algum momento difícil?',
                  controller: desafiosController,
                ),
                const SizedBox(height: 18),
                PrimaryButton(
                  text: 'Salvar Diário',
                  icon: Icons.save_outlined,
                  onPressed: () async {
                    final registroDiario = RegistroDiario(
                      paciente: null,
                      nivelHumor: nivelHumor,
                      pontosPositivos: positivosController.text,
                      dificuldadesDesafios: desafiosController.text,
                      dataHoraCriacao: DateTime.now().toIso8601String(),
                    );
                    await service.salvarRegistroDiario(
                      registroDiario,
                      widget.email,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PatientDiaryScreen extends StatefulWidget {
  const PatientDiaryScreen({
    required this.onBack,
    required this.onLogout,
    required this.onNav,
    required this.email,
    super.key,
  });

  final VoidCallback onBack;
  final VoidCallback onLogout;
  final ValueChanged<int> onNav;
  final String email;

  @override
  State<PatientDiaryScreen> createState() => _PatientDiaryScreenState();
}

class PatientReportScreen extends StatefulWidget {
  PatientReportScreen({
    required this.onBack,
    required this.onLogout,
    required this.onNav,
    required this.email,
    super.key,
  });

  final VoidCallback onBack;
  final VoidCallback onLogout;
  final ValueChanged<int> onNav;
  final String email;

  @override
  State<PatientReportScreen> createState() => _PatientReportScreenState();
}

class _PatientReportScreenState extends State<PatientReportScreen> {
  final ApiService service = ApiService();

  late Future<List<RelatorioSemanal>> relatoriosFuture;

  @override
  void initState() {
    super.initState();

    relatoriosFuture = service.carregarRelatoriosSemanais(widget.email);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      bottomNavigationBar: MindBottomNav(
        selectedIndex: 2,
        onTap: widget.onNav,
        email: widget.email,
      ),
      child: Column(
        children: [
          AppHeader(
            title: 'Relatórios Semanais',
            color: AppColors.patientHeader,
            avatarEmoji: '👩',
            onBack: widget.onBack,
            onLogout: widget.onLogout,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<RelatorioSemanal>>(
              future: relatoriosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }

                final relatorios = snapshot.data ?? [];

                if (relatorios.isEmpty) {
                  return const Center(
                    child: Text('Nenhum relatório encontrado'),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(18),
                  itemCount: relatorios.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 18),
                  itemBuilder: (context, index) {
                    final relatorio = relatorios[index];
                    final faixaDeDatas = relatorio.faixaDeDatas.replaceFirst(
                      '^',
                      ' :: ',
                    );

                    return PatientReportCard(
                      week: faixaDeDatas,
                      summary: relatorio.resumo,
                      positives: relatorio.totalPositivos.toString(),
                      challenges: relatorio.totalNegativos.toString(),
                      observacoes: relatorio.observacoes,
                      recomendacoes: relatorio.recomendacoes,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({
    required this.onBack,
    required this.onLogout,
    required this.onConfirm,
    required this.onNav,
    required this.email,
    super.key,
  });

  final VoidCallback onBack;
  final VoidCallback onLogout;
  final VoidCallback onConfirm;
  final ValueChanged<int> onNav;
  final String email;

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  String type = 'Psiquiatra';
  Profissional? profissional = null;

  ApiService service = ApiService();

  List<Profissional> professionals = [];

  Future<void> carregarProfissionais() async {
    final result = await service.carregarProfissionais(type);

    setState(() {
      professionals = result;
    });
  }

  @override
  void initState() {
    super.initState();
    carregarProfissionais();
  }

  DateTime? selectedDate;

  Future<void> selecionarData() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      bottomNavigationBar: MindBottomNav(
        selectedIndex: 0,
        onTap: widget.onNav,
        email: widget.email,
      ),
      child: Column(
        children: [
          AppHeader(
            title: 'Agendar Consulta',
            color: AppColors.patientHeader,
            avatarEmoji: '👩',
            onBack: widget.onBack,
            onLogout: widget.onLogout,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                const FieldLabel('Selecione a Data'),
                const SizedBox(height: 8),
                AppCard(
                  child: Column(
                    children: [
                      SelectOption(
                        text: 'Psicólogo',
                        selected: type == 'PSICOLOGO',
                        onTap: () async {
                          setState(() {
                            type = 'PSICOLOGO';
                            profissional = null;
                          });

                          await carregarProfissionais();
                        },
                      ),
                      const SizedBox(height: 10),
                      SelectOption(
                        text: 'Psiquiatra',
                        selected: type == 'PSIQUIATRA',
                        onTap: () async {
                          setState(() {
                            type = 'PSIQUIATRA';
                            profissional = null;
                          });

                          await carregarProfissionais();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                const FieldLabel('Selecione o profissional'),
                const SizedBox(height: 8),
                AppCard(
                  child: DropdownButtonFormField<Profissional>(
                    initialValue: null,
                    decoration: appInputDecoration('Profissional'),
                    items: professionals
                        .map(
                          (p) => DropdownMenuItem(
                            value: p,
                            child: Text(p.nomeCompleto),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => profissional = value);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 22),
                const FieldLabel('Selecione a Data'),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: selecionarData,
                  child: AppCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month),
                          const SizedBox(width: 12),
                          Text(
                            selectedDate == null
                                ? 'Toque para selecionar uma data'
                                : '${selectedDate!.day.toString().padLeft(2, '0')}/'
                                      '${selectedDate!.month.toString().padLeft(2, '0')}/'
                                      '${selectedDate!.year}',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                PrimaryButton(
                  text: 'Continuar',
                  onPressed: () {
                    if (selectedDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Selecione uma data')),
                      );
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AppointmentConfirmScreen(
                          onBack: () => Navigator.pop(context),
                          onLogout: () {},
                          onNav: (index) => {},
                          email: widget.email,
                          selectedDate: selectedDate!,
                          professional: profissional,
                          type: type,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AppointmentConfirmScreen extends StatefulWidget {
  AppointmentConfirmScreen({
    required this.onBack,
    required this.onLogout,
    required this.onNav,
    required this.email,
    required this.selectedDate,
    required this.professional,
    required this.type,
    super.key,
  });

  final VoidCallback onBack;
  final VoidCallback onLogout;
  final ValueChanged<int> onNav;
  final String email;
  final DateTime selectedDate;
  final Profissional? professional;
  final String type;

  @override
  State<AppointmentConfirmScreen> createState() =>
      _AppointmentConfirmScreenState();
}

class _AppointmentConfirmScreenState extends State<AppointmentConfirmScreen> {
  final ApiService service = ApiService();

  late Future<List<RecomendacaoHorario>> horariosFuture;

  Paciente? paciente;
  Consulta? consulta;

  @override
  void initState() {
    super.initState();

    horariosFuture = service.carregarHorariosDisponiveis(
      widget.selectedDate.toIso8601String().split('T')[0],
      widget.professional?.nomeUsuario ?? '',
    );

    carregarPacienteEConsulta();

    FirebaseMessaging.onMessage.listen((message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${message.notification?.title}: ${message.notification?.body}',
          ),
        ),
      );
    });
  }

  String? horarioSelecionado;

  Future<void> carregarPacienteEConsulta() async {
    final pacienteCarregado = await service.carregarPaciente(widget.email);

    setState(() {
      paciente = pacienteCarregado;

      consulta = Consulta(
        profissional: widget.professional,
        paciente: pacienteCarregado,
        atendida: false,
        cancelada: false,
        dataHoraConsulta: horarioSelecionado,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      bottomNavigationBar: MindBottomNav(
        selectedIndex: 0,
        onTap: widget.onNav,
        email: widget.email,
      ),
      child: Column(
        children: [
          AppHeader(
            title: 'Agendar Consulta',
            color: AppColors.patientHeader,
            avatarEmoji: '👩',
            onBack: widget.onBack,
            onLogout: widget.onLogout,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                Text(
                  '${widget.selectedDate.day.toString().padLeft(2, '0')}/'
                  '${widget.selectedDate.month.toString().padLeft(2, '0')}/'
                  '${widget.selectedDate.year}',
                ),
                const SizedBox(height: 18),
                const FieldLabel('Horários disponíveis'),
                const SizedBox(height: 8),
                AppCard(
                  child: FutureBuilder<List<RecomendacaoHorario>>(
                    future: horariosFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Text(
                          'Erro ao carregar horários: ${snapshot.error}',
                        );
                      }

                      final horarios = snapshot.data ?? [];

                      if (horarios.isEmpty) {
                        return const Text('Nenhum horário disponível.');
                      }

                      return Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: horarios.map((horario) {
                          return TimeChip(
                            time: horario.dataHoraConsulta.substring(11, 16),
                            selected:
                                horarioSelecionado == horario.dataHoraConsulta,
                            onTap: () {
                              setState(() {
                                horarioSelecionado = horario.dataHoraConsulta;
                                consulta?.dataHoraConsulta =
                                    horario.dataHoraConsulta.isEmpty
                                    ? null
                                    : '${horario.dataHoraConsulta.split('T')[0]}T${horario.dataHoraConsulta.substring(11, 16)}';
                              });
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: 'Confirmar Agendamento',
                  onPressed: () {
                    service.salvarAgendamento(consulta);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Consulta agendada para $horarioSelecionado.',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
