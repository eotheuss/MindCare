import 'dart:developer' as developer;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  await FirebaseMessaging.instance.setAutoInitEnabled(true);

  await messaging.requestPermission(alert: true, badge: true, sound: true);

  final notificationService = NotificationService();

  await notificationService.init();

  runApp(const MindCareApp());
}

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

Future<void> registerToken(String email) async {
  String? token = await FirebaseMessaging.instance.getToken();

  ApiService apiService = ApiService();

  await apiService.salvarToken(email, token);
}

class NotificationService {
  final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: android);

    await plugin.initialize(settings: settings);

    setupFCM();
  }

  void setupFCM() {
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;

      if (notification != null) {
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('${notification.title}: ${notification.body}')),
        );
      }
    });
  }
}

enum AppScreen {
  welcome,
  role,
  login,
  patientHome,
  patientDiary,
  patientReport,
  appointment,
  appointmentConfirm,
  professionalHome,
  professionalDiary,
  professionalReport,
}

enum UserRole { patient, professional }

class MindCareApp extends StatelessWidget {
  const MindCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      title: 'MindCare Diary',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.pink,
          brightness: Brightness.light,
        ),
      ),
      home: const MindCareFlow(),
    );
  }
}

class MindCareFlow extends StatefulWidget {
  const MindCareFlow({super.key});

  @override
  State<MindCareFlow> createState() => _MindCareFlowState();
}

class _MindCareFlowState extends State<MindCareFlow> {
  AppScreen screen = AppScreen.welcome;
  UserRole role = UserRole.patient;
  int patientTab = 0;
  int professionalTab = 0;

  void go(AppScreen next) {
    setState(() => screen = next);
  }

  void chooseRole(UserRole selectedRole) {
    setState(() {
      role = selectedRole;
      screen = AppScreen.login;
    });
  }

  void enterApp() {
    setState(() {
      if (role == UserRole.patient) {
        patientTab = 0;
        screen = AppScreen.patientHome;
      } else {
        professionalTab = 0;
        screen = AppScreen.professionalHome;
      }
    });
  }

  void patientNav(int index) {
    setState(() {
      patientTab = index;
      screen = switch (index) {
        0 => AppScreen.patientHome,
        1 => AppScreen.patientDiary,
        _ => AppScreen.patientReport,
      };
    });
  }

  void professionalNav(int index) {
    setState(() {
      professionalTab = index;
      screen = switch (index) {
        0 => AppScreen.professionalHome,
        1 => AppScreen.professionalDiary,
        _ => AppScreen.professionalReport,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final page = switch (screen) {
      AppScreen.welcome => WelcomeScreen(onStart: () => go(AppScreen.role)),
      AppScreen.role => RoleScreen(onRoleSelected: chooseRole),
      AppScreen.login => LoginScreen(
        role: role,
        onBack: () => go(AppScreen.role),
        onLogin: enterApp,
      ),
      AppScreen.patientHome => PatientHomeScreen(
        email: 'Maria Silva',
        onDiary: () => patientNav(1),
        onSchedule: () => go(AppScreen.appointment),
        onLogout: () => go(AppScreen.role),
        onNav: patientNav,
      ),
      AppScreen.patientDiary => PatientDiaryScreen(
        email: 'Maria Silva',
        onBack: () => patientNav(0),
        onLogout: () => go(AppScreen.role),
        onNav: patientNav,
      ),
      AppScreen.patientReport => PatientReportScreen(
        onBack: () => patientNav(0),
        onLogout: () => go(AppScreen.role),
        onNav: patientNav,
        email: 'Maria Silva',
      ),
      AppScreen.appointment => AppointmentScreen(
        onBack: () => patientNav(0),
        onLogout: () => go(AppScreen.role),
        onConfirm: () => go(AppScreen.appointmentConfirm),
        onNav: patientNav,
        email: 'Maria Silva',
      ),
      AppScreen.appointmentConfirm => AppointmentConfirmScreen(
        onBack: () => go(AppScreen.appointment),
        onLogout: () => go(AppScreen.role),
        onNav: patientNav,
        email: 'Maria Silva',
        selectedDate: DateTime.now(),
        professional: null,
        type: '',
      ),
      AppScreen.professionalHome => ProfessionalHomeScreen(
        onLogout: () => go(AppScreen.role),
        onPatientSelected: () => professionalNav(1),
        onNav: professionalNav,
      ),
      AppScreen.professionalDiary => ProfessionalDiaryScreen(
        onBack: () => professionalNav(0),
        onLogout: () => go(AppScreen.role),
        onReports: () => professionalNav(2),
      ),
      AppScreen.professionalReport => ProfessionalReportScreen(
        onBack: () => professionalNav(0),
        onLogout: () => go(AppScreen.role),
        onDiaries: () => professionalNav(1),
      ),
    };

    return page;
  }
}

class AppColors {
  static const background = Color(0xFFDFF6FF);
  static const patientHeader = Color(0xFF63BDF4);
  static const professionalHeader = Color(0xFFBE78E5);
  static const pink = Color(0xFFE93D9B);
  static const purple = Color(0xFF8257E5);
  static const blue = Color(0xFF168DDA);
  static const navy = Color(0xFF070B3F);
  static const green = Color(0xFF20C663);
  static const red = Color(0xFFFF5B63);
  static const card = Color(0xFFFFFFFF);
  static const muted = Color(0xFF667085);
}

class AppScaffold extends StatelessWidget {
  const AppScaffold({required this.child, this.bottomNavigationBar, super.key});

  final Widget child;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: child,
        ),
      ),
      bottomNavigationBar: bottomNavigationBar == null
          ? null
          : Center(
              heightFactor: 1,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: bottomNavigationBar,
              ),
            ),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({required this.onStart, super.key});

  final VoidCallback onStart;

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
                        developer.log(diary.nivelHumor);
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

class ProfessionalHomeScreen extends StatelessWidget {
  const ProfessionalHomeScreen({
    required this.onLogout,
    required this.onPatientSelected,
    required this.onNav,
    super.key,
  });

  final VoidCallback onLogout;
  final VoidCallback onPatientSelected;
  final ValueChanged<int> onNav;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Column(
        children: [
          AppHeader(
            color: AppColors.professionalHeader,
            avatarEmoji: '👨‍⚕️',
            onLogout: onLogout,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Painel Profissional',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Text(
                  'Acompanhe seus pacientes',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar paciente...',
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.35),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    isDense: true,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                Row(
                  children: const [
                    Expanded(
                      child: StatCard(
                        title: 'Total',
                        value: '5',
                        subtitle: 'Pacientes ativos',
                        color: Color(0xFF9A20E8),
                      ),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: StatCard(
                        title: 'Atenção',
                        value: '2',
                        subtitle: 'Precisam de atenção',
                        color: AppColors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Meus Pacientes',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                PatientTile(
                  emoji: '👨',
                  name: 'João Santos',
                  detail: 'Última entrada: Hoje\n7/7 esta semana',
                  status: 'Melhorando',
                  statusColor: AppColors.green,
                  onTap: onPatientSelected,
                ),
                PatientTile(
                  emoji: '👩',
                  name: 'Maria Silva',
                  detail: 'Última entrada: Ontem\n6/7 esta semana',
                  status: 'Estável',
                  statusColor: AppColors.blue,
                  onTap: onPatientSelected,
                ),
                PatientTile(
                  emoji: '👨',
                  name: 'Pedro Oliveira',
                  detail: 'Última entrada: Há 3 dias\n3/7 esta semana',
                  status: 'Atenção',
                  statusColor: AppColors.red,
                  onTap: onPatientSelected,
                ),
                PatientTile(
                  emoji: '👩',
                  name: 'Ana Costa',
                  detail: 'Última entrada: Hoje\n7/7 esta semana',
                  status: 'Estável',
                  statusColor: AppColors.blue,
                  onTap: onPatientSelected,
                ),
                PatientTile(
                  emoji: '👩',
                  name: 'Carla Souza',
                  detail: 'Última entrada: Há 5 dias\n2/7 esta semana',
                  status: 'Atenção',
                  statusColor: AppColors.red,
                  onTap: onPatientSelected,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfessionalDiaryScreen extends StatelessWidget {
  const ProfessionalDiaryScreen({
    required this.onBack,
    required this.onLogout,
    required this.onReports,
    super.key,
  });

  final VoidCallback onBack;
  final VoidCallback onLogout;
  final VoidCallback onReports;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Column(
        children: [
          ProfessionalPatientHeader(
            selectedReports: false,
            onBack: onBack,
            onLogout: onLogout,
            onDiaries: () {},
            onReports: onReports,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: const [
                Text(
                  'Entradas do Diário',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 12),
                ProfessionalDiaryCard(
                  emoji: '🙂',
                  day: '8 de abril',
                  mood: 'Bom',
                  positives:
                      'Tive uma reunião produtiva no trabalho e consegui resolver um problema complexo. Fui ao parque caminhar no fim do dia.',
                  challenges:
                      'Ansiedade leve pela manhã antes da reunião importante.',
                ),
                ProfessionalDiaryCard(
                  emoji: '🙂',
                  day: '7 de abril',
                  mood: 'Ótimo',
                  positives:
                      'Dia muito bom! Passei o tempo com a família, fizemos um almoço juntos. Me senti muito acolhida.',
                  challenges: 'Nada significativo.',
                ),
                ProfessionalDiaryCard(
                  emoji: '😐',
                  day: '6 de abril',
                  mood: 'Neutro',
                  positives:
                      'Concluí algumas tarefas pendentes. Li um livro que estava querendo há tempos.',
                  challenges:
                      'Me senti um pouco sozinha no período da tarde. Pensamentos sobre o futuro me deixaram preocupada.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfessionalReportScreen extends StatelessWidget {
  const ProfessionalReportScreen({
    required this.onBack,
    required this.onLogout,
    required this.onDiaries,
    super.key,
  });

  final VoidCallback onBack;
  final VoidCallback onLogout;
  final VoidCallback onDiaries;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Column(
        children: [
          ProfessionalPatientHeader(
            selectedReports: true,
            onBack: onBack,
            onLogout: onLogout,
            onDiaries: onDiaries,
            onReports: () {},
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                const Text(
                  'Relatório Semanal (Gerado por IA)',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Semana: 03/04 - 09/04/2026',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3EFFD),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Pontos Positivos\n\nMaria apresentou boa consistência nos registros (7/7 dias). Humor predominante: positivo. Identificados padrões de ansiedade leve relacionada a compromissos profissionais, mas com boa capacidade de regulação emocional.\n\n• Principais gatilhos: reuniões importantes, preocupações com o futuro.\n• Principais recursos: apoio familiar, atividades ao ar livre, leitura.\n• Sugestão: explorar técnicas de mindfulness antes de eventos estressantes.',
                          style: TextStyle(
                            color: Color(0xFF2453B8),
                            fontSize: 12,
                            height: 1.35,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Estatísticas',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: const [
                          Expanded(
                            child: MetricBox(
                              title: 'Dias positivos',
                              value: '5',
                              color: AppColors.green,
                              background: Color(0xFFDFF8E7),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: MetricBox(
                              title: 'Dias desafiadores',
                              value: '2',
                              color: AppColors.red,
                              background: Color(0xFFFFF0DF),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Observação e Recomendação',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: appInputDecoration(
                                'Escreva aqui suas orientações...',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          FloatingActionButton.small(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Orientação enviada.'),
                                ),
                              );
                            },
                            backgroundColor: const Color(0xFFB629E8),
                            child: const Icon(Icons.arrow_forward),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfessionalPatientHeader extends StatelessWidget {
  const ProfessionalPatientHeader({
    required this.selectedReports,
    required this.onBack,
    required this.onLogout,
    required this.onDiaries,
    required this.onReports,
    super.key,
  });

  final bool selectedReports;
  final VoidCallback onBack;
  final VoidCallback onLogout;
  final VoidCallback onDiaries;
  final VoidCallback onReports;

  @override
  Widget build(BuildContext context) {
    return AppHeader(
      color: AppColors.professionalHeader,
      avatarEmoji: '👩',
      onBack: onBack,
      onLogout: onLogout,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              SizedBox(width: 78),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Maria Silva',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Histórico e relatórios',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: TabButton(
                  text: 'Diários',
                  selected: !selectedReports,
                  onTap: onDiaries,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TabButton(
                  text: 'Relatórios',
                  selected: selectedReports,
                  onTap: onReports,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AppHeader extends StatelessWidget {
  const AppHeader({
    required this.color,
    required this.avatarEmoji,
    required this.onLogout,
    this.title,
    this.child,
    this.onBack,
    super.key,
  });

  final Color color;
  final String avatarEmoji;
  final VoidCallback onLogout;
  final VoidCallback? onBack;
  final String? title;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
      ).copyWith(color: color),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              children: [
                if (onBack != null)
                  IconButton(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back),
                    color: Colors.black,
                  )
                else
                  Avatar(emoji: avatarEmoji),
                const Expanded(child: Center(child: MindCareLogo(size: 18))),
                IconButton(
                  onPressed: onLogout,
                  icon: const Icon(Icons.logout),
                  color: Colors.black,
                ),
              ],
            ),
            if (title != null) ...[
              const SizedBox(height: 12),
              Text(
                title!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
            if (child != null) ...[
              const SizedBox(height: 10),
              Align(alignment: Alignment.centerLeft, child: child!),
            ],
          ],
        ),
      ),
    );
  }
}

class MindCareLogo extends StatelessWidget {
  const MindCareLogo({required this.size, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF12B9FF), AppColors.pink],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.auto_stories,
            color: Colors.white,
            size: size * 0.7,
          ),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'MindCare',
              style: TextStyle(
                color: const Color(0xFF138AF2),
                fontSize: size * 0.52,
                fontWeight: FontWeight.w900,
                height: 0.9,
              ),
            ),
            Text(
              'Diary',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: size * 0.24,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class Avatar extends StatelessWidget {
  const Avatar({required this.emoji, this.radius = 25, super.key});

  final String emoji;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final isProfessional = emoji.contains('⚕');
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white,
      child: Icon(
        isProfessional ? Icons.medical_services_outlined : Icons.person,
        color: isProfessional ? AppColors.blue : const Color(0xFF23975F),
        size: radius * 1.15,
      ),
    );
  }
}

class MindBottomNav extends StatelessWidget {
  const MindBottomNav({
    required this.selectedIndex,
    required this.onTap,
    required this.email,
    super.key,
  });

  final int selectedIndex;
  final String email;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => PatientHomeScreen(
                  onDiary: () {},
                  onSchedule: () {},
                  onLogout: () {},
                  onNav: (index) => {},
                  email: email,
                ),
              ),
            );
            break;

          case 1:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => PatientDiaryScreen(
                  onBack: () {},
                  onLogout: () {},
                  onNav: (index) => {},
                  email: email,
                ),
              ),
            );
            break;

          case 2:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => PatientReportScreen(
                  onBack: () {},
                  onLogout: () {},
                  onNav: (index) => {},
                  email: email,
                ),
              ),
            );
            break;
        }
      },
      backgroundColor: const Color(0xFFC7DFFF),
      indicatorColor: Colors.transparent,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.calendar_month, color: AppColors.pink),
          label: 'Início',
        ),
        NavigationDestination(
          icon: Icon(Icons.article, color: AppColors.pink),
          label: 'Diário',
        ),
        NavigationDestination(
          icon: Icon(Icons.assignment, color: AppColors.pink),
          label: 'Relatório',
        ),
      ],
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.text,
    required this.onPressed,
    this.icon,
    this.color = AppColors.pink,
    super.key,
  });

  final String text;
  final IconData? icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({required this.child, this.padding, super.key});

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.navy,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

InputDecoration appInputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
      color: Colors.black.withValues(alpha: 0.45),
      fontSize: 13,
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: const BorderSide(color: Colors.black, width: 1.2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: const BorderSide(color: Colors.black, width: 1.2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: const BorderSide(color: AppColors.pink, width: 1.6),
    ),
  );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({required this.icon, required this.text, super.key});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.pink, size: 20),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.navy,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class DiaryPreview extends StatelessWidget {
  const DiaryPreview({
    required this.emoji,
    required this.title,
    required this.subtitle,
    super.key,
  });

  final String emoji;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            MoodBadge(mood: emoji, size: 52),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MoodItem extends StatelessWidget {
  const MoodItem({
    required this.emoji,
    required this.label,
    required this.onTap,
    super.key,
  });

  final String emoji;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          MoodBadge(mood: emoji, size: 44),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class MoodBadge extends StatelessWidget {
  const MoodBadge({required this.mood, required this.size, super.key});

  final String mood;
  final double size;

  IconData get icon {
    return switch (mood) {
      '😁' || '😄' => Icons.sentiment_very_satisfied,
      '🙂' => Icons.sentiment_satisfied_alt,
      '🙁' => Icons.sentiment_dissatisfied,
      '😭' => Icons.sentiment_very_dissatisfied,
      _ => Icons.sentiment_neutral,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFFFDD63),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: const Color(0xFF2C2C2C), size: size * 0.72),
    );
  }
}

class JournalBox extends StatelessWidget {
  const JournalBox({
    required this.icon,
    required this.title,
    required this.titleColor,
    required this.hint,
    required this.controller,
    super.key,
  });

  final IconData icon;
  final String title;
  final Color titleColor;
  final String hint;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: titleColor, size: 18),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: titleColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            minLines: 4,
            maxLines: 5,
            decoration: appInputDecoration(hint),
          ),
        ],
      ),
    );
  }
}

class PatientReportCard extends StatelessWidget {
  const PatientReportCard({
    required this.week,
    required this.summary,
    required this.positives,
    required this.challenges,
    required this.observacoes,
    required this.recomendacoes,
    super.key,
  });

  final String week;
  final String summary;
  final String positives;
  final String challenges;
  final String observacoes;
  final String recomendacoes;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            week,
            style: const TextStyle(
              color: Color(0xFFB114F6),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Resumo da Semana',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            summary,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: MetricBox(
                  title: 'Positivos',
                  value: positives,
                  color: AppColors.green,
                  background: const Color(0xFFE1F9EA),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MetricBox(
                  title: 'Desafios',
                  value: challenges,
                  color: AppColors.red,
                  background: const Color(0xFFFFF1E2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF2ECFF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFC7B8FF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Observações do Profissional',
                  style: TextStyle(
                    color: AppColors.purple,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(observacoes, style: TextStyle(fontSize: 12)),
                SizedBox(height: 10),
                AppCard(
                  padding: EdgeInsets.all(10),
                  child: Text(recomendacoes, style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MetricBox extends StatelessWidget {
  const MetricBox({
    required this.title,
    required this.value,
    required this.color,
    required this.background,
    super.key,
  });

  final String title;
  final String value;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.65)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class TimeChip extends StatelessWidget {
  TimeChip({
    required this.time,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String time;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.navy,
        side: const BorderSide(color: AppColors.pink),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(time),
    );
  }
}

class SelectOption extends StatelessWidget {
  const SelectOption({
    required this.text,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? const Color(0xFF396EBE) : Colors.black26,
                width: 2,
              ),
            ),
            child: selected
                ? Center(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF396EBE),
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    super.key,
  });

  final String title;
  final String value;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}

class PatientTile extends StatelessWidget {
  const PatientTile({
    required this.emoji,
    required this.name,
    required this.detail,
    required this.status,
    required this.statusColor,
    required this.onTap,
    super.key,
  });

  final String emoji;
  final String name;
  final String detail;
  final String status;
  final Color statusColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AppCard(
          child: Row(
            children: [
              Avatar(emoji: emoji, radius: 27),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      detail,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TabButton extends StatelessWidget {
  const TabButton({
    required this.text,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: selected
              ? Colors.white
              : Colors.white.withValues(alpha: 0.42),
          foregroundColor: selected ? const Color(0xFF9A20E8) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? const Color(0xFF9A20E8) : Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class ProfessionalDiaryCard extends StatelessWidget {
  const ProfessionalDiaryCard({
    required this.emoji,
    required this.day,
    required this.mood,
    required this.positives,
    required this.challenges,
    super.key,
  });

  final String emoji;
  final String day;
  final String mood;
  final String positives;
  final String challenges;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE2D8FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFC018F0), width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MoodBadge(mood: emoji, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  mood,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pontos Positivos',
                        style: TextStyle(
                          color: AppColors.green,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(positives, style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 10),
                      const Text(
                        'Desafios',
                        style: TextStyle(
                          color: AppColors.red,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(challenges, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
