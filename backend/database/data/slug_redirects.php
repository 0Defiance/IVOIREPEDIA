<?php

/**
 * Anciens slugs publics conservés en redirection permanente (301).
 *
 * Chaque entrée est appliquée par `PersonalitiesSeeder` : l'article encore
 * publié sous l'ancien slug est renommé (sans perte de contenu) et la paire
 * `ancien => nouveau` est enregistrée dans `article_slug_redirects`. La page
 * publique et l'API répondent alors 301 vers la nouvelle adresse.
 *
 * N'ajouter ici qu'un renommage réel : un slug ne change pas pour un simple
 * ajustement de titre, et l'entrée reste indéfiniment.
 */
return [
    'augustin-denise-djore' => 'auguste-denise',
];
