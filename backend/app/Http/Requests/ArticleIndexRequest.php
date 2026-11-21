<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

/**
 * Paramètres de la liste publique d'articles — CONTEXT §11.1/§11.3.
 * `limit` est plafonné à 20 (ENF-PERF-05) : la validation serveur reste la
 * référence, l'interface ne fait qu'anticiper.
 */
class ArticleIndexRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true; // lecture publique
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'category' => ['nullable', 'string', 'max:120'],
            'tag' => ['nullable', 'string', 'max:120'],
            'q' => ['nullable', 'string', 'max:100'],
            // Slugs précis : l'accueil ne récupère ainsi que les articles
            // candidats à la couverture, au lieu de tout le corpus.
            'slugs' => [
                'nullable',
                'string',
                'max:400',
                'regex:/^[a-z0-9]+(?:-[a-z0-9]+)*(?:,[a-z0-9]+(?:-[a-z0-9]+)*)*$/',
            ],
            'page' => ['nullable', 'integer', 'min:1'],
            'limit' => ['nullable', 'integer', 'min:1', 'max:20'],
        ];
    }

    /**
     * Articles demandés nommément, dans l'ordre de la requête.
     *
     * @return list<string>
     */
    public function slugs(): array
    {
        $value = (string) $this->validated('slugs', '');

        if ($value === '') {
            return [];
        }

        return array_slice(explode(',', $value), 0, 20);
    }

    public function limit(): int
    {
        return (int) $this->validated('limit', 12);
    }

    public function page(): int
    {
        return (int) $this->validated('page', 1);
    }
}
