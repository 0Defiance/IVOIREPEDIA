<?php

/**
 * Série « Villes de Côte d'Ivoire » : les fiches des villes du répertoire
 * public (RGPH 2021) qui n'avaient pas encore d'article.
 *
 * Deux sources seulement portent le texte :
 * — le décret n° 2011-263 du 28 septembre 2011 (annexe), pour le statut de
 *   chef-lieu et la liste des départements de chaque région ;
 * — le RGPH 2021 de l'ANStat, pour l'effectif communal.
 *
 * Aucune superficie, altitude, distance, activité économique ou donnée
 * culturelle n'est avancée sans source vérifiée : ces parties sont signalées
 * comme non détaillées. Les projections régionales de l'ANStat (2022-2041)
 * existent mais ne sont pas déclinées par commune ici.
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
            ['p', "Aucune estimation communale postérieure à ce recensement n'est reprise ici ; les projections de l'ANStat sont régionales."],
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
            ['p', "Les chiffres plus récents disponibles à l'ANStat portent sur les régions et les départements, pas sur la commune : ils ne sont pas transposés ici."],
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
            ['p', "Cette fiche s'en tient à ce dénombrement : aucune projection communale récente n'est publiée par l'ANStat."],
        ],
    ],

    'soubre' => [
        'name' => 'Soubré',
        'population' => 272773,
        'summary' => 'Chef-lieu de la Nawa, Soubré est une ville du sud-ouest ivoirien, sur le Sassandra.',
        'blocks' => [
            ['p', 'Soubré est le chef-lieu de la Nawa, région du sud-ouest dont les départements sont Soubré et Guéyo dans le découpage de 2011.'],
            ['h2', 'Le cadre géographique'],
            ['p', 'La ville est bâtie sur le Sassandra, le grand fleuve qui traverse le sud-ouest du pays.'],
            ['h2', 'Le barrage'],
            ['p', "Un barrage hydroélectrique barre le fleuve à hauteur de la ville. Sa puissance et sa date de mise en service ne sont pas reprises ici, faute de source officielle vérifiée, et ses effets sur l'urbanisation restent à documenter."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 272 773 habitants dans la commune (RGPH 2021, ANStat).'],
            ['p', "Depuis, l'ANStat produit des projections par région et par département ; aucune ne porte spécifiquement sur la commune de Soubré dans cette fiche."],
        ],
    ],

    'duekoue' => [
        'name' => 'Duékoué',
        'population' => 220953,
        'summary' => "Chef-lieu du Guémon, Duékoué est une ville de l'ouest ivoirien.",
        'blocks' => [
            ['p', "Duékoué est le chef-lieu du Guémon, région de l'ouest qui regroupe les départements de Duékoué, Bangolo et Kouibly."],
            ['h2', 'Situation'],
            ['p', "La ville se trouve dans l'ouest du pays, sur les terres qui précèdent les montagnes de la frontière libérienne."],
            ['h2', 'Statut administratif'],
            ['p', "L'annexe du décret de 2011 attribue à Duékoué le chef-lieu de la région du Guémon et celui du département."],
            ['h2', 'Démographie'],
            ['p', 'Le RGPH de 2021 a recensé 220 953 habitants dans la commune (RGPH 2021, ANStat).'],
            ['p', "Les évolutions postérieures ne sont connues qu'à l'échelle régionale et ne sont pas reprises ici."],
        ],
    ],

    'bouafle' => [
        'name' => 'Bouaflé',
        'population' => 213967,
        'summary' => 'Chef-lieu de la Marahoué, Bouaflé est une ville du centre-ouest ivoirien.',
        'blocks' => [
            ['p', 'Bouaflé est le chef-lieu de la Marahoué ; le découpage de 2011 rattache à cette région les départements de Bouaflé, Sinfra et Zuénoula.'],
            ['h2', 'Situation'],
            ['p', 'La ville occupe le centre-ouest du pays, dans une zone de transition entre forêt et savane.'],
            ['h2', 'Administration'],
            ['p', "Bouaflé concentre le siège de la région et du département, d'après l'annexe du décret n° 2011-263 du 28 septembre 2011."],
            ['h2', 'Démographie'],
            ['p', "Le recensement général de la population et de l'habitat de 2021 y compte 213 967 habitants (RGPH 2021, ANStat)."],
            ['p', 'Ce chiffre communal est le dernier publié ; les projections régionales plus récentes ne descendent pas à ce niveau.'],
        ],
    ],

    'guiglo' => [
        'name' => 'Guiglo',
        'population' => 171454,
        'summary' => "Chef-lieu de la Cavally, Guiglo est une ville de l'ouest ivoirien.",
        'blocks' => [
            ['p', 'Guiglo est le chef-lieu de la Cavally, région frontalière du Liberia qui compte les départements de Guiglo, Bloléquin et Toulépleu.'],
            ['h2', 'Géographie'],
            ['p', "La ville occupe l'ouest du pays, à l'entrée de la forêt qui mène vers la frontière libérienne."],
            ['h2', 'Un chef-lieu frontalier'],
            ['p', "Le décret de 2011 en fait le siège de la région et du département ; le commerce avec le Liberia n'est pas documenté dans cette fiche."],
            ['h2', 'Démographie'],
            ['p', 'La commune comptait 171 454 habitants lors du recensement de 2021 (RGPH 2021, ANStat).'],
            ['p', "Aucune donnée communale plus récente n'est reprise ici, faute de publication officielle à cette échelle."],
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
            ['p', "Les tendances démographiques récentes ne sont publiées qu'au niveau régional et ne figurent pas dans cette fiche."],
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
            ['p', 'Les projections publiées depuis concernent la région, non la commune : cette fiche ne les extrapole pas.'],
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
            ['p', "Faute de chiffre communal plus récent, la fiche s'en tient à ce dénombrement."],
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
            ['p', "Aucune estimation communale postérieure n'a été retenue pour cette fiche."],
        ],
    ],

    'meagui' => [
        'name' => 'Méagui',
        'population' => 153483,
        'summary' => 'Méagui est une ville de la Nawa, dans le sud-ouest ivoirien.',
        'blocks' => [
            ['p', "Méagui se situe dans la région de la Nawa, dont Soubré est le chef-lieu et qui s'étend sur le sud-ouest forestier."],
            ['h2', 'Position'],
            ['p', 'La ville se trouve au sud-ouest du pays, entre les axes qui descendent vers le littoral.'],
            ['h2', 'Administration'],
            ['p', "Le statut administratif actuel de Méagui n'est pas détaillé ici : le découpage de 2011 ne la retient pas comme chef-lieu, et sa situation actuelle demande une source à jour."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 y compte 153 483 habitants (RGPH 2021, ANStat).'],
            ['p', 'Ce chiffre communal reste la seule donnée officielle reprise dans cette fiche.'],
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
            ['p', 'Les évolutions postérieures ne sont pas déclinées par commune dans cette fiche.'],
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
            ['p', "Aucune projection communale récente n'est reprise dans cette fiche."],
        ],
    ],

    'sinfra' => [
        'name' => 'Sinfra',
        'population' => 137210,
        'summary' => 'Sinfra est une ville de la Marahoué, dans le centre-ouest ivoirien.',
        'blocks' => [
            ['p', 'Sinfra appartient à la région de la Marahoué, dont le chef-lieu est Bouaflé et qui compte aussi le département de Zuénoula.'],
            ['h2', 'Position'],
            ['p', 'La ville se situe au centre-ouest du pays, dans une zone de contact entre forêt et savane.'],
            ['h2', 'Administration'],
            ['p', "Sinfra est chef-lieu de son département ; le siège régional reste à Bouaflé, d'après l'annexe du décret n° 2011-263."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 137 210 habitants dans la commune (RGPH 2021, ANStat).'],
            ['p', 'Cette fiche ne reprend pas de chiffre plus récent, faute de publication communale.'],
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
            ['p', 'Les projections régionales publiées depuis ne sont pas transposées à la commune ici.'],
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
            ['p', "Aucune estimation postérieure à ce recensement n'est reprise ici."],
        ],
    ],

    'danane' => [
        'name' => 'Danané',
        'population' => 131586,
        'summary' => "Danané est une ville du Tonkpi, dans l'ouest ivoirien, proche du Liberia et de la Guinée.",
        'blocks' => [
            ['p', 'Danané appartient à la région du Tonkpi, dont Man est le chef-lieu et qui réunit aussi Biankouma et Zouan-Hounien dans le découpage de 2011.'],
            ['h2', 'Géographie'],
            ['p', "La ville se trouve à l'ouest du pays, dans une zone de collines proche des frontières du Liberia et de la Guinée."],
            ['h2', 'Administration'],
            ['p', "Danané est chef-lieu de son département ; le siège régional est fixé à Man par l'annexe du décret n° 2011-263."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 y compte 131 586 habitants (RGPH 2021, ANStat).'],
            ['p', "Cette fiche s'en tient à ce dénombrement communal."],
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
            ['p', "Aucune donnée communale plus récente n'est disponible dans cette fiche."],
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
            ['p', "Les projections régionales de l'ANStat ne sont pas reprises à l'échelle communale dans cette fiche."],
        ],
    ],

    'blolequin' => [
        'name' => 'Bloléquin',
        'population' => 123133,
        'summary' => "Bloléquin est une ville de la Cavally, dans l'ouest ivoirien, proche du Liberia.",
        'blocks' => [
            ['p', "Bloléquin est l'un des trois départements de la Cavally, avec Guiglo et Toulépleu ; Guiglo est le chef-lieu régional."],
            ['h2', 'Géographie'],
            ['p', "La ville occupe l'ouest du pays, sur les terres forestières qui bordent le Liberia."],
            ['h2', 'Administration'],
            ['p', 'Bloléquin est chef-lieu de son département depuis le découpage de 2011, rattaché à la région de la Cavally.'],
            ['h2', 'Démographie'],
            ['p', 'La commune comptait 123 133 habitants au recensement de 2021 (RGPH 2021, ANStat).'],
            ['p', 'Ce chiffre reste la référence communale de la fiche.'],
        ],
    ],

    'bonon' => [
        'name' => 'Bonon',
        'population' => 116871,
        'summary' => 'Bonon est une ville de la Marahoué, dans le centre-ouest ivoirien.',
        'blocks' => [
            ['p', 'Bonon se situe dans la région de la Marahoué, dont le chef-lieu est Bouaflé.'],
            ['h2', 'Position'],
            ['p', 'La ville occupe le centre-ouest du pays, sur les terres forestières de la Marahoué.'],
            ['h2', 'Administration'],
            ['p', "Le découpage de 2011 ne retient pas Bonon comme chef-lieu ; son statut administratif actuel n'est pas détaillé ici, faute de texte à jour."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 116 871 habitants dans la commune (RGPH 2021, ANStat).'],
            ['p', "Aucune estimation communale postérieure n'est reprise dans cette fiche."],
        ],
    ],

    'zouan-hounien' => [
        'name' => 'Zouan-Hounien',
        'population' => 111099,
        'summary' => "Zouan-Hounien est une ville frontalière du Tonkpi, dans l'ouest ivoirien.",
        'blocks' => [
            ['p', "Zouan-Hounien fait partie du Tonkpi, région de l'ouest dont Man est le chef-lieu et qui compte aussi Biankouma et Danané dans le découpage de 2011."],
            ['h2', 'Géographie'],
            ['p', "La ville occupe l'extrême ouest du pays, contre la frontière libérienne."],
            ['h2', 'Administration'],
            ['p', "Zouan-Hounien est chef-lieu de son département, rattaché au Tonkpi par l'annexe du décret n° 2011-263."],
            ['h2', 'Démographie'],
            ['p', 'Le RGPH de 2021 y a recensé 111 099 habitants (RGPH 2021, ANStat).'],
            ['p', "Les données plus récentes n'existent qu'à l'échelle régionale et ne sont pas transposées ici."],
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
            ['p', "Aucun chiffre communal plus récent n'est repris dans cette fiche."],
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
            ['p', 'Cette fiche ne reprend pas de projection communale.'],
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
            ['p', "Les évolutions postérieures ne sont disponibles qu'au niveau régional."],
        ],
    ],

    'buyo' => [
        'name' => 'Buyo',
        'population' => 100848,
        'summary' => 'Buyo est une ville de la Nawa, dans le sud-ouest ivoirien, sur le Sassandra.',
        'blocks' => [
            ['p', 'Buyo se trouve dans la région de la Nawa, dont Soubré est le chef-lieu.'],
            ['h2', 'Le cadre géographique'],
            ['p', 'La ville est installée sur le Sassandra, en aval de Soubré.'],
            ['h2', 'Le barrage'],
            ['p', 'Un barrage et un lac de retenue portent le nom de la ville. Leur date de mise en service et les activités qui y sont liées ne sont pas reprises ici, faute de source officielle vérifiée.'],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 100 848 habitants dans la commune (RGPH 2021, ANStat).'],
            ['p', "Aucune estimation communale récente n'est ajoutée à ce chiffre."],
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
            ['p', 'Les chiffres régionaux plus récents ne sont pas transposés à la commune ici.'],
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
            ['p', "Cette fiche s'en tient à ce dénombrement communal."],
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
            ['p', "Aucune donnée communale plus récente n'est reprise ici."],
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
            ['p', "Les projections régionales ne descendent pas à l'échelle communale dans cette fiche."],
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
            ['p', 'Ce chiffre communal reste la seule donnée de population reprise.'],
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
            ['p', "Aucune estimation communale postérieure à ce recensement n'est reprise ici."],
        ],
    ],

    'toumodi' => [
        'name' => 'Toumodi',
        'population' => 88580,
        'summary' => 'Chef-lieu du Bélier, Toumodi est une ville du centre ivoirien.',
        'blocks' => [
            ['p', 'Toumodi est le chef-lieu du Bélier, région du centre composée des départements de Toumodi, Didiévi et Tiébissou.'],
            ['h2', 'Géographie'],
            ['p', 'La ville occupe le centre du pays, dans une zone de transition entre forêt et savane.'],
            ['h2', 'Statut administratif'],
            ['p', 'Le décret n° 2011-263 fixe à Toumodi le chef-lieu de la région et du département.'],
            ['h2', 'Démographie'],
            ['p', 'Au recensement de 2021, la commune comptait 88 580 habitants (RGPH 2021, ANStat).'],
            ['p', 'Les données plus récentes ne sont pas disponibles à cette échelle dans cette fiche.'],
        ],
    ],

];
