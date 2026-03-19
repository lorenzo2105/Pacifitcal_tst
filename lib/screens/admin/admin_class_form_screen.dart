import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pacifitcal/config/app_theme.dart';
import 'package:pacifitcal/models/class_model.dart';
import 'package:pacifitcal/services/firestore_service.dart';

class AdminClassFormScreen extends StatefulWidget {
  final String? classId;
  const AdminClassFormScreen({super.key, this.classId});

  @override
  State<AdminClassFormScreen> createState() => _AdminClassFormScreenState();
}

class _AdminClassFormScreenState extends State<AdminClassFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  final _nameCtrl = TextEditingController();
  final _coachCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _maxCtrl = TextEditingController(text: '15');
  final _durationCtrl = TextEditingController(text: '60');

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  bool _isLoading = false;
  ClassModel? _existingClass;

  bool get isEditing => widget.classId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) _loadClass();
  }

  Future<void> _loadClass() async {
    setState(() => _isLoading = true);
    _existingClass = await _firestoreService.getClass(widget.classId!);
    if (_existingClass != null) {
      final cls = _existingClass!;
      _nameCtrl.text = cls.name;
      _coachCtrl.text = cls.coach ?? '';
      _descriptionCtrl.text = cls.description ?? '';
      _maxCtrl.text = cls.maxParticipants.toString();
      _durationCtrl.text = cls.duration.toString();
      _selectedDate = cls.date;
      final parts = cls.time.split(':');
      _selectedTime = TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 9,
        minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _coachCtrl.dispose();
    _descriptionCtrl.dispose();
    _maxCtrl.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }

  String get _timeString =>
      '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final classModel = ClassModel(
        id: isEditing ? widget.classId! : '',
        name: _nameCtrl.text.trim(),
        date: _selectedDate,
        time: _timeString,
        duration: int.tryParse(_durationCtrl.text) ?? 60,
        maxParticipants: int.tryParse(_maxCtrl.text) ?? 15,
        currentParticipants:
            isEditing ? (_existingClass?.currentParticipants ?? 0) : 0,
        coach: _coachCtrl.text.trim().isEmpty ? null : _coachCtrl.text.trim(),
        description: _descriptionCtrl.text.trim().isEmpty
            ? null
            : _descriptionCtrl.text.trim(),
      );

      if (isEditing) {
        await _firestoreService.updateClass(classModel);
      } else {
        await _firestoreService.createClass(classModel);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Cours mis à jour !' : 'Cours créé !'),
            backgroundColor: AppTheme.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'MODIFIER COURS' : 'NOUVEAU COURS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading && isEditing
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Informations du cours'),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Nom du cours',
                        prefixIcon: Icon(Icons.fitness_center),
                        hintText: 'ex: WOD, HIIT, Haltérophilie...',
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Nom requis' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _coachCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Coach (optionnel)',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description (optionnel)',
                        prefixIcon: Icon(Icons.notes),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _sectionTitle('Date et heure'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _datePicker(context)),
                        const SizedBox(width: 12),
                        Expanded(child: _timePicker(context)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _sectionTitle('Capacité et durée'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _durationCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Durée (min)',
                              prefixIcon: Icon(Icons.timer_outlined),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Requis';
                              if (int.tryParse(v) == null || int.parse(v) <= 0)
                                return 'Invalide';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _maxCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Max. participants',
                              prefixIcon: Icon(Icons.people_outline),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Requis';
                              if (int.tryParse(v) == null || int.parse(v) <= 0)
                                return 'Invalide';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: AppTheme.primary))
                        : ElevatedButton.icon(
                            onPressed: _save,
                            icon:
                                Icon(isEditing ? Icons.save : Icons.add),
                            label: Text(isEditing
                                ? 'Mettre à jour'
                                : 'Créer le cours'),
                          ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
    );
  }

  Widget _datePicker(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.dark(primary: AppTheme.primary),
            ),
            child: child!,
          ),
        );
        if (picked != null) setState(() => _selectedDate = picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF3A3A3A)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                color: AppTheme.primary, size: 18),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Date',
                    style: TextStyle(
                        color: AppTheme.onSurfaceMuted, fontSize: 11)),
                Text(
                  DateFormat('dd/MM/yy').format(_selectedDate),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _timePicker(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: _selectedTime,
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.dark(primary: AppTheme.primary),
            ),
            child: child!,
          ),
        );
        if (picked != null) setState(() => _selectedTime = picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF3A3A3A)),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time_outlined,
                color: AppTheme.primary, size: 18),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Heure',
                    style: TextStyle(
                        color: AppTheme.onSurfaceMuted, fontSize: 11)),
                Text(
                  _timeString,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
