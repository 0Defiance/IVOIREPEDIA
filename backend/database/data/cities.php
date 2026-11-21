<?php

/**
 * Série « Villes de Côte d'Ivoire » : les fiches des villes du répertoire
 * public (RGPH 2021) qui n'avaient pas encore d'article.
 *
 * Trois sources portent le texte :
 * — les monographies régionales de l'ANStat (RGPH 2021, chapitre 11), pour les
 *   projections 2024 et 2025 du département et de la sous-préfecture ;
 * — le RGPH 2021 de l'ANStat, pour l'effectif communal ;
 * — la liste actuelle des départements de chaque région, telle que la donnent
 *   ces mêmes monographies.
 *
 * Les projections sont toujours annoncées comme telles : ce ne sont pas des
 * dénombrements, et elles portent sur la sous-préfecture, qui englobe la
 * commune sans se confondre avec elle.
 *
 * Aucune superficie, altitude, distance, activité économique ou donnée
 * culturelle n'est avancée sans source vérifiée : ces parties sont signalées
 * comme non détaillées.
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
            ['p', 'Daloa est le chef-lieu de la région du Haut-Sassandra, qui réunit les départements de Daloa, Issia, Vavoua et Zoukougbeu.'],
            ['h2', 'Situation'],
            ['p', 'La ville occupe le centre-ouest du pays, entre la zone forestière du sud et les savanes qui montent vers le nord.'],
            ['h2', 'Statut administratif'],
            ['p', 'Daloa cumule le siège de la région et celui du département du même nom, conformément à l\'annexe du décret de découpage de 2011.'],
            ['h2', 'Démographie'],
            ['p', 'Le recensement général de 2021 y a dénombré 421 879 habitants (RGPH 2021, ANStat).'],
            ['p', 'Les projections de l\'ANStat donnent 746 900 habitants au département de Daloa en 2024 et 759 433 en 2025 ; la sous-préfecture, qui englobe la commune, passerait de 446 420 à 453 672 habitants sur la même période. Ce sont des projections, non des dénombrements.'],
        ],
    ],

    'divo' => [
        'name' => 'Divo',
        'population' => 294559,
        'summary' => 'Chef-lieu du Lôh-Djiboua, Divo est une ville du sud ivoirien.',
        'blocks' => [
            ['p', 'Divo commande la région du Lôh-Djiboua, composée des départements de Divo, Lakota et Guitry.'],
            ['h2', 'Situation'],
            ['p', 'La ville se situe dans le sud du pays, dans la partie forestière qui descend vers le littoral.'],
            ['h2', 'Un chef-lieu de région'],
            ['p', "Le décret de 2011 fixe à Divo le chef-lieu régional et le siège du département, ce qui en fait le point d'ancrage administratif de tout l'espace Lôh-Djiboua."],
            ['h2', 'Démographie'],
            ['p', 'Au dernier recensement général, en 2021, la ville comptait 294 559 habitants (RGPH 2021, ANStat).'],
            ['p', 'Dans ses projections 2022-2041, l\'ANStat chiffre le département de Divo à 613 218 habitants en 2024, puis 626 833 en 2025. La sous-préfecture suit la même trajectoire : 316 276 puis 323 017 habitants. Il s\'agit de projections démographiques, établies à partir du RGPH 2021.'],
        ],
    ],

    'gagnoa' => [
        'name' => 'Gagnoa',
        'population' => 277044,
        'summary' => 'Chef-lieu du Gôh, Gagnoa est une ville du centre-ouest ivoirien.',
        'blocks' => [
            ['p', 'Gagnoa est la capitale administrative du Gôh, une région qui ne compte que deux départements : Gagnoa et Oumé.'],
            ['h2', 'Géographie'],
            ['p', 'La ville occupe le centre-ouest du pays, au cœur d\'une zone forestière.'],
            ['h2', 'Administration'],
            ['p', "Chef-lieu de région et de département, Gagnoa abrite les services déconcentrés de l'État pour le Gôh, selon l'annexe du décret n° 2011-263."],
            ['h2', 'Démographie'],
            ['p', 'La population communale s\'élevait à 277 044 habitants au recensement de 2021 (RGPH 2021, ANStat).'],
            ['p', 'Pour 2024 et 2025, la monographie régionale du Gôh avance 775 499 puis 792 253 habitants dans le département de Gagnoa, et 296 286 puis 302 432 dans la sous-préfecture du même nom. Ces chiffres sont des projections, pas des effectifs recensés.'],
        ],
    ],

    'soubre' => [
        'name' => 'Soubré',
        'population' => 272773,
        'summary' => 'Chef-lieu de la Nawa, Soubré est une ville du sud-ouest ivoirien, sur le Sassandra.',
        'blocks' => [
            ['p', 'Soubré est le chef-lieu de la Nawa, région du sud-ouest qui compte quatre départements : Soubré, Guéyo, Méagui et Buyo.'],
            ['h2', 'Le cadre géographique'],
            ['p', 'La ville est bâtie sur le Sassandra, le grand fleuve qui traverse le sud-ouest du pays.'],
            ['h2', 'Le barrage'],
            ['p', "Un barrage hydroélectrique barre le fleuve à hauteur de la ville. Sa puissance et sa date de mise en service ne sont pas reprises ici, faute de source officielle vérifiée, et ses effets sur l'urbanisation restent à documenter."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 272 773 habitants dans la commune (RGPH 2021, ANStat).'],
            ['p', 'La projection de l\'ANStat place le département de Soubré à 622 918 habitants en 2024 et 634 609 en 2025 ; la sous-préfecture, plus vaste que la commune, passerait de 287 346 à 292 281 habitants. Projections issues du RGPH 2021, à ne pas lire comme un décompte communal.'],
        ],
    ],

    'duekoue' => [
        'name' => 'Duékoué',
        'population' => 220953,
        'summary' => "Chef-lieu du Guémon, Duékoué est une ville de l'ouest ivoirien.",
        'blocks' => [
            ['p', "Duékoué est le chef-lieu du Guémon, région de l'ouest qui regroupe les départements de Duékoué, Bangolo, Facobly et Kouibly."],
            ['h2', 'Situation'],
            ['p', "La ville se trouve dans l'ouest du pays, sur les terres qui précèdent les montagnes de la frontière libérienne."],
            ['h2', 'Statut administratif'],
            ['p', "L'annexe du décret de 2011 attribue à Duékoué le chef-lieu de la région du Guémon et celui du département."],
            ['h2', 'Démographie'],
            ['p', 'Le RGPH de 2021 a recensé 220 953 habitants dans la commune (RGPH 2021, ANStat).'],
            ['p', 'Le département de Duékoué compterait 458 538 habitants en 2024 et 471 494 en 2025 selon l\'ANStat, la sous-préfecture 240 649 puis 247 362. Ce sont des projections, distinctes des effectifs du recensement de 2021.'],
        ],
    ],

    'bouafle' => [
        'name' => 'Bouaflé',
        'population' => 213967,
        'summary' => 'Chef-lieu de la Marahoué, Bouaflé est une ville du centre-ouest ivoirien.',
        'blocks' => [
            ['p', 'Bouaflé est le chef-lieu de la Marahoué, région qui réunit cinq départements : Bouaflé, Sinfra, Zuénoula, Bonon et Gohitafla.'],
            ['h2', 'Situation'],
            ['p', 'La ville occupe le centre-ouest du pays, dans une zone de transition entre forêt et savane.'],
            ['h2', 'Administration'],
            ['p', "Bouaflé concentre le siège de la région et du département, d'après l'annexe du décret n° 2011-263 du 28 septembre 2011."],
            ['h2', 'Démographie'],
            ['p', "Le recensement général de la population et de l'habitat de 2021 y compte 213 967 habitants (RGPH 2021, ANStat)."],
            ['p', 'Les projections 2024 et 2025 de l\'ANStat attribuent 321 835 puis 328 477 habitants au département de Bouaflé, et 228 798 puis 233 403 à la sous-préfecture. Il s\'agit de projections, non d\'un recensement.'],
        ],
    ],

    'guiglo' => [
        'name' => 'Guiglo',
        'population' => 171454,
        'summary' => "Chef-lieu de la Cavally, Guiglo est une ville de l'ouest ivoirien.",
        'blocks' => [
            ['p', 'Guiglo est le chef-lieu de la Cavally, région frontalière du Liberia qui compte quatre départements : Guiglo, Bloléquin, Toulépleu et Taï.'],
            ['h2', 'Géographie'],
            ['p', "La ville occupe l'ouest du pays, à l'entrée de la forêt qui mène vers la frontière libérienne."],
            ['h2', 'Un chef-lieu frontalier'],
            ['p', "Le décret de 2011 en fait le siège de la région et du département ; le commerce avec le Liberia n'est pas documenté dans cette fiche."],
            ['h2', 'Démographie'],
            ['p', 'La commune comptait 171 454 habitants lors du recensement de 2021 (RGPH 2021, ANStat).'],
            ['p', 'Les projections 2024 et 2025 du département et de la sous-préfecture ne sont pas disponibles pour la Cavally : seule la projection régionale est publiée à ce jour, soit 806 262 habitants en 2025, contre 708 241 au recensement de 2021.'],
        ],
    ],

    'lakota' => [
        'name' => 'Lakota',
        'population' => 169330,
        'summary' => 'Lakota est une ville du Lôh-Djiboua, dans le sud ivoirien.',
        'blocks' => [
            ['p', 'Lakota appartient à la région du Lôh-Djiboua, dont les départements sont Divo, Lakota et Guitry, et dont Divo est le chef-lieu.'],
            ['h2', 'Situation'],
            ['p', 'La ville se trouve au sud du pays, à l\'ouest de Divo, dans le domaine forestier.'],
            ['h2', 'Dans la région de Divo'],
            ['p', "Lakota est chef-lieu de son propre département ; le siège régional reste à Divo, selon l'annexe du décret de 2011."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 y a dénombré 169 330 habitants (RGPH 2021, ANStat).'],
            ['p', 'Même exercice pour Lakota : l\'ANStat projette 359 157 habitants dans le département en 2024 et 367 226 en 2025, et 182 300 puis 186 263 dans la sous-préfecture, qui englobe la commune. Ces valeurs sont des projections.'],
        ],
    ],

    'abengourou' => [
        'name' => 'Abengourou',
        'population' => 164424,
        'summary' => "Chef-lieu de l'Indénié-Djuablin, Abengourou est une ville de l'est ivoirien.",
        'blocks' => [
            ['p', "Abengourou est le chef-lieu de l'Indénié-Djuablin, région de l'est qui réunit Abengourou, Agnibilékrou et Bettié."],
            ['h2', 'Situation'],
            ['p', "La ville occupe l'est du pays, sur les terres qui s'étendent avant la frontière ghanéenne."],
            ['h2', 'Statut administratif'],
            ['p', "L'annexe du décret n° 2011-263 fixe à Abengourou le chef-lieu régional et le siège du département."],
            ['h2', 'Démographie'],
            ['p', "Au recensement de 2021, la commune d'Abengourou comptait 164 424 habitants (RGPH 2021, ANStat)."],
            ['p', 'En projection, le département d\'Abengourou réunit 461 974 habitants en 2024 et 471 986 en 2025 ; la sous-préfecture passerait de 177 060 à 180 756 habitants. L\'ANStat parle bien de projections, calculées à partir du RGPH 2021.'],
        ],
    ],

    'ferkessedougou' => [
        'name' => 'Ferkessédougou',
        'population' => 160267,
        'summary' => 'Chef-lieu du Tchologo, Ferkessédougou est une ville du nord ivoirien.',
        'blocks' => [
            ['p', 'Ferkessédougou est le chef-lieu du Tchologo, région du nord qui compte trois départements : Ferkessédougou, Ouangolodougou et Kong.'],
            ['h2', 'Géographie'],
            ['p', 'La ville se trouve au nord du pays, dans la zone de savane.'],
            ['h2', 'Un chef-lieu de région'],
            ['p', "Le décret de 2011 lui attribue le siège de la région et du département ; l'activité économique locale n'est pas documentée ici."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement général de 2021 compte 160 267 habitants dans la commune (RGPH 2021, ANStat).'],
            ['p', 'Pour le département de Ferkessédougou, l\'ANStat projette 212 104 habitants en 2024 et 219 441 en 2025 ; la sous-préfecture, qui contient la commune, suivrait de 179 202 à 185 376 habitants. Projections, et non effectifs recensés.'],
        ],
    ],

    'adzope' => [
        'name' => 'Adzopé',
        'population' => 156488,
        'summary' => 'Chef-lieu de La Mé, Adzopé est une ville du sud-est ivoirien.',
        'blocks' => [
            ['p', "Adzopé commande la région de La Mé, qui rassemble les départements d'Adzopé, Alépé, Akoupé et Yakassé-Attobrou."],
            ['h2', 'Situation'],
            ['p', 'La ville occupe le sud-est du pays, dans la forêt qui borde la zone lagunaire.'],
            ['h2', 'Administration'],
            ['p', "Chef-lieu de région et de département depuis le découpage de 2011, Adzopé abrite les services publics de tout l'espace de La Mé."],
            ['h2', 'Démographie'],
            ['p', 'La commune d\'Adzopé comptait 156 488 habitants au recensement de 2021 (RGPH 2021, ANStat).'],
            ['p', 'Les projections de l\'ANStat pour 2024 et 2025 donnent 307 674 puis 315 174 habitants au département d\'Adzopé, 168 883 puis 172 900 à la sous-préfecture. Ce sont des projections démographiques, pas des chiffres de recensement.'],
        ],
    ],

    'meagui' => [
        'name' => 'Méagui',
        'population' => 153483,
        'summary' => 'Méagui est une ville de la Nawa, dans le sud-ouest ivoirien.',
        'blocks' => [
            ['p', 'Méagui appartient à la Nawa, région du sud-ouest forestier dont Soubré est le chef-lieu et qui compte quatre départements : Soubré, Guéyo, Méagui et Buyo.'],
            ['h2', 'Position'],
            ['p', 'La ville se trouve au sud-ouest du pays, entre les axes qui descendent vers le littoral.'],
            ['h2', 'Administration'],
            ['p', 'Méagui est aujourd\'hui chef-lieu de département : la monographie régionale de la Nawa la compte parmi les quatre départements de la région.'],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 y compte 153 483 habitants (RGPH 2021, ANStat).'],
            ['p', 'Le département de Méagui apparaît dans les projections de l\'ANStat avec 318 730 habitants en 2024 et 324 718 en 2025 ; la sous-préfecture est projetée à 163 537 puis 166 533 habitants. Ces chiffres restent des projections.'],
        ],
    ],

    'bondoukou' => [
        'name' => 'Bondoukou',
        'population' => 141568,
        'summary' => "Chef-lieu du Gontougo, Bondoukou est une ville de l'est ivoirien.",
        'blocks' => [
            ['p', "Bondoukou est le chef-lieu du Gontougo, région de l'est composée des départements de Bondoukou, Sandégué, Koun-Fao, Transua et Tanda."],
            ['h2', 'Géographie'],
            ['p', "La ville occupe l'extrême est du pays, à faible distance de la frontière ghanéenne."],
            ['h2', 'Statut administratif'],
            ['p', "L'annexe du décret de 2011 en fait le siège de la région et du département du même nom."],
            ['h2', 'Démographie'],
            ['p', 'Le RGPH de 2021 y a recensé 141 568 habitants (RGPH 2021, ANStat).'],
            ['p', 'Dans la monographie du Gontougo, l\'ANStat projette 482 537 habitants dans le département de Bondoukou en 2024, 492 129 en 2025, et 151 259 puis 154 058 dans la sous-préfecture. Il s\'agit bien de projections.'],
        ],
    ],

    'dabou' => [
        'name' => 'Dabou',
        'population' => 138083,
        'summary' => 'Chef-lieu des Grands-Ponts, Dabou est une ville lagunaire du sud ivoirien.',
        'blocks' => [
            ['p', 'Dabou est le chef-lieu de la région des Grands-Ponts, qui réunit les départements de Dabou, Jacqueville et Grand-Lahou.'],
            ['h2', 'Situation'],
            ['p', "La ville se trouve au sud du pays, sur la rive nord de la lagune Ébrié, à l'ouest d'Abidjan."],
            ['h2', 'Un chef-lieu lagunaire'],
            ['p', 'Le décret de 2011 fixe à Dabou le siège de la région et du département ; les activités liées à la lagune ne sont pas détaillées ici.'],
            ['h2', 'Démographie'],
            ['p', 'La commune comptait 138 083 habitants lors du recensement de 2021 (RGPH 2021, ANStat).'],
            ['p', 'Les projections de l\'ANStat placent le département de Dabou à 226 567 habitants en 2024 et 230 405 en 2025, la sous-préfecture à 146 035 puis 148 403. Ce sont des projections, non un décompte de la commune.'],
        ],
    ],

    'sinfra' => [
        'name' => 'Sinfra',
        'population' => 137210,
        'summary' => 'Sinfra est une ville de la Marahoué, dans le centre-ouest ivoirien.',
        'blocks' => [
            ['p', 'Sinfra appartient à la région de la Marahoué, dont le chef-lieu est Bouaflé et qui réunit cinq départements : Bouaflé, Sinfra, Zuénoula, Bonon et Gohitafla.'],
            ['h2', 'Position'],
            ['p', 'La ville se situe au centre-ouest du pays, dans une zone de contact entre forêt et savane.'],
            ['h2', 'Administration'],
            ['p', "Sinfra est chef-lieu de son département ; le siège régional reste à Bouaflé, d'après l'annexe du décret n° 2011-263."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 137 210 habitants dans la commune (RGPH 2021, ANStat).'],
            ['p', 'Le département de Sinfra est projeté à 262 157 habitants en 2024 et 267 556 en 2025, la sous-préfecture à 147 121 puis 150 169. L\'ANStat précise qu\'il s\'agit de projections issues du RGPH 2021.'],
        ],
    ],

    'agboville' => [
        'name' => 'Agboville',
        'population' => 135082,
        'summary' => "Chef-lieu de l'Agnéby-Tiassa, Agboville est une ville du sud-est ivoirien.",
        'blocks' => [
            ['p', "Agboville est le chef-lieu de l'Agnéby-Tiassa, région du sud-est qui regroupe Agboville, Tiassalé, Sikensi et Taabo."],
            ['h2', 'Géographie'],
            ['p', 'La ville occupe le sud-est du pays, dans le domaine forestier, sur les axes qui relient Abidjan à l\'intérieur.'],
            ['h2', 'Statut administratif'],
            ['p', 'Le découpage de 2011 attribue à Agboville le siège de la région et du département.'],
            ['h2', 'Démographie'],
            ['p', "Au recensement général de 2021, la commune d'Agboville comptait 135 082 habitants (RGPH 2021, ANStat)."],
            ['p', 'Pour 2024 et 2025, l\'ANStat projette 412 723 puis 421 771 habitants dans le département d\'Agboville, et 145 307 puis 148 359 dans la sous-préfecture, qui englobe la commune. Ce sont des projections.'],
        ],
    ],

    'vavoua' => [
        'name' => 'Vavoua',
        'population' => 132528,
        'summary' => 'Vavoua est une ville du Haut-Sassandra, dans le centre-ouest ivoirien.',
        'blocks' => [
            ['p', 'Vavoua fait partie du Haut-Sassandra, région dont Daloa est le chef-lieu et qui comprend aussi Issia et Zoukougbeu.'],
            ['h2', 'Situation'],
            ['p', 'La ville se trouve au centre-ouest du pays, au nord de Daloa.'],
            ['h2', 'Administration'],
            ['p', "Vavoua est chef-lieu de son département ; le siège de la région reste à Daloa, conformément à l'annexe du décret de 2011."],
            ['h2', 'Démographie'],
            ['p', 'La population communale atteignait 132 528 habitants au recensement de 2021 (RGPH 2021, ANStat).'],
            ['p', 'Le département de Vavoua compterait 499 574 habitants en 2024 et 507 762 en 2025 selon les projections de l\'ANStat, la sous-préfecture 138 513 puis 140 603. Projections, et non effectifs recensés.'],
        ],
    ],

    'danane' => [
        'name' => 'Danané',
        'population' => 131586,
        'summary' => "Danané est une ville du Tonkpi, dans l'ouest ivoirien, proche du Liberia et de la Guinée.",
        'blocks' => [
            ['p', 'Danané appartient à la région du Tonkpi, dont Man est le chef-lieu et qui compte cinq départements : Man, Biankouma, Danané, Zouan-Hounien et Sipilou.'],
            ['h2', 'Géographie'],
            ['p', "La ville se trouve à l'ouest du pays, dans une zone de collines proche des frontières du Liberia et de la Guinée."],
            ['h2', 'Administration'],
            ['p', "Danané est chef-lieu de son département ; le siège régional est fixé à Man par l'annexe du décret n° 2011-263."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 y compte 131 586 habitants (RGPH 2021, ANStat).'],
            ['p', 'La monographie du Tonkpi projette 394 381 habitants dans le département de Danané en 2024 et 404 739 en 2025 ; la sous-préfecture suivrait de 141 935 à 145 510 habitants. Ces valeurs sont des projections.'],
        ],
    ],

    'oume' => [
        'name' => 'Oumé',
        'population' => 127153,
        'summary' => 'Oumé est une ville du Gôh, dans le centre-ouest ivoirien.',
        'blocks' => [
            ['p', 'Oumé partage la région du Gôh avec Gagnoa, qui en est le chef-lieu : ce sont les deux seuls départements de la région.'],
            ['h2', 'Position'],
            ['p', 'La ville occupe le centre-ouest du pays, dans une mosaïque de forêt et de savane boisée.'],
            ['h2', 'Administration'],
            ['p', 'Oumé est chef-lieu de son département ; le siège de la région du Gôh reste à Gagnoa, selon le décret de 2011.'],
            ['h2', 'Démographie'],
            ['p', 'Au recensement de 2021, la commune comptait 127 153 habitants (RGPH 2021, ANStat).'],
            ['p', 'Les projections de l\'ANStat donnent 279 609 habitants au département d\'Oumé en 2024 et 285 755 en 2025, et 136 317 puis 139 315 à la sous-préfecture. Il s\'agit de projections démographiques.'],
        ],
    ],

    'issia' => [
        'name' => 'Issia',
        'population' => 126252,
        'summary' => 'Issia est une ville du Haut-Sassandra, dans le centre-ouest ivoirien.',
        'blocks' => [
            ['p', "Issia est l'un des quatre départements du Haut-Sassandra, avec Daloa, Vavoua et Zoukougbeu ; Daloa en est le chef-lieu."],
            ['h2', 'Situation'],
            ['p', "La ville se trouve à l'ouest de Daloa, dans la partie forestière du centre-ouest."],
            ['h2', 'Statut administratif'],
            ['p', "L'annexe du décret de 2011 fait d'Issia un chef-lieu de département, rattaché à la région du Haut-Sassandra."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement général de 2021 y a dénombré 126 252 habitants (RGPH 2021, ANStat).'],
            ['p', 'Le département d\'Issia est projeté à 434 815 habitants en 2024 et 442 322 en 2025, la sous-préfecture à 133 446 puis 135 599. L\'ANStat présente ces chiffres comme des projections.'],
        ],
    ],

    'blolequin' => [
        'name' => 'Bloléquin',
        'population' => 123133,
        'summary' => "Bloléquin est une ville de la Cavally, dans l'ouest ivoirien, proche du Liberia.",
        'blocks' => [
            ['p', 'Bloléquin est l\'un des quatre départements de la Cavally, avec Guiglo, Toulépleu et Taï ; Guiglo est le chef-lieu régional.'],
            ['h2', 'Géographie'],
            ['p', "La ville occupe l'ouest du pays, sur les terres forestières qui bordent le Liberia."],
            ['h2', 'Administration'],
            ['p', 'Bloléquin est chef-lieu de son département depuis le découpage de 2011, rattaché à la région de la Cavally.'],
            ['h2', 'Démographie'],
            ['p', 'La commune comptait 123 133 habitants au recensement de 2021 (RGPH 2021, ANStat).'],
            ['p', 'Pour la Cavally, seules les projections régionales sont publiées : 806 262 habitants en 2025, contre 708 241 en 2021. Le détail par département et par sous-préfecture n\'est pas disponible à ce jour.'],
        ],
    ],

    'bonon' => [
        'name' => 'Bonon',
        'population' => 116871,
        'summary' => 'Bonon est une ville de la Marahoué, dans le centre-ouest ivoirien.',
        'blocks' => [
            ['p', 'Bonon se situe dans la région de la Marahoué, dont le chef-lieu est Bouaflé et qui compte cinq départements : Bouaflé, Sinfra, Zuénoula, Bonon et Gohitafla.'],
            ['h2', 'Position'],
            ['p', 'La ville occupe le centre-ouest du pays, sur les terres forestières de la Marahoué.'],
            ['h2', 'Administration'],
            ['p', 'Longtemps simple sous-préfecture, Bonon est devenue chef-lieu de département ; la monographie régionale de la Marahoué la compte parmi les cinq départements de la région.'],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 116 871 habitants dans la commune (RGPH 2021, ANStat).'],
            ['p', 'Devenu chef-lieu de département, Bonon est projeté à 177 451 habitants en 2024 et 181 008 en 2025 ; la sous-préfecture, qui englobe la commune, passerait de 123 372 à 125 778 habitants. Ce sont des projections de l\'ANStat.'],
        ],
    ],

    'zouan-hounien' => [
        'name' => 'Zouan-Hounien',
        'population' => 111099,
        'summary' => "Zouan-Hounien est une ville frontalière du Tonkpi, dans l'ouest ivoirien.",
        'blocks' => [
            ['p', "Zouan-Hounien fait partie du Tonkpi, région de l'ouest dont Man est le chef-lieu et qui compte cinq départements, dont Biankouma, Danané et Sipilou."],
            ['h2', 'Géographie'],
            ['p', "La ville occupe l'extrême ouest du pays, contre la frontière libérienne."],
            ['h2', 'Administration'],
            ['p', "Zouan-Hounien est chef-lieu de son département, rattaché au Tonkpi par l'annexe du décret n° 2011-263."],
            ['h2', 'Démographie'],
            ['p', 'Le RGPH de 2021 y a recensé 111 099 habitants (RGPH 2021, ANStat).'],
            ['p', 'Pour le département de Zouan-Hounien, les projections de l\'ANStat atteignent 272 986 habitants en 2024 et 280 055 en 2025 ; la sous-préfecture est projetée à 120 620 puis 123 680 habitants.'],
        ],
    ],

    'seguela' => [
        'name' => 'Séguéla',
        'population' => 103980,
        'summary' => 'Chef-lieu du Worodougou, Séguéla est une ville du nord-ouest ivoirien.',
        'blocks' => [
            ['p', 'Séguéla est le chef-lieu du Worodougou, région du nord-ouest qui compte deux départements : Séguéla et Kani.'],
            ['h2', 'Situation'],
            ['p', 'La ville se trouve au nord-ouest du pays, dans la savane boisée.'],
            ['h2', 'Statut administratif'],
            ['p', "L'annexe du décret de 2011 fixe à Séguéla le siège de la région et du département."],
            ['h2', 'Démographie'],
            ['p', 'La commune comptait 103 980 habitants au recensement de 2021 (RGPH 2021, ANStat).'],
            ['p', 'Le département de Séguéla est projeté à 332 719 habitants en 2024 et 344 686 en 2025, la sous-préfecture à 116 014 puis 120 107. Ces chiffres sont des projections issues du RGPH 2021.'],
        ],
    ],

    'daoukro' => [
        'name' => 'Daoukro',
        'population' => 101136,
        'summary' => "Chef-lieu de l'Iffou, Daoukro est une ville du centre-est ivoirien.",
        'blocks' => [
            ['p', "Daoukro est le chef-lieu de l'Iffou, région du centre-est composée des départements de Daoukro, M'Bahiakro et Prikro."],
            ['h2', 'Géographie'],
            ['p', 'La ville occupe le centre-est du pays, sur les terres qui séparent la forêt du centre et les savanes du nord.'],
            ['h2', 'Un chef-lieu de région'],
            ['p', 'Le décret de 2011 lui attribue le siège de la région et du département.'],
            ['h2', 'Démographie'],
            ['p', 'Au recensement de 2021, la commune de Daoukro comptait 101 136 habitants (RGPH 2021, ANStat).'],
            ['p', 'Les projections de l\'ANStat pour 2024 et 2025 donnent 156 736 puis 159 607 habitants au département de Daoukro, et 107 149 puis 109 041 à la sous-préfecture. Ce sont des projections, non des effectifs recensés.'],
        ],
    ],

    'aboisso' => [
        'name' => 'Aboisso',
        'population' => 100903,
        'summary' => 'Chef-lieu du Sud-Comoé, Aboisso est une ville du sud-est ivoirien, proche de la frontière ghanéenne.',
        'blocks' => [
            ['p', 'Aboisso est le chef-lieu du Sud-Comoé, région du sud-est qui réunit Aboisso, Adiaké, Grand-Bassam et Tiapoum.'],
            ['h2', 'Situation'],
            ['p', 'La ville occupe le sud-est du pays, à l\'intérieur des terres, non loin du Ghana.'],
            ['h2', 'Administration'],
            ['p', "L'annexe du décret n° 2011-263 fixe à Aboisso le chef-lieu de la région et du département."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement général de 2021 y compte 100 903 habitants (RGPH 2021, ANStat).'],
            ['p', 'Le département d\'Aboisso est projeté à 382 622 habitants en 2024 et 389 848 en 2025, la sous-préfecture à 107 396 puis 109 391. L\'ANStat parle de projections, calculées sur la base du RGPH 2021.'],
        ],
    ],

    'buyo' => [
        'name' => 'Buyo',
        'population' => 100848,
        'summary' => 'Buyo est une ville de la Nawa, dans le sud-ouest ivoirien, sur le Sassandra.',
        'blocks' => [
            ['p', 'Buyo se trouve dans la région de la Nawa, dont Soubré est le chef-lieu et qui compte quatre départements : Soubré, Guéyo, Méagui et Buyo.'],
            ['h2', 'Le cadre géographique'],
            ['p', 'La ville est installée sur le Sassandra, en aval de Soubré.'],
            ['h2', 'Le barrage'],
            ['p', 'Un barrage et un lac de retenue portent le nom de la ville. Leur date de mise en service et les activités qui y sont liées ne sont pas reprises ici, faute de source officielle vérifiée.'],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 100 848 habitants dans la commune (RGPH 2021, ANStat).'],
            ['p', 'Dans les projections de l\'ANStat, le département de Buyo réunit 187 616 habitants en 2024 et 191 326 en 2025 ; la sous-préfecture passerait de 106 862 à 108 960 habitants. Projections, et non dénombrement.'],
        ],
    ],

    'agnibilekrou' => [
        'name' => 'Agnibilékrou',
        'population' => 99501,
        'summary' => "Agnibilékrou est une ville de l'Indénié-Djuablin, dans l'est ivoirien, près du Ghana.",
        'blocks' => [
            ['p', "Agnibilékrou est l'un des trois départements de l'Indénié-Djuablin, avec Abengourou et Bettié ; Abengourou est le chef-lieu régional."],
            ['h2', 'Géographie'],
            ['p', "La ville occupe l'est du pays, contre la frontière ghanéenne."],
            ['h2', 'Statut administratif'],
            ['p', "Agnibilékrou est chef-lieu de son département, rattaché à l'Indénié-Djuablin par le découpage de 2011."],
            ['h2', 'Démographie'],
            ['p', 'La commune comptait 99 501 habitants au recensement de 2021 (RGPH 2021, ANStat).'],
            ['p', 'Le département d\'Agnibilékrou est projeté à 231 058 habitants en 2024 et 236 079 en 2025 ; la sous-préfecture suivrait, de 106 276 à 108 445 habitants. Ces valeurs sont des projections de l\'ANStat.'],
        ],
    ],

    'bouna' => [
        'name' => 'Bouna',
        'population' => 94883,
        'summary' => 'Chef-lieu du Bounkani, Bouna est une ville du nord-est ivoirien.',
        'blocks' => [
            ['p', 'Bouna est le chef-lieu du Bounkani, région du nord-est qui compte les départements de Bouna, Doropo, Nassian et Téhini.'],
            ['h2', 'Situation'],
            ['p', "La ville occupe l'extrême nord-est du pays, dans la savane, entre le Burkina Faso et le Ghana."],
            ['h2', 'Un chef-lieu de région'],
            ['p', 'Le décret de 2011 lui attribue le siège de la région et du département.'],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 y a dénombré 94 883 habitants (RGPH 2021, ANStat).'],
            ['p', 'Les projections de l\'ANStat attribuent 197 421 habitants au département de Bouna en 2024 et 204 135 en 2025, et 105 287 puis 108 828 à la sous-préfecture, qui englobe la commune. Ce sont des projections.'],
        ],
    ],

    'boundiali' => [
        'name' => 'Boundiali',
        'population' => 92792,
        'summary' => 'Chef-lieu de la Bagoué, Boundiali est une ville du nord-ouest ivoirien.',
        'blocks' => [
            ['p', 'Boundiali est le chef-lieu de la Bagoué, région du nord-ouest composée des départements de Boundiali, Tengréla et Kouto.'],
            ['h2', 'Géographie'],
            ['p', 'La ville se trouve au nord-ouest du pays, dans la zone de savane.'],
            ['h2', 'Statut administratif'],
            ['p', "L'annexe du décret n° 2011-263 fixe à Boundiali le chef-lieu de la région et du département."],
            ['h2', 'Démographie'],
            ['p', 'Au recensement de 2021, la commune comptait 92 792 habitants (RGPH 2021, ANStat).'],
            ['p', 'Pour 2024 et 2025, la monographie de la Bagoué projette 218 634 puis 225 553 habitants dans le département de Boundiali, et 102 413 puis 105 602 dans la sous-préfecture. Il s\'agit de projections.'],
        ],
    ],

    'tengrela' => [
        'name' => 'Tengréla',
        'population' => 92454,
        'summary' => 'Tengréla est une ville de la Bagoué, dans le nord ivoirien, à la frontière malienne.',
        'blocks' => [
            ['p', "Tengréla est l'un des trois départements de la Bagoué, avec Boundiali, qui en est le chef-lieu, et Kouto."],
            ['h2', 'Situation'],
            ['p', 'La ville occupe le nord du pays, contre la frontière malienne.'],
            ['h2', 'Administration'],
            ['p', 'Tengréla est chef-lieu de son département, rattaché à la Bagoué par le découpage de 2011.'],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 92 454 habitants dans la commune (RGPH 2021, ANStat).'],
            ['p', 'Le département de Tengréla est projeté à 157 031 habitants en 2024 et 162 034 en 2025, la sous-préfecture à 102 069 puis 105 320. Ces chiffres sont des projections.'],
        ],
    ],

    'sikensi' => [
        'name' => 'Sikensi',
        'population' => 91032,
        'summary' => "Sikensi est une ville de l'Agnéby-Tiassa, dans le sud ivoirien.",
        'blocks' => [
            ['p', "Sikensi fait partie de l'Agnéby-Tiassa, région du sud-est dont Agboville est le chef-lieu, avec Tiassalé et Taabo."],
            ['h2', 'Géographie'],
            ['p', 'La ville occupe le sud-est du pays, dans la zone forestière proche de la lagune.'],
            ['h2', 'Statut administratif'],
            ['p', "Sikensi est chef-lieu de son département, rattaché à l'Agnéby-Tiassa par l'annexe du décret de 2011."],
            ['h2', 'Démographie'],
            ['p', 'La commune comptait 91 032 habitants au recensement général de 2021 (RGPH 2021, ANStat).'],
            ['p', 'Les projections de l\'ANStat donnent 134 650 habitants au département de Sikensi en 2024 et 137 490 en 2025, et 97 078 puis 99 074 à la sous-préfecture. Ce sont des projections, non un recensement.'],
        ],
    ],

    'katiola' => [
        'name' => 'Katiola',
        'population' => 90641,
        'summary' => 'Chef-lieu du Hambol, Katiola est une ville du centre-nord ivoirien.',
        'blocks' => [
            ['p', 'Katiola est le chef-lieu du Hambol, région du centre-nord qui réunit les départements de Katiola, Dabakala et Niakaramandougou.'],
            ['h2', 'Situation'],
            ['p', 'La ville se trouve au centre-nord du pays, dans la savane.'],
            ['h2', 'Un chef-lieu de région'],
            ['p', "L'annexe du décret de 2011 en fait le siège de la région et du département."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 y compte 90 641 habitants (RGPH 2021, ANStat).'],
            ['p', 'Le département de Katiola est projeté à 177 320 habitants en 2024 et 182 901 en 2025, la sous-préfecture à 99 020 puis 102 077. L\'ANStat présente ces chiffres comme des projections.'],
        ],
    ],

    'toumodi' => [
        'name' => 'Toumodi',
        'population' => 88580,
        'summary' => 'Chef-lieu du Bélier, Toumodi est une ville du centre ivoirien.',
        'blocks' => [
            ['p', 'Toumodi est le chef-lieu du Bélier, région du centre composée des départements de Toumodi, Didiévi, Tiébissou et Djékanou.'],
            ['h2', 'Géographie'],
            ['p', 'La ville occupe le centre du pays, dans une zone de transition entre forêt et savane.'],
            ['h2', 'Statut administratif'],
            ['p', 'Le décret n° 2011-263 fixe à Toumodi le chef-lieu de la région et du département.'],
            ['h2', 'Démographie'],
            ['p', 'Au recensement de 2021, la commune comptait 88 580 habitants (RGPH 2021, ANStat).'],
            ['p', 'Même logique pour Toumodi : 180 562 habitants projetés dans le département en 2024, 184 413 en 2025, et 94 749 puis 98 665 dans la sous-préfecture. Projections, non effectifs recensés.'],
        ],
    ],

];
