import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:titan_tunes/core/app_theme.dart';
import 'package:titan_tunes/providers/artiste_provider.dart';
import 'package:titan_tunes/providers/audio_provider.dart';
import 'package:titan_tunes/providers/auth_provider.dart';

class CreateAlbumModal extends StatefulWidget {
  const CreateAlbumModal({super.key});

  @override
  State<CreateAlbumModal> createState() => _CreateAlbumModalState();
}

class _CreateAlbumModalState extends State<CreateAlbumModal> {
  final _titleCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  PlatformFile? _pickedCoverFile;

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickCover() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _pickedCoverFile = result.files.first;
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir un titre pour l\'album.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final artistId = auth.userId ?? '2';
    final artisteProv = context.read<ArtisteProvider>();
    final audioProv = context.read<AudioProvider>();

    final success = await artisteProv.creerAlbum(
      title: title,
      dateSortie: _selectedDate,
      artisteId: artistId,
      coverBytes: _pickedCoverFile?.bytes,
      coverPath: _pickedCoverFile?.path,
      coverName: _pickedCoverFile?.name,
    );

    if (!mounted) return;

    if (success) {
      // Rafraîchir les données audio globales
      audioProv.refreshData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Album « $title » créé avec succès !'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              artisteProv.albumError ?? 'Erreur lors de la création de l\'album.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final artisteProv = context.watch<ArtisteProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        22,
        18,
        22,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primary.withAlpha(25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.album_rounded, color: primary, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Créer un Album',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Sélecteur de Cover (Optionnel)
            InkWell(
              onTap: _pickCover,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primary.withAlpha(15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: primary.withAlpha(80),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Row(
                  children: [
                    if (_pickedCoverFile?.bytes != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.memory(
                          _pickedCoverFile!.bytes!,
                          width: 54,
                          height: 54,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: primary.withAlpha(30),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.add_photo_alternate_rounded,
                            color: primary, size: 28),
                      ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _pickedCoverFile != null
                                ? _pickedCoverFile!.name
                                : 'Pochette de l\'album (optionnel)',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: _pickedCoverFile != null ? primary : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _pickedCoverFile != null
                                ? '${(_pickedCoverFile!.size / 1024).toStringAsFixed(1)} Ko'
                                : 'Appuyez pour choisir une image (.jpg, .png)',
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.hintColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_pickedCoverFile != null)
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () => setState(() => _pickedCoverFile = null),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Titre de l'album
            const _InputLabel(label: 'Titre de l\'album :'),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.divider.withAlpha(100)),
              ),
              child: TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  hintText: 'ex: Racines du Golfe',
                  prefixIcon: Icon(Icons.album_outlined, size: 20),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Date de sortie
            const _InputLabel(label: 'Date de sortie officielle :'),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.divider.withAlpha(100)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 20, color: primary),
                    const SizedBox(width: 12),
                    Text(
                      '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Text(
                      'Modifier',
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),

            // Bouton soumettre
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: artisteProv.isCreatingAlbum ? null : _submit,
                icon: artisteProv.isCreatingAlbum
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_rounded),
                label: Text(
                  artisteProv.isCreatingAlbum
                      ? 'Création en cours...'
                      : 'Créer l\'album',
                  style:
                      const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputLabel extends StatelessWidget {
  final String label;
  const _InputLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }
}
