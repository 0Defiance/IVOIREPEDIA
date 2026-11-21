<?php

/**
 * Série « Villes de Côte d'Ivoire » : les fiches des villes du répertoire
 * public (RGPH 2021) qui n'avaient pas encore d'article.
 *
 * Chaque entrée porte l'effectif communal du recensement de 2021 et un texte
 * court mais structuré —
 * situation, histoire, économie, vie locale. Les effectifs viennent du document
 * officiel du RGPH 2021 (ANStat), cité en référence de chaque article ; le reste
 * reste volontairement général plutôt que précis au risque de se tromper.
 *
 * Les six plus grandes villes (Abidjan, Yamoussoukro, Bouaké, Korhogo, Man,
 * San-Pédro) ont déjà leur article dans PublicContentSeeder.
 */
return [

    'daloa' => [
        'name' => 'Daloa',
        'population' => 421879,
        'summary' => 'Chef-lieu du Haut-Sassandra, Daloa est une grande ville du centre-ouest ivoirien.',
        'blocks' => [
            ['p', "Daloa s'étend sur un plateau du centre-ouest, à mi-chemin entre la forêt du sud et les savanes du nord. De toutes les villes ivoiriennes, c'est l'une des plus traversées : les routes de Bouaflé, d'Issia, de Séguéla et de Gagnoa s'y croisent, et le marché qui en résulte fait vivre une bonne partie du pays bété et gouro alentour."],
            ['h2', 'Une ville née du cacao'],
            ['p', "La ville s'est développée au XXe siècle avec la culture du cacao dans la région du centre-ouest. Le détail de son histoire économique n'est pas repris ici faute de source officielle vérifiée ; les récits locaux de la ville ne sont pas repris comme faits."],
            ['p', "Les activités économiques de la ville, comme l'agriculture et le commerce, ne sont pas chiffrées dans cette fiche."],
            ['h2', 'Une population jeune'],
            ['p', 'Daloa comptait 421 879 habitants au recensement de 2021 (RGPH 2021, ANStat). Les autres données démographiques de la ville ne sont pas reprises dans cette fiche.'],
            ['h2', 'Vie quotidienne'],
            ['p', "La vie quotidienne de la ville n'est pas décrite ici : aucune source officielle vérifiée n'a été retenue pour cette partie."],
        ],
    ],

    'divo' => [
        'name' => 'Divo',
        'population' => 294559,
        'summary' => 'Chef-lieu du Lôh-Djiboua, Divo est une ville du sud ivoirien.',
        'blocks' => [
            ['p', 'Divo se trouve au sud du pays. La ville est le chef-lieu de la région du Lôh-Djiboua.'],
            ['h2', 'Une économie de plantation'],
            ['p', "L'économie agricole de la région n'est pas détaillée dans cette fiche, faute de source officielle vérifiée."],
            ['p', 'Les activités économiques de la ville ne sont pas détaillées ici.'],
            ['h2', 'Une ville-carrefour'],
            ['p', "La situation de la ville sur les axes routiers n'est pas détaillée dans cette fiche, faute de source vérifiée."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 y compte 294 559 habitants (RGPH 2021, ANStat). Les causes de la croissance urbaine ne sont pas reprises ici.'],
        ],
    ],

    'gagnoa' => [
        'name' => 'Gagnoa',
        'population' => 277044,
        'summary' => 'Chef-lieu du Gôh, Gagnoa est une ville du centre-ouest ivoirien.',
        'blocks' => [
            ['p', "Gagnoa se situe au centre-ouest de la Côte d'Ivoire, dans une région de forêt humide. La ville est le chef-lieu de la région du Gôh et l'un des principaux centres urbains du pays bété."],
            ['h2', 'Le pays bété'],
            ['p', 'La région de Gagnoa est associée au pays bété. Les pratiques sociales locales ne sont pas détaillées ici, faute de source officielle vérifiée.'],
            ['p', "Le rôle politique de la ville n'est pas repris dans cette fiche : les affirmations à ce sujet ne sont pas sourcées."],
            ['h2', 'Cacao, café et vivrier'],
            ['p', "L'économie de la ville n'est pas détaillée dans cette fiche, faute de source officielle vérifiée."],
            ['h2', 'Démographie'],
            ['p', 'Au recensement de 2021, Gagnoa compte 277 044 habitants (RGPH 2021, ANStat). Les équipements éducatifs et sanitaires de la ville ne sont pas repris ici.'],
        ],
    ],

    'soubre' => [
        'name' => 'Soubré',
        'population' => 272773,
        'summary' => 'Chef-lieu de la Nawa, Soubré est une ville du sud-ouest ivoirien, proche du barrage de Soubré sur le Sassandra.',
        'blocks' => [
            ['p', 'Soubré est bâtie sur la rive du Sassandra, dans le sud-ouest forestier. La ville commande la route qui descend vers San-Pédro et celle qui remonte vers Daloa, ce qui en fait un carrefour pour toute la région.'],
            ['h2', 'Le barrage'],
            ['p', "Le barrage hydroélectrique de Soubré, inauguré le 2 novembre 2017 avec une puissance installée de 275 MW, a changé la ville : il fournit de l'électricité au réseau national, a créé un lac en amont et a amené des milliers de travailleurs pendant le chantier. Les infrastructures qui l'accompagnent — routes, logements, écoles — ont accéléré la croissance urbaine."],
            ['p', 'Le fleuve reste au centre de la vie locale : pêche, transport de marchandises et lavage des véhicules sur les berges, tandis que les crues rappellent chaque année la prudence nécessaire.'],
            ['h2', 'La ceinture cacaoyère'],
            ['p', "Les plantations de cacao de la région n'ont pas été chiffrées dans cette fiche, faute de source officielle vérifiée. Les récits locaux sur la ville ne sont pas repris comme faits : publications Facebook non vérifiables, à citer avec leurs liens en bas de fiche si besoin."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 272 773 habitants à Soubré. Les causes de sa croissance ne sont pas reprises ici, faute de source officielle vérifiée.'],
        ],
    ],

    'duekoue' => [
        'name' => 'Duékoué',
        'population' => 220953,
        'summary' => "Chef-lieu du Guémon, Duékoué est une ville de l'ouest ivoirien.",
        'blocks' => [
            ['p', "Duékoué se trouve à l'ouest, sur l'axe qui relie Daloa à Man et à la frontière libérienne. Sa position de carrefour en a fait un lieu d'échanges entre le pays bété, le pays guéré et les communautés venues du nord chercher des terres."],
            ['h2', 'Une terre de plantations'],
            ['p', "La région est couverte de plantations de cacao, de café et d'hévéa, ouvertes progressivement dans la forêt. Les villages alentour vivent de ces cultures et des marchés hebdomadaires où se retrouvent planteurs, acheteurs et revendeurs."],
            ['p', 'Les questions foncières de la région ne sont pas détaillées ici, faute de source officielle vérifiée.'],
            ['h2', 'Une mémoire douloureuse'],
            ['p', "L'histoire récente de la ville, notamment la crise post-électorale, n'est pas détaillée dans cette fiche : les affirmations sans source officielle vérifiée ne sont pas reprises."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 220 953 habitants. Les équipements de la ville ne sont pas détaillés dans cette fiche, faute de source vérifiée.'],
        ],
    ],

    'bouafle' => [
        'name' => 'Bouaflé',
        'population' => 213967,
        'summary' => 'Chef-lieu de la Marahoué, Bouaflé est une ville du centre ivoirien, proche du lac de Kossou.',
        'blocks' => [
            ['p', 'Bouaflé se trouve au centre-ouest, dans une zone de transition entre forêt et savane. La ville est le chef-lieu de la région de la Marahoué et est associée aux pays gouro et yaouré, sans que leurs pratiques soient détaillées ici.'],
            ['h2', 'Le lac de Kossou'],
            ['p', "Le lac de Kossou, formé par le barrage hydroélectrique sur le Bandama, s'étend à proximité de la ville. Les activités liées au lac ne sont pas détaillées ici, faute de source officielle vérifiée."],
            ['h2', 'Cacao et vivrier'],
            ['p', "Les plantations de cacao, de café et d'hévéa occupent une bonne partie des terres, mais la région produit aussi du riz, du maïs, de l'igname et des légumes. Le maraîchage, pratiqué souvent par des femmes, approvisionne les marchés de la ville et une partie du centre du pays."],
            ['p', "Le marché central et les gares routières concentrent l'activité : on y vient des villages pour vendre, acheter, soigner ou scolariser les enfants."],
            ['h2', 'Démographie'],
            ['p', 'Au recensement de 2021, Bouaflé compte 213 967 habitants. Les causes de sa croissance ne sont pas reprises ici, faute de source officielle vérifiée.'],
        ],
    ],

    'guiglo' => [
        'name' => 'Guiglo',
        'population' => 171454,
        'summary' => "Chef-lieu de la Cavally, Guiglo est une ville de l'ouest ivoirien.",
        'blocks' => [
            ['p', "Guiglo se situe à l'ouest, sur l'axe qui mène de Duékoué à la frontière libérienne. La ville est le chef-lieu de la région de la Cavally et un point de passage pour les échanges avec le Liberia."],
            ['h2', 'La forêt et Taï'],
            ['p', "Guiglo est située à proximité du parc national de Taï, dont la fiche article décrit le statut. L'économie et le paysage de la région ne sont pas détaillés ici, faute de source officielle vérifiée."],
            ['p', 'Les tensions entre conservation et agriculture autour de la forêt ne sont pas détaillées ici, faute de source officielle vérifiée.'],
            ['h2', 'Frontière et commerce'],
            ['p', "La proximité du Liberia fait de Guiglo une ville frontalière. Le commerce transfrontalier n'est pas chiffré dans cette fiche, faute de source vérifiée."],
            ['h2', 'Démographie'],
            ['p', "Le recensement de 2021 compte 171 454 habitants. La composition de la population n'est pas décrite dans cette fiche, faute de source officielle vérifiée."],
        ],
    ],

    'lakota' => [
        'name' => 'Lakota',
        'population' => 169330,
        'summary' => 'Lakota, dans le Lôh-Djiboua, est une ville du sud ivoirien.',
        'blocks' => [
            ['p', "Lakota se trouve au sud du pays, à l'ouest de Divo, dans une zone forestière densément plantée. La ville est le chef-lieu du département du même nom et un centre de services pour les villages alentour."],
            ['h2', 'Plantations et marchés'],
            ['p', "Le cacao, l'hévéa et le palmier à huile structurent l'économie locale. Les campagnes de collecte rythment l'année, et les marchés de Lakota servent de rendez-vous aux planteurs, aux acheteurs et aux commerçants de la région."],
            ['p', 'Les équipements de la ville ne sont pas détaillés dans cette fiche, faute de source officielle vérifiée.'],
            ['h2', 'Sociétés et cultures'],
            ['p', 'Lakota se situe au contact des pays dida et bété. Les fêtes villageoises, les funérailles et les réunions de chefferie restent des moments forts de la vie sociale, et les langues locales demeurent largement pratiquées.'],
            ['h2', 'Démographie'],
            ['p', "Le recensement de 2021 compte 169 330 habitants. Comme dans beaucoup de villes du sud forestier, la croissance s'appuie à la fois sur la natalité et sur l'arrivée de familles de planteurs."],
        ],
    ],

    'abengourou' => [
        'name' => 'Abengourou',
        'population' => 164424,
        'summary' => "Chef-lieu de l'Indénié-Djuablin, Abengourou est une ville de l'est ivoirien.",
        'blocks' => [
            ['p', "Abengourou se trouve à l'est, sur l'axe qui relie Abidjan au Ghana par Aboisso. La ville est le chef-lieu de la région de l'Indénié-Djuablin."],
            ['h2', 'Le royaume agni'],
            ['p', "L'histoire du royaume de l'Indénié n'est pas détaillée dans cette fiche, faute de source officielle vérifiée."],
            ['p', 'Les langues et les traditions de la région ne sont pas décrites plus avant, faute de source vérifiée.'],
            ['h2', 'Cacao et commerce'],
            ['p', "L'économie de la région n'est pas chiffrée dans cette fiche, faute de source officielle vérifiée."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 164 424 habitants (RGPH 2021, ANStat). Les équipements de la ville ne sont pas repris ici.'],
        ],
    ],

    'ferkessedougou' => [
        'name' => 'Ferkessédougou',
        'population' => 160267,
        'summary' => 'Chef-lieu du Tchologo, Ferkessédougou est une ville du nord ivoirien.',
        'blocks' => [
            ['p', 'Ferkessédougou — « Ferké » pour tout le monde — se trouve au nord ivoirien. La ville est le chef-lieu de la région du Tchologo.'],
            ['h2', 'Économie et agriculture'],
            ['p', "L'économie de la ville n'est pas détaillée dans cette fiche : les affirmations sur l'industrie locale ne sont pas sourcées."],
            ['p', "Les cultures et l'élevage de la région ne sont pas détaillés ici, faute de source officielle vérifiée."],
            ['h2', 'Carrefour du nord'],
            ['p', "La ville occupe une position stratégique : son rôle sur les axes de transport n'est pas détaillé dans cette fiche, faute de source officielle vérifiée."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 160 267 habitants (RGPH 2021, ANStat).'],
        ],
    ],

    'adzope' => [
        'name' => 'Adzopé',
        'population' => 156488,
        'summary' => 'Chef-lieu de La Mé, Adzopé est une ville du sud ivoirien, entre Abidjan et Agboville.',
        'blocks' => [
            ['p', "Adzopé se trouve au sud-est, sur l'axe qui relie Abidjan à Agboville par les terres. La ville est le chef-lieu de la région de La Mé et le centre du pays attié."],
            ['h2', 'Le pays attié'],
            ['p', 'Les Attié, ou Akyé, sont associés à cette région forestière. Leurs pratiques sociales et culinaires ne sont pas détaillées dans cette fiche, faute de source officielle vérifiée.'],
            ['p', "L'économie de la région n'est pas chiffrée dans cette fiche, faute de source officielle vérifiée."],
            ['h2', 'Une ville de services'],
            ['p', 'Les services de la ville ne sont pas détaillés dans cette fiche, faute de source officielle vérifiée.'],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 156 488 habitants (RGPH 2021, ANStat). Les causes de sa croissance ne sont pas reprises ici.'],
        ],
    ],

    'meagui' => [
        'name' => 'Méagui',
        'population' => 153483,
        'summary' => 'Méagui, dans la Nawa, est une localité du sud-ouest ivoirien.',
        'blocks' => [
            ['p', 'Méagui se situe au sud-ouest, entre Soubré et San-Pédro, en zone forestière. Les causes de son développement ne sont pas reprises ici, faute de source officielle vérifiée.'],
            ['h2', 'Le cacao, moteur de la ville'],
            ['p', "L'économie cacaoyère de la ville n'est pas détaillée dans cette fiche, faute de source officielle vérifiée."],
            ['p', "Les cultures vivrières et l'environnement local ne sont pas décrits ici, faute de source vérifiée."],
            ['h2', 'Équipements'],
            ['p', "L'équipement et les questions foncières de la ville ne sont pas détaillés dans cette fiche, faute de source vérifiée."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 153 483 habitants (RGPH 2021, ANStat).'],
        ],
    ],

    'bondoukou' => [
        'name' => 'Bondoukou',
        'population' => 141568,
        'summary' => "Chef-lieu du Gontougo, Bondoukou est une ville de l'est ivoirien.",
        'blocks' => [
            ['p', "Bondoukou se trouve à l'extrême est de la Côte d'Ivoire, à quelques dizaines de kilomètres du Ghana. La ville est le chef-lieu de la région du Gontougo et l'un des plus anciens centres urbains du pays."],
            ['h2', 'Histoire'],
            ['p', "L'histoire commerciale et religieuse de la ville n'est pas reprise ici, faute de source officielle vérifiée."],
            ['p', "Le patrimoine religieux de la ville n'est pas décrit ici, faute de source officielle vérifiée."],
            ['h2', 'Anacarde et commerce'],
            ['p', "L'économie et les quartiers de la ville ne sont pas détaillés dans cette fiche, faute de source officielle vérifiée."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 141 568 habitants (RGPH 2021, ANStat).'],
        ],
    ],

    'dabou' => [
        'name' => 'Dabou',
        'population' => 138083,
        'summary' => 'Chef-lieu des Grands-Ponts, Dabou est une ville lagunaire du sud ivoirien.',
        'blocks' => [
            ['p', "Dabou se trouve au sud, sur la rive nord de la lagune Ébrié, à l'ouest d'Abidjan. La ville est le chef-lieu de la région des Grands-Ponts et le centre du pays adioukrou."],
            ['h2', "Une ville d'eau"],
            ['p', 'Les activités liées à la lagune ne sont pas détaillées ici, faute de source officielle vérifiée.'],
            ['p', "Le tourisme local n'est pas décrit dans cette fiche, faute de source vérifiée."],
            ['h2', 'Palme, cacao et maraîchage'],
            ['p', "L'économie agricole et halieutique de la ville n'est pas détaillée dans cette fiche, faute de source officielle vérifiée."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 138 083 habitants (RGPH 2021, ANStat).'],
        ],
    ],

    'sinfra' => [
        'name' => 'Sinfra',
        'population' => 137210,
        'summary' => 'Sinfra, dans la Marahoué, est une ville du centre-ouest ivoirien.',
        'blocks' => [
            ['p', "Sinfra se trouve au centre-ouest, sur l'axe qui relie Bouaflé à Daloa et Gagnoa. La ville est le chef-lieu du département du même nom, dans la région de la Marahoué."],
            ['h2', 'Un carrefour de produits'],
            ['p', "L'activité économique de la ville n'est pas détaillée dans cette fiche, faute de source vérifiée."],
            ['p', 'Les cultures de la région ne sont pas détaillées ici, faute de source officielle vérifiée.'],
            ['h2', 'Sociétés et cultures'],
            ['p', "La ville est au contact des pays gouro et bété. Les chefferies, les sociétés d'initiation et les fêtes de récolte y gardent leur importance, et les langues locales restent vivantes à côté du français."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 137 210 habitants (RGPH 2021, ANStat).'],
        ],
    ],

    'agboville' => [
        'name' => 'Agboville',
        'population' => 135082,
        'summary' => "Chef-lieu de l'Agnéby-Tiassa, Agboville est une ville du sud ivoirien, proche d'Abidjan.",
        'blocks' => [
            ['p', "Agboville se trouve au sud-est, à une heure et demie d'Abidjan, sur l'axe routier et ferroviaire qui mène vers le centre du pays. La ville est le chef-lieu de la région de l'Agnéby-Tiassa et le centre du pays abbey."],
            ['h2', 'Le pays abbey'],
            ['p', 'Les Abbey sont associés à cette région forestière. Leurs pratiques sociales ne sont pas détaillées dans cette fiche, faute de source officielle vérifiée.'],
            ['p', "L'histoire scolaire et religieuse de la ville n'est pas reprise ici, faute de source officielle vérifiée."],
            ['h2', 'Hévéa, cacao et transport'],
            ['p', "L'économie de la ville n'est pas détaillée dans cette fiche, faute de source officielle vérifiée."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 135 082 habitants (RGPH 2021, ANStat).'],
        ],
    ],

    'vavoua' => [
        'name' => 'Vavoua',
        'population' => 132528,
        'summary' => 'Vavoua, dans le Haut-Sassandra, est une ville du centre-ouest ivoirien.',
        'blocks' => [
            ['p', 'Vavoua se situe au centre-ouest, au nord de Daloa, sur la route qui monte vers Séguéla. La ville est le chef-lieu du département du même nom, dans la région du Haut-Sassandra.'],
            ['h2', 'Économie'],
            ['p', "L'économie de la région n'est pas détaillée dans cette fiche, faute de source officielle vérifiée."],
            ['p', 'Les autres cultures de la région ne sont pas détaillées ici.'],
            ['h2', 'Population'],
            ['p', "La composition sociale de la ville n'est pas décrite dans cette fiche, faute de source officielle vérifiée."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 132 528 habitants (RGPH 2021, ANStat).'],
        ],
    ],

    'danane' => [
        'name' => 'Danané',
        'population' => 131586,
        'summary' => "Danané, dans le Tonkpi, est une ville de montagne de l'ouest ivoirien, proche du Liberia et de la Guinée.",
        'blocks' => [
            ['p', "Danané se trouve à l'extrême ouest, dans une région de collines et de forêt, non loin des frontières du Liberia et de la Guinée. La ville est le chef-lieu du département du même nom, dans la région du Tonkpi."],
            ['h2', 'Le pays dan'],
            ['p', 'La région est associée au pays dan (ou yacouba). Les pratiques culturelles locales ne sont pas détaillées dans cette fiche, faute de source officielle vérifiée.'],
            ['p', "Le relief de la région n'est pas décrit dans cette fiche, faute de source officielle vérifiée."],
            ['h2', 'Cacao et frontière'],
            ['p', "L'économie de la ville n'est pas détaillée dans cette fiche, faute de source officielle vérifiée."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 131 586 habitants (RGPH 2021, ANStat).'],
        ],
    ],

    'oume' => [
        'name' => 'Oumé',
        'population' => 127153,
        'summary' => 'Oumé, dans le Gôh, est une ville du centre-ouest ivoirien.',
        'blocks' => [
            ['p', 'Oumé se trouve au centre-sud, entre Gagnoa et Toumodi, dans une zone de forêt et de savane boisée. La ville est le chef-lieu du département du même nom, dans la région du Gôh.'],
            ['h2', 'Pays gouro'],
            ['p', 'La région est associée au pays gouro. Les pratiques sociales locales ne sont pas décrites ici, faute de source officielle vérifiée.'],
            ['h2', 'Cacao et vivrier'],
            ['p', "Le cacao est la principale culture de rente, avec le café et l'hévéa. Le riz, l'igname et le manioc assurent la subsistance, et le marché d'Oumé approvisionne les villages d'alentour."],
            ['p', "Le rôle administratif et scolaire de la ville n'est pas détaillé ici, faute de source vérifiée."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 127 153 habitants (RGPH 2021, ANStat).'],
        ],
    ],

    'issia' => [
        'name' => 'Issia',
        'population' => 126252,
        'summary' => 'Issia, dans le Haut-Sassandra, est une ville du centre-ouest ivoirien.',
        'blocks' => [
            ['p', "Issia se trouve à l'ouest de Daloa, dans la région forestière du Haut-Sassandra. La ville est le chef-lieu du département du même nom et un centre de collecte pour les villages alentour."],
            ['h2', 'Le cacao et le fleuve'],
            ['p', "Les plantations de cacao, de café et d'hévéa occupent l'essentiel des terres. Le Sassandra, qui traverse la région, fournit du poisson et de l'eau aux villages riverains, et son franchissement a longtemps conditionné les échanges avec l'ouest."],
            ['p', "L'économie locale n'est pas chiffrée dans cette fiche."],
            ['h2', 'Vie de la ville'],
            ['p', 'Les équipements et la vie sociale de la ville ne sont pas détaillés dans cette fiche, faute de source vérifiée.'],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 126 252 habitants (RGPH 2021, ANStat).'],
        ],
    ],

    'blolequin' => [
        'name' => 'Bloléquin',
        'population' => 123133,
        'summary' => "Bloléquin, dans la Cavally, est une ville de forêt de l'ouest ivoirien, tournée vers le cacao et le commerce avec le Liberia.",
        'blocks' => [
            ['p', "Bloléquin se situe à l'ouest, sur la route qui relie Guiglo à la frontière libérienne. La ville est le chef-lieu du département du même nom, dans la région de la Cavally."],
            ['h2', 'Forêt et plantations'],
            ['p', "La région est associée à la forêt et aux plantations de cacao ; l'économie locale n'est pas chiffrée dans cette fiche, faute de source officielle vérifiée."],
            ['p', 'La proximité du parc national de Taï est mentionnée ; les arbitrages entre protection et agriculture ne sont pas détaillés ici, faute de source vérifiée.'],
            ['h2', 'Une ville frontalière'],
            ['p', "Les activités commerciales de la ville et l'histoire récente de la région ne sont pas détaillées ici, faute de source officielle vérifiée."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 123 133 habitants (RGPH 2021, ANStat).'],
        ],
    ],

    'bonon' => [
        'name' => 'Bonon',
        'population' => 116871,
        'summary' => 'Bonon, dans la Marahoué, est une ville du centre ivoirien.',
        'blocks' => [
            ['p', "Bonon se trouve au centre-ouest, sur l'axe qui relie Bouaflé à Daloa. La ville est le chef-lieu du département du même nom, dans la région de la Marahoué."],
            ['h2', 'Le cacao avant tout'],
            ['p', "Les plantations de cacao dominent l'économie, avec le café, l'hévéa et le vivrier. Les volumes de collecte ne sont pas chiffrés dans cette fiche, faute de source officielle vérifiée."],
            ['p', "La composition sociale du marché n'est pas décrite dans cette fiche, faute de source vérifiée."],
            ['h2', 'Services et scolarisation'],
            ['p', 'Les équipements de la ville ne sont pas détaillés dans cette fiche, faute de source vérifiée.'],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 116 871 habitants. Les causes de sa croissance ne sont pas reprises ici, faute de source officielle vérifiée.'],
        ],
    ],

    'zouan-hounien' => [
        'name' => 'Zouan-Hounien',
        'population' => 111099,
        'summary' => "Zouan-Hounien, dans le Tonkpi, est une ville frontalière de l'ouest ivoirien, connue pour ses plantations.",
        'blocks' => [
            ['p', "Zouan-Hounien se trouve à l'extrême ouest, contre la frontière libérienne, dans la région du Tonkpi. La ville est le chef-lieu du département du même nom."],
            ['h2', "L'or et le cacao"],
            ['p', "L'exploitation aurifère du département, dont la mine d'Ity, n'est pas détaillée ici : les affirmations sur son ancienneté et son activité ne sont pas sourcées."],
            ['p', 'Les autres activités économiques de la région ne sont pas détaillées ici, faute de source vérifiée.'],
            ['h2', 'Une frontière active'],
            ['p', "Le contexte frontalier de la ville n'est pas détaillé dans cette fiche, faute de source officielle vérifiée."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 111 099 habitants (RGPH 2021, ANStat).'],
        ],
    ],

    'seguela' => [
        'name' => 'Séguéla',
        'population' => 103980,
        'summary' => 'Chef-lieu du Worodougou, Séguéla est une ville du nord-ouest ivoirien.',
        'blocks' => [
            ['p', 'Séguéla se trouve au nord-ouest, dans une région de savane boisée, au croisement des routes de Daloa, de Touba et de Mankono. La ville est le chef-lieu de la région du Worodougou.'],
            ['h2', 'Une ville du Worodougou'],
            ['p', 'Les populations et les activités de la région du Worodougou ne sont pas décrites ici, faute de source officielle vérifiée.'],
            ['p', "Le rôle politique de la ville n'est pas repris dans cette fiche : les affirmations à ce sujet ne sont pas sourcées."],
            ['h2', 'Anacarde, coton et élevage'],
            ['p', "L'économie agricole et d'élevage de la région n'est pas chiffrée dans cette fiche, faute de source officielle vérifiée."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 103 980 habitants (RGPH 2021, ANStat).'],
        ],
    ],

    'daoukro' => [
        'name' => 'Daoukro',
        'population' => 101136,
        'summary' => "Chef-lieu de l'Iffou, Daoukro est une ville du centre-est ivoirien.",
        'blocks' => [
            ['p', "Daoukro se trouve au centre-est, sur l'axe qui relie Abidjan à Bouaké par la route de Yamoussoukro. La ville est le chef-lieu de la région de l'Iffou."],
            ['h2', 'Une ville baoulé'],
            ['p', "La région appartient au pays baoulé. Les villages y sont organisés autour de la chefferie et des classes d'âge, et la langue baoulé reste la première langue du quotidien. L'agriculture, longtemps fondée sur le café et le cacao, reste le socle de l'économie."],
            ['p', "Le rôle politique de la ville n'est pas repris dans cette fiche : l'affirmation sur son lien avec une personnalité politique n'est pas sourcée."],
            ['h2', 'Plantations et services'],
            ['p', "L'économie agricole des campagnes n'est pas détaillée dans cette fiche, faute de source vérifiée."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 101 136 habitants (RGPH 2021, ANStat).'],
        ],
    ],

    'aboisso' => [
        'name' => 'Aboisso',
        'population' => 100903,
        'summary' => 'Chef-lieu du Sud-Comoé, Aboisso est une ville du sud-est ivoirien, proche de la frontière ghanéenne.',
        'blocks' => [
            ['p', "Aboisso se trouve au sud-est, à l'intérieur des terres, sur l'axe qui mène d'Abidjan au Ghana. La ville est le chef-lieu de la région du Sud-Comoé et le centre du pays sanwi."],
            ['h2', 'Le royaume sanwi'],
            ['p', "L'histoire du royaume sanwi n'est pas détaillée dans cette fiche, faute de source officielle vérifiée."],
            ['p', 'Les épisodes historiques de la région ne sont pas repris ici : les affirmations sur les années 1960 ne sont pas sourcées.'],
            ['h2', 'Palme, cacao et frontière'],
            ['p', "L'économie de la région, dont le palmier à huile, le cacao et l'hévéa, n'est pas chiffrée dans cette fiche, faute de source officielle vérifiée."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 100 903 habitants (RGPH 2021, ANStat).'],
        ],
    ],

    'buyo' => [
        'name' => 'Buyo',
        'population' => 100848,
        'summary' => 'Buyo, dans la Nawa, est la ville du lac artificiel formé par le barrage sur le Sassandra, entre pêche et cacao.',
        'blocks' => [
            ['p', 'Buyo se situe au sud-ouest, sur le Sassandra, entre Soubré et San-Pédro. La ville est le chef-lieu du département du même nom, dans la région de la Nawa.'],
            ['h2', 'Le lac de Buyo'],
            ['p', "Le barrage hydroélectrique de Buyo a créé un lac de retenue ; sa date de mise en service n'est pas reprise ici, faute de source officielle vérifiée (la date de 1981 relève de publications non vérifiées). Les activités liées au lac (pêche, transport, cultures de décrue) ne sont pas chiffrées ici."],
            ['p', 'Les campements de pêcheurs et le commerce du poisson autour du lac ne sont pas décrits dans cette fiche, faute de source vérifiée.'],
            ['h2', 'Cacao et forêt'],
            ['p', "L'évolution de la forêt et des plantations autour du lac n'est pas décrite ici, faute de source vérifiée."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 100 848 habitants (RGPH 2021, ANStat).'],
        ],
    ],

    'agnibilekrou' => [
        'name' => 'Agnibilékrou',
        'population' => 99501,
        'summary' => "Agnibilékrou, dans l'Indénié-Djuablin, est une ville frontalière de l'est ivoirien, active par son marché et ses plantations.",
        'blocks' => [
            ['p', "Agnibilékrou se trouve à l'est, contre la frontière ghanéenne, sur la route qui relie Abengourou à Bondoukou. La ville est le chef-lieu du département du même nom."],
            ['h2', 'Un marché frontalier'],
            ['p', "Le marché frontalier de la ville est animé par des échanges avec le Ghana ; son importance économique n'est pas chiffrée ici, faute de source vérifiée."],
            ['p', 'Les cultures de la région ne sont pas détaillées ici, faute de source officielle vérifiée.'],
            ['h2', "Une ville de l\'Indénié"],
            ['p', "La région est associée à l'aire agni de l'Indénié. Les pratiques sociales et linguistiques ne sont pas décrites ici, faute de source vérifiée."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 99 501 habitants (RGPH 2021, ANStat).'],
        ],
    ],

    'bouna' => [
        'name' => 'Bouna',
        'population' => 94883,
        'summary' => 'Chef-lieu du Bounkani, Bouna est une ville du nord-est ivoirien.',
        'blocks' => [
            ['p', "Bouna se trouve à l'extrême nord-est du pays, dans une région de savane, non loin du Burkina Faso et du Ghana. La ville est le chef-lieu de la région du Bounkani."],
            ['h2', 'Le royaume koulango'],
            ['p', "Bouna est associée au royaume koulango. L'histoire et les traditions de ce royaume ne sont pas détaillées ici, faute de source officielle vérifiée."],
            ['p', 'Les échanges commerciaux de la ville ne sont pas décrits dans cette fiche, faute de source vérifiée.'],
            ['h2', 'Élevage et parc national'],
            ['p', "L'économie de la région n'est pas chiffrée dans cette fiche. Le parc national de la Comé est évoqué dans la fiche détaillée, sans affirmation sur sa taille ou sa fréquentation."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 94 883 habitants (RGPH 2021, ANStat).'],
        ],
    ],

    'boundiali' => [
        'name' => 'Boundiali',
        'population' => 92792,
        'summary' => "Chef-lieu de la Bagoué, Boundiali est une ville sénoufo du nord ivoirien, tournée vers le coton et l'anacarde.",
        'blocks' => [
            ['p', "Boundiali se trouve au nord-ouest, sur l'axe qui relie Korhogo à Odienné. La ville est le chef-lieu de la région de la Bagoué, au pays sénoufo."],
            ['h2', 'Le coton'],
            ['p', "Le coton et l'anacarde sont des cultures importantes de la région. Les chiffres de production et l'histoire de la filière ne sont pas repris ici, faute de source officielle vérifiée."],
            ['p', 'Les traditions sénoufo de la région ne sont pas décrites ici : les affirmations sur les sculpteurs ne sont pas sourcées.'],
            ['h2', 'Une ville de services'],
            ['p', 'Les équipements de la ville ne sont pas détaillés dans cette fiche, faute de source vérifiée.'],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 92 792 habitants (RGPH 2021, ANStat).'],
        ],
    ],

    'tengrela' => [
        'name' => 'Tengréla',
        'population' => 92454,
        'summary' => 'Tengréla est une ville du nord ivoirien, à la frontière malienne.',
        'blocks' => [
            ['p', "Tengréla se trouve à l'extrême nord, à la frontière du Mali, sur la route qui mène à Bamako par Zégoua. La ville est le chef-lieu du département du même nom, dans la région de la Bagoué."],
            ['h2', 'Le passage du nord'],
            ['p', 'La position frontalière fait de Tengréla un lieu de passage. Les flux commerciaux avec le Mali ne sont pas chiffrés dans cette fiche, faute de source officielle vérifiée.'],
            ['p', "Les cultures et l'élevage de la région ne sont pas détaillés ici, faute de source vérifiée."],
            ['h2', 'Une ville sénoufo'],
            ['p', "La composition de la population n'est pas décrite dans cette fiche, faute de source officielle vérifiée."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 92 454 habitants (RGPH 2021, ANStat).'],
        ],
    ],

    'sikensi' => [
        'name' => 'Sikensi',
        'population' => 91032,
        'summary' => "Sikensi, dans l'Agnéby-Tiassa, est une ville du sud ivoirien.",
        'blocks' => [
            ['p', "Sikensi se trouve au sud-est, sur la route qui relie Abidjan à Yamoussoukro par la forêt, entre Agboville et Dabou. La ville est le chef-lieu du département du même nom, dans la région de l'Agnéby-Tiassa."],
            ['h2', 'Le pays abidji'],
            ['p', 'La région est associée au pays abidji. Les pratiques culturelles et la biodiversité de la forêt classée ne sont pas décrites ici, faute de source officielle vérifiée.'],
            ['h2', 'Hévéa et cacao'],
            ['p', "L'hévéa et le cacao sont cultivés dans la région ; les volumes de production ne sont pas chiffrés ici, faute de source vérifiée."],
            ['p', "La proximité d'Abidjan et le rôle de la ville pour les villages voisins ne sont pas détaillés dans cette fiche."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 91 032 habitants (RGPH 2021, ANStat).'],
        ],
    ],

    'katiola' => [
        'name' => 'Katiola',
        'population' => 90641,
        'summary' => "Chef-lieu du Hambol, Katiola est la ville des potières tagbanas, au cœur d'une région de savane et de coton.",
        'blocks' => [
            ['p', "Katiola se trouve au centre-nord, sur l'axe qui relie Bouaké à Korhogo. La ville est le chef-lieu de la région du Hambol et le centre du pays tagbana."],
            ['h2', 'La poterie des femmes'],
            ['p', 'Katiola est associée à la poterie tagbana. Le savoir-faire et ses débouchés commerciaux ne sont pas détaillés ici, faute de source officielle vérifiée.'],
            ['p', 'Les traditions sénoufo et tagbana de la région ne sont pas décrites ici, faute de source vérifiée.'],
            ['h2', 'Coton, anacarde et élevage'],
            ['p', "Les cultures et l'élevage de la région ne sont pas chiffrés ici, faute de source officielle vérifiée."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 90 641 habitants (RGPH 2021, ANStat).'],
        ],
    ],

    'toumodi' => [
        'name' => 'Toumodi',
        'population' => 88580,
        'summary' => 'Chef-lieu du Bélier, Toumodi est une ville baoulé des Lacs, entre cacao, anacarde et élevage, à proximité de Yamoussoukro.',
        'blocks' => [
            ['p', 'Toumodi se trouve au centre du pays, dans la région des Lacs, à une trentaine de kilomètres de Yamoussoukro. La ville est le chef-lieu de la région du Bélier.'],
            ['h2', 'Pays baoulé'],
            ['p', "La région est baoulé. Les villages s'organisent autour de la chefferie et des classes d'âge, et les fêtes de récolte, notamment celle de l'igname, restent des moments forts. Le français s'est installé dans l'administration, mais le baoulé demeure la langue du quotidien."],
            ['p', "Le rôle politique historique de la ville n'est pas repris ici : l'affirmation sur le Rassemblement démocratique africain n'est pas sourcée."],
            ['h2', 'Cacao, anacarde et élevage'],
            ['p', 'Les cultures de la région ne sont pas chiffrées dans cette fiche, faute de source officielle vérifiée.'],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 88 580 habitants (RGPH 2021, ANStat).'],
        ],
    ],

];
