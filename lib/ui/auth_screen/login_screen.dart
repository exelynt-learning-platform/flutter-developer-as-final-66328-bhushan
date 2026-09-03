import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../employee_screen/employee_list_screen.dart';
import '../helper/custom_text_field.dart';
import '../helper/snackbar_helper.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() => context.read<AuthCubit>().signInWithEmail(
        _emailController.text,
        _passwordController.text,
      );

  void _googleSignIn() => context.read<AuthCubit>().signInWithGoogle();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const EmployeeListScreen()),
          );
        } else if (state is AuthError) {
          SnackbarHelper.showError(context, state.message);
        }
        // AuthGoogleCancelled → silent, do nothing
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return Scaffold(
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 600;
                final hPad =
                    isWide ? (constraints.maxWidth - 520) / 2 : 24.0;
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                      horizontal: hPad, vertical: 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        Center(
                          child: Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryColor
                                      .withValues(alpha: 0.25),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: Semantics(
                                label: 'Employee Manager app icon',
                                image: true,
                                child: Image.asset(
                                  'assets/images/app_icon.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: Text(
                            'Welcome Back',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Center(
                          child: Text(
                            'Sign in to continue',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6)),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Email
                        CustomTextField(
                          controller: _emailController,
                          label: 'Email Address',
                          hint: 'you@example.com',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Email is required';
                            }
                            if (!RegExp(
                                    r'^[\w-.]+@([\w-]+\.)+[\w-]{2,}$')
                                .hasMatch(val.trim())) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password
                        CustomTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hint: 'Min. 6 characters',
                          prefixIcon: Icons.lock_outlined,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) {
                            if (_formKey.currentState!.validate()) {
                              _login();
                            }
                          },
                          suffixWidget: Semantics(
                            label: _obscurePassword
                                ? 'Show password'
                                : 'Hide password',
                            button: true,
                            child: IconButton(
                              icon: Icon(_obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined),
                              onPressed: () => setState(() =>
                                  _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Password is required';
                            }
                            if (val.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const ForgotPasswordScreen()),
                            ),
                            child: const Text('Forgot Password?'),
                          ),
                        ),
                        const SizedBox(height: 8),

                        Semantics(
                          button: true,
                          label: 'Sign In',
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    if (_formKey.currentState!
                                        .validate()) {
                                      _login();
                                    }
                                  },
                            child: isLoading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5),
                                  )
                                : const Text('Sign In'),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Row(children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16),
                            child: Text('OR',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.5))),
                          ),
                          const Expanded(child: Divider()),
                        ]),
                        const SizedBox(height: 20),

                        Semantics(
                          button: true,
                          label: 'Continue with Google',
                          child: OutlinedButton.icon(
                            onPressed: isLoading ? null : _googleSignIn,
                            icon: const Icon(
                                Icons.g_mobiledata_rounded,
                                size: 28),
                            label:
                                const Text('Continue with Google'),
                          ),
                        ),
                        const SizedBox(height: 32),

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Text("Don't have an account? ",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium),
                            Semantics(
                              button: true,
                              label: 'Register for a new account',
                              child: GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const RegisterScreen()),
                                ),
                                child: Text(
                                  'Register',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
