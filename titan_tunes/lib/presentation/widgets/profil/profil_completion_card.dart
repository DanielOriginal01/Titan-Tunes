import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:titan_tunes/presentation/widgets/glassmorphism_widgets.dart';
import 'package:titan_tunes/providers/auth_provider.dart';

// ── Carte formulaire de complétion du profil ──────────────────────────────────
class ProfilCompletionCard extends StatefulWidget {
  const ProfilCompletionCard({super.key});

  @override
  State<ProfilCompletionCard> createState() => _ProfilCompletionCardState();
}

class _ProfilCompletionCardState extends State<ProfilCompletionCard> {
  final _formKey        = GlobalKey<FormState>();
  final _firstNameCtrl  = TextEditingController();
  final _lastNameCtrl   = TextEditingController();
  final _emailCtrl      = TextEditingController();
  DateTime? _birthDate;
  String    _gender     = 'Préfère ne pas dire';
  bool      _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final auth = context.read<AuthProvider>();
    _firstNameCtrl.text = auth.firstName ?? '';
    _lastNameCtrl.text  = auth.lastName  ?? '';
    _emailCtrl.text     = auth.email     ?? '';
    _birthDate          = auth.birthDate;
    _gender             = auth.gender ?? _gender;
    _initialized        = true;
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme        = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return GlassPanel(
      accentColor: primaryColor,
      child: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Mettez à jour vos informations personnelles et de contact.',
            style: theme.textTheme.bodyMedium),
          const SizedBox(height: 14),
          TextFormField(
            controller: _firstNameCtrl,
            decoration: const InputDecoration(labelText: 'Prénom'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _lastNameCtrl,
            decoration: const InputDecoration(labelText: 'Nom'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _emailCtrl,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _gender,
            decoration: const InputDecoration(labelText: 'Genre'),
            items: const [
              DropdownMenuItem(value: 'Masculin',           child: Text('Masculin')),
              DropdownMenuItem(value: 'Féminin',            child: Text('Féminin')),
              DropdownMenuItem(value: 'Autre',              child: Text('Autre')),
              DropdownMenuItem(value: 'Préfère ne pas dire',child: Text('Préfère ne pas dire')),
            ],
            onChanged: (v) { if (v != null) setState(() => _gender = v); },
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Date de naissance'),
            subtitle: Text(_birthDate == null
                ? 'Sélectionner une date'
                : _formatDate(_birthDate!)),
            trailing: Icon(Icons.date_range_rounded, color: primaryColor),
            onTap: _pickBirthDate,
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saveProfile,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Enregistrer les informations'),
            ),
          ),
        ]),
      ),
    );
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 20, now.month, now.day),
      firstDate: DateTime(1950),
      lastDate: now,
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  void _saveProfile() {
    context.read<AuthProvider>().updateProfileInfo(
      firstName: _firstNameCtrl.text,
      lastName:  _lastNameCtrl.text,
      email:     _emailCtrl.text,
      gender:    _gender,
      birthDate: _birthDate,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil mis à jour avec succès.')));
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────────
String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/'
    '${date.month.toString().padLeft(2, '0')}/'
    '${date.year}';
