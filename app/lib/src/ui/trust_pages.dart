import 'package:flutter/material.dart';

import '../api.dart';
import '../theme.dart';
import 'shell.dart';
import 'wiki_actions.dart';
import 'widgets/interactive.dart';

/// Pages de confiance du site : à propos, charte éditoriale, contact et
/// confidentialité.
///
/// Le pied de page les annonçait sans qu'elles existent. Elles disent ce que
/// le site contient, comment il est écrit, comment le corriger et ce qu'il
/// fait des données d'un lecteur — sans promesse que le code ne tient pas.

/// Bloc de contenu d'une page de confiance.
class TrustSection {
  const TrustSection(this.title, this.paragraphs);

  final String title;
  final List<String> paragraphs;
}

/// Squelette commun : sur-titre, titre, chapeau, sections, puis un pied de
/// page facultatif avec des liens internes.
class TrustPage extends StatelessWidget {
  const TrustPage({
    required this.eyebrow,
    required this.title,
    required this.intro,
    required this.sections,
    this.links = const {},
    super.key,
  });

  final String eyebrow;
  final String title;
  final String intro;
  final List<TrustSection> sections;

  /// Liens de pied de page : libellé → chemin interne.
  final Map<String, String> links;

  @override
  Widget build(BuildContext context) {
    return SiteShell(
      child: PageContainer(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 70),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.8,
                  fontWeight: FontWeight.w700,
                  color: IvoireColors.orangeDeep,
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 30,
                    height: 1.15,
                    fontWeight: FontWeight.w600,
                    color: IvoireColors.ink,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Text(
                  intro,
                  style: const TextStyle(
                    fontSize: 15.5,
                    height: 1.7,
                    color: IvoireColors.muted,
                  ),
                ),
              ),
              const SizedBox(height: 26),
              for (final section in sections) ...[
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: _SectionBlock(section: section),
                ),
                const SizedBox(height: 22),
              ],
              if (links.isNotEmpty) ...[
                const SizedBox(height: 6),
                Wrap(
                  spacing: 18,
                  runSpacing: 8,
                  children: [
                    for (final link in links.entries)
                      HoverLink(
                        label: link.key,
                        onTap: () => wikiGo(context, link.value),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionBlock extends StatelessWidget {
  const _SectionBlock({required this.section});

  final TrustSection section;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
      decoration: BoxDecoration(
        color: IvoireColors.paper,
        border: Border.all(color: IvoireColors.line),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: IvoireColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          for (final paragraph in section.paragraphs)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                paragraph,
                style: const TextStyle(
                  fontSize: 14.5,
                  height: 1.75,
                  color: IvoireColors.muted,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// « À propos » : ce que contient le site, comment il est écrit, sa licence.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const TrustPage(
      eyebrow: 'Le projet',
      title: 'Une encyclopédie ivoirienne, écrite et sourcée',
      intro:
          'IVOIREPEDIA rassemble des articles de fond sur la Côte d’Ivoire : '
          'histoire, géographie, société et culture. Chaque fiche s’appuie sur '
          'des documents consultables, et chaque chiffre renvoie à sa source.',
      sections: [
        TrustSection('Ce que le site contient', [
          'Des articles de fond, des fiches de villes issues du répertoire '
              'public, des récits d’histoire datés, les indicateurs du pays et '
              'la climatologie des villes, ainsi qu’une bibliothèque qui '
              'réunit toutes les références citées.',
          'Les lieux, les périodes et les institutions ont chacun leur fiche : '
              'on peut lire un article, puis suivre sa ville, son époque ou sa '
              'source sans quitter le site.',
        ]),
        TrustSection('Comment nous travaillons', [
          'Une information sans source ne vaut pas la peine d’être publiée : '
              'quand un chiffre ou une date n’est pas vérifiable, nous '
              'l’écrivons ou nous ne l’écrivons pas — nous ne comblons pas le '
              'vide par une estimation.',
          'Les images viennent de Wikimedia Commons ou de documents libres ; '
              'l’auteur et la licence sont affichés sous chaque photographie. '
              'Quand aucune photo libre n’existe, la fiche reste sans image.',
        ]),
        TrustSection('La licence du contenu', [
          'Les textes sont publiés sous licence Creative Commons '
              'Attribution — Partage dans les mêmes conditions 4.0 '
              '(CC BY-SA 4.0) : vous pouvez les reprendre, y compris '
              'commercialement, à condition de citer IVOIREPEDIA et de '
              'partager vos ajouts sous la même licence.',
          'Les photographies et les documents cités gardent leur licence '
              'propre, rappelée à chaque fois.',
        ]),
        TrustSection('Écrire, corriger, discuter', [
          'La charte éditoriale détaille nos règles ; la page de contact sert '
              'à signaler une erreur, proposer une source ou demander une '
              'correction. Chaque message est lu par l’équipe éditoriale.',
        ]),
      ],
      links: {
        'Lire la charte': '/charte',
        'Nous écrire': '/contact',
        'Voir les sources': '/sources',
      },
    );
  }
}

/// « Charte » : les règles que le site s'engage à tenir.
class CharterPage extends StatelessWidget {
  const CharterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const TrustPage(
      eyebrow: 'Charte éditoriale',
      title: 'Ce que nous nous engageons à faire',
      intro:
          'Une encyclopédie se juge à ses règles. Voici celles qui décident de '
          'ce qui est publié, corrigé ou retiré sur IVOIREPEDIA.',
      sections: [
        TrustSection('1. Une information, une source', [
          'Chaque chiffre, chaque date et chaque fait délicat renvoie à un '
              'document : recensement, rapport d’institution, ouvrage, fiche '
              'du patrimoine mondial. Les références sont publiques et '
              'consultables dans la bibliothèque du site.',
          'Un article sans référence vérifiable n’est pas publié.',
        ]),
        TrustSection('2. Rien d’inventé', [
          'Une donnée manquante reste manquante. Nous décrivons ce que les '
              'documents établissent et nous le disons quand une information '
              'n’est pas disponible ; nous ne présentons jamais une hypothèse '
              'comme un fait.',
        ]),
        TrustSection('3. Des images libres et créditées', [
          'Une photographie n’est publiée que si sa licence autorise la '
              'réutilisation ; l’auteur, la licence et la page d’origine sont '
              'affichés sous l’image. Nous n’insérons ni carte décorative ni '
              'portrait générique à la place d’une photo absente.',
        ]),
        TrustSection('4. Des corrections visibles', [
          'Toute erreur signalée est vérifiée puis corrigée. Les versions '
              'successives d’un article sont conservées côté rédaction : une '
              'correction ne fait pas disparaître ce qui a été publié avant.',
        ]),
        TrustSection('5. Neutralité et respect des personnes', [
          'Pas de promotion commerciale, pas de contenu haineux ou '
              'discriminatoire. Les communautés, les langues et les lieux sont '
              'nommés comme leurs habitants les nomment, et les désaccords '
              'entre sources sont exposés plutôt que tranchés au hasard.',
        ]),
        TrustSection('6. Une licence ouverte', [
          'Les textes sont sous CC BY-SA 4.0 : réutilisation libre, avec '
              'attribution et partage à l’identique. Les images gardent leur '
              'licence propre.',
        ]),
      ],
      links: {
        'Signaler une erreur': '/contact',
        'Voir les sources': '/sources',
        'À propos du projet': '/a-propos',
      },
    );
  }
}

/// « Confidentialité » : ce qui est stocké, où, et pendant combien de temps.
class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const TrustPage(
      eyebrow: 'Données personnelles',
      title: 'Ce que le site sait de vous',
      intro:
          'Le site se lit sans compte et sans publicité. Voici, sans détour, '
          'les seules données qui peuvent exister et ce qu’elles deviennent.',
      sections: [
        TrustSection('Sans compte : rien ne quitte votre navigateur', [
          'Les favoris, les lectures récentes, le thème de lecture et la '
              'taille du texte sont enregistrés dans le stockage local de '
              'votre navigateur. Ils ne sont pas envoyés au serveur et '
              'disparaissent si vous effacez les données du site.',
        ]),
        TrustSection('Avec un compte', [
          'Un compte demande un nom, une adresse électronique et un mot de '
              'passe conservé sous forme hachée : le mot de passe lui-même '
              'n’est jamais lisible. L’adresse sert à la connexion et à la '
              'réinitialisation du mot de passe.',
          'Aucune donnée de compte n’est vendue, louée ou transmise à des '
              'annonceurs. Le compte se supprime sur demande.',
        ]),
        TrustSection('Le formulaire de contact', [
          'Un message envoyé depuis la page de contact est conservé avec le '
              'nom et l’adresse que vous indiquez — tous deux facultatifs. '
              'Sans adresse, aucune réponse n’est possible. Le message sert '
              'uniquement à traiter votre demande, puis il est marqué comme '
              'traité.',
        ]),
        TrustSection('Ce que nous ne faisons pas', [
          'Pas de publicité, pas de traqueur publicitaire, pas de profilage, '
              'pas de revente de données. Les pages ne déposent pas de cookie '
              'de mesure d’audience.',
          'Les photographies sont chargées depuis Wikimedia Commons : leurs '
              'serveurs voient votre adresse IP lors de l’affichage, comme '
              'pour tout site externe.',
        ]),
        TrustSection('Vos droits', [
          'Vous pouvez demander l’accès, la correction ou la suppression des '
              'données liées à votre compte ou à un message envoyé. Écrivez '
              'depuis la page de contact en précisant votre demande.',
          'Les journaux techniques du serveur (adresse IP, date, page '
              'demandée) sont conservés pour la sécurité du service, puis '
              'purgés.',
        ]),
      ],
      links: {
        'Nous écrire': '/contact',
        'À propos du projet': '/a-propos',
      },
    );
  }
}

/// « Contact » : formulaire de correction, stocké pour le panneau éditorial.
class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _message = TextEditingController();
  final TextEditingController _trap = TextEditingController();
  bool _sending = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _message.dispose();
    _trap.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_sending || !(_form.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _sending = true;
      _error = null;
    });

    try {
      await ApiScope.of(context).sendContactMessage(
        message: _message.text.trim(),
        name: _name.text.trim().isEmpty ? null : _name.text.trim(),
        email: _email.text.trim().isEmpty ? null : _email.text.trim(),
        website: _trap.text,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _sending = false;
        _sent = true;
      });
      _message.clear();
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _sending = false;
        _error = error.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SiteShell(
      child: PageContainer(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 70),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'NOUS ÉCRIRE',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.8,
                  fontWeight: FontWeight.w700,
                  color: IvoireColors.orangeDeep,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Signaler une erreur, proposer une source',
                style: TextStyle(
                  fontSize: 30,
                  height: 1.15,
                  fontWeight: FontWeight.w600,
                  color: IvoireColors.ink,
                ),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: const Text(
                  'Une date fausse, un chiffre douteux, une photo mal '
                  'attribuée, une fiche à compléter : écrivez-nous. Indiquez '
                  'l’article concerné et, si vous en avez une, la source qui '
                  'tranche la question.',
                  style: TextStyle(
                    fontSize: 15.5,
                    height: 1.7,
                    color: IvoireColors.muted,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: _sent ? _confirmation(context) : _formBody(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _confirmation(BuildContext context) {
    return Container(
      key: const Key('contact-confirmation'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: IvoireColors.paper,
        border: Border.all(color: IvoireColors.green),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Message reçu.',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: IvoireColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Merci. Chaque message est lu par l’équipe éditoriale ; les '
            'corrections sont vérifiées avant d’être publiées. Si vous avez '
            'laissé une adresse, vous recevrez une réponse.',
            style: TextStyle(
              fontSize: 14.5,
              height: 1.7,
              color: IvoireColors.muted,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => setState(() => _sent = false),
            child: const Text('Écrire un autre message'),
          ),
        ],
      ),
    );
  }

  Widget _formBody(BuildContext context) {
    return Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            key: const Key('contact-name'),
            controller: _name,
            maxLength: 80,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Votre nom (facultatif)',
              border: OutlineInputBorder(),
              counterText: '',
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            key: const Key('contact-email'),
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Adresse électronique (facultatif)',
              helperText: 'Sans adresse, nous ne pouvons pas vous répondre.',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              final email = value?.trim() ?? '';

              if (email.isEmpty) {
                return null;
              }

              final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);

              return valid ? null : 'Cette adresse ne semble pas valide.';
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            key: const Key('contact-message'),
            controller: _message,
            minLines: 6,
            maxLines: 12,
            maxLength: 4000,
            decoration: const InputDecoration(
              labelText: 'Votre message',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              final message = value?.trim() ?? '';

              if (message.length < 20) {
                return 'Décrivez votre demande en quelques mots (20 caractères au moins).';
              }

              return null;
            },
          ),
          // Piège à robots : hors de la vue, jamais rempli par un humain.
          Offstage(
            offstage: true,
            child: TextFormField(
              key: const Key('contact-website'),
              controller: _trap,
              decoration: const InputDecoration(labelText: 'Site web'),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              key: const Key('contact-error'),
              style: const TextStyle(fontSize: 13.5, color: IvoireColors.orangeDeep),
            ),
          ],
          const SizedBox(height: 14),
          FilledButton(
            key: const Key('contact-submit'),
            onPressed: _sending ? null : _submit,
            child: Text(_sending ? 'Envoi…' : 'Envoyer le message'),
          ),
        ],
      ),
    );
  }
}
