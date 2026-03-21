import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pacifitcal/config/app_theme.dart';
import 'package:pacifitcal/models/class_template_model.dart';
import 'package:pacifitcal/services/firestore_service.dart';

class AdminTemplateFormScreen extends StatefulWidget {
  final String? templateId;
  const AdminTemplateFormScreen({super.key, this.templateId});

  @override
  State<AdminTemplateFormScreen> createState() =>
      _AdminTemplateFormScreenState();
}

class _AdminTemplateFormScreenState extends State<AdminTemplateFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  final _nameCtrl = TextEditingController();
  final _coachCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _maxCtrl = TextEditingController(text: '10');

  int _dayOfWeek = 1;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  bool _active = true;
  bool _isLoading = false;
  ClassTemplateModel? _existing;

  bool get isEditing => widget.templateId != null;

  static const _days = [
    'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'
  ];

  @override
  void initState() {
    super.initState();
    if (isEditing) _loadTemplate();
  }

  Future<void> _loadTemplate() async {
    setState(() => _isLoading = true);
    _existing = await _firestoreService.getTemplate(widget.templateId!);
    if (_existing != null) {
      final t = _existing!;
      _nameCtrl.text = t.name;
      _coachCtrl.text = t.coach ?? '';
      _descriptionCtrl.text = t.description ?? '';
      _maxCtrl.text = t.maxParticipants.toString();
      _dayOfWeek = t.dayOfWeek;
      _active = t.active;
      final sp = t.startTime.split(':');
      _startTime = TimeOfDay(
          hour: int.parse(sp[0]), minute: int.parse(sp[1]));
      final ep = t.endTime.split(':');
      _endTime = TimeOfDay(
          hour: int.parse(ep[0]), minute: int.parse(ep[1]));
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _coachCtrl.dispose();
    _descriptionCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
          // Auto-adjust end time to start+1h if end <= start
          final startMins = picked.hour * 60 + picked.minute;
          final endMins = _endTime.hour * 60 + _endTime.minute;
          if (endMins <= startMins) {
            final newEnd = startMins + 60;
            _endTime = TimeOfDay(
                hour: (newEnd ~/ 60) % 24, minute: newEnd % 60);
          }
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final template = ClassTemplateModel(
        id: widget.templateId ?? '',
        name: _nameCtrl.text.trim(),
        dayOfWeek: _dayOfWeek,
        startTime: _fmt(_startTime),
        endTime: _fmt(_endTime),
        maxParticipants: int.tryParse(_maxCtrl.text) ?? 10,
        coach: _coachCtrl.text.trim().isEmpty ? null : _coachCtrl.text.trim(),
        description: _descriptionCtrl.text.trim().isEmpty
            ? null
            : _descriptionCtrl.text.trim(),
        active: _active,
      );

      if (isEditing) {
        await _firestoreService.updateTemplate(template);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Template mis à jour !'),
              backgroundColor: AppTheme.success));
        }
      } else {
        await _firestoreService.createTemplate(template);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Séances créées pour 8 semaines !'),
              backgroundColor: AppTheme.success));
        }
      }
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppTheme.error));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && isEditing) {
      return const Scaffold(
          body: Center(
              child: CircularProgressIndicator(color: AppTheme.primary)));
    }

    return Scaffold(
      appBar: AppBar(
        title:
            Text(isEditing ? 'MODIFIER SÉANCE RÉCURRENTE' : 'NOUVELLE SÉANCE RÉCURRENTE'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Informations'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nom de la séance',
                  hintText: 'Ex: Small Group, Accès libre...',
                  prefixIcon: Icon(Icons.fitness_center_outlined),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _coachCtrl,
                decoration: const InputDecoration(
                  labelText: 'Coach (optionnel)',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _maxCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Places maximum',
                  prefixIcon: Icon(Icons.people_outline),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Requis';
                  if (int.tryParse(v) == null) return 'Nombre invalide';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _sectionTitle('Récurrence'),
              const SizedBox(height: 12),
              _buildDaySelector(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTimePicker('Heure de début', _fmt(_startTime), () => _pickTime(true))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTimePicker('Heure de fin', _fmt(_endTime), () => _pickTime(false))),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: AppTheme.primary, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isEditing
                            ? 'Durée : ${ClassTemplateModel(id: '', name: '', dayOfWeek: _dayOfWeek, startTime: _fmt(_startTime), endTime: _fmt(_endTime), maxParticipants: 10).durationMinutes} min'
                            : 'Génère les séances des 8 prochaines semaines tous les ${_days[_dayOfWeek - 1]}s',
                        style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w500,
                            fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _sectionTitle('Statut'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2A2A2A)),
                ),
                child: SwitchListTile(
                  title: const Text('Séance active',
                      style: TextStyle(color: Colors.white)),
                  subtitle: Text(
                    _active ? 'Visible par les adhérents' : 'Masquée',
                    style: const TextStyle(
                        color: AppTheme.onSurfaceMuted, fontSize: 12),
                  ),
                  value: _active,
                  activeColor: AppTheme.success,
                  onChanged: (v) => setState(() => _active = v),
                ),
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.primary))
                  : ElevatedButton.icon(
                      onPressed: _save,
                      icon: Icon(isEditing ? Icons.save : Icons.repeat),
                      label: Text(isEditing
                          ? 'Mettre à jour'
                          : 'Créer les séances récurrentes'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold, color: Colors.white));
  }

  Widget _buildDaySelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(7, (i) {
        final day = i + 1;
        final isSelected = _dayOfWeek == day;
        return GestureDetector(
          onTap: () => setState(() => _dayOfWeek = day),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primary.withOpacity(0.2)
                  : AppTheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primary
                    : const Color(0xFF2A2A2A),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Text(
              _days[i].substring(0, 3),
              style: TextStyle(
                color:
                    isSelected ? AppTheme.primary : AppTheme.onSurfaceMuted,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTimePicker(
      String label, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF3A3A3A)),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time_outlined,
                color: AppTheme.primary, size: 18),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: AppTheme.onSurfaceMuted, fontSize: 11)),
                Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
