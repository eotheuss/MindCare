import 'package:flutter/material.dart';

void main() {
  runApp(const MindCareApp());
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
        onDiary: () => patientNav(1),
        onSchedule: () => go(AppScreen.appointment),
        onLogout: () => go(AppScreen.role),
        onNav: patientNav,
      ),
      AppScreen.patientDiary => PatientDiaryScreen(
        onBack: () => patientNav(0),
        onLogout: () => go(AppScreen.role),
        onNav: patientNav,
      ),
      AppScreen.patientReport => PatientReportScreen(
        onBack: () => patientNav(0),
        onLogout: () => go(AppScreen.role),
        onNav: patientNav,
      ),
      AppScreen.appointment => AppointmentScreen(
        onBack: () => patientNav(0),
        onLogout: () => go(AppScreen.role),
        onConfirm: () => go(AppScreen.appointmentConfirm),
        onNav: patientNav,
      ),
      AppScreen.appointmentConfirm => AppointmentConfirmScreen(
        onBack: () => go(AppScreen.appointment),
        onLogout: () => go(AppScreen.role),
        onNav: patientNav,
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
              PrimaryButton(text: 'Entrar', onPressed: widget.onLogin),
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

class PatientHomeScreen extends StatelessWidget {
  const PatientHomeScreen({
    required this.onDiary,
    required this.onSchedule,
    required this.onLogout,
    required this.onNav,
    super.key,
  });

  final VoidCallback onDiary;
  final VoidCallback onSchedule;
  final VoidCallback onLogout;
  final ValueChanged<int> onNav;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      bottomNavigationBar: MindBottomNav(selectedIndex: 0, onTap: onNav),
      child: Column(
        children: [
          AppHeader(
            color: AppColors.patientHeader,
            avatarEmoji: '👩',
            onLogout: onLogout,
            child: const Text(
              'Olá Maria,\ncomo você está se sentindo hoje?',
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
                PrimaryButton(text: '+ Escrever no Diário', onPressed: onDiary),
                const SizedBox(height: 12),
                PrimaryButton(
                  text: 'Agendar Consulta',
                  color: AppColors.purple,
                  onPressed: onSchedule,
                ),
                const SizedBox(height: 16),
                const SectionTitle(
                  icon: Icons.calendar_month,
                  text: 'Recentes',
                ),
                const SizedBox(height: 8),
                const DiaryPreview(
                  emoji: '🙂',
                  title: 'Quarta-feira, 8 de Abril',
                  subtitle: 'Diário Completo',
                ),
                const DiaryPreview(
                  emoji: '😄',
                  title: 'Terça-feira, 7 de Abril',
                  subtitle: 'Diário Completo',
                ),
                const DiaryPreview(
                  emoji: '😐',
                  title: 'Segunda-feira, 6 de Abril',
                  subtitle: 'Diário Completo',
                ),
                const DiaryPreview(
                  emoji: '😭',
                  title: 'Sábado, 4 de Abril',
                  subtitle: 'Diário Completo',
                ),
                const DiaryPreview(
                  emoji: '🙁',
                  title: 'Sexta-feira, 3 de Abril',
                  subtitle: 'Diário Completo',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PatientDiaryScreen extends StatelessWidget {
  const PatientDiaryScreen({
    required this.onBack,
    required this.onLogout,
    required this.onNav,
    super.key,
  });

  final VoidCallback onBack;
  final VoidCallback onLogout;
  final ValueChanged<int> onNav;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      bottomNavigationBar: MindBottomNav(selectedIndex: 1, onTap: onNav),
      child: Column(
        children: [
          AppHeader(
            title: 'Meu Diário',
            color: AppColors.patientHeader,
            avatarEmoji: '👩',
            onBack: onBack,
            onLogout: onLogout,
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
                        children: const [
                          MoodItem(emoji: '😁', label: 'Ótimo'),
                          MoodItem(emoji: '🙂', label: 'Bem'),
                          MoodItem(emoji: '😐', label: 'Neutro'),
                          MoodItem(emoji: '🙁', label: 'Mal'),
                          MoodItem(emoji: '😭', label: 'Péssimo'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const JournalBox(
                  icon: Icons.add_circle_outline,
                  title: 'Pontos Positivos do Dia',
                  titleColor: AppColors.green,
                  hint:
                      'O que aconteceu de bom hoje? Quais momentos te deixaram feliz?',
                ),
                const SizedBox(height: 18),
                const JournalBox(
                  icon: Icons.sentiment_dissatisfied,
                  title: 'Dificuldades e Desafios',
                  titleColor: AppColors.red,
                  hint: 'O que te incomodou hoje? Houve algum momento difícil?',
                ),
                const SizedBox(height: 22),
                PrimaryButton(
                  text: 'Salvar Diário',
                  icon: Icons.save_outlined,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Diário salvo com sucesso!'),
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

class PatientReportScreen extends StatelessWidget {
  const PatientReportScreen({
    required this.onBack,
    required this.onLogout,
    required this.onNav,
    super.key,
  });

  final VoidCallback onBack;
  final VoidCallback onLogout;
  final ValueChanged<int> onNav;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      bottomNavigationBar: MindBottomNav(selectedIndex: 2, onTap: onNav),
      child: Column(
        children: [
          AppHeader(
            title: 'Relatórios Semanais',
            color: AppColors.patientHeader,
            avatarEmoji: '👩',
            onBack: onBack,
            onLogout: onLogout,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: const [
                PatientReportCard(
                  week: '03/04/2026 - 09/04/2026',
                  summary: 'Semana com bom equilíbrio emocional',
                  positives: '4',
                  challenges: '2',
                ),
                SizedBox(height: 18),
                PatientReportCard(
                  week: '27/03/2026 - 02/04/2026',
                  summary: 'Semana com alguns desafios.',
                  positives: '3',
                  challenges: '3',
                ),
              ],
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
    super.key,
  });

  final VoidCallback onBack;
  final VoidCallback onLogout;
  final VoidCallback onConfirm;
  final ValueChanged<int> onNav;

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  String type = 'Psiquiatra';
  String professional = 'Erica Okamura';

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      bottomNavigationBar: MindBottomNav(selectedIndex: 0, onTap: widget.onNav),
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
                        selected: type == 'Psicólogo',
                        onTap: () => setState(() => type = 'Psicólogo'),
                      ),
                      const SizedBox(height: 10),
                      SelectOption(
                        text: 'Psiquiatra',
                        selected: type == 'Psiquiatra',
                        onTap: () => setState(() => type = 'Psiquiatra'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                const FieldLabel('Selecione o profissional'),
                const SizedBox(height: 8),
                AppCard(
                  child: DropdownButtonFormField<String>(
                    initialValue: professional,
                    decoration: appInputDecoration('Profissional'),
                    items: const [
                      DropdownMenuItem(
                        value: 'Erica Okamura',
                        child: Text('Erica Okamura'),
                      ),
                      DropdownMenuItem(
                        value: 'Daniel Rocha',
                        child: Text('Daniel Rocha'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => professional = value);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 22),
                const FieldLabel('Selecione a Data'),
                const SizedBox(height: 8),
                const CalendarCard(),
                const SizedBox(height: 18),
                PrimaryButton(text: 'Continuar', onPressed: widget.onConfirm),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AppointmentConfirmScreen extends StatelessWidget {
  const AppointmentConfirmScreen({
    required this.onBack,
    required this.onLogout,
    required this.onNav,
    super.key,
  });

  final VoidCallback onBack;
  final VoidCallback onLogout;
  final ValueChanged<int> onNav;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      bottomNavigationBar: MindBottomNav(selectedIndex: 0, onTap: onNav),
      child: Column(
        children: [
          AppHeader(
            title: 'Agendar Consulta',
            color: AppColors.patientHeader,
            avatarEmoji: '👩',
            onBack: onBack,
            onLogout: onLogout,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                const CalendarCard(large: true),
                const SizedBox(height: 18),
                const FieldLabel('Horários disponíveis'),
                const SizedBox(height: 8),
                AppCard(
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: const [
                      TimeChip('08:00'),
                      TimeChip('09:00'),
                      TimeChip('10:00'),
                      TimeChip('11:00'),
                      TimeChip('14:00'),
                      TimeChip('16:00'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: 'Confirmar Agendamento',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Consulta agendada para 09/10 às 10:00.'),
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
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onTap,
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
  const MoodItem({required this.emoji, required this.label, super.key});

  final String emoji;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
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
    super.key,
  });

  final IconData icon;
  final String title;
  final Color titleColor;
  final String hint;

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
    super.key,
  });

  final String week;
  final String summary;
  final String positives;
  final String challenges;

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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Observações do Profissional',
                  style: TextStyle(
                    color: AppColors.purple,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Continue registrando suas emoções diariamente. Percebi uma evolução positiva em sua autoavaliação.',
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(height: 10),
                AppCard(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'Recomendação:\nMantenha as práticas de meditação e exercícios físicos.',
                    style: TextStyle(fontSize: 12),
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

class CalendarCard extends StatelessWidget {
  const CalendarCard({this.large = false, super.key});

  final bool large;

  @override
  Widget build(BuildContext context) {
    final days = [
      '28',
      '29',
      '30',
      '31',
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '10',
      '11',
      '12',
      '13',
      '14',
      '15',
      '16',
      '17',
      '18',
      '19',
      '20',
      '21',
      '22',
      '23',
      '24',
      '25',
      '26',
      '27',
      '28',
      '29',
      '30',
      '31',
    ];

    return AppCard(
      padding: EdgeInsets.all(large ? 24 : 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Outubro de 2026',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: large ? 1.25 : 1.05,
            children: const [
              CalendarText('S', bold: true),
              CalendarText('T', bold: true),
              CalendarText('Q', bold: true),
              CalendarText('Q', bold: true),
              CalendarText('S', bold: true),
              CalendarText('S', bold: true),
              CalendarText('D', bold: true),
            ],
          ),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: large ? 1.25 : 1.05,
            children: days
                .map(
                  (day) => CalendarText(
                    day,
                    faded:
                        ['28', '29', '30', '31'].contains(day) &&
                        days.indexOf(day) < 4,
                    selected: day == '9',
                  ),
                )
                .toList(),
          ),
          if (large) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Icon(Icons.chevron_left, color: Colors.black26),
                Icon(Icons.chevron_right, color: Colors.black26),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class CalendarText extends StatelessWidget {
  const CalendarText(
    this.text, {
    this.bold = false,
    this.faded = false,
    this.selected = false,
    super.key,
  });

  final String text;
  final bool bold;
  final bool faded;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: selected
            ? const BoxDecoration(
                color: Color(0xFFD7CBFF),
                shape: BoxShape.circle,
              )
            : null,
        child: Text(
          text,
          style: TextStyle(
            color: faded ? Colors.black26 : Colors.black87,
            fontWeight: bold || selected ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class TimeChip extends StatelessWidget {
  const TimeChip(this.time, {super.key});

  final String time;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {},
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
