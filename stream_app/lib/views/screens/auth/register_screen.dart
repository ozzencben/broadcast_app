import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_app/logic/providers/auth_provider.dart';
import 'package:stream_app/logic/wrappers/main_wrapper.dart';
import 'package:stream_app/views/widgets/grid_painter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.register(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainWrapper()),
        (route) => false, // Tüm geçmişi sil
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Kayıt başarısız'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: GridBackground(
          child: Stack(
            children: [
              // 2. Katman: Form İçeriği
              SafeArea(
                child: Stack(
                  children: [
                    // Sol üstteki geri butonu (Kullanıcı giriş yapmaya dönmek isterse diye)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        color: theme.colorScheme.onSurface,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),

                    Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 32.0,
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 450),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(
                                  height: 24,
                                ), // Geri butonu ile çakışmasın diye boşluk
                                Text(
                                  'Hesap\nOluştur.',
                                  style: theme.textTheme.displayLarge,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Aramıza katıl ve favori içeriklerini keşfet.',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                                const SizedBox(height: 48),

                                TextFormField(
                                  controller: _emailController,
                                  focusNode: _emailFocus,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  onFieldSubmitted: (_) {
                                    FocusScope.of(
                                      context,
                                    ).requestFocus(_passwordFocus);
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                    hintText: 'ornek@email.com',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Lütfen email adresinizi girin';
                                    }
                                    if (!RegExp(
                                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                    ).hasMatch(value)) {
                                      return 'Geçerli bir email girin';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),

                                TextFormField(
                                  controller: _passwordController,
                                  focusNode: _passwordFocus,
                                  obscureText: !_isPasswordVisible,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _submit(),
                                  decoration: InputDecoration(
                                    labelText: 'Şifre',
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isPasswordVisible
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.5),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isPasswordVisible =
                                              !_isPasswordVisible;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Lütfen bir şifre belirleyin';
                                    }
                                    if (value.length < 6) {
                                      return 'Şifre en az 6 karakter olmalı';
                                    }
                                    // Ekstra güvenlik istersen buraya büyük harf/rakam validasyonu da eklenebilir
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 48),

                                ElevatedButton(
                                  onPressed: isLoading ? null : _submit,
                                  child: isLoading
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 3,
                                            color: Colors.black87,
                                          ),
                                        )
                                      : const Text('Kayıt Ol'),
                                ),

                                const SizedBox(height: 24),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Zaten hesabın var mı?',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // Login ekranından geldiğimiz için pop yapmak yeterli
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Giriş Yap'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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
