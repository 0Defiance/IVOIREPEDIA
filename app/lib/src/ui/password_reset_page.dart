import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../auth.dart';
import '../theme.dart';
import 'display_settings.dart';
import 'shell.dart';
import 'widgets/page_parts.dart';

/// Parcours « mot de passe oublié » — Sprint 1.
///
/// Une seule adresse porte les deux étapes, parce que c'est exactement ce que
/// le courriel envoie : `/mot-de-passe-oublie` demande le lien, et
/// `/mot-de-passe-oublie?token=…&email=…` choisit le nouveau mot de passe.
/// Un lecteur qui a perdu son mot de passe n'est jamais bloqué ; le panneau
/// d'administration renvoie ici aussi.
class PasswordResetPage extends StatefulWidget {
  const PasswordResetPage({this.token, this.email, super.key});

  /// Jeton reçu par courriel ; absent quand on demande simplement un lien.
  final String? token;

  /// Adresse portée par le lien, ou saisie à l'étape précédente.
  final String? email;

  @override
  State<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  late final TextEditingController _email = TextEditingController(
    text: widget.email ?? '',
  );
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();

  bool _submitting = false;
  bool _obscure = true;
  String? _error;
  String? _notice;

  String get _token => (widget.token ?? '').trim();

  /// Vrai quand le lien est arrivé : on choisit alors le nouveau mot de passe.
  bool get _choosing => _token.isNotEmpty;

  @override
  void didUpdateWidget(PasswordResetPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Même adresse, autre jeton (ou plus de jeton) : le formulaire change de
    // sens et ne doit garder ni l'erreur ni la confirmation précédentes.
    if ((oldWidget.token ?? '') != (widget.token ?? '')) {
      _error = null;
      _notice = null;
      _password.clear();
      _confirm.clear();
    }

    final email = widget.email ?? '';
    if (oldWidget.email != widget.email && email.isNotEmpty) {
      _email.text = email;
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
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

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final notice = _choosing
          ? await store.resetPassword(
              email: _email.text,
              token: _token,
              password: _password.text,
            )
          : await store.requestPasswordReset(_email.text);

      if (mounted) {
        setState(() => _notice = notice);
      }
    } on AuthException catch (error) {
      if (mounted) {
        setState(() => _error = error.message);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'La demande a échoué. Réessayez.');
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

    return SiteShell(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 26, 20, 44),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              key: const Key('reset-page'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageHeader(
                  kicker: 'Votre compte',
                  title: _choosing
                      ? 'Choisir un nouveau mot de passe'
                      : 'Mot de passe oublié',
                  intro: _choosing
                      ? 'Ce lien est valable une heure et ne sert qu’une fois. '
                            'Choisissez un mot de passe d’au moins 8 caractères.'
                      : 'Indiquez l’adresse de votre compte : si elle est inscrite, '
                            'un lien de réinitialisation lui est envoyé. La lecture '
                            'reste libre et sans compte.',
                ),
                const SizedBox(height: 22),
                if (_notice != null) _noticePanel(tone) else _formPanel(tone),
                const SizedBox(height: 18),
                _backLink(tone),
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
            TextFormField(
              key: const Key('reset-email'),
              controller: _email,
              readOnly: _choosing,
              keyboardType: TextInputType.emailAddress,
              textInputAction: _choosing
                  ? TextInputAction.next
                  : TextInputAction.done,
              autofillHints: const [AutofillHints.email],
              validator: _validateEmail,
              onFieldSubmitted: (_) {
                if (!_choosing) {
                  _submit();
                }
              },
              decoration: const InputDecoration(
                labelText: 'Adresse électronique',
                hintText: 'vous@exemple.ci',
              ),
            ),
            if (_choosing) ...[
              const SizedBox(height: 14),
              TextFormField(
                key: const Key('reset-password'),
                controller: _password,
                obscureText: _obscure,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                validator: _validatePassword,
                decoration: InputDecoration(
                  labelText: 'Nouveau mot de passe',
                  hintText: 'Au moins 8 caractères',
                  suffixIcon: IconButton(
                    tooltip: _obscure ? 'Afficher' : 'Masquer',
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                key: const Key('reset-confirm'),
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
                key: const Key('reset-error'),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: IvoireColors.highlight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: IvoireColors.terracotta.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  _error!,
                  style: TextStyle(fontSize: 13, height: 1.45, color: tone.ink),
                ),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton(
              key: const Key('reset-submit'),
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
                  : Text(
                      _choosing
                          ? 'Enregistrer le mot de passe'
                          : 'Recevoir le lien',
                    ),
            ),
            const SizedBox(height: 12),
            Text(
              _choosing
                  ? 'Le lien est brûlé dès l’enregistrement : il ne pourra plus '
                        'resservir. Toutes les sessions ouvertes ailleurs sont fermées.'
                  : 'La réponse est la même que l’adresse soit inscrite ou non : '
                        'ce formulaire ne permet pas de savoir qui possède un compte.',
              style: TextStyle(fontSize: 11.5, height: 1.55, color: tone.faint),
            ),
          ],
        ),
      ),
    );
  }

  Widget _noticePanel(ToneColors tone) {
    return Container(
      key: const Key('reset-done'),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: tone.paper,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tone.lineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                _choosing
                    ? Icons.check_circle_outline
                    : Icons.mark_email_read_outlined,
                size: 22,
                color: IvoireColors.greenDeep,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _choosing ? 'Mot de passe changé' : 'Demande envoyée',
                  style: titleStyle(
                    size: 16,
                    weight: FontWeight.w600,
                    color: tone.ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _notice!,
            style: TextStyle(fontSize: 13.5, height: 1.6, color: tone.ink),
          ),
          const SizedBox(height: 12),
          Text(
            _choosing
                ? 'Connectez-vous avec ce nouveau mot de passe ; les autres '
                      'appareils devront se reconnecter.'
                : 'Le lien expire au bout d’une heure. Sans courriel après '
                      'quelques minutes, regardez les indésirables, puis '
                      'redemandez-en un.',
            style: TextStyle(fontSize: 12.5, height: 1.55, color: tone.muted),
          ),
          if (_choosing) ...[
            const SizedBox(height: 18),
            FilledButton(
              key: const Key('reset-signin'),
              onPressed: () => context.go('/connexion'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Se connecter'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _backLink(ToneColors tone) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          _choosing
              ? 'Lien expiré ou déjà utilisé ?'
              : 'Vous vous en souvenez ?',
          style: TextStyle(fontSize: 13.5, color: tone.muted),
        ),
        TextButton(
          key: const Key('reset-restart'),
          onPressed: () =>
              context.go(_choosing ? '/mot-de-passe-oublie' : '/connexion'),
          child: Text(
            _choosing ? 'Demander un nouveau lien' : 'Revenir à la connexion',
          ),
        ),
      ],
    );
  }
}
