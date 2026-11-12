<?php

/**
 * Compléments sourcés des articles déjà publiés.
 *
 * Deux natures de données, toutes deux vérifiées le 11 novembre 2026 :
 *  - `infobox` : effectifs du RGPH 2021 pour les villes (population communale,
 *    sauf Abidjan et Yamoussoukro, districts autonomes) ;
 *  - `references` : documents institutionnels qui documentent réellement le
 *    sujet — fiche UNESCO du bien, élément du patrimoine immatériel, site de
 *    l'institution, base statistique.
 *
 * On n'ajoute pas de référence « de principe » : un article sans source
 * vérifiable reste sans référence plutôt que d'en recevoir une qui ne dit rien.
 */
return [

    // --- Villes : effectifs communaux du RGPH 2021 -----------------------
    'abidjan' => [
        'infobox' => ['population' => 6321017, 'populationYear' => 2021],
        'references' => [
            [
                'kind' => 'REPORT',
                'authors' => 'ANStat (ex-INS)',
                'title' => 'Recensement général de la population et de l’habitat (RGPH) 2021 — résultats globaux définitifs',
                'publisher' => 'Ministère de l’Économie, du Plan et du Développement',
                'year' => 2022,
                'url' => 'https://plan.gouv.ci/uploads/publications/RGPH2021-RESULTATS-GLOBAUX-VF.pdf',
            ],
        ],
    ],

    'yamoussoukro' => [
        'infobox' => ['population' => 422072, 'populationYear' => 2021],
        'references' => [
            [
                'kind' => 'REPORT',
                'authors' => 'ANStat (ex-INS)',
                'title' => 'Recensement général de la population et de l’habitat (RGPH) 2021 — résultats globaux définitifs',
                'publisher' => 'Ministère de l’Économie, du Plan et du Développement',
                'year' => 2022,
                'url' => 'https://plan.gouv.ci/uploads/publications/RGPH2021-RESULTATS-GLOBAUX-VF.pdf',
            ],
        ],
    ],

    'bouake' => [
        'infobox' => ['population' => 832371, 'populationYear' => 2021],
        'references' => [
            [
                'kind' => 'REPORT',
                'authors' => 'ANStat (ex-INS)',
                'title' => 'Recensement général de la population et de l’habitat (RGPH) 2021 — résultats globaux définitifs',
                'publisher' => 'Ministère de l’Économie, du Plan et du Développement',
                'year' => 2022,
                'url' => 'https://plan.gouv.ci/uploads/publications/RGPH2021-RESULTATS-GLOBAUX-VF.pdf',
            ],
        ],
    ],

    'korhogo' => [
        'infobox' => ['population' => 440926, 'populationYear' => 2021],
        'references' => [
            [
                'kind' => 'REPORT',
                'authors' => 'ANStat (ex-INS)',
                'title' => 'Recensement général de la population et de l’habitat (RGPH) 2021 — résultats globaux définitifs',
                'publisher' => 'Ministère de l’Économie, du Plan et du Développement',
                'year' => 2022,
                'url' => 'https://plan.gouv.ci/uploads/publications/RGPH2021-RESULTATS-GLOBAUX-VF.pdf',
            ],
        ],
    ],

    'man' => [
        'infobox' => ['population' => 241969, 'populationYear' => 2021],
        'references' => [
            [
                'kind' => 'REPORT',
                'authors' => 'ANStat (ex-INS)',
                'title' => 'Recensement général de la population et de l’habitat (RGPH) 2021 — résultats globaux définitifs',
                'publisher' => 'Ministère de l’Économie, du Plan et du Développement',
                'year' => 2022,
                'url' => 'https://plan.gouv.ci/uploads/publications/RGPH2021-RESULTATS-GLOBAUX-VF.pdf',
            ],
        ],
    ],

    'san-pedro' => [
        'infobox' => ['population' => 390654, 'populationYear' => 2021],
        'references' => [
            [
                'kind' => 'REPORT',
                'authors' => 'ANStat (ex-INS)',
                'title' => 'Recensement général de la population et de l’habitat (RGPH) 2021 — résultats globaux définitifs',
                'publisher' => 'Ministère de l’Économie, du Plan et du Développement',
                'year' => 2022,
                'url' => 'https://plan.gouv.ci/uploads/publications/RGPH2021-RESULTATS-GLOBAUX-VF.pdf',
            ],
        ],
    ],

    // --- Patrimoine mondial et immatériel --------------------------------
    'parc-national-de-la-comoe' => [
        'references' => [
            [
                'kind' => 'WEB',
                'authors' => 'UNESCO',
                'title' => 'Parc national de la Comoé — liste du patrimoine mondial',
                'publisher' => 'Centre du patrimoine mondial',
                'year' => 1983,
                'url' => 'https://whc.unesco.org/fr/list/227',
            ],
            [
                'kind' => 'WEB',
                'authors' => 'UNESCO',
                'title' => 'État partie : Côte d’Ivoire — patrimoine mondial',
                'publisher' => 'Centre du patrimoine mondial',
                'year' => 2026,
                'url' => 'https://whc.unesco.org/fr/etatsparties/ci',
            ],
        ],
    ],

    'parc-national-de-tai' => [
        'references' => [
            [
                'kind' => 'WEB',
                'authors' => 'UNESCO',
                'title' => 'Parc national de Taï — liste du patrimoine mondial',
                'publisher' => 'Centre du patrimoine mondial',
                'year' => 1982,
                'url' => 'https://whc.unesco.org/fr/list/195',
            ],
        ],
    ],

    'grand-bassam' => [
        'references' => [
            [
                'kind' => 'WEB',
                'authors' => 'UNESCO',
                'title' => 'Ville historique de Grand-Bassam — liste du patrimoine mondial',
                'publisher' => 'Centre du patrimoine mondial',
                'year' => 2012,
                'url' => 'https://whc.unesco.org/fr/list/1322',
            ],
            [
                'kind' => 'REPORT',
                'authors' => 'ANStat (ex-INS)',
                'title' => 'Recensement général de la population et de l’habitat (RGPH) 2021 — résultats globaux définitifs',
                'publisher' => 'Ministère de l’Économie, du Plan et du Développement',
                'year' => 2022,
                'url' => 'https://plan.gouv.ci/uploads/publications/RGPH2021-RESULTATS-GLOBAUX-VF.pdf',
            ],
        ],
    ],

    'le-zaouli' => [
        'references' => [
            [
                'kind' => 'WEB',
                'authors' => 'UNESCO',
                'title' => 'Zaouli, musique et danse populaires des communautés gouro de Côte d’Ivoire',
                'publisher' => 'Patrimoine culturel immatériel',
                'year' => 2017,
                'url' => 'https://ich.unesco.org/en/RL/zaouli-popular-music-and-dance-of-the-guro-communities-in-cote-d-ivoire-01255',
            ],
        ],
    ],

    'attieke' => [
        'references' => [
            [
                'kind' => 'WEB',
                'authors' => 'UNESCO',
                'title' => 'Les savoir-faire liés à la fabrication de l’attiéké en Côte d’Ivoire',
                'publisher' => 'Patrimoine culturel immatériel',
                'year' => 2024,
                'url' => 'https://ich.unesco.org/fr/RL/les-savoir-faire-lies-a-la-fabrication-de-l-attieke-en-cote-d-ivoire-02086',
            ],
        ],
    ],

    // --- Institutions ----------------------------------------------------
    'assemblee-nationale' => [
        'references' => [
            [
                'kind' => 'WEB',
                'authors' => null,
                'title' => 'Assemblée nationale de Côte d’Ivoire — site officiel',
                'publisher' => 'Assemblée nationale',
                'year' => 2026,
                'url' => 'https://assnat.ci/',
            ],
        ],
    ],

    'senat' => [
        'references' => [
            [
                'kind' => 'WEB',
                'authors' => null,
                'title' => 'Sénat de Côte d’Ivoire — site officiel',
                'publisher' => 'Sénat',
                'year' => 2026,
                'url' => 'https://senat.ci/',
            ],
        ],
    ],

    'conseil-constitutionnel' => [
        'references' => [
            [
                'kind' => 'WEB',
                'authors' => null,
                'title' => 'Conseil constitutionnel de Côte d’Ivoire — site officiel',
                'publisher' => 'Conseil constitutionnel',
                'year' => 2026,
                'url' => 'https://www.conseil-constitutionnel.ci/',
            ],
        ],
    ],

    'president-de-la-republique' => [
        'references' => [
            [
                'kind' => 'WEB',
                'authors' => null,
                'title' => 'Présidence de la République de Côte d’Ivoire',
                'publisher' => 'Présidence de la République',
                'year' => 2026,
                'url' => 'https://www.presidence.ci/',
            ],
        ],
    ],

    'constitution-ivoirienne-de-2016' => [
        'references' => [
            [
                'kind' => 'WEB',
                'authors' => null,
                'title' => 'La Constitution — textes constitutionnels de Côte d’Ivoire',
                'publisher' => 'Présidence de la République',
                'year' => 2016,
                'url' => 'https://www.presidence.ci/la-cote-divoire/la-constitution',
            ],
        ],
    ],

    // --- Économie --------------------------------------------------------
    'le-cacao-en-cote-d-ivoire' => [
        'references' => [
            [
                'kind' => 'DATA',
                'authors' => 'FAO',
                'title' => 'FAOSTAT — production et commerce du cacao (Côte d’Ivoire)',
                'publisher' => 'Organisation des Nations unies pour l’alimentation et l’agriculture',
                'year' => 2026,
                'url' => 'https://www.fao.org/faostat/fr/#data/QCL',
            ],
        ],
    ],

    'l-anacarde' => [
        'references' => [
            [
                'kind' => 'DATA',
                'authors' => 'FAO',
                'title' => 'FAOSTAT — production de noix de cajou (Côte d’Ivoire)',
                'publisher' => 'Organisation des Nations unies pour l’alimentation et l’agriculture',
                'year' => 2026,
                'url' => 'https://www.fao.org/faostat/fr/#data/QCL',
            ],
        ],
    ],

    'l-hevea' => [
        'references' => [
            [
                'kind' => 'DATA',
                'authors' => 'FAO',
                'title' => 'FAOSTAT — production de caoutchouc naturel (Côte d’Ivoire)',
                'publisher' => 'Organisation des Nations unies pour l’alimentation et l’agriculture',
                'year' => 2026,
                'url' => 'https://www.fao.org/faostat/fr/#data/QCL',
            ],
        ],
    ],

    'la-brvm' => [
        'references' => [
            [
                'kind' => 'WEB',
                'authors' => null,
                'title' => 'Rapports des sociétés cotées',
                'publisher' => 'Bourse régionale des valeurs mobilières (BRVM)',
                'year' => 2026,
                'url' => 'https://www.brvm.org/fr/rapports-societes-cotees',
            ],
        ],
    ],

    'le-port-d-abidjan' => [
        'references' => [
            [
                'kind' => 'WEB',
                'authors' => null,
                'title' => 'Le port d’Abidjan — chiffres clés et rapports d’activité',
                'publisher' => 'Port autonome d’Abidjan',
                'year' => 2026,
                'url' => 'https://portabidjan.ci/',
            ],
        ],
    ],

    // --- Histoire --------------------------------------------------------
    'crise-politique-de-2002-2011' => [
        'references' => [
            [
                'kind' => 'DATA',
                'authors' => 'Uppsala Conflict Data Program',
                'title' => 'UCDP — base de données des conflits armés (Côte d’Ivoire)',
                'publisher' => 'Université d’Uppsala',
                'year' => 2026,
                'url' => 'https://ucdp.uu.se/',
            ],
        ],
    ],
];
