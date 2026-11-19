import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../auth.dart';
import '../theme.dart';
import 'display_settings.dart';
import 'shell.dart';
import 'widgets/page_parts.dart';

/// Connexion et création de compte — Sprint 1.
///
/// Un seul écran pour les deux gestes : mêmes champs, même mise en page, seule
/// la validation change (le nom et la confirmation n'existent qu'à
/// l'inscription).
class AuthPage extends StatefulWidget {
  const AuthPage({this.register = false, super.key});

  final bool register;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();

  bool _submitting = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (!widget.register) {
      return null;
    }

    if ((value ?? '').trim().length < 2) {
      return 'Indiquez votre nom.';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    final email = (value ?? '').trim();
    if (email.isEmpty) {
      return 'Indiquez votre adresse électronique.';
    }

    final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    return valid ? null : 'Cette adresse électronique n’est pas valide.';
  }

  String? _validatePassword(String? value) {
    if ((value ?? '').length < 8) {
      return 'Le mot de passe doit contenir au moins 8 caractères.';
    }

    return null;
  }

  String? _validateConfirm(String? value) {
    if (!widget.register) {
      return null;
    }

    return value == _password.text
        ? null
        : 'Les deux mots de passe ne correspondent pas.';
  }

  Future<void> _submit() async {
    final form = _form.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    final store = AuthScope.of(context);
    final messenger = ScaffoldMessenger.of(context);

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      if (widget.register) {
        await store.signUp(
          name: _name.text,
          email: _email.text,
          password: _password.text,
        );
      } else {
        await store.signIn(email: _email.text, password: _password.text);
      }

      if (!mounted) {
        return;
      }

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            widget.register
                ? 'Bienvenue sur IVOIREPEDIA, ${store.user?.firstName ?? ''}.'
                : 'Content de vous revoir, ${store.user?.firstName ?? ''}.',
          ),
          duration: const Duration(seconds: 3),
        ),
      );

      context.go('/');
    } on AuthException catch (error) {
      if (mounted) {
        setState(() => _error = error.message);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'La connexion a échoué. Réessayez.');
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);
    final store = AuthScope.of(context);

    return SiteShell(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 26, 20, 44),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              key: const Key('auth-page'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageHeader(
                  kicker: 'Votre espace',
                  title: widget.register ? 'Créer un compte' : 'Se connecter',
                  intro: widget.register
                      ? 'Un compte vous permet de retrouver votre bibliothèque '
                          'et, bientôt, de proposer des articles à la rédaction. '
                          'La lecture reste libre et sans compte.'
                      : 'Retrouvez votre bibliothèque et votre historique de '
                          'lecture. Aucun article n’est réservé aux inscrits.',
                ),
                const SizedBox(height: 22),
                if (store.signedIn)
                  _SignedInPanel(user: store.user!, tone: tone)
                else
                  _formPanel(tone),
                const SizedBox(height: 18),
                _switchLink(tone),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _formPanel(ToneColors tone) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: tone.paper,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tone.lineSoft),
      ),
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.register) ...[
              TextFormField(
                key: const Key('auth-name'),
                controller: _name,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
                validator: _validateName,
                decoration: const InputDecoration(
                  labelText: 'Nom ou pseudonyme',
                  hintText: 'Awa Koné',
                ),
              ),
              const SizedBox(height: 14),
            ],
            TextFormField(
              key: const Key('auth-email'),
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: _validateEmail,
              decoration: const InputDecoration(
                labelText: 'Adresse électronique',
                hintText: 'vous@exemple.ci',
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              key: const Key('auth-password'),
              controller: _password,
              obscureText: _obscure,
              textInputAction:
                  widget.register ? TextInputAction.next : TextInputAction.done,
              autofillHints: [
                widget.register
                    ? AutofillHints.newPassword
                    : AutofillHints.password,
              ],
              validator: _validatePassword,
              onFieldSubmitted: (_) {
                if (!widget.register) {
                  _submit();
                }
              },
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                hintText: widget.register ? 'Au moins 8 caractères' : null,
                suffixIcon: IconButton(
                  tooltip: _obscure ? 'Afficher' : 'Masquer',
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(
                    _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    size: 20,
                  ),
                ),
              ),
            ),
            if (!widget.register)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  key: const Key('auth-forgot'),
                  onPressed: () => context.go('/mot-de-passe-oublie'),
                  child: const Text('Mot de passe oublié ?'),
                ),
              ),
            if (widget.register) ...[
              const SizedBox(height: 14),
              TextFormField(
                key: const Key('auth-confirm'),
                controller: _confirm,
                obscureText: _obscure,
                textInputAction: TextInputAction.done,
                validator: _validateConfirm,
                onFieldSubmitted: (_) => _submit(),
                decoration: const InputDecoration(
                  labelText: 'Confirmer le mot de passe',
                ),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                key: const Key('auth-error'),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: IvoireColors.highlight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: IvoireColors.terracotta.withValues(alpha: 0.35)),
                ),
                child: Text(
                  _error!,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: tone.ink,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton(
              key: const Key('auth-submit'),
              onPressed: _submitting ? null : _submit,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.register ? 'Créer mon compte' : 'Se connecter'),
            ),
            const SizedBox(height: 12),
            Text(
              'Vos identifiants ne servent qu’à IVOIREPEDIA. Le mot de passe est '
              'conservé sous forme chiffrée sur le serveur, jamais sur cet appareil.',
              style: TextStyle(fontSize: 11.5, height: 1.55, color: tone.faint),
            ),
          ],
        ),
      ),
    );
  }

  Widget _switchLink(ToneColors tone) {
    final signedIn = AuthScope.of(context).signedIn;

    if (signedIn) {
      return const SizedBox.shrink();
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          widget.register ? 'Vous avez déjà un compte ?' : 'Pas encore de compte ?',
          style: TextStyle(fontSize: 13.5, color: tone.muted),
        ),
        TextButton(
          key: const Key('auth-switch'),
          onPressed: () => context.go(widget.register ? '/connexion' : '/inscription'),
          child: Text(widget.register ? 'Se connecter' : 'Créer un compte'),
        ),
      ],
    );
  }
}

/// Panneau affiché une fois la session ouverte : le compte, puis de quoi agir.
class _SignedInPanel extends StatelessWidget {
  const _SignedInPanel({required this.user, required this.tone});

  final AuthUser user;
  final ToneColors tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: tone.paper,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tone.lineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: IvoireColors.green.withValues(alpha: 0.12),
                child: Text(
                  user.firstName.isEmpty
                      ? '?'
                      : user.firstName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    fontFamily: kFont,
                    fontWeight: FontWeight.w700,
                    color: IvoireColors.greenDeep,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: titleStyle(size: 16, weight: FontWeight.w600, color: tone.ink),
                    ),
                    Text(user.email, style: TextStyle(fontSize: 12.5, color: tone.muted)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            user.emailVerified
                ? 'Votre adresse est vérifiée.'
                : 'Votre adresse n’est pas encore vérifiée : la vérification par '
                    'courriel arrive avec l’ouverture des contributions.',
            style: TextStyle(fontSize: 12.5, height: 1.55, color: tone.muted),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => context.go('/ma-bibliotheque'),
                icon: const Icon(Icons.bookmarks_outlined, size: 16),
                label: const Text('Ma bibliothèque'),
              ),
              TextButton.icon(
                key: const Key('auth-signout'),
                onPressed: () => AuthScope.of(context).signOut(),
                icon: const Icon(Icons.logout, size: 16),
                label: const Text('Se déconnecter'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
