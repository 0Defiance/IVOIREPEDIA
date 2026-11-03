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
            'page' => ['nullable', 'integer', 'min:1'],
            'limit' => ['nullable', 'integer', 'min:1', 'max:20'],
        ];
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
