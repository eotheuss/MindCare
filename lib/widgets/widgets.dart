import 'package:flutter/material.dart';
import 'package:mindcare/main.dart';
import 'package:mindcare/screens/screens.dart';

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
