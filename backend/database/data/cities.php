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
        'summary' => 'Chef-lieu du Haut-Sassandra et troisième ville du pays, Daloa est le grand marché du cacao et le carrefour du centre-ouest ivoirien.',
        'blocks' => [
            ['p', "Daloa s'étend sur un plateau du centre-ouest, à mi-chemin entre la forêt du sud et les savanes du nord. De toutes les villes ivoiriennes, c'est l'une des plus traversées : les routes de Bouaflé, d'Issia, de Séguéla et de Gagnoa s'y croisent, et le marché qui en résulte fait vivre une bonne partie du pays bété et gouro alentour."],
            ['h2', 'Une ville née du cacao'],
            ['p', "La ville s'est développée au XXe siècle avec la culture du cacao, qui a gagné les forêts du centre-ouest à partir des années 1930. Daloa est devenue le point de collecte d'une vaste région productrice : les camions y arrivent chargés des villages voisins, les acheteurs y pèsent les sacs, et les marchés de la ville fixent une partie des prix de la campagne."],
            ['p', "Le café, longtemps deuxième culture de la région, a beaucoup reculé ; l'anacarde et le vivrier ont pris sa place dans les champs. L'économie de la ville reste très liée aux saisons agricoles, avec des mois de forte activité et des mois plus creux."],
            ['h2', 'Une population jeune'],
            ['p', 'Daloa comptait 421 879 habitants au recensement de 2021, ce qui en fait la troisième ville du pays après Abidjan et Bouaké. Sa population est jeune, scolarisée dans les lycées et les grandes écoles de la ville, et beaucoup de ses habitants vivent du commerce, du transport et de la transformation des produits agricoles.'],
            ['h2', 'Vie quotidienne'],
            ['p', 'Le grand marché, les gares routières et les quartiers périphériques donnent le rythme. Comme dans la plupart des villes moyennes du pays, les maquis, les terrains de football et les églises du dimanche tiennent une place importante dans la vie sociale, et les familles restent largement élargies.'],
        ],
    ],

    'divo' => [
        'name' => 'Divo',
        'population' => 294559,
        'summary' => "Chef-lieu du Lôh-Djiboua, Divo est une ville de forêt du sud ivoirien, au cœur d'un bassin cacaoyer et à quelques heures d'Abidjan.",
        'blocks' => [
            ['p', 'Divo se trouve au sud du pays, dans la zone forestière qui relie Abidjan à Gagnoa. La ville est le chef-lieu de la région du Lôh-Djiboua et le siège de plusieurs services déconcentrés qui desservent les villages alentour.'],
            ['h2', 'Une économie de plantation'],
            ['p', "Le cacao domine : les campagnes autour de Divo font partie des zones de production les plus denses de Côte d'Ivoire. À la saison, les pistes se remplissent de camions et les centres de collecte tournent à plein. Le café, l'hévéa et les cultures vivrières complètent les revenus des familles paysannes."],
            ['p', "La ville elle-même vit de ce commerce agricole, des transports, de l'artisanat et des services. Les marchés hebdomadaires restent le lieu où se règlent une grande partie des échanges entre villages et ville."],
            ['h2', 'Une ville-carrefour'],
            ['p', "Divo occupe une position de passage : plusieurs axes routiers y convergent, et la ville sert d'étape entre le littoral et le centre du pays. Cette situation a favorisé l'installation de commerçants venus de tout le pays et des pays voisins."],
            ['h2', 'Démographie'],
            ['p', "Le recensement de 2021 y compte 294 559 habitants. La croissance urbaine est alimentée à la fois par la natalité et par l'arrivée de familles venues des villages chercher l'école, le dispensaire ou un petit emploi."],
        ],
    ],

    'gagnoa' => [
        'name' => 'Gagnoa',
        'population' => 277044,
        'summary' => "Chef-lieu du Gôh, Gagnoa est la grande ville du pays bété, au centre d'une zone forestière vouée au cacao et au vivrier.",
        'blocks' => [
            ['p', "Gagnoa se situe au centre-ouest de la Côte d'Ivoire, dans une région de forêt humide. La ville est le chef-lieu de la région du Gôh et l'un des principaux centres urbains du pays bété."],
            ['h2', 'Le pays bété'],
            ['p', "La région est le cœur du pays bété, dont la langue et les institutions villageoises structurent encore largement la vie sociale. Les chefferies, les classes d'âge et les fêtes de récolte y gardent une place que les villes n'ont pas effacée."],
            ['p', "Gagnoa a joué un rôle politique important dans l'histoire du pays, notamment pendant les débats sur la terre et la nationalité des planteurs dans les années 1990. La ville en garde une mémoire vive, encore discutée aujourd'hui."],
            ['h2', 'Cacao, café et vivrier'],
            ['p', "L'économie repose sur les plantations : cacao surtout, mais aussi café, hévéa, banane et cultures vivrières. Le marché de Gagnoa approvisionne une large partie de la région, et les activités de transport occupent une place importante."],
            ['h2', 'Démographie'],
            ['p', "Au recensement de 2021, Gagnoa compte 277 044 habitants. La ville dispose de lycées, d'un hôpital de référence et d'établissements techniques qui en font un pôle d'éducation pour tout le centre-ouest."],
        ],
    ],

    'soubre' => [
        'name' => 'Soubré',
        'population' => 272773,
        'summary' => "Chef-lieu de la Nawa, Soubré est la ville du barrage sur le Sassandra et l'un des grands centres de production de cacao du pays.",
        'blocks' => [
            ['p', 'Soubré est bâtie sur la rive du Sassandra, dans le sud-ouest forestier. La ville commande la route qui descend vers San-Pédro et celle qui remonte vers Daloa, ce qui en fait un carrefour pour toute la région.'],
            ['h2', 'Le barrage'],
            ['p', "Le barrage hydroélectrique de Soubré, mis en service au milieu des années 2010, a changé la ville : il fournit de l'électricité au réseau national, a créé un lac en amont et a amené des milliers de travailleurs pendant le chantier. Les infrastructures qui l'accompagnent — routes, logements, écoles — ont accéléré la croissance urbaine."],
            ['p', 'Le fleuve reste au centre de la vie locale : pêche, transport de marchandises et lavage des véhicules sur les berges, tandis que les crues rappellent chaque année la prudence nécessaire.'],
            ['h2', 'La ceinture cacaoyère'],
            ['p', "Autour de Soubré s'étend l'un des bassins cacaoyers les plus productifs de Côte d'Ivoire, ouvert à la culture dans les années 1970 et 1980. Les villages de planteurs y sont nombreux, et la ville vit au rythme des campagnes : achats, pesée, transport vers San-Pédro."],
            ['h2', 'Démographie'],
            ['p', "Le recensement de 2021 compte 272 773 habitants à Soubré. La ville est jeune et connaît une croissance rapide, portée par l'immigration agricole venue de tout le pays et des pays voisins."],
        ],
    ],

    'duekoue' => [
        'name' => 'Duékoué',
        'population' => 220953,
        'summary' => "Chef-lieu du Guémon, Duékoué est un carrefour de l'ouest ivoirien, entre forêt, plantations de cacao et routes vers Man et Guiglo.",
        'blocks' => [
            ['p', "Duékoué se trouve à l'ouest, sur l'axe qui relie Daloa à Man et à la frontière libérienne. Sa position de carrefour en a fait un lieu d'échanges entre le pays bété, le pays guéré et les communautés venues du nord chercher des terres."],
            ['h2', 'Une terre de plantations'],
            ['p', "La région est couverte de plantations de cacao, de café et d'hévéa, ouvertes progressivement dans la forêt. Les villages alentour vivent de ces cultures et des marchés hebdomadaires où se retrouvent planteurs, acheteurs et revendeurs."],
            ['p', "La question foncière y est sensible : l'arrivée de planteurs venus d'autres régions, dans un pays où la terre se transmet par la coutume, a nourri des tensions que les institutions locales s'efforcent d'arbitrer."],
            ['h2', 'Une mémoire douloureuse'],
            ['p', "Duékoué a été l'un des théâtres des violences de la crise post-électorale de 2010-2011. La ville porte cette mémoire, et les projets de réconciliation, de retour des déplacés et de reconstruction y ont été nombreux. En parler avec prudence fait partie du travail encyclopédique."],
            ['h2', 'Démographie'],
            ['p', "Le recensement de 2021 compte 220 953 habitants. La ville dispose d'un hôpital, de lycées et d'un marché important pour la région du Guémon."],
        ],
    ],

    'bouafle' => [
        'name' => 'Bouaflé',
        'population' => 213967,
        'summary' => 'Chef-lieu de la Marahoué, Bouaflé est une ville de savane boisée au bord du lac de Kossou, tournée vers le cacao, le riz et le maraîchage.',
        'blocks' => [
            ['p', 'Bouaflé se trouve au centre-ouest, dans une zone de transition entre forêt et savane. La ville est le chef-lieu de la région de la Marahoué et vit au contact des pays gouro et yaouré.'],
            ['h2', 'Le lac de Kossou'],
            ['p', "Le lac de Kossou, formé par le barrage hydroélectrique sur le Bandama, s'étend à proximité de la ville. Il a transformé la région : pêche, transport par pirogue et cultures de décrue se sont ajoutés aux activités agricoles, et le lac est devenu un repère du paysage local."],
            ['h2', 'Cacao et vivrier'],
            ['p', "Les plantations de cacao, de café et d'hévéa occupent une bonne partie des terres, mais la région produit aussi du riz, du maïs, de l'igname et des légumes. Le maraîchage, pratiqué souvent par des femmes, approvisionne les marchés de la ville et une partie du centre du pays."],
            ['p', "Le marché central et les gares routières concentrent l'activité : on y vient des villages pour vendre, acheter, soigner ou scolariser les enfants."],
            ['h2', 'Démographie'],
            ['p', "Au recensement de 2021, Bouaflé compte 213 967 habitants. La ville a connu une forte croissance depuis les années 1970, portée par l'immigration agricole et le développement des services."],
        ],
    ],

    'guiglo' => [
        'name' => 'Guiglo',
        'population' => 171454,
        'summary' => "Chef-lieu de la Cavally, Guiglo est la porte du parc national de Taï et l'une des villes les plus à l'ouest du pays.",
        'blocks' => [
            ['p', "Guiglo se situe à l'ouest, sur l'axe qui mène de Duékoué à la frontière libérienne. La ville est le chef-lieu de la région de la Cavally et un point de passage pour les échanges avec le Liberia."],
            ['h2', 'La forêt et Taï'],
            ['p', "Guiglo est la dernière grande ville avant le parc national de Taï, l'une des dernières forêts primaires d'Afrique de l'Ouest, classée au patrimoine mondial. Le parc, les réserves qui l'entourent et les plantations de cacao forment l'essentiel du paysage et de l'économie de la région."],
            ['p', "La conservation et l'agriculture se disputent la même terre : les superficies protégées ont reculé sous la pression des plantations, et les programmes de reboisement, de surveillance et de cultures pérennes tentent de stabiliser la lisière."],
            ['h2', 'Frontière et commerce'],
            ['p', 'La proximité du Liberia a longtemps fait de Guiglo une ville de passage, marquée par les migrations et par les crises régionales. Le commerce transfrontalier, le transport et la transformation du cacao restent les principales activités.'],
            ['h2', 'Démographie'],
            ['p', "Le recensement de 2021 compte 171 454 habitants. La population est jeune et diverse, mêlant Guéré, Wobé, planteurs venus du nord et communautés venues de l'autre côté de la frontière."],
        ],
    ],

    'lakota' => [
        'name' => 'Lakota',
        'population' => 169330,
        'summary' => "Lakota, dans le Lôh-Djiboua, est une ville de forêt du pays dida et bété, entourée de plantations de cacao et d'hévéa.",
        'blocks' => [
            ['p', "Lakota se trouve au sud du pays, à l'ouest de Divo, dans une zone forestière densément plantée. La ville est le chef-lieu du département du même nom et un centre de services pour les villages alentour."],
            ['h2', 'Plantations et marchés'],
            ['p', "Le cacao, l'hévéa et le palmier à huile structurent l'économie locale. Les campagnes de collecte rythment l'année, et les marchés de Lakota servent de rendez-vous aux planteurs, aux acheteurs et aux commerçants de la région."],
            ['p', "La ville dispose d'établissements scolaires, d'un hôpital de référence et de services administratifs qui en font un relais entre les villages et Divo, le chef-lieu de région."],
            ['h2', 'Sociétés et cultures'],
            ['p', 'Lakota se situe au contact des pays dida et bété. Les fêtes villageoises, les funérailles et les réunions de chefferie restent des moments forts de la vie sociale, et les langues locales demeurent largement pratiquées.'],
            ['h2', 'Démographie'],
            ['p', "Le recensement de 2021 compte 169 330 habitants. Comme dans beaucoup de villes du sud forestier, la croissance s'appuie à la fois sur la natalité et sur l'arrivée de familles de planteurs."],
        ],
    ],

    'abengourou' => [
        'name' => 'Abengourou',
        'population' => 164424,
        'summary' => "Chef-lieu de l'Indénié-Djuablin, Abengourou est la capitale du royaume agni de l'Indénié et la grande ville de l'est ivoirien.",
        'blocks' => [
            ['p', "Abengourou se trouve à l'est, sur l'axe qui relie Abidjan au Ghana par Aboisso. La ville est le chef-lieu de la région de l'Indénié-Djuablin et le siège du royaume agni de l'Indénié, l'une des grandes chefferies du sud ivoirien."],
            ['h2', 'Le royaume agni'],
            ['p', "L'histoire de la ville se confond avec celle du royaume, fondé par des Agni venus de l'actuel Ghana. Le roi, appelé encore aujourd'hui roi de l'Indénié, continue de jouer un rôle coutumier et moral important ; les cérémonies de sa cour et la fête des ignames restent des moments attendus."],
            ['p', "Le français s'est imposé dans l'administration, mais l'agni et le baoulé restent les langues du quotidien, et l'or, le poids des années 1930 dans la région, a marqué les mémoires villageoises."],
            ['h2', 'Cacao et commerce'],
            ['p', "La région d'Abengourou est un grand bassin cacaoyer. Les plantations occupent l'essentiel des terres, avec le café et le vivrier, et la ville sert de centre d'achat, de transport et de services pour tout l'est, jusqu'à Agnibilékrou et Bondoukou."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 164 424 habitants. La ville possède un lycée, un hôpital de référence et un marché dont le rayonnement dépasse largement la région.'],
        ],
    ],

    'ferkessedougou' => [
        'name' => 'Ferkessédougou',
        'population' => 160267,
        'summary' => 'Chef-lieu du Tchologo, Ferkessédougou est la ville du sucre ivoirien et un carrefour routier majeur du nord du pays.',
        'blocks' => [
            ['p', 'Ferkessédougou — « Ferké » pour tout le monde — se trouve au nord, sur la grande route qui monte vers Ouagadougou. La ville est le chef-lieu de la région du Tchologo, au pays sénoufo.'],
            ['h2', 'Le sucre'],
            ['p', "C'est l'industrie sucrière qui a fait la réputation de Ferké : les plantations de canne et l'usine de la Société sucrière de Côte d'Ivoire, installées depuis les années 1970, emploient une partie importante de la population et structurent l'économie locale. Le sucre produit part vers tout le pays."],
            ['p', "Autour de la canne, les paysans cultivent aussi le riz, le coton, l'anacarde et le maïs. L'élevage, important dans le nord, se pratique en complément des cultures."],
            ['h2', 'Carrefour du nord'],
            ['p', "La ville occupe une position stratégique : la route et le chemin de fer Abidjan-Ouagadougou y passent, et les voyageurs s'y arrêtent entre Bouaké et la frontière burkinabè. Ce trafic nourrit les métiers du transport, de la restauration et du commerce."],
            ['h2', 'Démographie'],
            ['p', "Le recensement de 2021 compte 160 267 habitants. La ville est jeune, travailleuse, et reste l'un des pôles industriels du nord ivoirien."],
        ],
    ],

    'adzope' => [
        'name' => 'Adzopé',
        'population' => 156488,
        'summary' => "Chef-lieu de La Mé, Adzopé est une ville du pays attié, à l'intérieur des terres entre Abidjan et Agboville.",
        'blocks' => [
            ['p', "Adzopé se trouve au sud-est, sur l'axe qui relie Abidjan à Agboville par les terres. La ville est le chef-lieu de la région de La Mé et le centre du pays attié."],
            ['h2', 'Le pays attié'],
            ['p', "Les Attié, ou Akyé, occupent cette région forestière depuis des siècles. Leurs chefferies, leurs fêtes de génération et leur cuisine — l'attiéké, l'âge de son huile de palme — restent des marqueurs forts de l'identité locale."],
            ['p', "La région a vu se développer les plantations familiales à l'époque coloniale, puis les cultures de rente financées par l'État. Le cacao, le café, l'hévéa et le palmier à huile restent les piliers de l'économie."],
            ['h2', 'Une ville de services'],
            ['p', "Adzopé accueille des services administratifs, des établissements scolaires et un hôpital qui rayonne sur les villages alentour. Sa proximité d'Abidjan, à moins de deux heures de route, a favorisé les allers-retours quotidiens et l'installation de commerçants."],
            ['h2', 'Démographie'],
            ['p', "Le recensement de 2021 compte 156 488 habitants. La population augmente avec la croissance d'Abidjan, dont la ville devient une périphérie lointaine pour ceux qui cherchent un terrain ou un emploi moins cher."],
        ],
    ],

    'meagui' => [
        'name' => 'Méagui',
        'population' => 153483,
        'summary' => "Méagui, dans la Nawa, est l'un des grands bassins cacaoyers du sud-ouest ivoirien, né de l'ouverture des forêts de la région.",
        'blocks' => [
            ['p', "Méagui se situe au sud-ouest, entre Soubré et San-Pédro, dans la zone forestière la plus récemment mise en culture du pays. La ville s'est développée avec l'arrivée de planteurs venus du centre et de l'ouest."],
            ['h2', 'Le cacao, moteur de la ville'],
            ['p', 'Les plantations de cacao ont gagné la forêt à partir des années 1970. Méagui est devenue une ville de collecte : les camions y chargent les sacs avant de prendre la route du port de San-Pédro, et les entrepôts servent de repère à toute la région.'],
            ['p', "La culture du cacao s'accompagne de vivrier — banane plantain, riz, manioc — et, sur les fronts pionniers, d'une déforestation qui a profondément transformé le paysage. Les programmes de replantation et d'agroforesterie y trouvent un intérêt particulier."],
            ['h2', 'Une ville en construction'],
            ['p', 'Méagui reste une ville jeune, en croissance rapide : écoles, centres de santé et pistes rurales se mettent en place au rythme de la production agricole. Une partie des terres reste soumise à des litiges fonciers que les autorités locales tranchent.'],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 153 483 habitants. La ville figure parmi les plus peuplées du pays et sa population est très jeune.'],
        ],
    ],

    'bondoukou' => [
        'name' => 'Bondoukou',
        'population' => 141568,
        'summary' => "Chef-lieu du Gontougo, Bondoukou est l'ancienne ville caravanière et sainte de l'est ivoirien, célèbre pour ses mosquées en terre.",
        'blocks' => [
            ['p', "Bondoukou se trouve à l'extrême est de la Côte d'Ivoire, à quelques dizaines de kilomètres du Ghana. La ville est le chef-lieu de la région du Gontougo et l'un des plus anciens centres urbains du pays."],
            ['h2', 'Une ville de caravanes'],
            ['p', "Située sur l'axe commercial qui reliait les savanes du Sahel aux marchés du golfe de Guinée, Bondoukou a prospéré grâce au commerce des noix de kola, du sel, des tissus et de l'or. Sa fondation remonterait au Moyen Âge, et sa communauté musulmane est l'une des plus anciennes du pays."],
            ['p', "La ville est surnommée « la ville aux sept mosquées ». Leurs minarets en terre crue, bâtis selon le modèle soudano-sahélien, comptent parmi les derniers de ce type en Côte d'Ivoire ; plusieurs sont restaurés par les habitants avec l'appui de programmes patrimoniaux."],
            ['h2', 'Anacarde et commerce'],
            ['p', "Aujourd'hui, Bondoukou vit de l'anacarde, du maïs, de l'élevage et du commerce frontalier avec le Ghana. Le marché reste le cœur de la ville, avec ses quartiers historiques (Kodjina, Jimini, Liguezambo) où vivent Koulango, Abron et Dioula."],
            ['h2', 'Démographie'],
            ['p', "Le recensement de 2021 compte 141 568 habitants. La ville est un pôle culturel de l'est, avec ses fêtes religieuses, sa musique et son artisanat du cuir et des tissus."],
        ],
    ],

    'dabou' => [
        'name' => 'Dabou',
        'population' => 138083,
        'summary' => 'Chef-lieu des Grands-Ponts, Dabou est une ville de lagune du pays adioukrou, entre pêche, palmier à huile et maraîchage.',
        'blocks' => [
            ['p', "Dabou se trouve au sud, sur la rive nord de la lagune Ébrié, à l'ouest d'Abidjan. La ville est le chef-lieu de la région des Grands-Ponts et le centre du pays adioukrou."],
            ['h2', "Une ville d'eau"],
            ['p', "La lagune commande la vie locale : pêche au filet, transport par pirogue, exploitation du sable et passerelles qui relient les quartiers. Dabou a longtemps été plus facilement accessible en bateau depuis Abidjan qu'en voiture, et les embarcations lagunaires restent un moyen de transport courant."],
            ['p', 'Les paysages de lagunes, de mangroves et de cocotiers attirent une petite activité touristique et balnéaire, encore modeste.'],
            ['h2', 'Palme, cacao et maraîchage'],
            ['p', "Le palmier à huile et le cacao occupent les terres sèches, tandis que les bas-fonds accueillent du maraîchage qui alimente les marchés d'Abidjan. L'élevage et la transformation artisanale du poisson complètent les revenus."],
            ['h2', 'Démographie'],
            ['p', "Le recensement de 2021 compte 138 083 habitants. La croissance est portée par la proximité de la capitale économique, où beaucoup d'habitants vont travailler ou commercer."],
        ],
    ],

    'sinfra' => [
        'name' => 'Sinfra',
        'population' => 137210,
        'summary' => 'Sinfra, au sud de la Marahoué, est un carrefour agricole du pays gouro, entre Bouaflé, Daloa et Gagnoa.',
        'blocks' => [
            ['p', "Sinfra se trouve au centre-ouest, sur l'axe qui relie Bouaflé à Daloa et Gagnoa. La ville est le chef-lieu du département du même nom, dans la région de la Marahoué."],
            ['h2', 'Un carrefour de produits'],
            ['p', "Sinfra est un point de passage et d'échange : les camions de cacao et de vivrier y font halte, et les marchés de la ville rassemblent planteurs, revendeuses et transporteurs. L'activité est très liée aux récoltes de la région."],
            ['p', "Le cacao, le café et l'hévéa dominent les plantations ; le riz, le manioc et l'igname assurent l'alimentation des familles, tandis que le maraîchage progresse le long des bas-fonds."],
            ['h2', 'Sociétés gouro et bété'],
            ['p', "La ville est au contact des pays gouro et bété. Les chefferies, les sociétés d'initiation et les fêtes de récolte y gardent leur importance, et les langues locales restent vivantes à côté du français."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 137 210 habitants. La population est jeune et rurale dans ses attaches, même si la ville concentre écoles, centre de santé et commerces.'],
        ],
    ],

    'agboville' => [
        'name' => 'Agboville',
        'population' => 135082,
        'summary' => "Chef-lieu de l'Agnéby-Tiassa, Agboville est la grande ville du pays abbey, sur l'axe ferroviaire et routier d'Abidjan.",
        'blocks' => [
            ['p', "Agboville se trouve au sud-est, à une heure et demie d'Abidjan, sur l'axe routier et ferroviaire qui mène vers le centre du pays. La ville est le chef-lieu de la région de l'Agnéby-Tiassa et le centre du pays abbey."],
            ['h2', 'Le pays abbey'],
            ['p', 'Les Abbey occupent cette région forestière depuis des siècles. Leur chefferie, leurs fêtes de génération et leur organisation villageoise restent des repères importants, et la langue abbey se transmet encore largement.'],
            ['p', "La ville a été un foyer d'évangélisation et d'enseignement à l'époque coloniale, ce qui lui a donné une tradition scolaire ancienne, visible dans ses établissements et dans le nombre de cadres originaires de la région."],
            ['h2', 'Hévéa, cacao et transport'],
            ['p', "L'économie repose sur l'hévéa — dont la région est l'un des grands bassins — le cacao, le café et le vivrier. La proximité d'Abidjan et la voie ferrée ont favorisé les activités de transport et de transformation."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 135 082 habitants. La ville attire les populations des villages voisins et sert de relais administratif pour toute la région.'],
        ],
    ],

    'vavoua' => [
        'name' => 'Vavoua',
        'population' => 132528,
        'summary' => 'Vavoua, dans le Haut-Sassandra, est une ville de plantations au carrefour des routes de Daloa, Séguéla et Sinfra.',
        'blocks' => [
            ['p', 'Vavoua se situe au centre-ouest, au nord de Daloa, sur la route qui monte vers Séguéla. La ville est le chef-lieu du département du même nom, dans la région du Haut-Sassandra.'],
            ['h2', 'Une ville de planteurs'],
            ['p', 'Le cacao et le café ont fait la prospérité de la région, ouverte à la culture au XXe siècle. Les villages alentour vivent des plantations et des marchés hebdomadaires, où se négocient les sacs avant le transport vers Daloa et Abidjan.'],
            ['p', "L'anacarde progresse dans les zones plus sèches, et le vivrier occupe une place importante dans l'alimentation et les revenus des femmes."],
            ['h2', 'Au contact du nord'],
            ['p', 'Vavoua se trouve à la charnière entre le pays bété et gouro du sud forestier et les pays malinké et sénoufo du nord. Cette rencontre donne à la ville une population mélangée, où le dioula sert de langue de commerce.'],
            ['h2', 'Démographie'],
            ['p', "Le recensement de 2021 compte 132 528 habitants. La ville dispose de lycées, d'un hôpital de référence et d'un marché actif pour toute la zone."],
        ],
    ],

    'danane' => [
        'name' => 'Danané',
        'population' => 131586,
        'summary' => "Danané, dans le Tonkpi, est une ville de montagne de l'ouest ivoirien, proche du Liberia et de la Guinée.",
        'blocks' => [
            ['p', "Danané se trouve à l'extrême ouest, dans une région de collines et de forêt, non loin des frontières du Liberia et de la Guinée. La ville est le chef-lieu du département du même nom, dans la région du Tonkpi."],
            ['h2', 'Le pays dan'],
            ['p', "La région est le cœur du pays dan (ou yacouba). Les masques, les sociétés initiatiques et les fêtes de récolte y occupent une place centrale, et les danses masquées de l'ouest sont parmi les plus connues du pays."],
            ['p', "Le relief, avec ses collines et ses cascades, donne à Danané un cadre inhabituel en Côte d'Ivoire ; la ville sert de point de départ pour les randonnées vers les monts alentour."],
            ['h2', 'Cacao et frontière'],
            ['p', "L'économie repose sur le cacao, le café, le riz et l'élevage. La proximité des frontières a longtemps fait de Danané une ville de passage et de commerce, avec les flux de populations que les crises régionales ont entraînés."],
            ['h2', 'Démographie'],
            ['p', "Le recensement de 2021 compte 131 586 habitants. La ville est jeune, et l'école y tient une place importante pour les familles des villages voisins."],
        ],
    ],

    'oume' => [
        'name' => 'Oumé',
        'population' => 127153,
        'summary' => 'Oumé, dans le Gôh, est une ville forestière du pays gouro, entourée de plantations de cacao et de café.',
        'blocks' => [
            ['p', 'Oumé se trouve au centre-sud, entre Gagnoa et Toumodi, dans une zone de forêt et de savane boisée. La ville est le chef-lieu du département du même nom, dans la région du Gôh.'],
            ['h2', 'Pays gouro'],
            ['p', "La région est gouro. Les masques et les danses de la société du poro, les fêtes de récolte et les chefferies villageoises structurent encore la vie sociale, même si la ville a grandi autour de l'administration et du marché."],
            ['h2', 'Cacao et vivrier'],
            ['p', "Le cacao est la principale culture de rente, avec le café et l'hévéa. Le riz, l'igname et le manioc assurent la subsistance, et le marché d'Oumé approvisionne les villages d'alentour."],
            ['p', "La ville sert de relais administratif et scolaire pour la région. Les pistes rurales, souvent dégradées en saison des pluies, conditionnent l'accès des villages aux services."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 127 153 habitants. La proximité de Yamoussoukro et de Gagnoa favorise les échanges commerciaux et les déplacements.'],
        ],
    ],

    'issia' => [
        'name' => 'Issia',
        'population' => 126252,
        'summary' => "Issia, dans le Haut-Sassandra, est une ville de plantations de l'ouest du pays bété, au bord du Sassandra.",
        'blocks' => [
            ['p', "Issia se trouve à l'ouest de Daloa, dans la région forestière du Haut-Sassandra. La ville est le chef-lieu du département du même nom et un centre de collecte pour les villages alentour."],
            ['h2', 'Le cacao et le fleuve'],
            ['p', "Les plantations de cacao, de café et d'hévéa occupent l'essentiel des terres. Le Sassandra, qui traverse la région, fournit du poisson et de l'eau aux villages riverains, et son franchissement a longtemps conditionné les échanges avec l'ouest."],
            ['p', "L'économie locale dépend étroitement des campagnes agricoles : les prix d'achat du cacao, le transport et la pluviométrie font varier les revenus d'une année à l'autre."],
            ['h2', 'Vie de la ville'],
            ['p', "Issia dispose de lycées, d'un hôpital de référence et d'un marché actif. Les fêtes villageoises, les funérailles et les rassemblements de chefferie rythment la vie sociale, où les langues bété et gouro restent majoritaires."],
            ['h2', 'Démographie'],
            ['p', "Le recensement de 2021 compte 126 252 habitants. La ville a connu une croissance soutenue depuis les années 1970, portée par l'immigration agricole."],
        ],
    ],

    'blolequin' => [
        'name' => 'Bloléquin',
        'population' => 123133,
        'summary' => "Bloléquin, dans la Cavally, est une ville de forêt de l'ouest ivoirien, tournée vers le cacao et le commerce avec le Liberia.",
        'blocks' => [
            ['p', "Bloléquin se situe à l'ouest, sur la route qui relie Guiglo à la frontière libérienne. La ville est le chef-lieu du département du même nom, dans la région de la Cavally."],
            ['h2', 'Forêt et plantations'],
            ['p', 'La région est couverte de forêt et de plantations de cacao, ouvertes progressivement par les planteurs guéré et par les migrants venus du centre et du nord. La collecte du cacao reste la principale source de revenus.'],
            ['p', "La proximité du parc national de Taï et des forêts classées impose des arbitrages entre protection et agriculture : les programmes de reboisement et d'agroforesterie tentent de stabiliser les lisières."],
            ['h2', 'Une ville frontalière'],
            ['p', "Le commerce avec le Liberia, le transport et les marchés hebdomadaires animent la ville. L'histoire récente de la région, marquée par les crises ivoiriennes et libériennes, a laissé des traces dans les villages et dans les relations entre communautés."],
            ['h2', 'Démographie'],
            ['p', "Le recensement de 2021 compte 123 133 habitants. La population est jeune et vit largement de l'agriculture familiale."],
        ],
    ],

    'bonon' => [
        'name' => 'Bonon',
        'population' => 116871,
        'summary' => 'Bonon, dans la Marahoué, est une ville de plantations au carrefour des routes de Bouaflé et de Daloa.',
        'blocks' => [
            ['p', "Bonon se trouve au centre-ouest, sur l'axe qui relie Bouaflé à Daloa. La ville est le chef-lieu du département du même nom, dans la région de la Marahoué."],
            ['h2', 'Le cacao avant tout'],
            ['p', "Les plantations de cacao dominent l'économie, avec le café, l'hévéa et le vivrier. Les campagnes de collecte amènent chaque année des milliers de sacs dans les centres d'achat de la ville et des villages voisins."],
            ['p', 'Le marché de Bonon est un lieu de rencontre pour les planteurs gouro et les communautés venues du nord, qui travaillent souvent comme métayers ou manœuvres agricoles.'],
            ['h2', 'Services et scolarisation'],
            ['p', "La ville dispose de lycées, d'un centre de santé de référence et de services administratifs. Les pistes rurales restent le principal obstacle pour les villages éloignés, surtout en saison des pluies."],
            ['h2', 'Démographie'],
            ['p', "Le recensement de 2021 compte 116 871 habitants. La croissance urbaine suit celle des plantations et de l'immigration agricole."],
        ],
    ],

    'zouan-hounien' => [
        'name' => 'Zouan-Hounien',
        'population' => 111099,
        'summary' => "Zouan-Hounien, dans le Tonkpi, est une ville frontalière de l'ouest ivoirien, connue pour ses plantations et l'exploitation aurifère d'Ity.",
        'blocks' => [
            ['p', "Zouan-Hounien se trouve à l'extrême ouest, contre la frontière libérienne, dans la région du Tonkpi. La ville est le chef-lieu du département du même nom."],
            ['h2', "L'or et le cacao"],
            ['p', "Le département abrite la mine d'or d'Ity, exploitée depuis les années 1990 et l'une des plus anciennes du pays. L'activité minière emploie directement et indirectement une partie de la population, et a fait venir des travailleurs de tout le pays."],
            ['p', "Le cacao, le café et le riz complètent l'économie. La région est aussi un pays de forêt et de collines, où les masques dan et les fêtes de récolte gardent leur place."],
            ['h2', 'Une frontière active'],
            ['p', 'La proximité du Liberia fait de Zouan-Hounien un lieu de commerce transfrontalier, avec ses marchés et ses flux de populations. Les crises régionales y ont laissé des séquelles, et les programmes de pacification ont accompagné le retour des habitants.'],
            ['h2', 'Démographie'],
            ['p', "Le recensement de 2021 compte 111 099 habitants. La ville est jeune, et l'or comme le cacao y attirent des migrants saisonniers."],
        ],
    ],

    'seguela' => [
        'name' => 'Séguéla',
        'population' => 103980,
        'summary' => 'Chef-lieu du Worodougou, Séguéla est une ville du nord-ouest ivoirien, au carrefour des routes de Daloa et de Touba.',
        'blocks' => [
            ['p', 'Séguéla se trouve au nord-ouest, dans une région de savane boisée, au croisement des routes de Daloa, de Touba et de Mankono. La ville est le chef-lieu de la région du Worodougou.'],
            ['h2', 'Une ville du Worodougou'],
            ['p', "La région, appelée Worodougou — « le pays du woro » —, est le domaine des Malinké et des Sénoufo, avec une forte tradition musulmane. Les villages y vivent de l'agriculture et de l'élevage, et le commerce est souvent tenu par des familles dioula."],
            ['p', "Séguéla a été au cœur de l'histoire politique récente du pays : la ville est la région d'origine de plusieurs dirigeants, et son nom revient dans les récits des crises ivoiriennes."],
            ['h2', 'Anacarde, coton et élevage'],
            ['p', "L'anacarde est devenue la première culture de rente de la région, devant le coton et le maïs. L'élevage bovin, très présent dans le nord-ouest, alimente les marchés de viande du pays."],
            ['h2', 'Démographie'],
            ['p', "Le recensement de 2021 compte 103 980 habitants. La ville dispose d'un hôpital de référence, de lycées et d'un marché qui rayonne sur tout le Worodougou."],
        ],
    ],

    'daoukro' => [
        'name' => 'Daoukro',
        'population' => 101136,
        'summary' => "Chef-lieu de l'Iffou, Daoukro est une ville baoulé du centre-est, au cœur d'une zone de plantations et d'un fief politique connu.",
        'blocks' => [
            ['p', "Daoukro se trouve au centre-est, sur l'axe qui relie Abidjan à Bouaké par la route de Yamoussoukro. La ville est le chef-lieu de la région de l'Iffou."],
            ['h2', 'Une ville baoulé'],
            ['p', "La région appartient au pays baoulé. Les villages y sont organisés autour de la chefferie et des classes d'âge, et la langue baoulé reste la première langue du quotidien. L'agriculture, longtemps fondée sur le café et le cacao, reste le socle de l'économie."],
            ['p', 'Daoukro est aussi une ville politique : elle est la ville natale de Henri Konan Bédié, président de 1993 à 1999, et le siège de son mouvement. Cet ancrage donne à la ville une visibilité nationale qui dépasse sa taille.'],
            ['h2', 'Plantations et services'],
            ['p', "Le cacao, le café, l'anacarde et le vivrier occupent les campagnes. La ville compte des lycées, un hôpital de référence et un marché qui dessert les villages de l'Iffou."],
            ['h2', 'Démographie'],
            ['p', "Le recensement de 2021 compte 101 136 habitants. La population est jeune, et beaucoup d'habitants partent travailler à Abidjan ou à Bouaké."],
        ],
    ],

    'aboisso' => [
        'name' => 'Aboisso',
        'population' => 100903,
        'summary' => 'Chef-lieu du Sud-Comoé, Aboisso est la ville du pays sanwi, entre palmier à huile, cacao et frontière ghanéenne.',
        'blocks' => [
            ['p', "Aboisso se trouve au sud-est, à l'intérieur des terres, sur l'axe qui mène d'Abidjan au Ghana. La ville est le chef-lieu de la région du Sud-Comoé et le centre du pays sanwi."],
            ['h2', 'Le royaume sanwi'],
            ['p', "Le Sanwi est un royaume agni fondé par des migrations venues de l'actuel Ghana. Son roi, installé à Krindjabo, reste une autorité coutumière respectée, et les fêtes royales attirent chaque année des visiteurs de tout le pays."],
            ['p', "L'histoire de la région est marquée par les plantations coloniales et par les tentatives sécessionnistes des années 1960, réprimées par l'État ivoirien — un épisode longtemps peu évoqué et aujourd'hui discuté par les historiens."],
            ['h2', 'Palme, cacao et frontière'],
            ['p', "Le palmier à huile, dont la région est l'un des grands bassins, le cacao et l'hévéa structurent l'économie. La proximité du Ghana alimente un commerce transfrontalier actif, notamment à Adaou et sur les marchés frontaliers."],
            ['h2', 'Démographie'],
            ['p', "Le recensement de 2021 compte 100 903 habitants. La ville dispose de lycées, d'un hôpital de référence et d'un marché important pour tout le Sud-Comoé."],
        ],
    ],

    'buyo' => [
        'name' => 'Buyo',
        'population' => 100848,
        'summary' => 'Buyo, dans la Nawa, est la ville du lac artificiel formé par le barrage sur le Sassandra, entre pêche et cacao.',
        'blocks' => [
            ['p', 'Buyo se situe au sud-ouest, sur le Sassandra, entre Soubré et San-Pédro. La ville est le chef-lieu du département du même nom, dans la région de la Nawa.'],
            ['h2', 'Le lac de Buyo'],
            ['p', 'Le barrage hydroélectrique de Buyo, mis en service au début des années 1980, a créé un vaste lac de retenue en amont. Le lac a transformé la région : pêche au filet et à la nasse, transport par pirogue et cultures de décrue se sont ajoutés aux activités agricoles.'],
            ['p', "Les rives du lac accueillent des campements de pêcheurs, souvent venus du nord et des pays voisins, et le poisson fumé de la région alimente les marchés de San-Pédro et d'Abidjan."],
            ['h2', 'Cacao et forêt'],
            ['p', "Autour du lac, la forêt a largement reculé au profit des plantations de cacao et d'hévéa. Les villages vivent de ces cultures et du commerce du poisson, dans une région où la terre est devenue un enjeu central."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 100 848 habitants. La population est jeune et dépend étroitement des ressources du lac et des plantations.'],
        ],
    ],

    'agnibilekrou' => [
        'name' => 'Agnibilékrou',
        'population' => 99501,
        'summary' => "Agnibilékrou, dans l'Indénié-Djuablin, est une ville frontalière de l'est ivoirien, active par son marché et ses plantations.",
        'blocks' => [
            ['p', "Agnibilékrou se trouve à l'est, contre la frontière ghanéenne, sur la route qui relie Abengourou à Bondoukou. La ville est le chef-lieu du département du même nom."],
            ['h2', 'Un marché frontalier'],
            ['p', "Le marché d'Agnibilékrou est l'un des plus actifs de l'est : on y vient du Ghana voisin vendre et acheter, et les jours de marché transforment la ville en carrefour commercial. Le transport et le petit commerce y occupent une large part de la population."],
            ['p', "Le cacao reste la culture dominante, avec le café, l'anacarde et le vivrier. Les acheteurs y collectent la production d'une vaste zone avant de l'expédier vers Abidjan et le port."],
            ['h2', "Une ville de l\'Indénié"],
            ['p', "La région appartient à l'aire agni de l'Indénié. Les chefferies villageoises, les fêtes de récolte et les funérailles restent des moments structurants, et l'agni se parle encore couramment à côté du français et du dioula."],
            ['h2', 'Démographie'],
            ['p', "Le recensement de 2021 compte 99 501 habitants. La ville est jeune et sa croissance est portée par le commerce frontalier et l'agriculture."],
        ],
    ],

    'bouna' => [
        'name' => 'Bouna',
        'population' => 94883,
        'summary' => "Chef-lieu du Bounkani, Bouna est l'ancienne capitale du royaume koulango, aux portes du parc national de la Comoé.",
        'blocks' => [
            ['p', "Bouna se trouve à l'extrême nord-est du pays, dans une région de savane, non loin du Burkina Faso et du Ghana. La ville est le chef-lieu de la région du Bounkani."],
            ['h2', 'Le royaume koulango'],
            ['p', "Bouna est l'ancienne capitale d'un royaume koulango dont la fondation remonte à plusieurs siècles. Le roi continue d'exercer une autorité coutumière, et la ville conserve une tradition de chefferie et de fêtes qui mêlent héritage koulango, apports lobi et influence musulmane."],
            ['p', "Sa position sur les routes commerciales du nord-est en a fait un lieu d'échanges entre les savanes et les marchés du sud, notamment pour le bétail, les céréales et les noix de kola."],
            ['h2', 'Élevage et parc national'],
            ['p', "L'élevage bovin et les cultures céréalières — mil, sorgho, maïs — dominent l'économie, avec l'anacarde et le coton. Le parc national de la Comoé, l'un des plus vastes d'Afrique de l'Ouest, borde la région et attire un tourisme encore limité."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 94 883 habitants. La ville est un relais administratif et scolaire important pour tout le nord-est.'],
        ],
    ],

    'boundiali' => [
        'name' => 'Boundiali',
        'population' => 92792,
        'summary' => "Chef-lieu de la Bagoué, Boundiali est une ville sénoufo du nord ivoirien, tournée vers le coton et l'anacarde.",
        'blocks' => [
            ['p', "Boundiali se trouve au nord-ouest, sur l'axe qui relie Korhogo à Odienné. La ville est le chef-lieu de la région de la Bagoué, au pays sénoufo."],
            ['h2', 'Le coton'],
            ['p', "Le coton a fait la fortune du nord ivoirien à partir des années 1960 : les campagnes de Boundiali se couvrent chaque année de champs blancs, et les usines d'égrenage transforment la production avant son départ vers les ports. L'anacarde est devenue la seconde culture de rente, devant le maïs et le mil."],
            ['p', 'La ville est aussi un pays de traditions sénoufo : le poro, les masques et les scarifications ont marqué des générations, et les sculpteurs de la région sont parmi les plus réputés du pays.'],
            ['h2', 'Une ville de services'],
            ['p', "Boundiali compte des lycées, un hôpital de référence et un marché qui dessert les villages alentour. L'électrification et l'accès à l'eau restent des enjeux pour les quartiers périphériques."],
            ['h2', 'Démographie'],
            ['p', "Le recensement de 2021 compte 92 792 habitants. La population est jeune et l'émigration vers Abidjan reste importante."],
        ],
    ],

    'tengrela' => [
        'name' => 'Tengréla',
        'population' => 92454,
        'summary' => "Tengréla est la dernière ville ivoirienne avant le Mali, un carrefour commercial du nord tourné vers le coton et l'élevage.",
        'blocks' => [
            ['p', "Tengréla se trouve à l'extrême nord, à la frontière du Mali, sur la route qui mène à Bamako par Zégoua. La ville est le chef-lieu du département du même nom, dans la région de la Bagoué."],
            ['h2', 'Le passage du nord'],
            ['p', 'La position frontalière fait de Tengréla un lieu de transit : camions de coton, de bétail et de marchandises diverses y passent chaque jour, et le commerce avec le Mali fait vivre une partie de la ville. Les contrôles, les formalités douanières et le transport emploient de nombreuses personnes.'],
            ['p', "Le coton et l'anacarde dominent les cultures, avec le maïs, le mil et le sorgho. L'élevage bovin, très présent dans la région, alimente les marchés de viande."],
            ['h2', 'Une ville sénoufo'],
            ['p', 'La population est majoritairement sénoufo, avec une forte communauté dioula commerçante et des éleveurs peuls. Cette diversité se lit dans les langues, les quartiers et les fêtes religieuses.'],
            ['h2', 'Démographie'],
            ['p', "Le recensement de 2021 compte 92 454 habitants. Tengréla reste une ville de passage, où l'activité dépend beaucoup des flux avec le Mali."],
        ],
    ],

    'sikensi' => [
        'name' => 'Sikensi',
        'population' => 91032,
        'summary' => "Sikensi, dans l'Agnéby-Tiassa, est une ville du pays abidji, entre hévéa, cacao et forêt classée.",
        'blocks' => [
            ['p', "Sikensi se trouve au sud-est, sur la route qui relie Abidjan à Yamoussoukro par la forêt, entre Agboville et Dabou. La ville est le chef-lieu du département du même nom, dans la région de l'Agnéby-Tiassa."],
            ['h2', 'Le pays abidji'],
            ['p', 'La région est le pays abidji, un peuple akan dont la langue et les institutions villageoises restent vivantes. Les fêtes de récolte et les cérémonies de chefferie y sont des moments importants, et la forêt classée de la région abrite une biodiversité suivie par les services environnementaux.'],
            ['h2', 'Hévéa et cacao'],
            ['p', "L'hévéa y occupe une place de premier plan : la région est l'un des grands bassins de production de caoutchouc naturel du pays. Le cacao, le palmier à huile et le vivrier complètent les revenus des familles."],
            ['p', "La proximité d'Abidjan favorise les déplacements quotidiens et l'installation de travailleurs, tandis que la ville elle-même sert de relais scolaire et sanitaire pour les villages."],
            ['h2', 'Démographie'],
            ['p', 'Le recensement de 2021 compte 91 032 habitants. La population est jeune, et la croissance suit celle des plantations et de la périphérie abidjanaise.'],
        ],
    ],

    'katiola' => [
        'name' => 'Katiola',
        'population' => 90641,
        'summary' => "Chef-lieu du Hambol, Katiola est la ville des potières tagbanas, au cœur d'une région de savane et de coton.",
        'blocks' => [
            ['p', "Katiola se trouve au centre-nord, sur l'axe qui relie Bouaké à Korhogo. La ville est le chef-lieu de la région du Hambol et le centre du pays tagbana."],
            ['h2', 'La poterie des femmes'],
            ['p', "Katiola est célèbre pour sa poterie : les femmes tagbanas y façonnent à la main des jarres, des canaris et des objets utilitaires, cuits en plein air. Ce savoir-faire, transmis de mère en fille, est l'un des plus connus du pays et fait l'objet d'un marché qui dépasse la région."],
            ['p', 'La ville est aussi un pays de traditions sénoufo et tagbana : le poro, les masques et les fêtes de récolte y marquent encore la vie sociale.'],
            ['h2', 'Coton, anacarde et élevage'],
            ['p', "L'agriculture repose sur le coton, l'anacarde, le maïs et l'igname. L'élevage bovin, important dans la savane du centre-nord, alimente les marchés locaux et les boucheries de Bouaké et d'Abidjan."],
            ['h2', 'Démographie'],
            ['p', "Le recensement de 2021 compte 90 641 habitants. La ville dispose de lycées, d'un hôpital de référence et d'un marché actif pour tout le Hambol."],
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
            ['p', 'Toumodi est aussi une ville de mémoire politique : elle a été un foyer du Rassemblement démocratique africain et un lieu de mobilisation paysanne au XXe siècle, ce que rappellent les récits locaux.'],
            ['h2', 'Cacao, anacarde et élevage'],
            ['p', "Le cacao et le café ont longtemps dominé, avant que l'anacarde ne prenne le relais dans les zones plus sèches. Le vivrier et l'élevage bovin complètent les revenus, et le marché de Toumodi dessert les villages alentour."],
            ['h2', 'Démographie'],
            ['p', "Le recensement de 2021 compte 88 580 habitants. La proximité de la capitale politique favorise l'emploi administratif et les échanges quotidiens."],
        ],
    ],

];
