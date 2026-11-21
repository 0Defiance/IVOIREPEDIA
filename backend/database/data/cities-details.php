<?php

/**
 * Compléments des fiches « Villes de Côte d'Ivoire » : relief et climat, puis
 * quartiers et équipements.
 *
 * Ces sections ne reprennent que des éléments qui ne sont pas inventés : aucune
 * altitude, pluviométrie, liste de quartiers ou équipement n'est donnée sans
 * source officielle vérifiée. Chaque section indique ce qui n'est pas détaillé.
 */
$generic = static function (string $city): array {
    return [
        ['h2', 'Relief et climat'],
        ['p', "Le relief et le climat de $city ne sont pas détaillés dans cette fiche, faute de source officielle vérifiée."],
        ['p', "Les données de précipitations, d'altitude et de végétation ne sont pas reprises ici tant qu'elles ne sont pas sourcées."],
        ['h2', 'Quartiers et équipements'],
        ['p', "Les quartiers et les équipements de $city ne sont pas listés dans cette fiche, faute de source officielle vérifiée."],
        ['p', 'Le recensement de 2021 et les faits administratifs de la fiche principale restent la référence pour cette ville.'],
    ];
};

return [

    'daloa' => $generic('Daloa'),
    'divo' => $generic('Divo'),
    'gagnoa' => $generic('Gagnoa'),
    'soubre' => $generic('Soubré'),
    'duekoue' => $generic('Duékoué'),
    'bouafle' => $generic('Bouaflé'),
    'guiglo' => $generic('Guiglo'),
    'lakota' => $generic('Lakota'),
    'abengourou' => $generic('Abengourou'),
    'ferkessedougou' => $generic('Ferkessédougou'),
    'adzope' => $generic('Adzopé'),
    'meagui' => $generic('Méagui'),
    'bondoukou' => $generic('Bondoukou'),
    'dabou' => $generic('Dabou'),
    'sinfra' => $generic('Sinfra'),
    'agboville' => $generic('Agboville'),
    'vavoua' => $generic('Vavoua'),
    'danane' => $generic('Danané'),
    'oume' => $generic('Oumé'),
    'issia' => $generic('Issia'),
    'blolequin' => $generic('Bloléquin'),
    'bonon' => $generic('Bonon'),
    'zouan-hounien' => $generic('Zouan-Hounien'),
    'seguela' => $generic('Séguéla'),
    'daoukro' => $generic('Daoukro'),
    'aboisso' => $generic('Aboisso'),
    'buyo' => $generic('Buyo'),
    'agnibilekrou' => $generic('Agnibilékrou'),
    'bouna' => $generic('Bouna'),
    'boundiali' => $generic('Boundiali'),
    'tengrela' => $generic('Tengréla'),
    'sikensi' => $generic('Sikensi'),
    'katiola' => $generic('Katiola'),
    'toumodi' => $generic('Toumodi'),

];
