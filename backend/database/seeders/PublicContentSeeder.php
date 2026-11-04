<?php

namespace Database\Seeders;

use App\Enums\ArticleStatus;
use App\Enums\ArticleType;
use App\Models\Article;
use App\Models\Category;
use App\Models\Tag;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

/**
 * Contenu de démonstration de la lecture publique.
 *
 * Ces cinquante articles donnent « de la vie » au site : ils couvrent les huit
 * catégories, les trois types à infobox (CONTEXT §8.3) et l'essentiel des
 * sujets attendus d'une encyclopédie ivoirienne — histoire, territoires,
 * langues, institutions, culture, patrimoine, économie.
 *
 * Règle éditoriale : uniquement des faits établis, formulés prudemment quand
 * une date ou un chiffre prête à débat, et une référence réelle par article
 * sensible. Ces textes restent des contenus de démonstration à faire relire
 * par l'équipe éditoriale avant l'ouverture publique (CONTEXT §14).
 */
class PublicContentSeeder extends Seeder
{
    /** @var array<string, string> */
    private const TAG_NAMES = [
        'abidjan' => 'Abidjan',
        'capitale' => 'Capitale',
        'independance' => 'Indépendance',
        'histoire-politique' => 'Histoire politique',
        'langues-kwa' => 'Langues kwa',
        'gastronomie' => 'Gastronomie',
        'biodiversite' => 'Biodiversité',
        'architecture' => 'Architecture',
        'agriculture' => 'Agriculture',
        'droit-constitutionnel' => 'Droit constitutionnel',
        'patrimoine' => 'Patrimoine',
        'femmes' => 'Femmes',
        'premiere-republique' => 'Première République',
        'crise-politique' => 'Crise politique',
        'resistance' => 'Résistance',
        'royautes' => 'Royautés',
        'sport' => 'Sport',
        'musique' => 'Musique',
        'peuples' => 'Peuples',
        'unesco' => 'Patrimoine mondial',
        'danse' => 'Danse',
        'litterature' => 'Littérature',
        'monnaie' => 'Monnaie',
        'port' => 'Port',
        'foret' => 'Forêt',
        'langues-mande' => 'Langues mandé',
        'langues-gur' => 'Langues gur',
        'langues-kru' => 'Langues kru',
        'administration' => 'Administration',
        'ville' => 'Ville',
        'fleuves' => 'Fleuves',
        'industrie' => 'Industrie',
        'finance' => 'Finance',
    ];

    public function run(): void
    {
        $author = $this->author();
        $categories = Category::query()->pluck('id', 'slug');
        $tags = $this->tags();

        foreach ($this->articles() as $index => $spec) {
            $article = Article::query()->updateOrCreate(
                ['slug' => $spec['slug']],
                [
                    'title' => $spec['title'],
                    'summary' => $spec['summary'],
                    'content' => $this->delta($spec['blocks']),
                    'infobox' => $spec['infobox'] ?? null,
                    'type' => $spec['type'],
                    'status' => ArticleStatus::PUBLISHED,
                    'cover_image_url' => null,
                    'cover_image_alt' => null,
                    'lock_version' => 1,
                    'current_version' => 1,
                    'author_id' => $author->id,
                    'category_id' => $categories[$spec['category']],
                    'published_at' => now()->subDays(($index + 1) * 3),
                ],
            );

            $article->tags()->sync(
                array_map(fn (string $slug) => $tags[$slug]->id, $spec['tags'])
            );

            $article->references()->delete();

            foreach ($spec['references'] ?? [] as $position => $reference) {
                $article->references()->create([...$reference, 'position' => $position + 1]);
            }
        }
    }

    /**
     * Auteur des contenus de démonstration : le premier compte éditorial
     * existant, sinon un compte de rédaction dédié.
     */
    private function author(): User
    {
        $author = User::query()
            ->whereIn('role', ['ADMIN', 'EDITOR'])
            ->orderBy('created_at')
            ->first();

        return $author ?? User::query()->create([
            'name' => 'La rédaction',
            'email' => 'redaction@ivoirepedia.ci',
            'password_hash' => Hash::make(Str::random(40)),
            'role' => 'EDITOR',
            'email_verified_at' => now(),
        ]);
    }

    /** @return array<string, Tag> */
    private function tags(): array
    {
        $tags = [];

        foreach (self::TAG_NAMES as $slug => $name) {
            $tags[$slug] = Tag::query()->updateOrCreate(
                ['slug' => $slug],
                ['name' => $name],
            );
        }

        return $tags;
    }

    /**
     * Convertit des blocs simples en Delta Quill (ADR-003 : jamais de HTML).
     *
     * @param  array<int, array{0: string, 1: string}>  $blocks  [['h2'|'p'|'li'|'quote', texte], …]
     * @return array{ops: array<int, array<string, mixed>>}
     */
    private function delta(array $blocks): array
    {
        $ops = [];

        foreach ($blocks as [$kind, $text]) {
            $ops[] = match ($kind) {
                'h2' => ['insert' => $text."\n", 'attributes' => ['header' => 2]],
                'li' => ['insert' => $text."\n", 'attributes' => ['list' => 'bullet']],
                'quote' => ['insert' => $text."\n", 'attributes' => ['blockquote' => true]],
                default => ['insert' => $text."\n"],
            };
        }

        return ['ops' => $ops];
    }

    /**
     * @return array<int, array<string, mixed>>
     */
    private function articles(): array
    {
        return [
            [
                'slug' => 'abidjan',
                'title' => 'Abidjan',
                'summary' => "Capitale économique de la Côte d'Ivoire, Abidjan s'est construite sur les lagunes Ébrié et s'impose comme la première métropole du pays.",
                'type' => ArticleType::REGION,
                'category' => 'geographie',
                'tags' => ['abidjan', 'capitale'],
                'infobox' => [
                    'level' => 'DISTRICT',
                    'population' => 6321017,
                    'populationYear' => 2021,
                    'areaKm2' => 2140,
                    'ethnicGroups' => [],
                    'languages' => ['Français', 'Baoulé', 'Attié', 'Ébrié', 'Dioula'],
                ],
                'blocks' => [
                    ['p', "Abidjan est le principal pôle urbain, économique et culturel de la Côte d'Ivoire. Installée sur la rive nord de la lagune Ébrié, la ville s'est développée autour du port et des quartiers du Plateau, puis a absorbé les communes voisines pour former, en 2001, le District autonome d'Abidjan."],
                    ['h2', 'Une capitale économique, pas politique'],
                    ['p', "Si Yamoussoukro est devenue la capitale politique en 1983, Abidjan concentre toujours l'essentiel des institutions financières, des sièges d'entreprises et des médias nationaux. Le port d'Abidjan, avec le canal de Vridi ouvert en 1950, est historiquement l'une des portes d'entrée du commerce ouest-africain."],
                    ['h2', 'Une ville de lagunes et de quartiers'],
                    ['p', "La géographie urbaine d'Abidjan est marquée par l'eau : les ponts qui franchissent la lagune relient le Plateau à Treichville, Marcory et Koumassi, tandis que Cocody et Yopougon accueillent l'essentiel de la croissance résidentielle."],
                    ['li', 'Le Plateau, quartier administratif et des affaires'],
                    ['li', 'Treichville et Adjamé, héritiers des noyaux urbains coloniaux'],
                    ['li', 'Cocody, Yopougon et Abobo, communes les plus peuplées'],
                    ['p', "Ce sont aujourd'hui dix communes urbaines et trois sous-préfectures (Anyama, Bingerville, Songon) qui composent le district."],
                    ['h2', "Une métropole à l'échelle ouest-africaine"],
                    ['p', "Avec plus de six millions d'habitants au recensement de 2021, Abidjan figure parmi les plus grandes agglomérations d'Afrique de l'Ouest. Sa démographie pose des défis connus de mobilité, d'assainissement et d'accès au logement, qui structurent les politiques urbaines du pays."],
                ],
                'references' => [
                    [
                        'kind' => 'OTHER',
                        'authors' => null,
                        'title' => "Recensement général de la population et de l'habitat (RGPH) 2021",
                        'publisher' => "Institut national de la statistique (INS), Côte d'Ivoire",
                        'year' => 2022,
                        'url' => 'https://www.ins.ci',
                    ],
                ],
            ],
            [
                'slug' => 'yamoussoukro',
                'title' => 'Yamoussoukro',
                'summary' => "Capitale politique de la Côte d'Ivoire depuis 1983, Yamoussoukro est aussi la ville natale de Félix Houphouët-Boigny.",
                'type' => ArticleType::REGION,
                'category' => 'geographie',
                'tags' => ['capitale'],
                'infobox' => [
                    'level' => 'DISTRICT',
                    'population' => null,
                    'populationYear' => null,
                    'areaKm2' => 3500,
                    'ethnicGroups' => ['Baoulé'],
                    'languages' => ['Français', 'Baoulé'],
                ],
                'blocks' => [
                    ['p', "Yamoussoukro est la capitale politique de la Côte d'Ivoire. Le transfert du statut de capitale, décidé en 1983, a fait d'un bourg baoulé du centre du pays le siège des institutions, sans lui retirer son caractère de ville à taille humaine."],
                    ['h2', "De N'Gokro à Yamoussoukro"],
                    ['p', "Le village s'appelait N'Gokro avant de prendre le nom de la reine Yamousso. Félix Houphouët-Boigny y est né en 1905 et y a fait construire, une fois au pouvoir, les équipements qui devaient en faire une capitale : palais, fondation, lacs artificiels et basilique."],
                    ['h2', 'Une capitale institutionnelle'],
                    ['p', "Le District autonome de Yamoussoukro accueille la présidence de la République et plusieurs administrations centrales. Une partie de l'activité diplomatique et économique reste toutefois à Abidjan, ce qui fait du pays une configuration à deux pôles."],
                    ['h2', 'La ville et son monument'],
                    ['p', "La basilique Notre-Dame de la Paix, consacrée en 1990, a durablement marqué le paysage et l'imaginaire de la ville. Elle constitue, avec les lacs artificiels et la Fondation Houphouët-Boigny, l'un des repères urbains les plus cités du pays."],
                ],
            ],
            [
                'slug' => 'felix-houphouet-boigny',
                'title' => 'Félix Houphouët-Boigny',
                'summary' => "Médecin et homme d'État ivoirien (1905-1993), premier président de la Côte d'Ivoire indépendante, au pouvoir de 1960 à sa mort.",
                'type' => ArticleType::BIOGRAPHY,
                'category' => 'personnalites',
                'tags' => ['independance', 'histoire-politique'],
                'infobox' => [
                    'fullName' => 'Félix Houphouët-Boigny',
                    'birthDate' => '1905-10-18',
                    'birthPlace' => "Yamoussoukro (alors N'Gokro)",
                    'deathDate' => '1993-12-07',
                    'deathPlace' => 'Yamoussoukro',
                    'nationalities' => ['Ivoirienne'],
                    'occupations' => ['Médecin', "Homme d'État"],
                ],
                'blocks' => [
                    ['p', "Félix Houphouët-Boigny est la figure centrale de la vie politique ivoirienne du XXe siècle. Né le 18 octobre 1905 à N'Gokro, devenu Yamoussoukro, il est mort le 7 décembre 1993 dans la même ville, après trente-trois ans à la tête de l'État."],
                    ['h2', 'Le médecin et le syndicaliste'],
                    ['p', 'Diplômé de médecine, il commence par défendre les planteurs africains face aux grandes sociétés coloniales. En 1944, il fonde le Syndicat agricole africain, qui devient une force politique.'],
                    ['h2', 'Le RDA et la loi-cadre'],
                    ['p', "En 1946, il participe à la création du Rassemblement démocratique africain (RDA) à Bamako. Élu député, il porte plusieurs réformes, dont la loi-cadre de 1956 qui élargit l'autonomie des territoires."],
                    ['h2', 'La présidence (1960-1993)'],
                    ['p', "À l'indépendance, en 1960, il devient président de la République. Sa politique repose sur la stabilité des institutions, l'ouverture économique aux investissements étrangers et le développement de l'agriculture d'exportation, en particulier le cacao et le café."],
                    ['quote', "On lui doit l'expression d'une « paix des braves », formule employée dans les crises politiques des années 1990."],
                    ['p', "Son héritage est discuté : croissance et stabilité pendant les deux premières décennies, mais aussi centralisation du pouvoir et tensions autour de sa succession, qui marquent l'histoire du pays après 1993."],
                ],
            ],
            [
                'slug' => 'constitution-ivoirienne-de-2016',
                'title' => 'Constitution ivoirienne de 2016',
                'summary' => 'Adoptée par référendum le 30 octobre 2016, elle fonde la Troisième République et crée les fonctions de vice-président et de Sénat.',
                'type' => ArticleType::INSTITUTION,
                'category' => 'institutions',
                'tags' => ['droit-constitutionnel'],
                'infobox' => [
                    'officialName' => "Constitution de la République de Côte d'Ivoire",
                    'acronym' => 'Loi n° 2016-886',
                    'institutionType' => 'Texte constitutionnel',
                    'foundedYear' => 2016,
                    'headquarters' => 'Abidjan',
                ],
                'blocks' => [
                    ['p', 'La Constitution du 8 novembre 2016, adoptée par référendum le 30 octobre 2016 avec un taux de participation contesté mais une large approbation officielle, ouvre ce que la vie politique ivoirienne appelle la Troisième République.'],
                    ['h2', 'Ce que le texte change'],
                    ['li', "Création d'un poste de vice-président, élu sur le même ticket que le président"],
                    ['li', "Institution d'un Sénat, aux côtés de l'Assemblée nationale"],
                    ['li', "Réaffirmation de l'État de droit et des droits fondamentaux dans le préambule"],
                    ['p', "Le texte conserve un régime présidentiel fort, tout en introduisant des contre-pouvoirs institutionnels : Conseil constitutionnel, Cour de cassation et Conseil d'État voient leurs rôles précisés."],
                    ['h2', 'Une révision, pas une table rase'],
                    ['p', "La Constitution de 2016 remplace celle de 2000 sans effacer l'héritage juridique antérieur : de nombreuses lois ordinaires restent en vigueur, et le texte organise lui-même la transition institutionnelle."],
                    ['p', "Ses dispositions ont été complétées par plusieurs lois organiques, notamment sur le fonctionnement du Sénat et sur le statut de l'opposition."],
                ],
                'references' => [
                    [
                        'kind' => 'OTHER',
                        'authors' => null,
                        'title' => "Loi n° 2016-886 du 8 novembre 2016 portant Constitution de la République de Côte d'Ivoire",
                        'publisher' => "Journal officiel de la République de Côte d'Ivoire",
                        'year' => 2016,
                        'url' => 'https://www.gouv.ci',
                    ],
                ],
            ],
            [
                'slug' => 'les-akan',
                'title' => 'Les Akan',
                'summary' => "Ensemble de peuples d'Afrique de l'Ouest partageant des langues kwa et des institutions sociales matrilinéaires, présents notamment en Côte d'Ivoire et au Ghana.",
                'type' => ArticleType::TOPIC,
                'category' => 'langues',
                'tags' => ['langues-kwa'],
                'blocks' => [
                    ['p', "Le mot « Akan » désigne à la fois une famille de langues et l'ensemble des sociétés qui les parlent, principalement au Ghana et en Côte d'Ivoire. En Côte d'Ivoire, les Baoulé, les Agni et les Abron en sont les représentants les plus nombreux."],
                    ['h2', 'Une famille de langues, pas un peuple unique'],
                    ['p', "Les langues akan appartiennent à la branche tano des langues kwa, elles-mêmes rattachées au grand ensemble nigéro-congolais. Le twi et le fanti au Ghana, le baoulé et l'agni en Côte d'Ivoire en sont des variétés apparentées, mais non interchangeables."],
                    ['h2', 'Des sociétés matrilinéaires'],
                    ['p', "Chez la plupart des peuples akan, la filiation et l'héritage se transmettent par la mère : le lignage, ou abusua, structure la parenté, la solidarité et l'accès aux responsabilités. Le chef est choisi au sein de ce lignage, sous le contrôle des anciens."],
                    ['h2', 'Symboles et or'],
                    ['p', "L'or, les poids à peser (mrammuo) et les tissus kente occupent une place centrale dans la vie sociale et rituelle. Le siège royal, ou tabouret, incarne la légitimité du pouvoir."],
                ],
            ],
            [
                'slug' => 'le-baoule',
                'title' => 'Le baoulé',
                'summary' => "Langue kwa parlée par plusieurs millions de personnes en Côte d'Ivoire, le baoulé est l'une des langues nationales les plus présentes dans la vie quotidienne.",
                'type' => ArticleType::TOPIC,
                'category' => 'langues',
                'tags' => ['langues-kwa'],
                'blocks' => [
                    ['p', "Le baoulé est une langue du groupe akan parlée principalement dans le centre et le sud-est de la Côte d'Ivoire. Elle est l'une des langues nationales les plus diffusées du pays et fonctionne largement comme langue véhiculaire dans les régions concernées."],
                    ['h2', 'Une langue à tons'],
                    ['p', "Comme la plupart des langues kwa, le baoulé est tonal : la hauteur de la voix porte du sens et distingue des mots par ailleurs identiques. L'orthographe utilise l'alphabet latin, avec des lettres supplémentaires et des signes de ton."],
                    ['h2', 'Transmission et écriture'],
                    ['p', "La langue se transmet d'abord à l'oral, dans la famille et au marché. Des programmes d'alphabétisation et des publications en baoulé existent depuis plusieurs décennies, mais l'écrit reste minoritaire face au français, langue officielle."],
                    ['p', 'Comme beaucoup de langues africaines, le baoulé connaît une pression urbaine forte : à Abidjan, les jeunes générations alternent souvent baoulé, français et dioula.'],
                ],
            ],
            [
                'slug' => 'attieke',
                'title' => "L'attiéké",
                'summary' => "Semoule de manioc fermentée, l'attiéké est l'un des accompagnements les plus répandus de la cuisine ivoirienne, souvent servi avec du poisson braisé.",
                'type' => ArticleType::TOPIC,
                'category' => 'culture',
                'tags' => ['gastronomie'],
                'blocks' => [
                    ['p', "L'attiéké est une semoule obtenue à partir de manioc fermenté, râpé puis cuit à la vapeur. Plat quotidien en Côte d'Ivoire, il accompagne aussi bien le poisson que la viande ou les sauces."],
                    ['h2', 'Une origine lagunaire'],
                    ['p', "Sa préparation est traditionnellement associée aux populations du littoral, notamment les Ébrié et les Adioukrou, chez qui le plat porte des noms proches d'« adjèkè ». Il s'est ensuite diffusé dans tout le pays et dans la sous-région."],
                    ['h2', 'La fermentation, cœur du goût'],
                    ['p', "Le manioc est épluché, râpé, puis mis à fermenter quelques jours. Cette étape développe l'acidité caractéristique du plat. La pâte est ensuite pressée, tamisée en grains fins, puis cuite à la vapeur."],
                    ['h2', 'À table'],
                    ['p', "L'attiéké se sert chaud, généralement avec du poisson braisé, des tomates et des oignons, ou avec une sauce claire. La variante « attiéké-garba », avec du thon frit et de l'attiéké frais, est devenue un plat de rue emblématique, notamment à Abidjan."],
                ],
            ],
            [
                'slug' => 'parc-national-du-banco',
                'title' => 'Parc national du Banco',
                'summary' => "Forêt classée au cœur d'Abidjan, le Banco est à la fois un poumon vert urbain et un lieu de recherche sur la forêt tropicale.",
                'type' => ArticleType::TOPIC,
                'category' => 'patrimoine',
                'tags' => ['biodiversite', 'abidjan', 'patrimoine'],
                'blocks' => [
                    ['p', "Le parc national du Banco occupe environ 3 000 hectares au nord d'Abidjan, à cheval sur les communes d'Attécoubé et d'Adjamé. Classé en 1953, il constitue l'une des rares forêts primaires urbaines d'Afrique de l'Ouest."],
                    ['h2', 'Une forêt dans la ville'],
                    ['p', 'Le parc abrite une forêt dense humide, des sources et un arboretum. Il est traversé par des sentiers utilisés pour la marche et la course, ce qui en fait un espace de respiration pour les habitants de la capitale économique.'],
                    ['h2', 'Un laboratoire à ciel ouvert'],
                    ['p', "Sa proximité avec les centres de recherche et l'université en a fait un terrain d'étude pour les botanistes et les écologues. Plusieurs essences y sont inventoriées et des programmes de reboisement y ont été conduits."],
                    ['h2', 'Des pressions urbaines'],
                    ['p', "L'extension de l'agglomération, l'occupation informelle et la pollution mettent sous tension cette réserve. Sa protection dépend autant de la surveillance du parc que de la gestion globale de l'urbanisation au nord d'Abidjan."],
                ],
            ],
            [
                'slug' => 'basilique-notre-dame-de-la-paix',
                'title' => 'Basilique Notre-Dame de la Paix',
                'summary' => "Édifiée à Yamoussoukro et consacrée en 1990, la basilique est l'un des monuments les plus visibles de la Côte d'Ivoire contemporaine.",
                'type' => ArticleType::TOPIC,
                'category' => 'patrimoine',
                'tags' => ['architecture', 'capitale', 'patrimoine'],
                'blocks' => [
                    ['p', "La basilique Notre-Dame de la Paix se dresse à Yamoussoukro, sur un vaste espace aménagé à l'écart du centre. Consacrée le 10 septembre 1990 par le pape Jean-Paul II, elle est depuis l'un des édifices religieux les plus remarquables du continent."],
                    ['h2', "Un projet d'État"],
                    ['p', "La construction est voulue par Félix Houphouët-Boigny, qui en fait don à l'Église catholique. Le chantier, lancé à la fin des années 1980, mobilise des entreprises internationales et transforme durablement le paysage de la ville."],
                    ['h2', 'Une architecture inspirée de Rome'],
                    ['p', "Le plan reprend celui de la basilique Saint-Pierre : nef centrale, coupole surélevée, colonnades latérales. Le dôme atteint environ 158 mètres de hauteur, et l'édifice peut accueillir des milliers de fidèles assis."],
                    ['h2', 'Un lieu de culte et de visite'],
                    ['p', 'Au-delà de sa fonction religieuse, la basilique est devenue un passage obligé pour les visiteurs de Yamoussoukro et un symbole ambivalent : prouesse architecturale pour les uns, coût questionné pour les autres dans un pays alors en crise économique.'],
                ],
            ],
            [
                'slug' => 'marche-des-femmes-de-1949',
                'title' => 'La marche des femmes de 1949',
                'summary' => "En décembre 1949, des milliers de femmes marchent d'Abidjan à Grand-Bassam pour obtenir la libération de responsables politiques emprisonnés.",
                'type' => ArticleType::TOPIC,
                'category' => 'histoire',
                'tags' => ['femmes', 'histoire-politique', 'independance'],
                'blocks' => [
                    ['p', "La marche des femmes de décembre 1949 est l'un des épisodes les plus cités de l'histoire politique ivoirienne. Des milliers de femmes venues de tout le pays convergent vers Grand-Bassam pour réclamer la libération de dirigeants du Rassemblement démocratique africain (RDA) arrêtés par l'administration coloniale."],
                    ['h2', 'Le contexte'],
                    ['p', "Après la répression de 1949 et l'arrestation de plusieurs responsables, dont des élus, le RDA cherche à maintenir la mobilisation. Les femmes, très impliquées dans les sections locales, organisent un mouvement de protestation de grande ampleur."],
                    ['h2', 'Une marche et un symbole'],
                    ['p', "Parties d'Abidjan, les marcheuses rejoignent Grand-Bassam, alors capitale coloniale. Leur détermination, et la médiatisation de l'événement, pèsent sur la décision de libérer les prisonniers politiques en 1950."],
                    ['h2', 'Un héritage discuté'],
                    ['p', "L'épisode est aujourd'hui commémoré comme un moment fondateur de l'engagement des femmes en politique. Les historiens en discutent le déroulé exact et l'ampleur, tout en reconnaissant son rôle dans la construction du récit national."],
                ],
                'references' => [
                    [
                        'kind' => 'OTHER',
                        'authors' => null,
                        'title' => "Archives nationales de Côte d'Ivoire — fonds de l'AOF",
                        'publisher' => "Archives nationales de Côte d'Ivoire",
                        'year' => null,
                        'url' => null,
                    ],
                ],
            ],
            [
                'slug' => 'le-cacao-en-cote-d-ivoire',
                'title' => "Le cacao en Côte d'Ivoire",
                'summary' => "Premier producteur mondial de cacao, la Côte d'Ivoire a bâti une part de son économie sur cette filière, avec des enjeux persistants de prix et de transformation locale.",
                'type' => ArticleType::TOPIC,
                'category' => 'economie',
                'tags' => ['agriculture'],
                'blocks' => [
                    ['p', "La Côte d'Ivoire est le premier producteur mondial de cacao, avec une récolte qui représente une part majeure de l'offre internationale. La filière fait vivre plusieurs millions de personnes, de la plantation au port."],
                    ['h2', "Une culture d'exportation"],
                    ['p', "Introduite à la fin du XIXe siècle, la culture du cacaoyer s'étend d'abord dans le sud-est, puis gagne le centre-ouest et le sud-ouest au fil des décennies. Elle accompagne la croissance économique des années 1960-1970."],
                    ['h2', 'Le prix, question centrale'],
                    ['p', "Les producteurs sont exposés aux cours mondiaux, fixés à Londres et New York. Le pays a mis en place un système de prix bord champ garanti et une régulation de la commercialisation, dont l'efficacité est débattue."],
                    ['h2', 'Transformer sur place'],
                    ['p', "Depuis les années 2010, l'enjeu est de broyer et transformer une part croissante de la production localement, pour capter davantage de valeur ajoutée. Des usines de transformation se sont installées près d'Abidjan et de San-Pédro."],
                    ['p', 'La filière reste confrontée à des défis de durabilité : déforestation, revenus des planteurs, travail des enfants et traçabilité des fèves.'],
                ],
                'references' => [
                    [
                        'kind' => 'OTHER',
                        'authors' => null,
                        'title' => 'Rapports annuels sur la filière cacao-café',
                        'publisher' => 'Conseil du café-cacao',
                        'year' => null,
                        'url' => 'https://www.conseilcafecacao.ci',
                    ],
                ],
            ],
            // ——— Géographie ———————————————————————————————————————————————
            [
                'slug' => 'bouake',
                'title' => 'Bouaké',
                'summary' => "Deuxième ville de Côte d'Ivoire, Bouaké est le grand carrefour du centre du pays, entre coton, commerce et mémoire des crises politiques.",
                'type' => ArticleType::REGION,
                'category' => 'geographie',
                'tags' => ['ville'],
                'infobox' => [
                    'level' => 'DEPARTMENT',
                    'populationYear' => 2021,
                    'languages' => ['Français', 'Baoulé', 'Dioula'],
                ],
                'blocks' => [
                    ['p', 'Bouaké occupe une place à part dans la géographie ivoirienne : située au centre du pays, dans la région du Gbêkê, elle est la deuxième ville du pays par sa population et le principal marché des savanes du centre.'],
                    ['h2', 'Un carrefour de transports et de commerce'],
                    ['p', "La ville s'est développée comme relais sur l'axe Abidjan–Ouagadougou et comme centre de collecte du coton et des productions vivrières du centre. Elle abrite aussi des activités textiles et agroalimentaires héritées de la politique d'industrialisation des années 1970."],
                    ['h2', 'Le centre de la rébellion de 2002'],
                    ['p', "En septembre 2002, Bouaké devient le quartier général de la rébellion qui contrôle le nord du pays pendant près d'une décennie. La ville reste marquée par cette période, entre enclavement économique et reconstruction progressive après 2011."],
                ],
            ],
            [
                'slug' => 'san-pedro',
                'title' => 'San-Pédro',
                'summary' => "Port du sud-ouest bâti pour exporter le bois puis le cacao, San-Pédro est aujourd'hui le deuxième port maritime du pays.",
                'type' => ArticleType::REGION,
                'category' => 'geographie',
                'tags' => ['port', 'ville'],
                'infobox' => [
                    'level' => 'DEPARTMENT',
                    'languages' => ['Français', 'Kroumen', 'Bété'],
                ],
                'blocks' => [
                    ['p', "San-Pédro se trouve sur la côte sud-ouest, à l'embouchure du fleuve San-Pédro. La ville est née de la décision, dans les années 1960, d'ouvrir un second port maritime pour désengorger Abidjan et exporter le bois du Sud-Ouest."],
                    ['h2', 'Un port pour le cacao et le bois'],
                    ['p', "Le port entre en service au début des années 1970. Il expédie aujourd'hui une part importante du cacao, du café, du bois et du caoutchouc produits dans la région, et dispose d'un terminal pour la pêche industrielle."],
                    ['h2', 'Une ville industrielle'],
                    ['p', "Autour du port se sont installées des usines de transformation du cacao et du bois, ainsi qu'une zone franche. La ville reste toutefois dépendante de la saisonnalité des matières premières et de la concurrence d'Abidjan."],
                ],
            ],
            [
                'slug' => 'korhogo',
                'title' => 'Korhogo',
                'summary' => 'Chef-lieu du nord ivoirien et capitale du pays sénoufo, Korhogo est connue pour ses toiles peintes, ses masques et sa tradition de sculpture.',
                'type' => ArticleType::REGION,
                'category' => 'geographie',
                'tags' => ['ville', 'peuples'],
                'infobox' => [
                    'level' => 'DEPARTMENT',
                    'languages' => ['Français', 'Sénoufo', 'Dioula'],
                ],
                'blocks' => [
                    ['p', "Korhogo est la principale ville du nord de la Côte d'Ivoire, au cœur du pays sénoufo. Elle est le chef-lieu de la région des Savanes et un centre administratif et commercial de première importance pour les échanges avec le Mali et le Burkina Faso."],
                    ['h2', 'La ville des toiles et des masques'],
                    ['p', "Korhogo est réputée pour ses toiles de coton peintes à la main, réalisées selon une technique aujourd'hui largement destinée au marché de l'art, ainsi que pour ses sculpteurs et ses masques. Le musée régional et les ateliers du quartier artisanal en sont les vitrines."],
                    ['h2', 'Le Poro et la société sénoufo'],
                    ['p', "La société sénoufo est organisée autour du Poro, une institution d'initiation qui structure la transmission des savoirs et l'accès aux responsabilités. Les villages alentour conservent des bois sacrés et des lieux rituels qui ponctuent la vie cérémonielle."],
                ],
            ],
            [
                'slug' => 'man',
                'title' => 'Man',
                'summary' => "Au pied des montagnes de l'ouest, Man est la capitale du pays dan (yacouba) et le point de départ des randonnées vers le mont Tonkoui.",
                'type' => ArticleType::REGION,
                'category' => 'geographie',
                'tags' => ['ville', 'peuples'],
                'infobox' => [
                    'level' => 'DEPARTMENT',
                    'languages' => ['Français', 'Dan', 'Dioula'],
                ],
                'blocks' => [
                    ['p', "Man se situe dans l'ouest de la Côte d'Ivoire, au pied des reliefs qui annoncent le massif du Nimba. Chef-lieu de la région du Tonkpi, la ville est le centre du pays dan, également appelé yacouba."],
                    ['h2', 'Une ville entre montagnes et cascades'],
                    ['p', "La proximité du mont Tonkoui, l'un des points culminants du pays, et de la cascade de Man en fait une destination appréciée des randonneurs. Les ponts de lianes, autrefois nombreux dans la région, restent un motif culturel fort."],
                    ['h2', 'Masques et société dan'],
                    ['p', "Les Dan sont connus pour leurs masques sculptés, dont les masques « gorge » et les masques-jeux, ainsi que pour une organisation sociale villageoise structurée par les classes d'âge. La région vit aussi de la culture du cacao, du café et de l'hévéa."],
                ],
            ],
            [
                'slug' => 'le-bandama',
                'title' => 'Le Bandama',
                'summary' => 'Plus long fleuve entièrement ivoirien, le Bandama descend du nord vers le sud et alimente le lac de Kossou, principal réservoir hydroélectrique du pays.',
                'type' => ArticleType::TOPIC,
                'category' => 'geographie',
                'tags' => ['fleuves'],
                'blocks' => [
                    ['p', "Le Bandama prend sa source dans le nord du pays et descend vers le sud sur environ 800 kilomètres avant de rejoindre la lagune de Grand-Lahou, puis l'océan Atlantique. Il est le plus long fleuve dont le bassin est presque entièrement situé en Côte d'Ivoire."],
                    ['h2', 'Le barrage de Kossou'],
                    ['p', "La mise en eau du barrage de Kossou, au début des années 1970, a créé l'un des plus grands lacs artificiels d'Afrique de l'Ouest. L'ouvrage fournit de l'électricité et régule le débit du fleuve, au prix du déplacement de populations et de la perte de terres agricoles."],
                    ['h2', 'Un fleuve convoité'],
                    ['p', "Le Bandama et ses affluents, le Bandama blanc et le Bandama rouge, structurent l'agriculture et la pêche de la région. La qualité de l'eau et l'envasement du lac sont suivis de près par les services de l'État."],
                ],
            ],
            // ——— Histoire ————————————————————————————————————————————————
            [
                'slug' => 'independance-de-la-cote-d-ivoire',
                'title' => "L'indépendance de la Côte d'Ivoire",
                'summary' => "Proclamée le 7 août 1960, l'indépendance fait de Félix Houphouët-Boigny le premier président de la République de Côte d'Ivoire.",
                'type' => ArticleType::TOPIC,
                'category' => 'histoire',
                'tags' => ['independance', 'histoire-politique'],
                'blocks' => [
                    ['p', "La Côte d'Ivoire accède à l'indépendance le 7 août 1960, après deux années de statut autonome au sein de la Communauté française. Félix Houphouët-Boigny, déjà président du Conseil depuis 1959, devient le premier président de la République."],
                    ['h2', 'De la colonie à la République'],
                    ['p', "Colonie française depuis 1893, le territoire a été intégré à l'Afrique-Occidentale française avant de devenir, en 1958, une république autonome. Les élections de 1959 donnent au Parti démocratique de Côte d'Ivoire (PDCI-RDA) la quasi-totalité des sièges."],
                    ['h2', 'Les premiers choix du jeune État'],
                    ['p', "Le nouveau pouvoir mise sur l'agriculture d'exportation, l'ouverture aux capitaux étrangers et la stabilité politique. Abidjan reste la capitale, et le français la langue officielle. Le pays adhère à l'ONU en septembre 1960."],
                ],
                'references' => [
                    [
                        'kind' => 'OTHER',
                        'authors' => null,
                        'title' => "Journal officiel de la République de Côte d'Ivoire, 1960",
                        'publisher' => 'Imprimerie nationale',
                        'year' => 1960,
                        'url' => null,
                    ],
                ],
            ],
            [
                'slug' => 'coup-d-etat-de-1999',
                'title' => "Le coup d'État de 1999",
                'summary' => "Le 24 décembre 1999, un soulèvement militaire renverse Henri Konan Bédié : c'est le premier coup d'État de l'histoire du pays.",
                'type' => ArticleType::TOPIC,
                'category' => 'histoire',
                'tags' => ['crise-politique', 'histoire-politique'],
                'blocks' => [
                    ['p', "Dans la nuit du 24 décembre 1999, des militaires prennent le contrôle d'Abidjan et renversent le président Henri Konan Bédié. Le général Robert Guéï prend la tête d'un Comité national de salut public et promet une transition courte."],
                    ['h2', 'Les causes'],
                    ['p', "Le mécontentement des soldats, les tensions autour de la succession de Félix Houphouët-Boigny et la crise économique alimentent le putsch. La notion d'« ivoirité », promue par le camp présidentiel, avait déjà crispé le débat politique."],
                    ['h2', 'Une transition contestée'],
                    ['p', 'Une nouvelle Constitution est adoptée par référendum en juillet 2000, puis une élection présidentielle est organisée en octobre. La victoire de Laurent Gbagbo est contestée par Robert Guéï, qui est écarté du pouvoir dans la foulée.'],
                ],
            ],
            [
                'slug' => 'crise-politique-de-2002-2011',
                'title' => 'La crise politique de 2002-2011',
                'summary' => "Ouverte par la tentative de coup d'État du 19 septembre 2002, la crise ivoirienne ne se referme qu'en 2011, après la guerre post-électorale.",
                'type' => ArticleType::TOPIC,
                'category' => 'histoire',
                'tags' => ['crise-politique', 'histoire-politique'],
                'blocks' => [
                    ['p', "Le 19 septembre 2002, une tentative de coup d'État échoue à Abidjan mais débouche sur la prise de contrôle du nord du pays par des Forces nouvelles. Le pays est coupé en deux pendant près de neuf ans."],
                    ['h2', 'Accords et partitions'],
                    ['p', "Les accords de Linas-Marcoussis (2003) puis l'accord politique de Ouagadougou (2007) organisent une sortie de crise progressive : gouvernement de réconciliation, redéploiement de l'administration et préparation des élections."],
                    ['h2', 'La guerre post-électorale de 2010-2011'],
                    ['p', "L'élection présidentielle de novembre 2010 oppose Laurent Gbagbo à Alassane Ouattara. Le refus du président sortant de reconnaître les résultats, validés par la commission électorale et la communauté internationale, plonge le pays dans une crise violente qui s'achève par l'arrestation de Laurent Gbagbo le 11 avril 2011."],
                ],
            ],
            [
                'slug' => 'samory-toure',
                'title' => 'Samory Touré',
                'summary' => "Fondateur de l'empire du Wassoulou, Samory Touré (vers 1830-1900) a résisté pendant près de vingt ans à la conquête coloniale française en Afrique de l'Ouest.",
                'type' => ArticleType::BIOGRAPHY,
                'category' => 'personnalites',
                'tags' => ['resistance', 'histoire-politique'],
                'infobox' => [
                    'fullName' => 'Samory Touré',
                    'birthPlace' => 'Manyambaladougou (actuelle Guinée)',
                    'nationalities' => ['Guinéenne', 'Malienne'],
                    'occupations' => ['Souverain', 'Chef militaire'],
                ],
                'blocks' => [
                    ['p', "Samory Touré est l'une des grandes figures de la résistance à la colonisation en Afrique de l'Ouest. Né vers 1830 dans le pays malinké, il fonde l'empire du Wassoulou, qui s'étend sur une partie de l'actuelle Guinée, du Mali et du nord de la Côte d'Ivoire."],
                    ['h2', 'Un empire commerçant et militaire'],
                    ['p', "Son pouvoir repose sur le commerce, notamment de l'or et des armes, et sur une armée organisée. Il installe sa capitale à Bissandougou, puis déplace son territoire face à l'avancée des troupes françaises."],
                    ['h2', 'La résistance et la capture'],
                    ['p', "Pendant près de vingt ans, Samory Touré oppose une guérilla aux colonnes françaises. Capturé en 1898 dans l'ouest de l'actuelle Côte d'Ivoire, il est déporté au Gabon, où il meurt en 1900. Sa mémoire reste vive dans toute la sous-région."],
                ],
            ],
            [
                'slug' => 'royaume-de-kong',
                'title' => 'Le royaume de Kong',
                'summary' => "Cité-État dioula du nord ivoirien, Kong a dominé au XVIIIe siècle le commerce entre la savane et les forêts, avant d'être détruite par Samory Touré.",
                'type' => ArticleType::TOPIC,
                'category' => 'histoire',
                'tags' => ['royautes', 'histoire-politique'],
                'blocks' => [
                    ['p', "Kong, dans l'actuel nord de la Côte d'Ivoire, a été au XVIIIe siècle le centre d'un royaume dioula prospère, à la charnière des routes commerciales qui reliaient Djenné, le Sahel et le golfe de Guinée."],
                    ['h2', 'Une puissance commerçante'],
                    ['p', 'Le royaume contrôlait le commerce du sel, des tissus, des noix de kola et des armes. Sa capitale abritait une cour lettrée et des mosquées de style soudanais, dont certaines sont encore visibles.'],
                    ['h2', 'Déclin et destruction'],
                    ['p', 'Affaibli par les rivalités internes et la concurrence des grands empires voisins, Kong est finalement détruit à la fin du XIXe siècle par les troupes de Samory Touré. La ville perd alors son rôle de carrefour au profit de Korhogo et de Bouaké.'],
                ],
            ],
            // ——— Personnalités ———————————————————————————————————————————
            [
                'slug' => 'henri-konan-bedie',
                'title' => 'Henri Konan Bédié',
                'summary' => "Économiste et homme d'État ivoirien (1934-2023), Henri Konan Bédié a succédé à Félix Houphouët-Boigny et présidé le pays de 1993 à 1999.",
                'type' => ArticleType::BIOGRAPHY,
                'category' => 'personnalites',
                'tags' => ['histoire-politique'],
                'infobox' => [
                    'fullName' => 'Henri Konan Bédié',
                    'birthDate' => '1934-05-05',
                    'birthPlace' => 'Dadiékro, près de Dimbokro',
                    'deathDate' => '2023-08-01',
                    'deathPlace' => 'Abidjan',
                    'nationalities' => ['Ivoirienne'],
                    'occupations' => ['Économiste', "Homme d'État"],
                ],
                'blocks' => [
                    ['p', "Henri Konan Bédié est né le 5 mai 1934 à Dadiékro, dans la région de Dimbokro. Économiste formé en France, il entre au gouvernement en 1966 et devient ministre de l'Économie et des Finances, avant d'être élu président de l'Assemblée nationale."],
                    ['h2', 'La succession de 1993'],
                    ['p', "À la mort de Félix Houphouët-Boigny, en décembre 1993, il lui succède à la tête de l'État et du PDCI-RDA. Il est élu président en 1995, lors d'une élection boycottée par une partie de l'opposition."],
                    ['h2', 'La chute de 1999 et le retour'],
                    ['p', "Renversé par le coup d'État du 24 décembre 1999, il s'exile puis revient en 2001. Il reste une figure majeure de la vie politique ivoirienne, candidat à plusieurs élections présidentielles et artisan de rapprochements avec le pouvoir. Il meurt à Abidjan le 1er août 2023."],
                ],
            ],
            [
                'slug' => 'laurent-gbagbo',
                'title' => 'Laurent Gbagbo',
                'summary' => "Historien et homme d'État ivoirien né en 1945, Laurent Gbagbo a présidé la Côte d'Ivoire de 2000 à 2011.",
                'type' => ArticleType::BIOGRAPHY,
                'category' => 'personnalites',
                'tags' => ['histoire-politique', 'crise-politique'],
                'infobox' => [
                    'fullName' => 'Laurent Koudou Gbagbo',
                    'birthDate' => '1945-05-31',
                    'birthPlace' => 'Gagnoa',
                    'nationalities' => ['Ivoirienne'],
                    'occupations' => ['Historien', "Homme d'État"],
                ],
                'blocks' => [
                    ['p', "Laurent Gbagbo est né le 31 mai 1945 à Gagnoa, dans le centre-ouest. Historien de formation, il enseigne puis milite dans l'opposition au parti unique, ce qui lui vaut plusieurs séjours en exil et en prison dans les années 1980."],
                    ['h2', 'Le Front populaire ivoirien'],
                    ['p', "Il fonde le Front populaire ivoirien (FPI) en 1988 et devient l'une des principales figures de l'opposition. Après la transition de 1999-2000, il remporte l'élection présidentielle d'octobre 2000 face à Robert Guéï."],
                    ['h2', 'La présidence et la crise'],
                    ['p', "Sa présidence est marquée par la partition du pays à partir de 2002 et par une longue crise politique. Après l'élection contestée de 2010, il refuse de céder le pouvoir et est arrêté le 11 avril 2011. Acquitté par la Cour pénale internationale en 2019, il revient en Côte d'Ivoire en 2021."],
                ],
            ],
            [
                'slug' => 'alassane-ouattara',
                'title' => 'Alassane Ouattara',
                'summary' => "Économiste et homme d'État ivoirien né en 1942, Alassane Ouattara est président de la République depuis 2011.",
                'type' => ArticleType::BIOGRAPHY,
                'category' => 'personnalites',
                'tags' => ['histoire-politique'],
                'infobox' => [
                    'fullName' => 'Alassane Dramane Ouattara',
                    'birthDate' => '1942-01-01',
                    'birthPlace' => 'Dimbokro',
                    'nationalities' => ['Ivoirienne'],
                    'occupations' => ['Économiste', "Homme d'État"],
                ],
                'blocks' => [
                    ['p', "Alassane Ouattara est né le 1er janvier 1942 à Dimbokro. Docteur en économie formé aux États-Unis, il travaille au Fonds monétaire international, où il devient directeur adjoint, avant de revenir en Côte d'Ivoire."],
                    ['h2', 'Premier ministre et opposition'],
                    ['p', "Nommé Premier ministre en 1990, il conduit un programme d'ajustement économique. Écarté du pouvoir après 1993, il fonde le Rassemblement des républicains (RDR) et devient, au fil des crises, le principal adversaire de Laurent Gbagbo."],
                    ['h2', 'La présidence depuis 2011'],
                    ['p', "Reconnu vainqueur de l'élection de 2010 par la commission électorale et la communauté internationale, il accède à la présidence en avril 2011. Réélu en 2015 et en 2020, il conduit une politique de reconstruction et d'attractivité économique, tout en restant critiqué par une partie de l'opposition."],
                ],
            ],
            [
                'slug' => 'robert-guei',
                'title' => 'Robert Guéï',
                'summary' => "Général ivoirien (1941-2002), Robert Guéï a dirigé la transition de 1999-2000 avant d'être écarté du pouvoir.",
                'type' => ArticleType::BIOGRAPHY,
                'category' => 'personnalites',
                'tags' => ['histoire-politique', 'crise-politique'],
                'infobox' => [
                    'fullName' => 'Robert Guéï',
                    'birthDate' => '1941-03-16',
                    'birthPlace' => 'Kabakouma',
                    'deathDate' => '2002-09-19',
                    'deathPlace' => 'Abidjan',
                    'nationalities' => ['Ivoirienne'],
                    'occupations' => ['Militaire', "Homme d'État"],
                ],
                'blocks' => [
                    ['p', "Robert Guéï est un officier ivoirien né en 1941 dans l'ouest du pays. Chef d'état-major de l'armée sous Félix Houphouët-Boigny, il est écarté de ses fonctions en 1995 avant de prendre la tête du Comité national de salut public après le coup d'État de décembre 1999."],
                    ['h2', 'Une transition contestée'],
                    ['p', "Il promet une transition brève et fait adopter une nouvelle Constitution en 2000. Mais sa candidature à l'élection présidentielle, puis sa tentative de s'opposer à la proclamation des résultats, provoquent sa chute en octobre 2000."],
                    ['h2', 'La mort de 2002'],
                    ['p', "Robert Guéï est tué le 19 septembre 2002, au premier jour de la tentative de coup d'État, dans des circonstances qui n'ont jamais été entièrement éclaircies."],
                ],
            ],
            [
                'slug' => 'didier-drogba',
                'title' => 'Didier Drogba',
                'summary' => 'Ancien attaquant international ivoirien né en 1978, Didier Drogba est la figure la plus connue du football ivoirien et un acteur de la réconciliation nationale.',
                'type' => ArticleType::BIOGRAPHY,
                'category' => 'personnalites',
                'tags' => ['sport'],
                'infobox' => [
                    'fullName' => 'Didier Yves Drogba Tébily',
                    'birthDate' => '1978-03-11',
                    'birthPlace' => 'Abidjan',
                    'nationalities' => ['Ivoirienne'],
                    'occupations' => ['Footballeur'],
                ],
                'blocks' => [
                    ['p', "Didier Drogba est né le 11 mars 1978 à Abidjan. Formé en France, il s'impose comme attaquant à Marseille avant de rejoindre Chelsea en 2004, où il devient l'un des meilleurs buteurs de l'histoire du club londonien."],
                    ['h2', 'Les Éléphants'],
                    ['p', "Capitaine de la sélection ivoirienne, il mène les Éléphants à deux finales de Coupe d'Afrique des nations, en 2006 et en 2012. Son appel à la réconciliation, lancé en 2005 après la qualification pour la Coupe du monde, reste un moment marquant de la vie publique ivoirienne."],
                    ['h2', 'Après le football'],
                    ['p', "Retiré des terrains en 2018, il s'engage dans des actions humanitaires, notamment pour l'accès à l'eau potable et la santé. Il est ambassadeur de plusieurs organisations internationales et reste une icône populaire en Côte d'Ivoire."],
                ],
            ],
            [
                'slug' => 'alpha-blondy',
                'title' => 'Alpha Blondy',
                'summary' => 'Chanteur ivoirien de reggae né en 1953, Alpha Blondy a fait de la musique un espace de critique sociale et de dialogue entre les religions.',
                'type' => ArticleType::BIOGRAPHY,
                'category' => 'personnalites',
                'tags' => ['musique'],
                'infobox' => [
                    'fullName' => 'Seydou Koné, dit Alpha Blondy',
                    'birthDate' => '1953-01-01',
                    'birthPlace' => 'Dimbokro',
                    'nationalities' => ['Ivoirienne'],
                    'occupations' => ['Chanteur', 'Auteur-compositeur'],
                ],
                'blocks' => [
                    ['p', "Alpha Blondy, de son vrai nom Seydou Koné, est né le 1er janvier 1953 à Dimbokro. Après des études aux États-Unis et un passage par la Côte d'Ivoire, il s'impose dans les années 1980 comme la voix du reggae africain."],
                    ['h2', 'Un reggae engagé'],
                    ['p', "Ses chansons mêlent français, dioula, anglais et arabe pour dénoncer la corruption, la guerre et l'injustice. L'album « Jérusalem » (1986), enregistré avec des musiciens israéliens et palestiniens, reste son geste artistique le plus commenté."],
                    ['h2', 'Une icône panafricaine'],
                    ['p', 'Alpha Blondy se produit sur les scènes du monde entier et revendique une fidélité à ses racines ivoiriennes. Il est aussi connu pour ses prises de position en faveur de la paix et du dialogue interreligieux.'],
                ],
            ],
            // ——— Institutions ————————————————————————————————————————————
            [
                'slug' => 'president-de-la-republique',
                'title' => 'Le président de la République',
                'summary' => "Clé de voûte des institutions ivoiriennes, le président est élu au suffrage universel direct pour cinq ans et dirige l'exécutif.",
                'type' => ArticleType::INSTITUTION,
                'category' => 'institutions',
                'tags' => ['administration', 'droit-constitutionnel'],
                'infobox' => [
                    'officialName' => 'Président de la République de Côte d’Ivoire',
                    'institutionType' => 'Chef de l’État',
                    'headquarters' => 'Palais présidentiel, Abidjan',
                ],
                'blocks' => [
                    ['p', "Le président de la République est le chef de l'État ivoirien. Il est élu au suffrage universel direct pour un mandat de cinq ans, selon les règles fixées par la Constitution de 2016."],
                    ['h2', 'Ses pouvoirs'],
                    ['p', "Il nomme le Premier ministre et les membres du gouvernement, dispose du pouvoir réglementaire et représente l'État à l'étranger. Il peut dissoudre l'Assemblée nationale et saisir le Conseil constitutionnel dans les cas prévus par le texte."],
                    ['h2', 'Un régime présidentiel fort'],
                    ['p', "La Constitution de 2016 a créé un poste de vice-président élu sur le même ticket, chargé de remplacer le président en cas de vacance. Malgré ces évolutions, l'équilibre institutionnel reste marqué par la prééminence de l'exécutif."],
                ],
            ],
            [
                'slug' => 'assemblee-nationale',
                'title' => "L'Assemblée nationale",
                'summary' => "Chambre basse du Parlement ivoirien, l'Assemblée nationale compte 255 députés élus pour cinq ans.",
                'type' => ArticleType::INSTITUTION,
                'category' => 'institutions',
                'tags' => ['administration', 'droit-constitutionnel'],
                'infobox' => [
                    'officialName' => "Assemblée nationale de Côte d'Ivoire",
                    'institutionType' => 'Chambre législative',
                    'foundedYear' => 1959,
                    'headquarters' => 'Abidjan',
                ],
                'blocks' => [
                    ['p', "L'Assemblée nationale est la chambre basse du Parlement ivoirien. Ses 255 députés sont élus pour cinq ans au scrutin de liste dans les circonscriptions du pays."],
                    ['h2', 'Voter la loi et contrôler le gouvernement'],
                    ['p', "L'Assemblée examine et vote les lois, autorise le budget de l'État et contrôle l'action du gouvernement par les questions écrites et orales, les commissions d'enquête et, le cas échéant, la motion de censure."],
                    ['h2', 'Un bicamérisme récent'],
                    ['p', "Depuis la Constitution de 2016, le Parlement est bicaméral : l'Assemblée nationale siège aux côtés du Sénat, créé en 2018. Les deux chambres examinent successivement les textes, avec une procédure de navette en cas de désaccord."],
                ],
            ],
            [
                'slug' => 'senat',
                'title' => 'Le Sénat',
                'summary' => 'Créé par la Constitution de 2016, le Sénat ivoirien compte 99 membres et représente les collectivités territoriales.',
                'type' => ArticleType::INSTITUTION,
                'category' => 'institutions',
                'tags' => ['administration', 'droit-constitutionnel'],
                'infobox' => [
                    'officialName' => "Sénat de Côte d'Ivoire",
                    'institutionType' => 'Chambre législative',
                    'foundedYear' => 2016,
                    'headquarters' => 'Yamoussoukro',
                ],
                'blocks' => [
                    ['p', 'Le Sénat est la chambre haute du Parlement ivoirien, instituée par la Constitution de 2016. Il compte 99 sénateurs : deux tiers élus par les conseillers régionaux et municipaux, un tiers nommé par le président de la République.'],
                    ['h2', 'Une chambre de représentation territoriale'],
                    ['p', "Le Sénat a pour vocation de représenter les collectivités territoriales et de participer à l'examen des lois, en particulier celles qui concernent la décentralisation. Sa première session s'est tenue en 2018."],
                    ['h2', 'Critiques et débats'],
                    ['p', "La création de la chambre a été critiquée par l'opposition, qui y voyait un coût supplémentaire et un affaiblissement du rôle de l'Assemblée nationale. Ses partisans soulignent au contraire une meilleure prise en compte des territoires."],
                ],
            ],
            [
                'slug' => 'conseil-constitutionnel',
                'title' => 'Le Conseil constitutionnel',
                'summary' => 'Le Conseil constitutionnel ivoirien contrôle la conformité des lois à la Constitution et proclame les résultats des élections nationales.',
                'type' => ArticleType::INSTITUTION,
                'category' => 'institutions',
                'tags' => ['administration', 'droit-constitutionnel'],
                'infobox' => [
                    'officialName' => 'Conseil constitutionnel de Côte d’Ivoire',
                    'institutionType' => 'Juridiction constitutionnelle',
                    'headquarters' => 'Abidjan',
                ],
                'blocks' => [
                    ['p', 'Le Conseil constitutionnel est la juridiction chargée de veiller au respect de la Constitution ivoirienne. Il examine la conformité des lois et des traités avant leur promulgation ou leur ratification.'],
                    ['h2', 'Juge des élections'],
                    ['p', 'Il proclame les résultats définitifs des élections présidentielles, législatives et sénatoriales, et statue sur les contentieux électoraux. Il reçoit le serment du président de la République.'],
                    ['h2', 'Une composition encadrée'],
                    ['p', "Ses membres sont nommés par le président de la République, le président de l'Assemblée nationale et le président du Sénat. Ses décisions s'imposent aux pouvoirs publics et à toutes les autorités administratives et juridictionnelles."],
                ],
            ],
            // ——— Langues ———————————————————————————————————————————————
            [
                'slug' => 'le-dioula',
                'title' => 'Le dioula',
                'summary' => "Langue mandé du nord de la Côte d'Ivoire, le dioula sert de langue de commerce et de contact dans une grande partie de l'Afrique de l'Ouest.",
                'type' => ArticleType::TOPIC,
                'category' => 'langues',
                'tags' => ['langues-mande'],
                'blocks' => [
                    ['p', "Le dioula (ou jula) est une variété mandé parlée dans le nord de la Côte d'Ivoire, ainsi qu'au Burkina Faso et au Mali. Il est très proche du bambara et du malinké, avec lesquels la communication reste largement possible."],
                    ['h2', 'La langue du marché'],
                    ['p', "Historiquement diffusé par les réseaux de commerçants musulmans, le dioula est devenu la langue véhiculaire des marchés, des transports et des quartiers populaires du nord et de l'ouest du pays. De nombreux Ivoiriens l'utilisent en seconde langue."],
                    ['h2', 'Écriture et transmission'],
                    ['p', "Le dioula s'écrit avec l'alphabet latin, mais aussi avec l'écriture arabe dans un usage religieux. Il est enseigné dans certaines écoles et fait l'objet de programmes d'alphabétisation, notamment dans les zones cotonnières."],
                ],
            ],
            [
                'slug' => 'le-senoufo',
                'title' => 'Le sénoufo',
                'summary' => 'Langue du groupe gur parlée dans le nord ivoirien, le sénoufo est associé à la société du Poro et à une riche tradition de sculpture.',
                'type' => ArticleType::TOPIC,
                'category' => 'langues',
                'tags' => ['langues-gur', 'peuples'],
                'blocks' => [
                    ['p', "Le sénoufo appartient au groupe des langues gur (ou voltaïques), parlées principalement dans le nord de la Côte d'Ivoire et au Burkina Faso. Il connaît plusieurs variétés locales, dont le sénoufo de Korhogo et celui de Boundiali."],
                    ['h2', 'Une langue et une institution'],
                    ['p', "Le sénoufo est étroitement lié au Poro, société d'initiation qui organise la transmission des savoirs, des chants et des récits. Les funérailles, les travaux agricoles et les fêtes villageoises rythment son usage."],
                    ['h2', 'Une tradition orale vivante'],
                    ['p', "La langue porte un important patrimoine oral : contes, proverbes, chants de labour et récits d'origine. Des linguistes et des associations culturelles en ont entrepris la transcription depuis les années 1970."],
                ],
            ],
            [
                'slug' => 'le-bete',
                'title' => 'Le bété',
                'summary' => "Langue kru du centre-ouest de la Côte d'Ivoire, le bété est parlé dans la région de Gagnoa, Daloa et Soubré.",
                'type' => ArticleType::TOPIC,
                'category' => 'langues',
                'tags' => ['langues-kru'],
                'blocks' => [
                    ['p', "Le bété fait partie des langues kru, parlées dans le centre-ouest et le sud-ouest de la Côte d'Ivoire. Il se divise en plusieurs parlers, dont le bété de Gagnoa et celui de Daloa."],
                    ['h2', 'Une langue de la forêt'],
                    ['p', 'Historiquement liée aux sociétés de la forêt, la langue bété accompagne les travaux agricoles, notamment la culture du cacao, et les rites funéraires. Elle est aussi très présente dans la musique urbaine ivoirienne.'],
                    ['h2', 'Transmission et usage'],
                    ['p', 'Comme beaucoup de langues nationales, le bété recule dans les villes au profit du français et du dioula, mais reste la langue du village et de la famille. Des émissions de radio et des publications contribuent à sa vitalité.'],
                ],
            ],
            [
                'slug' => 'le-dan',
                'title' => 'Le dan (yacouba)',
                'summary' => "Langue mandé du sud parlée à l'ouest de la Côte d'Ivoire, le dan est la langue du peuple yacouba, connu pour ses masques.",
                'type' => ArticleType::TOPIC,
                'category' => 'langues',
                'tags' => ['langues-mande', 'peuples'],
                'blocks' => [
                    ['p', "Le dan est une langue mandé du sud parlée dans l'ouest de la Côte d'Ivoire, autour de Man, ainsi qu'en Guinée. Les locuteurs ivoiriens sont couramment désignés sous le nom de Yacouba."],
                    ['h2', 'Masques et société'],
                    ['p', 'La langue accompagne un univers rituel marqué par les masques, dont les masques « gorge », et par les sociétés initiatiques. Les récits généalogiques et les chants de funérailles y occupent une place centrale.'],
                    ['h2', 'Une langue transfrontalière'],
                    ['p', "Le dan se parle de part et d'autre de la frontière avec la Guinée et le Liberia, où vivent d'autres communautés dan. Cette continuité explique la richesse des variantes locales et la circulation des répertoires musicaux."],
                ],
            ],
            [
                'slug' => 'le-nouchi',
                'title' => 'Le nouchi',
                'summary' => "Argot urbain né dans les rues d'Abidjan dans les années 1980, le nouchi mêle français, langues ivoiriennes et anglais.",
                'type' => ArticleType::TOPIC,
                'category' => 'langues',
                'tags' => ['langues-kru'],
                'blocks' => [
                    ['p', "Le nouchi est un argot urbain apparu à Abidjan dans les années 1980, dans les quartiers populaires et les milieux de la débrouille. Il emprunte au français, au dioula, au baoulé, au bété et à l'anglais."],
                    ['h2', 'Une langue de la jeunesse'],
                    ['p', "D'abord marqueur d'identité des jeunes désœuvrés, le nouchi s'est diffusé par la musique, la publicité et les réseaux sociaux. Il est aujourd'hui compris par une large partie de la population urbaine et utilisé dans la presse satirique."],
                    ['h2', "Un objet d'étude"],
                    ['p', 'Des linguistes ivoiriens étudient le nouchi comme un laboratoire du français en Afrique. Son lexique évolue vite, et certains de ses mots entrent dans la langue courante, jusque dans les discours officiels.'],
                ],
            ],
            // ——— Culture ———————————————————————————————————————————————
            [
                'slug' => 'le-zaouli',
                'title' => 'Le zaouli',
                'summary' => "Danse masquée du peuple gouro, le zaouli est inscrit au patrimoine culturel immatériel de l'UNESCO depuis 2017.",
                'type' => ArticleType::TOPIC,
                'category' => 'culture',
                'tags' => ['danse', 'patrimoine', 'unesco'],
                'blocks' => [
                    ['p', "Le zaouli est une danse masquée pratiquée par les Gouro, dans le centre-ouest de la Côte d'Ivoire. Elle associe un masque sculpté, un costume de fibres et un rythme de tambours rapide, autour d'un danseur central."],
                    ['h2', 'Une danse de virtuosité'],
                    ['p', 'Le danseur enchaîne des pas rapides et des figures acrobatiques, tandis que les percussionnistes soutiennent un tempo soutenu. La performance est réputée pour son exigence physique et sa dimension spectaculaire.'],
                    ['h2', 'Une reconnaissance internationale'],
                    ['p', "Le zaouli a été inscrit en 2017 sur la liste représentative du patrimoine culturel immatériel de l'humanité. Cette reconnaissance a renforcé sa visibilité, notamment lors des festivals et des cérémonies villageoises."],
                ],
                'references' => [
                    [
                        'kind' => 'OTHER',
                        'authors' => null,
                        'title' => 'Liste représentative du patrimoine culturel immatériel de l’humanité',
                        'publisher' => 'UNESCO',
                        'year' => 2017,
                        'url' => 'https://ich.unesco.org',
                    ],
                ],
            ],
            [
                'slug' => 'le-goli',
                'title' => 'Le goli',
                'summary' => "Masquerade baoulé aux masques circulaires, le goli accompagne les funérailles et les grandes cérémonies du centre de la Côte d'Ivoire.",
                'type' => ArticleType::TOPIC,
                'category' => 'culture',
                'tags' => ['danse', 'peuples'],
                'blocks' => [
                    ['p', 'Le goli est une institution cérémonielle baoulé qui réunit musique, danse et masques. Il se manifeste lors des funérailles de notables, des fêtes de village et de certaines célébrations publiques.'],
                    ['h2', 'Des masques en couple'],
                    ['p', "Le goli met souvent en scène deux masques complémentaires : un masque rond et plat, considéré comme féminin, et un masque plus haut et allongé, associé au masculin. Leur danse est accompagnée d'orchestres de tambours et de trompes."],
                    ['h2', 'Un patrimoine vivant'],
                    ['p', 'Transmis dans des lignages spécialisés, le goli reste pratiqué dans le centre du pays. Des festivals et des compagnies de danse contribuent à le faire connaître hors des villages, tout en posant la question de sa mise en spectacle.'],
                ],
            ],
            [
                'slug' => 'le-kedjenou',
                'title' => 'Le kedjenou',
                'summary' => "Plat mijoté en pot de terre, le kedjenou est l'une des recettes les plus emblématiques de la cuisine ivoirienne.",
                'type' => ArticleType::TOPIC,
                'category' => 'culture',
                'tags' => ['gastronomie'],
                'blocks' => [
                    ['p', "Le kedjenou est un ragoût de poulet, de pintade ou de poisson, cuit lentement à l'étouffée dans un canari, un pot de terre. Il est préparé avec des tomates, des oignons, du piment et des feuilles de laurier local."],
                    ['h2', 'Une cuisson sans eau ajoutée'],
                    ['p', "La viande et les légumes rendent leur jus sous un couvercle scellé, ce qui concentre les saveurs. Le plat, d'origine baoulé, se mange avec du riz, de l'attiéké ou du foutou."],
                    ['h2', 'Un plat de fête et de famille'],
                    ['p', "Le kedjenou est servi lors des repas de fête et des grandes réunions familiales. Sa préparation, longue, en fait un plat que l'on partage et que l'on prépare à plusieurs."],
                ],
            ],
            [
                'slug' => 'le-coupe-decale',
                'title' => 'Le coupé-décalé',
                'summary' => 'Genre musical et chorégraphique apparu au début des années 2000, le coupé-décalé a conquis les pistes de danse africaines depuis la diaspora ivoirienne.',
                'type' => ArticleType::TOPIC,
                'category' => 'culture',
                'tags' => ['musique', 'danse'],
                'blocks' => [
                    ['p', 'Le coupé-décalé naît au début des années 2000 dans la diaspora ivoirienne à Paris, autour de figures comme Douk Saga. Le style mêle rythmes électroniques, percussions et chants en nouchi.'],
                    ['h2', 'Une musique de fête'],
                    ['p', 'Le genre se caractérise par des tempos rapides, des slogans et des pas de danse collectifs. Il accompagne les soirées, les mariages et les compétitions sportives, et a donné naissance à de nombreuses variantes locales.'],
                    ['h2', 'Un phénomène de société'],
                    ['p', "Au-delà de la musique, le coupé-décalé a été associé à un style de vie ostentatoire, puis critiqué pour ses excès. Il reste l'un des exports culturels ivoiriens les plus visibles, porté par des artistes comme DJ Arafat."],
                ],
            ],
            [
                'slug' => 'le-zouglou',
                'title' => 'Le zouglou',
                'summary' => "Né dans les campus d'Abidjan au début des années 1990, le zouglou est une musique de témoignage social devenue emblématique de la jeunesse ivoirienne.",
                'type' => ArticleType::TOPIC,
                'category' => 'culture',
                'tags' => ['musique'],
                'blocks' => [
                    ['p', "Le zouglou apparaît au début des années 1990 dans les cités universitaires d'Abidjan, notamment à Yopougon. Des étudiants y racontent, sur des rythmes simples et des chœurs, le quotidien des campus et les difficultés de la vie urbaine."],
                    ['h2', 'Une musique de témoignage'],
                    ['p', "Les textes parlent de pauvreté, de débrouille, de corruption et d'amour, dans un français mêlé de nouchi. Le style se distingue par ses percussions, ses chœurs et une gestuelle collective."],
                    ['h2', 'Une diffusion durable'],
                    ['p', 'Des groupes comme Magic System ou Les Parents du Campus ont porté le zouglou sur les scènes internationales. Le genre reste une référence pour la chanson ivoirienne engagée et un marqueur générationnel.'],
                ],
            ],
            [
                'slug' => 'ahmadou-kourouma',
                'title' => 'Ahmadou Kourouma',
                'summary' => 'Écrivain ivoirien (1927-2003), Ahmadou Kourouma a renouvelé le roman africain de langue française et reçu le prix Renaudot en 2000.',
                'type' => ArticleType::BIOGRAPHY,
                'category' => 'personnalites',
                'tags' => ['litterature'],
                'infobox' => [
                    'fullName' => 'Ahmadou Kourouma',
                    'birthDate' => '1927-11-24',
                    'birthPlace' => 'Boundiali',
                    'deathDate' => '2003-12-11',
                    'deathPlace' => 'Lyon',
                    'nationalities' => ['Ivoirienne'],
                    'occupations' => ['Écrivain'],
                ],
                'blocks' => [
                    ['p', "Ahmadou Kourouma est né le 24 novembre 1927 à Boundiali, dans le nord de la Côte d'Ivoire. Après des études en France, il devient statisticien, tout en écrivant une œuvre romanesque marquante."],
                    ['h2', 'Les Soleils des indépendances'],
                    ['p', 'Publié en 1968, son premier roman, « Les Soleils des indépendances », rompt avec le français académique en intégrant la syntaxe et les images malinké. Il y interroge les désillusions qui suivent les indépendances africaines.'],
                    ['h2', 'Une œuvre de dénonciation'],
                    ['p', "Ses romans suivants décrivent les dictatures, les guerres et la corruption. « Allah n'est pas obligé », paru en 2000, reçoit le prix Renaudot et le prix Goncourt des lycéens. Kourouma meurt à Lyon le 11 décembre 2003."],
                ],
            ],
            // ——— Patrimoine ————————————————————————————————————————————
            [
                'slug' => 'grand-bassam',
                'title' => 'Grand-Bassam',
                'summary' => "Ancienne capitale coloniale de la Côte d'Ivoire, Grand-Bassam est inscrite au patrimoine mondial de l'UNESCO depuis 2012.",
                'type' => ArticleType::REGION,
                'category' => 'patrimoine',
                'tags' => ['patrimoine', 'unesco', 'ville'],
                'blocks' => [
                    ['p', "Grand-Bassam se trouve à une quarantaine de kilomètres à l'est d'Abidjan, à l'embouchure de la lagune Ouladine. La ville a été la capitale de la Côte d'Ivoire coloniale de 1893 à 1900, avant que l'épidémie de fièvre jaune ne pousse l'administration à gagner Bingerville."],
                    ['h2', 'Un quartier colonial classé'],
                    ['p', "Le quartier France conserve un ensemble de bâtiments administratifs, de villas et de commerces de la période coloniale. Ce patrimoine architectural a été inscrit en 2012 sur la liste du patrimoine mondial de l'UNESCO."],
                    ['h2', 'Une ville entre mémoire et tourisme'],
                    ['p', "Grand-Bassam est aujourd'hui une destination de week-end pour les Abidjanais, avec ses plages, ses restaurants et son musée. La préservation des bâtiments anciens reste un défi, entre restauration et pression foncière."],
                ],
                'references' => [
                    [
                        'kind' => 'OTHER',
                        'authors' => null,
                        'title' => 'Ville historique de Grand-Bassam',
                        'publisher' => 'UNESCO, patrimoine mondial',
                        'year' => 2012,
                        'url' => 'https://whc.unesco.org',
                    ],
                ],
            ],
            [
                'slug' => 'parc-national-de-tai',
                'title' => 'Parc national de Taï',
                'summary' => "Dernière grande forêt primaire de l'ouest ivoirien, le parc de Taï est inscrit au patrimoine mondial depuis 1982.",
                'type' => ArticleType::TOPIC,
                'category' => 'patrimoine',
                'tags' => ['biodiversite', 'foret', 'unesco'],
                'blocks' => [
                    ['p', "Le parc national de Taï occupe le sud-ouest de la Côte d'Ivoire, près de la frontière libérienne. Il protège l'une des dernières grandes forêts primaires d'Afrique de l'Ouest, dans un climat équatorial humide."],
                    ['h2', 'Une biodiversité exceptionnelle'],
                    ['p', "Le parc abrite des chimpanzés, des éléphants de forêt et l'hippopotame pygmée, espèce rare et menacée. Sa végétation compte des centaines d'essences forestières, dont certaines sont endémiques."],
                    ['h2', 'Protection et pressions'],
                    ['p', "Classé en 1972 et inscrit au patrimoine mondial en 1982, le parc souffre du braconnage, de l'exploitation forestière illégale et de l'empiètement agricole. Sa gestion associe l'État, des bailleurs internationaux et des projets de recherche."],
                ],
                'references' => [
                    [
                        'kind' => 'OTHER',
                        'authors' => null,
                        'title' => 'Réserve naturelle intégrale du mont Nimba / Parc national de Taï',
                        'publisher' => 'UNESCO, patrimoine mondial',
                        'year' => 1982,
                        'url' => 'https://whc.unesco.org',
                    ],
                ],
            ],
            [
                'slug' => 'parc-national-de-la-comoe',
                'title' => 'Parc national de la Comoé',
                'summary' => 'Plus vaste aire protégée du pays, le parc de la Comoé couvre savanes et forêts du nord-est et figure au patrimoine mondial depuis 1983.',
                'type' => ArticleType::TOPIC,
                'category' => 'patrimoine',
                'tags' => ['biodiversite', 'foret', 'unesco'],
                'blocks' => [
                    ['p', "Le parc national de la Comoé s'étend sur le nord-est de la Côte d'Ivoire, entre les savanes soudaniennes et des lambeaux de forêt. Il doit son nom au fleuve Comoé, qui le traverse."],
                    ['h2', 'Un gradient écologique rare'],
                    ['p', "Le parc présente une transition continue entre forêt humide et savane, ce qui explique la diversité de sa faune : éléphants, buffles, antilopes, hippopotames et de nombreux oiseaux. Il constitue avec Taï l'un des deux grands ensembles protégés du pays."],
                    ['h2', 'Une protection fragile'],
                    ['p', "Inscrit au patrimoine mondial en 1983, le parc a été touché par le braconnage et par l'instabilité des années 2000. Des programmes de surveillance et de réintroduction y ont été relancés depuis 2011."],
                ],
                'references' => [
                    [
                        'kind' => 'OTHER',
                        'authors' => null,
                        'title' => 'Parc national de la Comoé',
                        'publisher' => 'UNESCO, patrimoine mondial',
                        'year' => 1983,
                        'url' => 'https://whc.unesco.org',
                    ],
                ],
            ],
            [
                'slug' => 'mont-nimba',
                'title' => 'Le mont Nimba',
                'summary' => "Point culminant de la Côte d'Ivoire avec 1 752 mètres, le mont Nimba est une réserve naturelle intégrale partagée avec la Guinée.",
                'type' => ArticleType::TOPIC,
                'category' => 'patrimoine',
                'tags' => ['biodiversite', 'unesco'],
                'blocks' => [
                    ['p', "Le mont Nimba culmine à 1 752 mètres à la frontière entre la Côte d'Ivoire, la Guinée et le Liberia. C'est le point le plus haut du pays, visible de loin dans l'ouest."],
                    ['h2', 'Une réserve intégrale'],
                    ['p', "La réserve naturelle intégrale du mont Nimba a été créée en 1944, avant d'être inscrite au patrimoine mondial en 1981. Elle protège une faune et une flore originales, adaptées à l'altitude et aux forêts de montagne."],
                    ['h2', 'Exploitation et protection'],
                    ['p', "Le sous-sol du massif est riche en minerai de fer, ce qui a longtemps nourri des projets miniers. La protection du site, fragile, fait l'objet d'un suivi international et de coopération entre les pays concernés."],
                ],
            ],
            // ——— Économie —————————————————————————————————————————————
            [
                'slug' => 'l-anacarde',
                'title' => "L'anacarde",
                'summary' => "La noix de cajou est devenue la première culture de rente du nord ivoirien, mais l'essentiel de la transformation se fait encore à l'étranger.",
                'type' => ArticleType::TOPIC,
                'category' => 'economie',
                'tags' => ['agriculture'],
                'blocks' => [
                    ['p', "L'anacardier, introduit en Côte d'Ivoire au milieu du XXe siècle, est aujourd'hui cultivé dans presque tout le nord du pays. La noix de cajou brute est devenue une source de revenus essentielle pour des centaines de milliers de producteurs."],
                    ['h2', 'Un géant mondial'],
                    ['p', "La Côte d'Ivoire figure parmi les premiers producteurs mondiaux de noix de cajou brute. La filière est encadrée par un conseil de régulation et un prix bord champ fixé chaque campagne."],
                    ['h2', 'Le défi de la transformation'],
                    ['p', "L'essentiel des noix est exporté brut vers l'Inde et le Vietnam. Le pays cherche à développer la transformation locale pour capter la valeur ajoutée, mais se heurte au coût de l'énergie et à la concurrence des acheteurs asiatiques."],
                ],
            ],
            [
                'slug' => 'le-port-d-abidjan',
                'title' => "Le port d'Abidjan",
                'summary' => "Ouvert en 1950 grâce au canal de Vridi, le port d'Abidjan est le premier port maritime de Côte d'Ivoire et un hub pour l'Afrique de l'Ouest.",
                'type' => ArticleType::TOPIC,
                'category' => 'economie',
                'tags' => ['port', 'industrie'],
                'blocks' => [
                    ['p', "Le port d'Abidjan s'ouvre sur l'océan Atlantique grâce au canal de Vridi, percé en 1950. Il se développe ensuite dans la lagune Ébrié et devient le principal point d'entrée des marchandises du pays."],
                    ['h2', 'Un hub régional'],
                    ['p', 'Le port traite le trafic de conteneurs, les produits pétroliers, le cacao, le bois et les marchandises destinées au Burkina Faso, au Mali et au Niger. Cette fonction de transit lui donne une importance régionale.'],
                    ['h2', 'Extension et concurrence'],
                    ['p', 'Le second terminal à conteneurs, mis en service au début des années 2020, a augmenté la capacité du port. Abidjan reste cependant en concurrence avec les ports de Tema, Lomé et San-Pédro pour le trafic ouest-africain.'],
                ],
            ],
            [
                'slug' => 'le-franc-cfa',
                'title' => 'Le franc CFA',
                'summary' => "Monnaie commune de plusieurs pays d'Afrique de l'Ouest, le franc CFA (XOF) est émis par la BCEAO et rattaché à l'euro.",
                'type' => ArticleType::TOPIC,
                'category' => 'economie',
                'tags' => ['monnaie', 'finance'],
                'blocks' => [
                    ['p', "La Côte d'Ivoire utilise le franc CFA de l'Afrique de l'Ouest, codé XOF, émis par la Banque centrale des États de l'Afrique de l'Ouest (BCEAO), dont le siège est à Dakar."],
                    ['h2', 'Une monnaie partagée'],
                    ['p', "Huit pays membres de l'UEMOA partagent cette monnaie : Bénin, Burkina Faso, Côte d'Ivoire, Guinée-Bissau, Mali, Niger, Sénégal et Togo. La BCEAO fixe la politique monétaire commune et gère les réserves de change."],
                    ['h2', 'Un ancrage contesté'],
                    ['p', "Le franc CFA est rattaché à l'euro à parité fixe, avec une garantie de convertibilité assurée par la France. Ce dispositif est critiqué par ceux qui y voient une perte de souveraineté monétaire, et défendu par ceux qui soulignent sa stabilité."],
                ],
            ],
            [
                'slug' => 'la-brvm',
                'title' => 'La BRVM',
                'summary' => "Bourse régionale des valeurs mobilières basée à Abidjan, la BRVM fédère les marchés financiers de huit pays d'Afrique de l'Ouest.",
                'type' => ArticleType::TOPIC,
                'category' => 'economie',
                'tags' => ['finance'],
                'blocks' => [
                    ['p', "La Bourse régionale des valeurs mobilières (BRVM) est installée à Abidjan. Elle réunit les marchés financiers des huit États membres de l'UEMOA et constitue l'une des principales places boursières du continent."],
                    ['h2', 'Une bourse commune'],
                    ['p', "Créée à la fin des années 1990, la BRVM permet aux entreprises et aux États de lever des capitaux auprès d'investisseurs de la zone. Les banques et les sociétés de télécommunications y occupent une place importante."],
                    ['h2', "Un indicateur de l'économie régionale"],
                    ['p', "L'indice BRVM 30 et la capitalisation boursière servent de baromètre pour la sous-région. La place reste toutefois limitée par le faible nombre de sociétés cotées et par la liquidité des échanges."],
                ],
            ],
            [
                'slug' => 'l-hevea',
                'title' => "L'hévéa",
                'summary' => "La Côte d'Ivoire est le premier producteur africain de caoutchouc naturel, grâce aux plantations d'hévéa du sud forestier.",
                'type' => ArticleType::TOPIC,
                'category' => 'economie',
                'tags' => ['agriculture', 'industrie'],
                'blocks' => [
                    ['p', "L'hévéa, arbre à latex originaire d'Amazonie, a été introduit en Côte d'Ivoire au début du XXe siècle. Les grandes plantations se sont développées dans le sud forestier à partir des années 1950."],
                    ['h2', 'Premier producteur africain'],
                    ['p', "Le pays est aujourd'hui le premier producteur africain de caoutchouc naturel et figure parmi les premiers exportateurs mondiaux. La filière fait vivre des centaines de milliers de petits planteurs et alimente des usines de transformation."],
                    ['h2', 'Déforestation et durabilité'],
                    ['p', "L'extension des plantations est l'une des causes de la déforestation ivoirienne. Des programmes de replantation et de traçabilité tentent de concilier la rentabilité de la filière avec la protection des forêts restantes."],
                ],
            ],
        ];
    }
}
