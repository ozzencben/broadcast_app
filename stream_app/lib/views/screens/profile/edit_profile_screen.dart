import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:stream_app/core/theme.dart';
import 'package:stream_app/views/widgets/grid_painter.dart'; // GridBackground burada tanımlı varsayıyorum
import '../../../../data/models/user/user_model.dart';
import '../../../../logic/providers/user_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _imagePicker = ImagePicker();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  Gender? _selectedGender;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().user;
    _firstNameController = TextEditingController(text: user?.firstName);
    _lastNameController = TextEditingController(text: user?.lastName);
    _usernameController = TextEditingController(text: user?.username);
    _bioController = TextEditingController(text: user?.bio);
    _selectedGender = user?.gender;
    _selectedDate = user?.birthDate;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final updateData = {
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'username': _usernameController.text.trim(),
      'bio': _bioController.text.trim(),
      'gender': _selectedGender?.name,
      if (_selectedDate != null)
        'birth_date': _selectedDate!.toIso8601String().split('T')[0],
    };

    final success = await context.read<UserProvider>().updateProfile(
      updateData,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil başarıyla güncellendi')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<UserProvider>().errorMessage ?? 'Hata oluştu',
            ),
          ),
        );
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    // 1. Kullanıcıya galeriyi aç
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // Cloudinary'ye göndermeden önce biraz sıkıştıralım
      maxWidth: 800,
    );

    if (image != null) {
      // 2. Provider üzerinden yükleme işlemini başlat
      final success = await context.read<UserProvider>().uploadProfileImage(
        image.path,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil fotoğrafı güncellendi!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.read<UserProvider>().errorMessage ??
                    'Yükleme başarısız',
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    final user = context.watch<UserProvider>().user;
    final isLoadingImage = context.watch<UserProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profili Düzenle'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: GridBackground(
        // Kendi yazdığın Grid Painter widget'ı
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 120, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Profil Fotoğrafı ---
                Center(
                  child: Stack(
                    children: [
                      _buildShadowWrapper(
                        borderRadius: 100,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 55,
                            backgroundColor: AppTheme.accentPurple.withValues(
                              alpha: 0.1,
                            ),
                            backgroundImage: user?.profileImageUrl != null
                                ? NetworkImage(user!.profileImageUrl!)
                                : null,
                            child: user?.profileImageUrl == null
                                ? const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.grey,
                                  )
                                : (isLoadingImage
                                      ? const CircularProgressIndicator()
                                      : null),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 5,
                        right: 5,
                        child: GestureDetector(
                          onTap: _pickAndUploadImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // --- Ad & Soyad ---
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _firstNameController,
                        label: 'Ad',
                        hint: 'Adınız',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _lastNameController,
                        label: 'Soyad',
                        hint: 'Soyadınız',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // --- Kullanıcı Adı ---
                _buildTextField(
                  controller: _usernameController,
                  label: 'Kullanıcı Adı',
                  hint: 'kullanici_adi',
                  validator: (val) => val!.isEmpty ? 'Boş bırakılamaz' : null,
                ),
                const SizedBox(height: 20),

                // --- Cinsiyet Seçimi ---
                _buildLabel('Cinsiyet'),
                _buildShadowWrapper(
                  child: DropdownButtonFormField<Gender>(
                    value: _selectedGender,
                    items: Gender.values.map((g) {
                      return DropdownMenuItem(
                        value: g,
                        child: Text(g.name.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedGender = val),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // --- Doğum Tarihi ---
                _buildLabel('Doğum Tarihi'),
                _buildShadowWrapper(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate ?? DateTime(2000),
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null)
                        setState(() => _selectedDate = picked);
                    },
                    borderRadius: BorderRadius.circular(100),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                      ),
                      child: Text(
                        _selectedDate == null
                            ? 'Doğum Tarihi Seç'
                            : DateFormat('dd MMMM yyyy').format(_selectedDate!),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // --- Bio ---
                _buildTextField(
                  controller: _bioController,
                  label: 'Hakkında',
                  hint: 'Kendinden bahset...',
                  maxLines: 4,
                ),
                const SizedBox(height: 40),

                // --- Kaydet Butonu ---
                Consumer<UserProvider>(
                  builder: (context, provider, child) {
                    return provider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _saveProfile,
                            child: const Text('DEĞİŞİKLİKLERİ KAYDET'),
                          );
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Yardımcı Widget: Input Etiketleri
  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppTheme.textDark.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  // Yardımcı Widget: Gölgeli Sarmalayıcı
  Widget _buildShadowWrapper({
    required Widget child,
    double borderRadius = 100,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentPurple.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  // Yardımcı Widget: Özelleştirilmiş TextField
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        _buildShadowWrapper(
          borderRadius: maxLines > 1 ? 24 : 100, // Bio alanı için daha az oval
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 20,
              ),
              // Tema dosyasındaki borderları burada eziyoruz çünkü Container dekorasyonu kullanıyoruz
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(maxLines > 1 ? 24 : 100),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(maxLines > 1 ? 24 : 100),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
