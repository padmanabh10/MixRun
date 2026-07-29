import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:mixrun/l10n/gen/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/account_controller.dart';
import '../../shared/widgets/gold_button.dart';
import '../../shared/widgets/light_back_button.dart';
import '../../shared/widgets/parchment_scaffold.dart';

/// Email/password + Google sign-in. Closes itself once the player is signed in.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _isRegister = false;
  bool _popped = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _close() {
    if (_popped) return;
    _popped = true;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.settings);
    }
  }

  Future<void> _submitEmail(AccountController account) async {
    if (_isRegister) {
      await account.registerWithEmail(_email.text, _password.text);
    } else {
      await account.signInWithEmail(_email.text, _password.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context);
    final AccountController account = context.watch<AccountController>();

    // Auto-close once authentication succeeds.
    if (account.isSignedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _close());
    }

    return ParchmentScaffold(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: Row(
                children: <Widget>[
                  LightBackButton(onTap: _close),
                  const SizedBox(width: 10),
                  Text(
                    _isRegister ? strings.createAccount : strings.signIn,
                    style: AppText.display(
                      size: 22,
                      weight: FontWeight.w800,
                      color: AppColors.cocoa,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 6, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    strings.signInBlurb,
                    style: AppText.body(size: 14, color: AppColors.mutedBrown),
                  ),
                  const SizedBox(height: 22),
                  _Field(
                    controller: _email,
                    label: strings.email,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (_) => account.clearError(),
                  ),
                  const SizedBox(height: 14),
                  _Field(
                    controller: _password,
                    label: strings.password,
                    obscure: true,
                    onChanged: (_) => account.clearError(),
                  ),
                  if (account.error != null) ...<Widget>[
                    const SizedBox(height: 14),
                    Text(
                      account.error!,
                      style: AppText.body(size: 13, color: AppColors.brick),
                    ),
                  ],
                  const SizedBox(height: 22),
                  GoldButton(
                    solid: true,
                    label: _isRegister ? strings.createAccount : strings.signIn,
                    fontSize: 17,
                    onPressed: account.busy
                        ? () {}
                        : () => _submitEmail(account),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => setState(() => _isRegister = !_isRegister),
                    child: Text(
                      _isRegister
                          ? strings.toggleToSignIn
                          : strings.toggleToRegister,
                      style: AppText.display(
                        size: 14,
                        color: AppColors.spiceBrown,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _OrDivider(label: strings.orDivider),
                  const SizedBox(height: 14),
                  _GoogleButton(
                    label: strings.continueWithGoogle,
                    onPressed:
                        account.busy ? null : account.signInWithGoogle,
                  ),
                  if (account.busy) ...<Widget>[
                    const SizedBox(height: 22),
                    const Center(child: CircularProgressIndicator()),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.onChanged,
    this.obscure = false,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final ValueChanged<String> onChanged;
  final bool obscure;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      onChanged: onChanged,
      cursorColor: AppColors.gold,
      style: AppText.body(size: 15, color: AppColors.cocoa),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppText.body(size: 14, color: AppColors.mutedBrown),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.cocoa.withValues(alpha: 0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final Color line = AppColors.cocoa.withValues(alpha: 0.12);
    return Row(
      children: <Widget>[
        Expanded(child: Divider(color: line)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: AppText.body(size: 12, color: AppColors.fadedBrown),
          ),
        ),
        Expanded(child: Divider(color: line)),
      ],
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.g_mobiledata_rounded,
          size: 28, color: AppColors.cocoa),
      label: Text(
        label,
        style: AppText.display(
          size: 15,
          weight: FontWeight.w700,
          color: AppColors.cocoa,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        backgroundColor: Colors.white,
        side: BorderSide(color: AppColors.cocoa.withValues(alpha: 0.15)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
