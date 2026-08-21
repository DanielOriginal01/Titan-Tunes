import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:titan_tunes/core/app_theme.dart';
import 'package:titan_tunes/data/models/categorie.dart';
import 'package:titan_tunes/providers/artiste_provider.dart';
import 'package:titan_tunes/providers/audio_provider.dart';
import 'package:titan_tunes/providers/auth_provider.dart';

class PublishSongModal extends StatefulWidget {
  const PublishSongModal({super.key});

  @override
  State<PublishSongModal> createState() => _PublishSongModalState();
}

class _PublishSongModalState extends State<PublishSongModal> {
  final _titreCtrl = TextEditingController();
  final _dureeCtrl = TextEditingController(text: '210');
  final _paroleCtrl = TextEditingController();

  int _selectedCategorieId = 1;
  int? _selectedAlbumId;
  PlatformFile? _pickedAudioFile;
  PlatformFile? _pickedCoverFile;

  @override
  void dispose() {
    _titreCtrl.dispose();
    _dureeCtrl.dispose();
    _paroleCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAudio() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'aac', 'm4a'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _pickedAudioFile = result.files.first;
        if (_titreCtrl.text.trim().isEmpty) {
          final rawName = _pickedAudioFile!.name;
          final cleanName = rawName.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '');
          _titreCtrl.text = cleanName;
        }
      });
    }
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

  Future<void> _submit() async {
    final titre = _titreCtrl.text.trim();
    if (titre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir un titre pour le morceau.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_pickedAudioFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un fichier audio (.mp3 ou .wav).'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final duree = int.tryParse(_dureeCtrl.text.trim()) ?? 180;
    final auth = context.read<AuthProvider>();
    final artistId = auth.userId ?? '2';
    final artisteProv = context.read<ArtisteProvider>();
    final audioProv = context.read<AudioProvider>();

    final success = await artisteProv.publierChanson(
      titre: titre,
      duree: duree,
      parole: _paroleCtrl.text.trim(),
      artisteId: artistId,
      categorieId: _selectedCategorieId,
      albumId: _selectedAlbumId,
      filePath: _pickedAudioFile!.path,
      fileBytes: _pickedAudioFile!.bytes,
      fileName: _pickedAudioFile!.name,
      coverBytes: _pickedCoverFile?.bytes,
      coverPath: _pickedCoverFile?.path,
      coverName: _pickedCoverFile?.name,
    );

    if (!mounted) return;

    if (success) {
      // Rafraîchir les données du player / catalogue global
      audioProv.refreshData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Titre « $titre » publié avec succès !'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              artisteProv.publishError ?? 'Erreur lors de la publication.'),
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

    final categories = artisteProv.categories.isNotEmpty
        ? artisteProv.categories
        : const [
            Categorie(id: 1, nom: 'Afrobeat'),
            Categorie(id: 2, nom: 'Hip-Hop / Rap'),
            Categorie(id: 3, nom: 'Gospel'),
            Categorie(id: 4, nom: 'Coupé-Décalé'),
            Categorie(id: 6, nom: 'R&B / Soul'),
          ];

    final albums = artisteProv.albums;

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
                      child: Icon(Icons.music_note_rounded, color: primary, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Publier un Titre',
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

            // Sélecteur de fichier audio (Obligatoire)
            InkWell(
              onTap: _pickAudio,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: primary.withAlpha(100),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _pickedAudioFile != null
                          ? Icons.audio_file_rounded
                          : Icons.cloud_upload_rounded,
                      size: 36,
                      color: primary,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _pickedAudioFile != null
                          ? _pickedAudioFile!.name
                          : 'Choisir le fichier audio (.mp3 / .wav)',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _pickedAudioFile != null ? primary : null,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_pickedAudioFile != null)
                      Text(
                        '${(_pickedAudioFile!.size / (1024 * 1024)).toStringAsFixed(2)} Mo',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.hintColor,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Sélecteur de Cover (Optionnel)
            InkWell(
              onTap: _pickCover,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.divider.withAlpha(100)),
                ),
                child: Row(
                  children: [
                    if (_pickedCoverFile?.bytes != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          _pickedCoverFile!.bytes!,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.add_photo_alternate_rounded,
                            color: primary, size: 22),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _pickedCoverFile != null
                                ? _pickedCoverFile!.name
                                : 'Pochette de la chanson (optionnel)',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: _pickedCoverFile != null ? primary : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _pickedCoverFile != null
                                ? '${(_pickedCoverFile!.size / 1024).toStringAsFixed(1)} Ko'
                                : 'Choisir une image pour le single',
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
            const SizedBox(height: 14),

            // Titre
            const _InputLabel(label: 'Titre de la chanson :'),
            _StyledField(
              controller: _titreCtrl,
              hint: 'ex: Mon Nouveau Hit',
              icon: Icons.title_rounded,
              isDark: isDark,
            ),
            const SizedBox(height: 14),

            // Rattachement Album (Optionnel)
            const _InputLabel(label: 'Album associé :'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.divider.withAlpha(100)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int?>(
                  value: _selectedAlbumId,
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Single indépendant (aucun album)'),
                    ),
                    ...albums.map((album) => DropdownMenuItem<int?>(
                          value: int.tryParse(album.id),
                          child: Text('Album : ${album.title}'),
                        )),
                  ],
                  onChanged: (v) {
                    setState(() => _selectedAlbumId = v);
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Catégorie / Genre
            const _InputLabel(label: 'Genre / Catégorie :'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.divider.withAlpha(100)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedCategorieId,
                  isExpanded: true,
                  items: categories
                      .map((cat) => DropdownMenuItem<int>(
                            value: cat.id,
                            child: Text(cat.nom),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => _selectedCategorieId = v);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Durée estimée en secondes
            const _InputLabel(label: 'Durée en secondes :'),
            _StyledField(
              controller: _dureeCtrl,
              hint: 'ex: 215',
              icon: Icons.timer_outlined,
              isDark: isDark,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 14),

            // Paroles
            const _InputLabel(label: 'Paroles (optionnel) :'),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.divider.withAlpha(100)),
              ),
              child: TextField(
                controller: _paroleCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Saisissez les paroles du morceau...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(14),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Bouton soumettre
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: artisteProv.isPublishing ? null : _submit,
                icon: artisteProv.isPublishing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.publish_rounded),
                label: Text(
                  artisteProv.isPublishing
                      ? 'Publication en cours...'
                      : 'Publier le morceau',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700),
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

class _StyledField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isDark;
  final TextInputType? keyboardType;

  const _StyledField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.isDark,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider.withAlpha(100)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
