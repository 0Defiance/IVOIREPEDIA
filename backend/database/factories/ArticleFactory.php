<?php

namespace Database\Factories;

use App\Enums\ArticleStatus;
use App\Enums\ArticleType;
use App\Models\Article;
use App\Models\Category;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

/**
 * @extends Factory<Article>
 */
class ArticleFactory extends Factory
{
    protected $model = Article::class;

    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $title = fake()->unique()->sentence(4);

        return [
            'title' => $title,
            'slug' => Str::slug($title).'-'.Str::lower(Str::random(5)),
            'summary' => fake()->sentence(14),
            'content' => ['ops' => [['insert' => fake()->paragraph()."\n"]]],
            'type' => ArticleType::TOPIC,
            'status' => ArticleStatus::DRAFT,
            'category_id' => Category::factory(),
            'author_id' => User::factory()->contributor(),
            'lock_version' => 0,
            'current_version' => 0,
        ];
    }

    public function submitted(): static
    {
        return $this->state(fn () => ['status' => ArticleStatus::SUBMITTED]);
    }

    public function inReview(): static
    {
        return $this->state(fn () => ['status' => ArticleStatus::IN_REVIEW]);
    }

    public function approved(): static
    {
        return $this->state(fn () => ['status' => ArticleStatus::APPROVED]);
    }

    public function published(): static
    {
        return $this->state(fn () => [
            'status' => ArticleStatus::PUBLISHED,
            'published_at' => now()->subDay(),
        ]);
    }

    public function archived(): static
    {
        return $this->state(fn () => [
            'status' => ArticleStatus::ARCHIVED,
            'published_at' => now()->subMonth(),
        ]);
    }

    /** Article de cet auteur précis. */
    public function by(User $author): static
    {
        return $this->state(fn () => ['author_id' => $author->getKey()]);
    }
}
