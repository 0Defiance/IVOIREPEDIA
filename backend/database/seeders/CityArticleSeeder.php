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
 * Série « Villes de Côte d'Ivoire » : une fiche par ville du répertoire
 * public (`/lieux/{slug}`).
 *
 * Le rafraîchissement ne détruit rien de ce qui a été fait à la main :
 *  - un article publié qui n'appartient pas à la série n'est jamais réécrit ;
 *  - une fiche de la série n'est réécrite champ par champ que si la base
 *    contient encore ce que le seeder y a mis (`series_state` garde
 *    l'empreinte de chaque champ machine) : une modification faite depuis
 *    `/admin` survit au passage suivant ;
 *  - au premier passage sur une fiche sans empreinte, rien n'est remplacé :
 *    si le contenu diffère de la série, il est conservé, l'empreinte est
 *    posée et la fiche est signalée pour relecture ;
 *  - les sources et les étiquettes ne sont jamais supprimées : la référence
 *    du recensement, celle de la monographie régionale (qui porte les
 *    projections) et l'étiquette « ville » sont ajoutées si elles manquent,
 *    sans toucher aux autres.
 *
 * La variable d'environnement `CITY_SEEDER_ADOPT=1` marque une fois les fiches
 * d'une série antérieure à la colonne `series` : elle ne sert qu'à la reprise,
 * puis le marquage suffit. Une variable d'environnement, pas une option :
 * `db:seed` n'accepte pas d'option propre à un seeder, et `getenv()` reste
 * lisible quand la configuration est mise en cache.
 *
 * Les illustrations de couverture ne sont pas gérées ici : elles viennent de
 * `articles:attach-images`, qui porte la licence et l'auteur de chaque photo.
 */
class CityArticleSeeder extends Seeder
{
    public const SERIES = 'villes';

    /** Document officiel des résultats du RGPH 2021, source des effectifs. */
    public const CENSUS_URL = 'https://plan.gouv.ci/uploads/publications/RGPH2021-RESULTATS-GLOBAUX-VF.pdf';

    private const CENSUS_REFERENCE = [
        'kind' => 'REPORT',
        'authors' => 'ANStat (ex-INS)',
        'title' => 'Recensement général de la population et de l’habitat (RGPH) 2021 — résultats globaux définitifs',
        'publisher' => 'Ministère de l’Économie, du Plan et du Développement',
        'year' => 2022,
        'url' => self::CENSUS_URL,
    ];

    /** Champs produits par la série et protégés par empreinte. */
    private const SYNCED_FIELDS = ['title', 'summary', 'content', 'infobox'];

    public function run(): void
    {
        /** @var array<string, array<string, mixed>> $cities */
        $cities = require database_path('data/cities.php');
        /** @var array<string, array<int, array{0: string, 1: string}>> $details */
        $details = require database_path('data/cities-details.php');
        /** @var array{regions: array<string, array{title: string, url: string}>, cities: array<string, string>} $monographs */
        $monographs = require database_path('data/cities-monographs.php');

        $author = $this->author();
        $category = Category::query()->firstOrCreate(
            ['slug' => 'geographie'],
            ['name' => 'Géographie', 'position' => 1],
        );
        $tag = Tag::query()->updateOrCreate(['slug' => 'ville'], ['name' => 'Ville']);

        $adopt = getenv('CITY_SEEDER_ADOPT') === '1';
        $created = 0;
        $updated = 0;
        $adopted = 0;
        $preserved = 0;
        $untouched = 0;
        /** @var array<int, string> $divergents */
        $divergents = [];

        foreach (array_values($cities) as $index => $city) {
            $slug = Str::slug((string) $city['name']);
            $blocks = array_merge($city['blocks'], $details[$slug] ?? []);
            $article = Article::withTrashed()->where('slug', $slug)->first();

            // Un article écrit par quelqu'un d'autre garde son texte.
            $claimed = false;

            if ($article !== null && $article->series !== self::SERIES) {
                if (! $adopt) {
                    $untouched++;

                    continue;
                }

                // Adoption demandée explicitement : la fiche rejoint la série
                // et reçoit son contenu, empreintes comprises.
                $claimed = true;
                $adopted++;
            }

            $attributes = [
                'title' => $city['name'],
                'summary' => $city['summary'],
                'content' => $this->delta($blocks),
                'infobox' => [
                    'level' => 'CITY',
                    'population' => $city['population'],
                    'populationYear' => 2021,
                ],
            ];

            if ($article === null) {
                $article = Article::query()->create([
                    ...$attributes,
                    'slug' => $slug,
                    'series' => self::SERIES,
                    'series_state' => $this->fingerprints($attributes),
                    'type' => ArticleType::REGION,
                    'status' => ArticleStatus::PUBLISHED,
                    'lock_version' => 1,
                    'current_version' => 1,
                    'author_id' => $author->id,
                    'category_id' => $category->id,
                    'published_at' => now()->subDays($index * 2 + 1),
                ]);
                $created++;
            } else {
                /** @var array<string, string> $state */
                $state = is_array($article->series_state) ? $article->series_state : [];
                /** @var array<int, string> $divergent */
                $divergent = [];
                $writable = $this->writableFields($article, $attributes, $state, $divergent, $claimed);

                if (count($writable) < count(self::SYNCED_FIELDS)) {
                    $preserved++;
                }

                if ($divergent !== []) {
                    $divergents[] = $slug;
                }

                // Eloquent n'écrit que les valeurs modifiées : une fiche déjà
                // à jour garde son `updated_at`.
                $article->fill([
                    ...$writable,
                    'series' => self::SERIES,
                    'series_state' => $state,
                ])->save();

                $updated++;
            }

            // Ajout sans retrait : les étiquettes éditoriales restent.
            $article->tags()->syncWithoutDetaching([$tag->id]);

            $this->attachCensusReference($article);
            $this->attachMonographReference(
                $article,
                $monographs['regions'][$monographs['cities'][$slug] ?? ''] ?? null,
            );
        }

        $this->command?->info(sprintf(
            '%d fiche(s) créée(s), %d mise(s) à jour (dont %d avec des champs édités préservés), %d adoptée(s), %d article(s) hors série laissé(s) intact(s).',
            $created,
            $updated,
            $preserved,
            $adopted,
            $untouched,
        ));

        if ($divergents !== []) {
            $this->command?->warn(sprintf(
                'Contenu différent de la série, conservé et désormais protégé : %s. Pour reprendre la version de la série, videz `series_state` de ces fiches.',
                implode(', ', $divergents),
            ));
        }
    }

    /**
     * Ajoute la source du recensement si elle manque, sans supprimer les
     * références ajoutées depuis le panneau.
     */
    private function attachCensusReference(Article $article): void
    {
        $exists = $article->references()->where('url', self::CENSUS_URL)->exists();

        if ($exists) {
            return;
        }

        $article->references()->create([
            ...self::CENSUS_REFERENCE,
            'position' => ((int) $article->references()->max('position')) + 1,
            'accessed_at' => now()->toDateString(),
        ]);
    }

    /**
     * Ajoute la monographie régionale qui porte les projections, si son PDF
     * est publié sur le site de l'ANStat ; les autres références restent.
     *
     * @param  array{title: string, url: string}|null  $monograph
     */
    private function attachMonographReference(Article $article, ?array $monograph): void
    {
        if ($monograph === null) {
            return;
        }

        if ($article->references()->where('url', $monograph['url'])->exists()) {
            return;
        }

        $article->references()->create([
            'kind' => 'REPORT',
            'authors' => 'ANStat (ex-INS)',
            'title' => $monograph['title'],
            'publisher' => 'ANStat',
            'year' => null,
            'url' => $monograph['url'],
            'position' => ((int) $article->references()->max('position')) + 1,
            'accessed_at' => now()->toDateString(),
        ]);
    }

    /**
     * Ne garde que les champs que le seeder peut encore écrire : ceux dont
     * l'empreinte enregistrée correspond toujours au contenu de la base.
     *
     * Une empreinte absente date d'avant le suivi (fiche créée par une version
     * antérieure du seeder). On ne sait pas si le contenu vient de la série ou
     * d'une main humaine : rien n'est remplacé, l'empreinte est posée, et les
     * champs divergents sont signalés à l'appelant.
     *
     * @param  array<string, mixed>  $attributes
     * @param  array<string, string>  $state
     * @param  array<int, string>  $divergent
     * @return array<string, mixed>
     */
    private function writableFields(Article $article, array $attributes, array &$state, array &$divergent, bool $force = false): array
    {
        $writable = [];

        foreach (self::SYNCED_FIELDS as $field) {
            $fingerprint = $this->fingerprint($attributes[$field]);
            $recorded = $state[$field] ?? null;
            $current = $this->fingerprint($article->getAttribute($field));

            if ($force) {
                $writable[$field] = $attributes[$field];
                $state[$field] = $fingerprint;

                continue;
            }

            if ($recorded !== null) {
                if ($recorded !== $current) {
                    continue;
                }

                $writable[$field] = $attributes[$field];
                $state[$field] = $fingerprint;

                continue;
            }

            $state[$field] = $fingerprint;

            if ($current === $fingerprint) {
                $writable[$field] = $attributes[$field];

                continue;
            }

            $divergent[] = $field;
        }

        return $writable;
    }

    /**
     * @param  array<string, mixed>  $attributes
     * @return array<string, string>
     */
    private function fingerprints(array $attributes): array
    {
        $prints = [];

        foreach (self::SYNCED_FIELDS as $field) {
            $prints[$field] = $this->fingerprint($attributes[$field] ?? null);
        }

        return $prints;
    }

    private function fingerprint(mixed $value): string
    {
        $json = json_encode($this->canonical($value), JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);

        return hash('sha256', (string) $json);
    }

    /**
     * Trie les clés avant d'empreindre : MySQL réordonne les objets JSON, et
     * l'empreinte d'une valeur relue doit rester celle de la valeur écrite.
     */
    private function canonical(mixed $value): mixed
    {
        if (! is_array($value)) {
            return $value;
        }

        if (! array_is_list($value)) {
            ksort($value);
        }

        return array_map(fn (mixed $item): mixed => $this->canonical($item), $value);
    }

    /**
     * Convertit les blocs simples en Delta Quill (ADR-003 : jamais de HTML).
     *
     * @param  array<int, array{0: string, 1: string}>  $blocks
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

    /** Le premier compte éditorial existant, sinon le compte de rédaction. */
    private function author(): User
    {
        $author = User::query()
            ->whereIn('role', ['ADMIN', 'EDITOR'])
            ->orderBy('created_at')
            ->first();

        return $author ?? User::query()->firstOrCreate(
            ['email' => 'redaction@ivoirepedia.ci'],
            [
                'name' => 'La rédaction',
                'password_hash' => Hash::make(Str::random(40)),
                'role' => 'EDITOR',
                'email_verified_at' => now(),
            ],
        );
    }
}
