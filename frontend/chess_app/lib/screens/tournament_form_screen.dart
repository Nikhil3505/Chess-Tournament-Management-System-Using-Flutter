import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tournament.dart';
import '../providers/tournament_provider.dart';

class TournamentFormScreen extends ConsumerStatefulWidget {
  final Tournament? tournament;

  const TournamentFormScreen({super.key, this.tournament});

  @override
  ConsumerState<TournamentFormScreen> createState() => _TournamentFormScreenState();
}

class _TournamentFormScreenState extends ConsumerState<TournamentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _startCtrl;
  late final TextEditingController _endCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.tournament?.name ?? '');
    _descCtrl = TextEditingController(text: widget.tournament?.description ?? '');
    _startCtrl = TextEditingController(text: widget.tournament?.startDate ?? '');
    _endCtrl = TextEditingController(text: widget.tournament?.endDate ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController ctrl) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      ctrl.text = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.tournament != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Tournament' : 'Add Tournament')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Tournament Name'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Description (optional)'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _startCtrl,
                decoration: const InputDecoration(labelText: 'Start Date (YYYY-MM-DD)'),
                readOnly: true,
                onTap: () => _pickDate(_startCtrl),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _endCtrl,
                decoration: const InputDecoration(labelText: 'End Date (YYYY-MM-DD)'),
                readOnly: true,
                onTap: () => _pickDate(_endCtrl),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.save),
                label: Text(isEdit ? 'Update' : 'Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final t = Tournament(
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      startDate: _startCtrl.text.trim(),
      endDate: _endCtrl.text.trim(),
    );
    bool success;
    if (widget.tournament != null && widget.tournament!.id != null) {
      success = await ref.read(tournamentProvider.notifier).updateTournament(widget.tournament!.id!, t);
    } else {
      success = await ref.read(tournamentProvider.notifier).addTournament(t);
    }
    if (success && mounted) {
      Navigator.pop(context, true);
    }
  }
}
