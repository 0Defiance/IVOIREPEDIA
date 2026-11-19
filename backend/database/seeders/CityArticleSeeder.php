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
 * public (`/lieux/{slug}`) qui n'avait pas encore d'article.
 *
 * Le seeder ne crée que les fiches absentes : un article qui existe déjà, quel
 * que soit son auteur, n'est jamais réécrit — la série complète le répertoire,
 * elle ne remplace pas le travail éditorial. Relancé, il ne fait donc rien.
 * Chaque fiche reçoit la catégorie « Géographie », l'étiquette « Ville » et la
 * référence officielle du RGPH 2021, celle d'où viennent les effectifs cités.
 *
 * Règle éditoriale : rien d'inventé. Les chiffres sont ceux du recensement, les
 * autres affirmations restent générales et prudentes ; une fiche ne raconte pas
 * ce qu'elle ne sait pas.
 */
class CityArticleSeeder extends Seeder
{
    /**
     * Document officiel des résultats du RGPH 2021, source des effectifs
     * communaux cités par chaque fiche.
     */
    private const CENSUS_REFERENCE = [
        'kind' => 'REPORT',
        'authors' => 'ANStat (ex-INS)',
        'title' => 'Recensement général de la population et de l’habitat (RGPH) 2021 — résultats globaux définitifs',
        'publisher' => 'Ministère de l’Économie, du Plan et du Développement',
        'year' => 2022,
        'url' => 'https://plan.gouv.ci/uploads/publications/RGPH2021-RESULTATS-GLOBAUX-VF.pdf',
    ];

    public function run(): void
    {
        /** @var array<string, array<string, mixed>> $cities */
        $cities = require database_path('data/cities.php');

        $author = $this->author();
        $category = Category::query()->firstOrCreate(
            ['slug' => 'geographie'],
            ['name' => 'Géographie', 'position' => 1],
        );
        $tag = Tag::query()->updateOrCreate(['slug' => 'ville'], ['name' => 'Ville']);

        $created = 0;
        $existing = 0;

        foreach (array_values($cities) as $index => $city) {
            $slug = Str::slug((string) $city['name']);

            if (Article::withTrashed()->where('slug', $slug)->exists()) {
                $existing++;

                continue;
            }

            $article = Article::query()->create(
                [
                    'slug' => $slug,
                    'title' => $city['name'],
                    'summary' => $city['summary'],
                    'content' => $this->delta($city['blocks']),
                    'infobox' => [
                        'level' => 'CITY',
                        'population' => $city['population'],
                        'populationYear' => 2021,
                    ],
                    'type' => ArticleType::REGION,
                    'status' => ArticleStatus::PUBLISHED,
                    'lock_version' => 1,
                    'current_version' => 1,
                    'author_id' => $author->id,
                    'category_id' => $category->id,
                    'published_at' => now()->subDays($index * 2 + 1),
                ],
            );

            $created++;

            $article->tags()->sync([$tag->id]);
            $article->references()->delete();
            $article->references()->create([
                ...self::CENSUS_REFERENCE,
                'position' => 1,
                'accessed_at' => now()->toDateString(),
            ]);
        }

        $this->command?->info(sprintf(
            '%d fiche(s) créée(s), %d déjà présente(s) laissée(s) intacte(s).',
            $created,
            $existing,
        ));
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
