<?php

namespace Database\Seeders;

use App\Enums\ArticleStatus;
use App\Enums\ArticleType;
use App\Models\Article;
use App\Models\ArticleSlugRedirect;
use App\Models\Category;
use App\Models\Tag;
use App\Models\User;
use Illuminate\Database\Seeder;

/**
 * Biographies vérifiées (première tranche).
 *
 * Lit `database/data/personalities.php` et publie chaque fiche comme un
 * article `BIOGRAPHY` dans la catégorie Personnalités, avec son
 * étiquette de groupe (`biographies-politiciens`, etc.) et sa
 * bibliographie. Idempotent : relancer le seeder met les fiches à jour
 * sans les dupliquer (clé `slug`).
 *
 * Règle éditoriale (CONTEXT §1.2) : aucune fiche n'est publiée sans
 * date vérifiée sur la page Wikipédia referencée et sans référence
 * bibliographique. Pour passer de 10 à 100 par groupe, on étend le
 * fichier de données fiche après fiche, avec la même relecture.
 */
class PersonalitiesSeeder extends Seeder
{
    /** @var array<string, string> */
    private const GROUP_TAGS = [
        'politiciens' => 'Politiques',
        'ecrivains' => 'Écrivains',
        'sportifs' => 'Sportifs',
        'artistes' => 'Artistes',
    ];

    public function run(): void
    {
        $this->applyRenames();

        $author = $this->author();
        $category = Category::query()->where('slug', 'personnalites')->first();

        if ($category === null) {
            $this->command?->warn('Catégorie « personnalités » absente — exécutez CategorySeeder avant.');

            return;
        }

        /** @var array<string, array<int, array<string, mixed>>> $groups */
        $groups = require database_path('data/personalities.php');

        foreach ($groups as $group => $entries) {
            $tagSlug = 'biographies-'.$group;
            $tag = Tag::query()->updateOrCreate(
                ['slug' => $tagSlug],
                ['name' => 'Biographies : '.(self::GROUP_TAGS[$group] ?? $group)],
            );

            foreach ($entries as $index => $entry) {
                $article = Article::query()->updateOrCreate(
                    ['slug' => $entry['slug']],
                    [
                        'title' => $entry['name'],
                        'summary' => $entry['summary'],
                        'content' => $this->delta($entry['blocks']),
                        'infobox' => $this->infobox($entry),
                        'type' => ArticleType::BIOGRAPHY,
                        'status' => ArticleStatus::PUBLISHED,
                        'lock_version' => 1,
                        'current_version' => 1,
                        'author_id' => $author->id,
                        'category_id' => $category->id,
                        'published_at' => now()->subDays(($index + 1) * 2),
                    ],
                );

                $article->tags()->sync([$tag->id]);
                $article->references()->delete();

                foreach ($entry['bibliography'] as $position => $reference) {
                    $article->references()->create([
                        'kind' => 'OTHER',
                        'authors' => null,
                        'title' => $reference['title'],
                        'publisher' => $reference['publisher'],
                        'year' => $reference['year'],
                        'url' => $reference['url'],
                        'position' => $position + 1,
                    ]);
                }
            }
        }
    }

    /**
     * Applique les renommages déclarés dans `database/data/slug_redirects.php`.
     *
     * L'article publié sous l'ancien slug est renommé — le contenu éditorial
     * n'est pas perdu — et la paire est conservée pour la redirection 301 :
     * l'ancienne adresse reste donc joignable indéfiniment.
     */
    private function applyRenames(): void
    {
        /** @var array<string, string> $renames */
        $renames = require database_path('data/slug_redirects.php');

        foreach ($renames as $oldSlug => $newSlug) {
            $legacy = Article::query()->where('slug', $oldSlug)->first();
            $current = Article::query()->where('slug', $newSlug)->first();

            if ($legacy !== null) {
                if ($current === null) {
                    $legacy->update(['slug' => $newSlug]);
                } else {
                    $legacy->delete();
                }
            }

            ArticleSlugRedirect::query()->updateOrCreate(
                ['old_slug' => $oldSlug],
                ['new_slug' => $newSlug],
            );
        }
    }

    private function author(): User
    {
        $author = User::query()
            ->whereIn('role', ['ADMIN', 'EDITOR'])
            ->orderBy('created_at')
            ->first();

        if ($author !== null) {
            return $author;
        }

        return User::query()->create([
            'name' => 'La rédaction',
            'email' => 'redaction@ivoirepedia.ci',
            'password_hash' => 'hash',
            'role' => 'EDITOR',
            'email_verified_at' => now(),
        ]);
    }

    /**
     * @param  array<string, mixed>  $entry
     * @return array<string, mixed>
     */
    private function infobox(array $entry): array
    {
        return array_filter([
            'fullName' => $entry['fullName'],
            'birthDate' => $entry['birth'],
            'birthPlace' => $entry['birthPlace'],
            'deathDate' => $entry['death'],
            'deathPlace' => $entry['deathPlace'],
            'nationalities' => ['Ivoirienne'],
            'occupations' => $entry['occupations'],
        ], fn (mixed $value) => $value !== null && $value !== []);
    }

    /**
     * Convertit des blocs simples en Delta Quill (ADR-003).
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
}
