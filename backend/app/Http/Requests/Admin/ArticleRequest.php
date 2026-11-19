<?php

namespace App\Http\Requests\Admin;

use App\Enums\ArticleType;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

/**
 * Création et modification d'un article depuis le panneau.
 *
 * Le corps est saisi au panneau comme du texte simple : chaque paragraphe
 * devient une opération Delta (`insert`), le format stocké ne change pas.
 * Une ligne commençant par « ## » devient un titre de section.
 */
class ArticleRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user() !== null;
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'title' => ['required', 'string', 'min:3', 'max:255'],
            'summary' => ['required', 'string', 'min:10', 'max:500'],
            'body' => ['required', 'string', 'min:20', 'max:60000'],
            'type' => ['required', Rule::enum(ArticleType::class)],
            'category_id' => ['required', 'string', 'exists:categories,id'],
            'cover_image_url' => ['nullable', 'url', 'max:500'],
            'cover_image_alt' => ['nullable', 'string', 'max:255', 'required_with:cover_image_url'],
            'cover_image_credit' => ['nullable', 'string', 'max:255'],
            'reference_title' => ['nullable', 'string', 'max:255'],
            'reference_publisher' => ['nullable', 'string', 'max:255'],
            'reference_url' => ['nullable', 'url', 'max:500'],
        ];
    }

    /**
     * @return array<string, string>
     */
    public function messages(): array
    {
        return [
            'title.required' => 'Donnez un titre à l’article.',
            'title.min' => 'Le titre doit contenir au moins 3 caractères.',
            'summary.required' => 'Écrivez un résumé : il sert de chapô et de description.',
            'summary.min' => 'Le résumé doit contenir au moins 10 caractères.',
            'summary.max' => 'Le résumé ne peut pas dépasser 500 caractères.',
            'body.required' => 'Le corps de l’article est vide.',
            'body.min' => 'Le corps de l’article est trop court.',
            'category_id.required' => 'Choisissez une catégorie.',
            'category_id.exists' => 'Cette catégorie n’existe pas.',
            'cover_image_url.url' => 'L’adresse de l’image n’est pas valide.',
            'cover_image_alt.required_with' => 'Un texte alternatif est obligatoire avec une image.',
            'reference_title.required_with' => 'Indiquez le titre de la source.',
            'reference_url.url' => 'L’adresse de la source n’est pas valide.',
        ];
    }

    /**
     * Contenu Delta Quill construit à partir du texte saisi.
     *
     * @return array{ops: list<array<string, mixed>>}
     */
    public function content(): array
    {
        $ops = [];

        foreach (preg_split('/\R{2,}/u', (string) $this->input('body')) ?: [] as $block) {
            $block = trim($block);

            if ($block === '') {
                continue;
            }

            if (str_starts_with($block, '## ')) {
                $ops[] = [
                    'insert' => mb_substr(ltrim(substr($block, 3)), 0, 200)."\n",
                    'attributes' => ['header' => 2],
                ];

                continue;
            }

            $ops[] = ['insert' => str_replace("\n", ' ', $block)."\n"];
        }

        return ['ops' => $ops];
    }
}
