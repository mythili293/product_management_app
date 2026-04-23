import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: "admin@console.net");
  final _passwordController = TextEditingController(text: "secure_admin");

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final result =
          await authProvider.signIn(_emailController.text, _passwordController.text);
      if (result.isSuccess) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Admin Access Granted.", style: TextStyle(color: Colors.greenAccent)), backgroundColor: Colors.black87));
        Navigator.pop(context); // Pop back so Wrapper can re-route natively
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E293B), // Dark blue-grey for admin vibe
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.admin_panel_settings, size: 80, color: Colors.blueAccent),
                const SizedBox(height: 20),
                Text('Admin Portal', style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('Secure System Access', style: GoogleFonts.inter(fontSize: 16, color: Colors.blueGrey[300])),
                const SizedBox(height: 48),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 30, offset: const Offset(0, 15)),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Admin Login', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF1F2937))),
                        const SizedBox(height: 24),
                        CustomTextField(
                          controller: _emailController,
                          labelText: 'Admin Email',
                          prefixIcon: Icons.shield_outlined,
                          validator: (value) => value!.isEmpty ? 'Enter designated admin email' : null,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _passwordController,
                          labelText: 'Master Password',
                          prefixIcon: Icons.lock_outline,
                          obscureText: true,
                          validator: (value) => value!.isEmpty ? 'Enter master password' : null,
                        ),
                        const SizedBox(height: 32),
                        Provider.of<AuthProvider>(context).isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : PrimaryButton(
                                text: 'AUTHORIZE ACCESS',
                                onPressed: _login,
                              ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Return to User Login', style: GoogleFonts.inter(color: Colors.blueGrey[200], fontWeight: FontWeight.w600)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
