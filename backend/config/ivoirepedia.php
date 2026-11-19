<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Relecture par l'auteur
    |--------------------------------------------------------------------------
    |
    | Phase solo : le fondateur est seul ADMIN et doit pouvoir prendre en
    | relecture ses propres articles. À désactiver (ALLOW_SELF_REVIEW=false)
    | dès l'arrivée du premier éditeur — la règle reste alors appliquée par
    | `Workflow::assertTransition`.
    |
    */

    'allow_self_review' => (bool) env('ALLOW_SELF_REVIEW', true),

    /*
    |--------------------------------------------------------------------------
    | Adresse publique du site
    |--------------------------------------------------------------------------
    |
    | Sert aux liens envoyés par courriel (réinitialisation du mot de passe).
    | Elle pointe vers l'application Flutter, pas vers l'API.
    |
    */

    'site_url' => env('SITE_URL', 'https://ivoirepedia.alwaysdata.net'),

];
