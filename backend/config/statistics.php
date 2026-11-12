<?php

/**
 * Indicateurs de la page « La Côte d'Ivoire en chiffres ».
 *
 * Chaque entrée est un code d'indicateur de la Banque mondiale (World
 * Development Indicators) : c'est la source la plus complète, la plus
 * régulièrement mise à jour et la seule, ici, à publier une série annuelle
 * exploitable sous licence CC BY 4.0. Les libellés sont traduits à la main ;
 * l'unité sert à l'affichage, le facteur à la mise à l'échelle (les WDI
 * publient parfois des pourcentages en points de base).
 *
 * Les chiffres du recensement (RGPH 2021) ne viennent pas d'ici : ils sont
 * importés depuis `database/data/rgph-2021.json`, parce qu'ils décrivent des
 * divisions administratives et non une série annuelle.
 */
return [

    /** Source commune des indicateurs annuels. */
    'source' => [
        'name' => 'Banque mondiale — World Development Indicators',
        'url' => 'https://data.worldbank.org/country/ci',
        'licence' => 'CC BY 4.0',
    ],

    /** Pays interrogé (code ISO 3 lettres de l'API Banque mondiale). */
    'country' => 'CIV',

    /** Première année demandée à l'API. */
    'since' => 1990,

    /** Thèmes affichés, dans l'ordre. */
    'themes' => [
        'demographie' => [
            'label' => 'Démographie',
            'indicators' => [
                'SP.POP.TOTL' => ['Population totale', 'habitants', 0],
                'SP.POP.GROW' => ['Croissance démographique', '% par an', 1],
                'SP.POP.TOTL.FE.ZS' => ['Part des femmes', '%', 1],
                'SP.URB.TOTL.IN.ZS' => ['Population urbaine', '%', 1],
                'EN.POP.DNST' => ['Densité de population', 'hab./km²', 1],
                'SP.DYN.LE00.IN' => ['Espérance de vie à la naissance', 'ans', 1],
                'SP.DYN.TFRT.IN' => ['Indice de fécondité', 'enfants par femme', 2],
                'SP.DYN.IMRT.IN' => ['Mortalité infantile', 'pour 1 000 naissances', 1],
                'SP.POP.0014.TO.ZS' => ['Moins de 15 ans', '%', 1],
                'SP.POP.65UP.TO.ZS' => ['65 ans et plus', '%', 1],
            ],
        ],
        'economie' => [
            'label' => 'Économie',
            'indicators' => [
                'NY.GDP.MKTP.CD' => ['Produit intérieur brut', 'USD courants', 0],
                'NY.GDP.MKTP.KD.ZG' => ['Croissance du PIB', '% par an', 1],
                'NY.GDP.PCAP.CD' => ['PIB par habitant', 'USD courants', 0],
                'NY.GDP.PCAP.PP.CD' => ['PIB par habitant (PPA)', 'USD internationaux', 0],
                'FP.CPI.TOTL.ZG' => ['Inflation', '% par an', 1],
                'NV.AGR.TOTL.ZS' => ["Valeur ajoutée de l'agriculture", '% du PIB', 1],
                'NV.IND.MANF.ZS' => ['Valeur ajoutée manufacturière', '% du PIB', 1],
                'NE.EXP.GNFS.ZS' => ['Exportations de biens et services', '% du PIB', 1],
                'NE.IMP.GNFS.ZS' => ['Importations de biens et services', '% du PIB', 1],
                'BX.KLT.DINV.CD.WD' => ['Investissements directs étrangers', 'USD', 0],
                'GC.DOD.TOTL.GD.ZS' => ['Dette publique', '% du PIB', 1],
                'AG.SRF.TOTL.K2' => ['Superficie du territoire', 'km²', 0],
            ],
        ],
        'societe' => [
            'label' => 'Société et travail',
            'indicators' => [
                'SL.UEM.TOTL.ZS' => ['Chômage', '% de la population active', 1],
                'SL.TLF.CACT.ZS' => ["Taux d'activité", '% des 15 ans et plus', 1],
                'SI.POV.DDAY' => ['Extrême pauvreté', '% de la population', 1],
                'SI.POV.GINI' => ['Indice de Gini', '0 à 100', 1],
                'SG.GEN.PARL.ZS' => ['Femmes au Parlement', '% des sièges', 1],
                'SL.UEM.1524.ZS' => ['Chômage des 15-24 ans', '% de la population active jeune', 1],
                'SP.DYN.CONU.ZS' => ['Prévalence contraceptive', '% des femmes', 1],
            ],
        ],
        'sante' => [
            'label' => 'Santé',
            'indicators' => [
                'SH.DYN.MORT' => ['Mortalité avant 5 ans', 'pour 1 000 naissances', 1],
                'SH.STA.MMRT' => ['Mortalité maternelle', 'pour 100 000 naissances', 0],
                'SH.XPD.CHEX.GD.ZS' => ['Dépenses de santé', '% du PIB', 1],
                'SH.IMM.MEAS' => ['Vaccination DTC3', '% des enfants', 1],
                'SH.H2O.BASW.ZS' => ["Accès à l'eau potable", '% de la population', 1],
                'SH.STA.SMSS.ZS' => ['Assainissement de base', '% de la population', 1],
                'SH.TBS.INCD' => ['Incidence de la tuberculose', 'pour 100 000', 1],
                'SH.MLR.INCD.P3' => ['Incidence du paludisme', 'pour 1 000 à risque', 1],
            ],
        ],
        'education' => [
            'label' => 'Éducation',
            'indicators' => [
                'SE.ADT.LITR.ZS' => ['Alphabétisation des adultes', '% des 15 ans et plus', 1],
                'SE.PRM.ENRR' => ['Scolarisation primaire', '% brut', 1],
                'SE.PRM.CUAT.ZS' => ['Achèvement du primaire', '% de la classe d’âge', 1],
                'SE.SEC.ENRR' => ['Scolarisation secondaire', '% brut', 1],
                'SE.TER.ENRR' => ['Scolarisation supérieure', '% brut', 1],
                'SE.ENR.PRSC.FM.ZS' => ['Parité filles/garçons au primaire', 'indice', 2],
                'SE.XPD.TOTL.GD.ZS' => ["Dépenses d'éducation", '% du PIB', 1],
            ],
        ],
        'environnement' => [
            'label' => 'Énergie et environnement',
            'indicators' => [
                'EG.ELC.ACCS.ZS' => ["Accès à l'électricité", '% de la population', 1],
                'EG.USE.PCAP.KG.OE' => ["Consommation d'énergie", 'kg équivalent pétrole par habitant', 0],
                'AG.LND.FRST.ZS' => ['Couvert forestier', '% du territoire', 1],
                'AG.LND.AGRI.ZS' => ['Terres agricoles', '% du territoire', 1],
                'EN.GHG.CO2.MT.CE.AR5' => ['Émissions de CO₂', 'millions de tonnes', 2],
                'IT.NET.USER.ZS' => ['Internautes', '% de la population', 1],
                'IT.CEL.SETS.P2' => ['Abonnements mobiles', 'pour 100 habitants', 1],
            ],
        ],
    ],

    /** Indicateurs mis en avant en haut de la page, dans l'ordre. */
    'headline' => [
        'SP.POP.TOTL',
        'NY.GDP.MKTP.CD',
        'NY.GDP.PCAP.CD',
        'SP.DYN.LE00.IN',
        'SE.ADT.LITR.ZS',
        'SP.URB.TOTL.IN.ZS',
    ],

];
