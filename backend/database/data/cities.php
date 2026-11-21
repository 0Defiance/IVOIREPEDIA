<?php

/**
 * Série « Villes de Côte d'Ivoire » : les fiches des villes du répertoire
 * public (RGPH 2021) qui n'avaient pas encore d'article.
 *
 * Chaque entrée ne retient que des éléments vérifiables : la position de la
 * ville dans le pays, son statut administratif (chef-lieu de région ou de
 * département) et l'effectif communal du recensement de 2021 (ANStat). Ce qui
 * relève de l'histoire, de l'économie, du peuplement ou des pratiques
 * culturelles est signalé comme non détaillé plutôt qu'affirmé sans source.
 *
 * Les six plus grandes villes (Abidjan, Yamoussoukro, Bouaké, Korhogo, Man,
 * San-Pédro) ont déjà leur article dans PublicContentSeeder.
 */
return [

    'daloa' => [
        'name' => 'Daloa',
        'population' => 421879,
        'summary' => 'Chef-lieu du Haut-Sassandra, Daloa est une ville du centre-ouest ivoirien.',
        'blocks' => [
            ['p', "Daloa se trouve au centre-ouest de la Côte d'Ivoire. La ville est le chef-lieu de la région du Haut-Sassandra."],
            ['h2', 'Situation'],
            ['p', 'La ville occupe le centre-ouest du pays. Ses liaisons routières et sa place dans les échanges régionaux ne sont pas détaillées ici, faute de source officielle vérifiée.'],
            ['h2', 'Histoire et économie'],
            ['p', "L'histoire de la ville, son peuplement et l'économie de sa région ne sont pas repris dans cette fiche, faute de source officielle vérifiée."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 421 879 habitants (RGPH 2021, ANStat).'],
            ['p', "La répartition par sexe, par âge et par quartier n'est pas reprise dans cette fiche."],
        ],
    ],

    'divo' => [
        'name' => 'Divo',
        'population' => 294559,
        'summary' => 'Chef-lieu du Lôh-Djiboua, Divo est une ville du sud ivoirien.',
        'blocks' => [
            ['p', 'Divo se trouve au sud de la Côte d\'Ivoire. La ville est le chef-lieu de la région du Lôh-Djiboua.'],
            ['h2', 'Situation'],
            ['p', 'La ville occupe le sud du pays. Ses liaisons routières ne sont pas détaillées ici, faute de source officielle vérifiée.'],
            ['h2', 'Histoire et économie'],
            ['p', "L'histoire de la ville et l'économie de sa région ne sont pas reprises dans cette fiche, faute de source officielle vérifiée."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 y compte 294 559 habitants (RGPH 2021, ANStat).'],
            ['p', "La répartition par sexe, par âge et par quartier n'est pas reprise dans cette fiche."],
        ],
    ],

    'gagnoa' => [
        'name' => 'Gagnoa',
        'population' => 277044,
        'summary' => 'Chef-lieu du Gôh, Gagnoa est une ville du centre-ouest ivoirien.',
        'blocks' => [
            ['p', "Gagnoa se trouve au centre-ouest de la Côte d'Ivoire. La ville est le chef-lieu de la région du Gôh."],
            ['h2', 'Situation'],
            ['p', 'La ville occupe le centre-ouest du pays. Ses liaisons routières ne sont pas détaillées ici, faute de source officielle vérifiée.'],
            ['h2', 'Histoire et économie'],
            ['p', "L'histoire de la ville, son peuplement et l'économie de sa région ne sont pas repris dans cette fiche, faute de source officielle vérifiée."],
            ['h2', 'Démographie'],
            ['p', 'Au recensement de 2021, Gagnoa compte 277 044 habitants (RGPH 2021, ANStat).'],
            ['p', "La répartition par sexe, par âge et par quartier n'est pas reprise dans cette fiche."],
        ],
    ],

    'soubre' => [
        'name' => 'Soubré',
        'population' => 272773,
        'summary' => 'Chef-lieu de la Nawa, Soubré est une ville du sud-ouest ivoirien, sur le Sassandra.',
        'blocks' => [
            ['p', "Soubré se trouve au sud-ouest de la Côte d'Ivoire, sur le Sassandra. La ville est le chef-lieu de la région de la Nawa."],
            ['h2', 'Situation'],
            ['p', 'La ville occupe le sud-ouest du pays, sur le fleuve Sassandra. Ses liaisons routières ne sont pas détaillées ici, faute de source officielle vérifiée.'],
            ['h2', 'Le barrage'],
            ['p', 'Le barrage hydroélectrique de Soubré est un ouvrage sur le Sassandra. Sa date de mise en service et sa puissance ne sont pas reprises ici, faute de source officielle vérifiée ; ses effets sur la ville ne sont pas détaillés.'],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 272 773 habitants (RGPH 2021, ANStat).'],
            ['p', "La répartition par sexe, par âge et par quartier n'est pas reprise dans cette fiche."],
        ],
    ],

    'duekoue' => [
        'name' => 'Duékoué',
        'population' => 220953,
        'summary' => "Chef-lieu du Guémon, Duékoué est une ville de l'ouest ivoirien.",
        'blocks' => [
            ['p', "Duékoué se trouve à l'ouest de la Côte d'Ivoire. La ville est le chef-lieu de la région du Guémon."],
            ['h2', 'Situation'],
            ['p', "La ville occupe l'ouest du pays. Ses liaisons routières ne sont pas détaillées ici, faute de source officielle vérifiée."],
            ['h2', 'Histoire et économie'],
            ['p', "L'histoire récente de la ville, son peuplement et l'économie de sa région ne sont pas repris dans cette fiche, faute de source officielle vérifiée."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 220 953 habitants (RGPH 2021, ANStat).'],
            ['p', "La répartition par sexe, par âge et par quartier n'est pas reprise dans cette fiche."],
        ],
    ],

    'bouafle' => [
        'name' => 'Bouaflé',
        'population' => 213967,
        'summary' => 'Chef-lieu de la Marahoué, Bouaflé est une ville du centre-ouest ivoirien.',
        'blocks' => [
            ['p', "Bouaflé se trouve au centre-ouest de la Côte d'Ivoire. La ville est le chef-lieu de la région de la Marahoué."],
            ['h2', 'Situation'],
            ['p', 'La ville occupe le centre-ouest du pays. Ses liaisons routières ne sont pas détaillées ici, faute de source officielle vérifiée.'],
            ['h2', 'Histoire et économie'],
            ['p', "L'histoire de la ville, les pratiques sociales de la région et les cultures de ses campagnes ne sont pas reprises dans cette fiche, faute de source officielle vérifiée."],
            ['h2', 'Démographie'],
            ['p', 'Au recensement de 2021, Bouaflé compte 213 967 habitants (RGPH 2021, ANStat).'],
            ['p', "La répartition par sexe, par âge et par quartier n'est pas reprise dans cette fiche."],
        ],
    ],

    'guiglo' => [
        'name' => 'Guiglo',
        'population' => 171454,
        'summary' => "Chef-lieu de la Cavally, Guiglo est une ville de l'ouest ivoirien.",
        'blocks' => [
            ['p', "Guiglo se trouve à l'ouest de la Côte d'Ivoire. La ville est le chef-lieu de la région de la Cavally."],
            ['h2', 'Situation'],
            ['p', "La ville occupe l'ouest du pays. Le commerce transfrontalier et ses liaisons routières ne sont pas détaillés ici, faute de source officielle vérifiée."],
            ['h2', 'Histoire et économie'],
            ['p', "L'histoire de la ville, son peuplement et l'économie de sa région ne sont pas repris dans cette fiche, faute de source officielle vérifiée."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 171 454 habitants (RGPH 2021, ANStat).'],
            ['p', "La répartition par sexe, par âge et par quartier n'est pas reprise dans cette fiche."],
        ],
    ],

    'lakota' => [
        'name' => 'Lakota',
        'population' => 169330,
        'summary' => 'Chef-lieu du département de Lakota, dans le Lôh-Djiboua, Lakota est une ville du sud ivoirien.',
        'blocks' => [
            ['p', 'Lakota se trouve au sud de la Côte d\'Ivoire. La ville est le chef-lieu du département de Lakota, dans la région du Lôh-Djiboua.'],
            ['h2', 'Situation'],
            ['p', 'La ville occupe le sud du pays. Ses liaisons routières ne sont pas détaillées ici, faute de source officielle vérifiée.'],
            ['h2', 'Histoire et économie'],
            ['p', "L'histoire de la ville, les pratiques sociales de la région et les cultures de ses campagnes ne sont pas reprises dans cette fiche, faute de source officielle vérifiée."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 169 330 habitants (RGPH 2021, ANStat).'],
            ['p', "La répartition par sexe, par âge et par quartier n'est pas reprise dans cette fiche."],
        ],
    ],

    'abengourou' => [
        'name' => 'Abengourou',
        'population' => 164424,
        'summary' => "Chef-lieu de l'Indénié-Djuablin, Abengourou est une ville de l'est ivoirien.",
        'blocks' => [
            ['p', "Abengourou se trouve à l'est de la Côte d'Ivoire. La ville est le chef-lieu de la région de l'Indénié-Djuablin."],
            ['h2', 'Situation'],
            ['p', "La ville occupe l'est du pays. Ses liaisons routières ne sont pas détaillées ici, faute de source officielle vérifiée."],
            ['h2', 'Histoire et économie'],
            ['p', "L'histoire de la région, ses langues et l'économie de la ville ne sont pas reprises dans cette fiche, faute de source officielle vérifiée."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 164 424 habitants (RGPH 2021, ANStat).'],
            ['p', "La répartition par sexe, par âge et par quartier n'est pas reprise dans cette fiche."],
        ],
    ],

    'ferkessedougou' => [
        'name' => 'Ferkessédougou',
        'population' => 160267,
        'summary' => 'Chef-lieu du Tchologo, Ferkessédougou est une ville du nord ivoirien.',
        'blocks' => [
            ['p', 'Ferkessédougou se trouve au nord de la Côte d\'Ivoire. La ville est le chef-lieu de la région du Tchologo.'],
            ['h2', 'Situation'],
            ['p', 'La ville occupe le nord du pays. Ses liaisons routières ne sont pas détaillées ici, faute de source officielle vérifiée.'],
            ['h2', 'Histoire et économie'],
            ['p', "L'économie de la ville, les cultures et l'élevage de la région ne sont pas repris dans cette fiche, faute de source officielle vérifiée."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 160 267 habitants (RGPH 2021, ANStat).'],
            ['p', "La répartition par sexe, par âge et par quartier n'est pas reprise dans cette fiche."],
        ],
    ],

    'adzope' => [
        'name' => 'Adzopé',
        'population' => 156488,
        'summary' => 'Chef-lieu de La Mé, Adzopé est une ville du sud-est ivoirien.',
        'blocks' => [
            ['p', 'Adzopé se trouve au sud-est de la Côte d\'Ivoire. La ville est le chef-lieu de la région de La Mé.'],
            ['h2', 'Situation'],
            ['p', 'La ville occupe le sud-est du pays. Ses liaisons routières ne sont pas détaillées ici, faute de source officielle vérifiée.'],
            ['h2', 'Histoire et économie'],
            ['p', "Les groupes de population de la région, son histoire et l'économie de la ville ne sont pas repris dans cette fiche, faute de source officielle vérifiée."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 156 488 habitants (RGPH 2021, ANStat).'],
            ['p', "La répartition par sexe, par âge et par quartier n'est pas reprise dans cette fiche."],
        ],
    ],

    'meagui' => [
        'name' => 'Méagui',
        'population' => 153483,
        'summary' => 'Méagui est une ville de la Nawa, dans le sud-ouest ivoirien.',
        'blocks' => [
            ['p', 'Méagui se trouve au sud-ouest de la Côte d\'Ivoire, dans la région de la Nawa.'],
            ['h2', 'Situation'],
            ['p', 'La ville occupe le sud-ouest du pays. Ses liaisons routières ne sont pas détaillées ici, faute de source officielle vérifiée.'],
            ['h2', 'Histoire et économie'],
            ['p', "L'histoire de la ville, son économie et les cultures de la région ne sont pas reprises dans cette fiche, faute de source officielle vérifiée."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 153 483 habitants (RGPH 2021, ANStat).'],
            ['p', "La répartition par sexe, par âge et par quartier n'est pas reprise dans cette fiche."],
        ],
    ],

    'bondoukou' => [
        'name' => 'Bondoukou',
        'population' => 141568,
        'summary' => "Chef-lieu du Gontougo, Bondoukou est une ville de l'est ivoirien.",
        'blocks' => [
            ['p', "Bondoukou se trouve à l'est de la Côte d'Ivoire, près de la frontière ghanéenne. La ville est le chef-lieu de la région du Gontougo."],
            ['h2', 'Situation'],
            ['p', "La ville occupe l'est du pays, à proximité du Ghana. Ses liaisons routières ne sont pas détaillées ici, faute de source officielle vérifiée."],
            ['h2', 'Histoire et économie'],
            ['p', "L'histoire de la ville, son patrimoine, ses quartiers et son économie ne sont pas repris dans cette fiche, faute de source officielle vérifiée."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 141 568 habitants (RGPH 2021, ANStat).'],
            ['p', "La répartition par sexe, par âge et par quartier n'est pas reprise dans cette fiche."],
        ],
    ],

    'dabou' => [
        'name' => 'Dabou',
        'population' => 138083,
        'summary' => 'Chef-lieu des Grands-Ponts, Dabou est une ville du sud ivoirien.',
        'blocks' => [
            ['p', "Dabou se trouve au sud de la Côte d'Ivoire, à l'ouest d'Abidjan. La ville est le chef-lieu de la région des Grands-Ponts."],
            ['h2', 'Situation'],
            ['p', "La ville occupe le sud du pays, à l'ouest d'Abidjan. Ses liaisons routières ne sont pas détaillées ici, faute de source officielle vérifiée."],
            ['h2', 'Histoire et économie'],
            ['p', "Les activités liées à la lagune, le tourisme et l'économie agricole de la ville ne sont pas repris dans cette fiche, faute de source officielle vérifiée."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 138 083 habitants (RGPH 2021, ANStat).'],
            ['p', "La répartition par sexe, par âge et par quartier n'est pas reprise dans cette fiche."],
        ],
    ],

    'sinfra' => [
        'name' => 'Sinfra',
        'population' => 137210,
        'summary' => 'Chef-lieu du département de Sinfra, dans la Marahoué, Sinfra est une ville du centre-ouest ivoirien.',
        'blocks' => [
            ['p', 'Sinfra se trouve au centre-ouest de la Côte d\'Ivoire. La ville est le chef-lieu du département de Sinfra, dans la région de la Marahoué.'],
            ['h2', 'Situation'],
            ['p', 'La ville occupe le centre-ouest du pays. Ses liaisons routières ne sont pas détaillées ici, faute de source officielle vérifiée.'],
            ['h2', 'Histoire et économie'],
            ['p', "L'économie de la ville, les cultures de la région et les pratiques sociales de ses habitants ne sont pas repris dans cette fiche, faute de source officielle vérifiée."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 137 210 habitants (RGPH 2021, ANStat).'],
            ['p', "La répartition par sexe, par âge et par quartier n'est pas reprise dans cette fiche."],
        ],
    ],

    'agboville' => [
        'name' => 'Agboville',
        'population' => 135082,
        'summary' => "Chef-lieu de l'Agnéby-Tiassa, Agboville est une ville du sud-est ivoirien.",
        'blocks' => [
            ['p', "Agboville se trouve au sud-est de la Côte d'Ivoire. La ville est le chef-lieu de la région de l'Agnéby-Tiassa."],
            ['h2', 'Situation'],
            ['p', 'La ville occupe le sud-est du pays. Ses liaisons routières et ferroviaires ne sont pas détaillées ici, faute de source officielle vérifiée.'],
            ['h2', 'Histoire et économie'],
            ['p', "Les groupes de population de la région, son histoire et l'économie de la ville ne sont pas repris dans cette fiche, faute de source officielle vérifiée."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 135 082 habitants (RGPH 2021, ANStat).'],
            ['p', "La répartition par sexe, par âge et par quartier n'est pas reprise dans cette fiche."],
        ],
    ],

    'vavoua' => [
        'name' => 'Vavoua',
        'population' => 132528,
        'summary' => 'Chef-lieu du département de Vavoua, dans le Haut-Sassandra, Vavoua est une ville du centre-ouest ivoirien.',
        'blocks' => [
            ['p', 'Vavoua se trouve au centre-ouest de la Côte d\'Ivoire. La ville est le chef-lieu du département de Vavoua, dans la région du Haut-Sassandra.'],
            ['h2', 'Situation'],
            ['p', 'La ville occupe le centre-ouest du pays. Ses liaisons routières ne sont pas détaillées ici, faute de source officielle vérifiée.'],
            ['h2', 'Histoire et économie'],
            ['p', "L'économie de la région, les cultures de ses campagnes et la composition de la population ne sont pas reprises dans cette fiche, faute de source officielle vérifiée."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 132 528 habitants (RGPH 2021, ANStat).'],
            ['p', "La répartition par sexe, par âge et par quartier n'est pas reprise dans cette fiche."],
        ],
    ],

    'danane' => [
        'name' => 'Danané',
        'population' => 131586,
        'summary' => "Chef-lieu du département de Danané, dans le Tonkpi, Danané est une ville de l'ouest ivoirien, proche du Liberia et de la Guinée.",
        'blocks' => [
            ['p', "Danané se trouve à l'ouest de la Côte d'Ivoire, près des frontières du Liberia et de la Guinée. La ville est le chef-lieu du département de Danané, dans la région du Tonkpi."],
            ['h2', 'Situation'],
            ['p', "La ville occupe l'ouest du pays, près du Liberia et de la Guinée. Son relief et ses liaisons routières ne sont pas détaillés ici, faute de source officielle vérifiée."],
            ['h2', 'Histoire et économie'],
            ['p', "L'histoire de la ville, les pratiques culturelles de la région et son économie ne sont pas reprises dans cette fiche, faute de source officielle vérifiée."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 131 586 habitants (RGPH 2021, ANStat).'],
            ['p', "La répartition par sexe, par âge et par quartier n'est pas reprise dans cette fiche."],
        ],
    ],

    'oume' => [
        'name' => 'Oumé',
        'population' => 127153,
        'summary' => "Chef-lieu du département d'Oumé, dans le Gôh, Oumé est une ville du centre-ouest ivoirien.",
        'blocks' => [
            ['p', 'Oumé se trouve au centre-ouest de la Côte d\'Ivoire. La ville est le chef-lieu du département d\'Oumé, dans la région du Gôh.'],
            ['h2', 'Situation'],
            ['p', 'La ville occupe le centre-ouest du pays. Ses liaisons routières ne sont pas détaillées ici, faute de source officielle vérifiée.'],
            ['h2', 'Histoire et économie'],
            ['p', "L'économie de la ville, les cultures de la région et les pratiques sociales de ses habitants ne sont pas repris dans cette fiche, faute de source officielle vérifiée."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 127 153 habitants (RGPH 2021, ANStat).'],
            ['p', "La répartition par sexe, par âge et par quartier n'est pas reprise dans cette fiche."],
        ],
    ],

    'issia' => [
        'name' => 'Issia',
        'population' => 126252,
        'summary' => "Chef-lieu du département d'Issia, dans le Haut-Sassandra, Issia est une ville du centre-ouest ivoirien.",
        'blocks' => [
            ['p', 'Issia se trouve à l\'ouest de la Côte d\'Ivoire. La ville est le chef-lieu du département d\'Issia, dans la région du Haut-Sassandra.'],
            ['h2', 'Situation'],
            ['p', "La ville occupe l'ouest du pays. Ses liaisons routières ne sont pas détaillées ici, faute de source officielle vérifiée."],
            ['h2', 'Histoire et économie'],
            ['p', 'Les plantations de la région, le rôle de la ville dans la collecte et ses équipements ne sont pas repris dans cette fiche, faute de source officielle vérifiée.'],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 126 252 habitants (RGPH 2021, ANStat).'],
            ['p', "La répartition par sexe, par âge et par quartier n'est pas reprise dans cette fiche."],
        ],
    ],

    'blolequin' => [
        'name' => 'Bloléquin',
        'population' => 123133,
        'summary' => "Chef-lieu du département de Bloléquin, dans la Cavally, Bloléquin est une ville de l'ouest ivoirien, proche du Liberia.",
        'blocks' => [
            ['p', "Bloléquin se trouve à l'ouest de la Côte d'Ivoire, près de la frontière libérienne. La ville est le chef-lieu du département de Bloléquin, dans la région de la Cavally."],
            ['h2', 'Situation'],
            ['p', "La ville occupe l'ouest du pays, près du Liberia. Ses liaisons routières ne sont pas détaillées ici, faute de source officielle vérifiée."],
            ['h2', 'Histoire et économie'],
            ['p', "Les plantations, les activités commerciales et l'histoire récente de la région ne sont pas reprises dans cette fiche, faute de source officielle vérifiée."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 123 133 habitants (RGPH 2021, ANStat).'],
            ['p', "La répartition par sexe, par âge et par quartier n'est pas reprise dans cette fiche."],
        ],
    ],

    'bonon' => [
        'name' => 'Bonon',
        'population' => 116871,
        'summary' => 'Chef-lieu du département de Bonon, dans la Marahoué, Bonon est une ville du centre-ouest ivoirien.',
        'blocks' => [
            ['p', 'Bonon se trouve au centre-ouest de la Côte d\'Ivoire. La ville est le chef-lieu du département de Bonon, dans la région de la Marahoué.'],
            ['h2', 'Situation'],
            ['p', 'La ville occupe le centre-ouest du pays. Ses liaisons routières ne sont pas détaillées ici, faute de source officielle vérifiée.'],
            ['h2', 'Histoire et économie'],
            ['p', 'Les plantations, le marché et les équipements de la ville ne sont pas repris dans cette fiche, faute de source officielle vérifiée.'],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 116 871 habitants (RGPH 2021, ANStat).'],
            ['p', "La répartition par sexe, par âge et par quartier n'est pas reprise dans cette fiche."],
        ],
    ],

    'zouan-hounien' => [
        'name' => 'Zouan-Hounien',
        'population' => 111099,
        'summary' => "Chef-lieu du département de Zouan-Hounien, dans le Tonkpi, Zouan-Hounien est une ville de l'ouest ivoirien, à la frontière libérienne.",
        'blocks' => [
            ['p', "Zouan-Hounien se trouve à l'ouest de la Côte d'Ivoire, à la frontière libérienne. La ville est le chef-lieu du département de Zouan-Hounien, dans la région du Tonkpi."],
            ['h2', 'Situation'],
            ['p', "La ville occupe l'ouest du pays, contre la frontière libérienne. Ses liaisons routières ne sont pas détaillées ici, faute de source officielle vérifiée."],
            ['h2', 'Histoire et économie'],
            ['p', "L'exploitation aurifère, les plantations et les activités commerciales de la ville ne sont pas reprises dans cette fiche, faute de source officielle vérifiée."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 111 099 habitants (RGPH 2021, ANStat).'],
            ['p', "La répartition par sexe, par âge et par quartier n'est pas reprise dans cette fiche."],
        ],
    ],

    'seguela' => [
        'name' => 'Séguéla',
        'population' => 103980,
        'summary' => 'Chef-lieu du Worodougou, Séguéla est une ville du nord-ouest ivoirien.',
        'blocks' => [
            ['p', 'Séguéla se trouve au nord-ouest de la Côte d\'Ivoire. La ville est le chef-lieu de la région du Worodougou.'],
            ['h2', 'Situation'],
            ['p', 'La ville occupe le nord-ouest du pays. Ses liaisons routières ne sont pas détaillées ici, faute de source officielle vérifiée.'],
            ['h2', 'Histoire et économie'],
            ['p', 'Les populations de la région, son agriculture et son élevage ne sont pas décrits dans cette fiche, faute de source officielle vérifiée.'],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 103 980 habitants (RGPH 2021, ANStat).'],
            ['p', "La répartition par sexe, par âge et par quartier n'est pas reprise dans cette fiche."],
        ],
    ],

    'daoukro' => [
        'name' => 'Daoukro',
        'population' => 101136,
        'summary' => "Chef-lieu de l'Iffou, Daoukro est une ville du centre-est ivoirien.",
        'blocks' => [
            ['p', "Daoukro se trouve au centre-est de la Côte d'Ivoire. La ville est le chef-lieu de la région de l'Iffou."],
            ['h2', 'Situation'],
            ['p', 'La ville occupe le centre-est du pays. Ses liaisons routières ne sont pas détaillées ici, faute de source officielle vérifiée.'],
            ['h2', 'Histoire et économie'],
            ['p', 'Les groupes de population de la région, son agriculture et son histoire ne sont pas décrits dans cette fiche, faute de source officielle vérifiée.'],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 101 136 habitants (RGPH 2021, ANStat).'],
            ['p', "La répartition par sexe, par âge et par quartier n'est pas reprise dans cette fiche."],
        ],
    ],

    'aboisso' => [
        'name' => 'Aboisso',
        'population' => 100903,
        'summary' => 'Chef-lieu du Sud-Comoé, Aboisso est une ville du sud-est ivoirien, proche de la frontière ghanéenne.',
        'blocks' => [
            ['p', "Aboisso se trouve au sud-est de la Côte d'Ivoire, près de la frontière ghanéenne. La ville est le chef-lieu de la région du Sud-Comoé."],
            ['h2', 'Situation'],
            ['p', 'La ville occupe le sud-est du pays, près du Ghana. Ses liaisons routières ne sont pas détaillées ici, faute de source officielle vérifiée.'],
            ['h2', 'Histoire et économie'],
            ['p', "L'histoire de la région et l'économie de la ville ne sont pas détaillées dans cette fiche, faute de source officielle vérifiée."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 100 903 habitants (RGPH 2021, ANStat).'],
            ['p', "La répartition par sexe, par âge et par quartier n'est pas reprise dans cette fiche."],
        ],
    ],

    'buyo' => [
        'name' => 'Buyo',
        'population' => 100848,
        'summary' => 'Chef-lieu du département de Buyo, dans la Nawa, Buyo est une ville du sud-ouest ivoirien, sur le Sassandra.',
        'blocks' => [
            ['p', 'Buyo se trouve au sud-ouest de la Côte d\'Ivoire, sur le Sassandra. La ville est le chef-lieu du département de Buyo, dans la région de la Nawa.'],
            ['h2', 'Situation'],
            ['p', 'La ville occupe le sud-ouest du pays, sur le fleuve Sassandra. Ses liaisons routières ne sont pas détaillées ici, faute de source officielle vérifiée.'],
            ['h2', 'Le barrage'],
            ['p', 'Le barrage et le lac de Buyo ne sont pas décrits dans cette fiche : leur date de mise en service et les activités qui y sont liées ne sont pas reprises faute de source officielle vérifiée.'],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 100 848 habitants (RGPH 2021, ANStat).'],
            ['p', "La répartition par sexe, par âge et par quartier n'est pas reprise dans cette fiche."],
        ],
    ],

    'agnibilekrou' => [
        'name' => 'Agnibilékrou',
        'population' => 99501,
        'summary' => "Chef-lieu du département d'Agnibilékrou, dans l'Indénié-Djuablin, Agnibilékrou est une ville de l'est ivoirien, près du Ghana.",
        'blocks' => [
            ['p', "Agnibilékrou se trouve à l'est de la Côte d'Ivoire, près de la frontière ghanéenne. La ville est le chef-lieu du département d'Agnibilékrou, dans la région de l'Indénié-Djuablin."],
            ['h2', 'Situation'],
            ['p', "La ville occupe l'est du pays, près du Ghana. Ses liaisons routières ne sont pas détaillées ici, faute de source officielle vérifiée."],
            ['h2', 'Histoire et économie'],
            ['p', 'Le marché frontalier, les cultures de la région et les pratiques sociales de ses habitants ne sont pas décrits dans cette fiche, faute de source officielle vérifiée.'],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 99 501 habitants (RGPH 2021, ANStat).'],
            ['p', "La répartition par sexe, par âge et par quartier n'est pas reprise dans cette fiche."],
        ],
    ],

    'bouna' => [
        'name' => 'Bouna',
        'population' => 94883,
        'summary' => 'Chef-lieu du Bounkani, Bouna est une ville du nord-est ivoirien.',
        'blocks' => [
            ['p', "Bouna se trouve au nord-est de la Côte d'Ivoire. La ville est le chef-lieu de la région du Bounkani."],
            ['h2', 'Situation'],
            ['p', 'La ville occupe le nord-est du pays. Ses liaisons routières ne sont pas détaillées ici, faute de source officielle vérifiée.'],
            ['h2', 'Histoire et économie'],
            ['p', "L'histoire de la ville, ses échanges commerciaux et l'économie de la région ne sont pas détaillés dans cette fiche, faute de source officielle vérifiée."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 94 883 habitants (RGPH 2021, ANStat).'],
            ['p', "La répartition par sexe, par âge et par quartier n'est pas reprise dans cette fiche."],
        ],
    ],

    'boundiali' => [
        'name' => 'Boundiali',
        'population' => 92792,
        'summary' => 'Chef-lieu de la Bagoué, Boundiali est une ville du nord-ouest ivoirien.',
        'blocks' => [
            ['p', 'Boundiali se trouve au nord-ouest de la Côte d\'Ivoire. La ville est le chef-lieu de la région de la Bagoué.'],
            ['h2', 'Situation'],
            ['p', 'La ville occupe le nord-ouest du pays. Ses liaisons routières ne sont pas détaillées ici, faute de source officielle vérifiée.'],
            ['h2', 'Histoire et économie'],
            ['p', 'Les cultures de la région, son élevage et ses traditions ne sont pas détaillés dans cette fiche, faute de source officielle vérifiée.'],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 92 792 habitants (RGPH 2021, ANStat).'],
            ['p', "La répartition par sexe, par âge et par quartier n'est pas reprise dans cette fiche."],
        ],
    ],

    'tengrela' => [
        'name' => 'Tengréla',
        'population' => 92454,
        'summary' => 'Chef-lieu du département de Tengréla, dans la Bagoué, Tengréla est une ville du nord ivoirien, à la frontière malienne.',
        'blocks' => [
            ['p', 'Tengréla se trouve au nord de la Côte d\'Ivoire, à la frontière malienne. La ville est le chef-lieu du département de Tengréla, dans la région de la Bagoué.'],
            ['h2', 'Situation'],
            ['p', 'La ville occupe le nord du pays, contre la frontière malienne. Ses liaisons routières ne sont pas détaillées ici, faute de source officielle vérifiée.'],
            ['h2', 'Histoire et économie'],
            ['p', 'Les flux commerciaux, les cultures de la région et la composition de la population ne sont pas détaillés dans cette fiche, faute de source officielle vérifiée.'],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 92 454 habitants (RGPH 2021, ANStat).'],
            ['p', "La répartition par sexe, par âge et par quartier n'est pas reprise dans cette fiche."],
        ],
    ],

    'sikensi' => [
        'name' => 'Sikensi',
        'population' => 91032,
        'summary' => "Chef-lieu du département de Sikensi, dans l'Agnéby-Tiassa, Sikensi est une ville du sud ivoirien.",
        'blocks' => [
            ['p', "Sikensi se trouve au sud-est de la Côte d'Ivoire. La ville est le chef-lieu du département de Sikensi, dans la région de l'Agnéby-Tiassa."],
            ['h2', 'Situation'],
            ['p', 'La ville occupe le sud-est du pays. Ses liaisons routières ne sont pas détaillées ici, faute de source officielle vérifiée.'],
            ['h2', 'Histoire et économie'],
            ['p', 'Les pratiques culturelles de la région, ses cultures et les équipements de la ville ne sont pas décrits dans cette fiche, faute de source officielle vérifiée.'],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 91 032 habitants (RGPH 2021, ANStat).'],
            ['p', "La répartition par sexe, par âge et par quartier n'est pas reprise dans cette fiche."],
        ],
    ],

    'katiola' => [
        'name' => 'Katiola',
        'population' => 90641,
        'summary' => 'Chef-lieu du Hambol, Katiola est une ville du centre-nord ivoirien.',
        'blocks' => [
            ['p', 'Katiola se trouve au centre-nord de la Côte d\'Ivoire. La ville est le chef-lieu de la région du Hambol.'],
            ['h2', 'Situation'],
            ['p', 'La ville occupe le centre-nord du pays. Ses liaisons routières ne sont pas détaillées ici, faute de source officielle vérifiée.'],
            ['h2', 'Histoire et économie'],
            ['p', 'La poterie, les traditions de la région et son économie ne sont pas détaillées dans cette fiche, faute de source officielle vérifiée.'],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 90 641 habitants (RGPH 2021, ANStat).'],
            ['p', "La répartition par sexe, par âge et par quartier n'est pas reprise dans cette fiche."],
        ],
    ],

    'toumodi' => [
        'name' => 'Toumodi',
        'population' => 88580,
        'summary' => 'Chef-lieu du Bélier, Toumodi est une ville du centre ivoirien.',
        'blocks' => [
            ['p', 'Toumodi se trouve au centre de la Côte d\'Ivoire. La ville est le chef-lieu de la région du Bélier.'],
            ['h2', 'Situation'],
            ['p', 'La ville occupe le centre du pays. Ses liaisons routières ne sont pas détaillées ici, faute de source officielle vérifiée.'],
            ['h2', 'Histoire et économie'],
            ['p', 'Les groupes de population de la région, son agriculture et son histoire ne sont pas décrits dans cette fiche, faute de source officielle vérifiée.'],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 88 580 habitants (RGPH 2021, ANStat).'],
            ['p', "La répartition par sexe, par âge et par quartier n'est pas reprise dans cette fiche."],
        ],
    ],

];
