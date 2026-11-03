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
 * Ces dix articles donnent « de la vie » au site : ils couvrent les huit
 * catégories et les trois types à infobox (CONTEXT §8.3). Ce sont des textes
 * de démonstration, pas du contenu validé éditorialement : le Sprint 5 exige
 * au moins 30 articles de qualité avant l'ouverture publique (CONTEXT §14).
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
        ];
    }
}
