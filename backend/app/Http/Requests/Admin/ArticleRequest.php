<?php

namespace App\Http\Requests\Admin;

use App\Enums\ArticleType;
use App\Support\ReferenceUrl;
use Closure;
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
            'cover_image_license' => ['nullable', 'string', 'max:60'],
            'cover_image_source_url' => ['nullable', 'url', 'max:500'],
            'references' => ['nullable', 'array', 'max:20'],
            'references.*.title' => ['nullable', 'string', 'max:255'],
            'references.*.authors' => ['nullable', 'string', 'max:255'],
            'references.*.publisher' => ['nullable', 'string', 'max:255'],
            'references.*.year' => ['nullable', 'integer', 'min:1800', 'max:2100'],
            'references.*.url' => [
                'nullable',
                'url',
                'max:500',
                function (string $attribute, mixed $value, Closure $fail): void {
                    if (is_string($value) && ReferenceUrl::isHomePage($value)) {
                        $fail('L’adresse de la source doit pointer vers une page précise, pas vers l’accueil d’un site.');
                    }
                },
            ],
            'infobox' => ['nullable', 'array', 'max:20'],
            'infobox.*.label' => ['nullable', 'string', 'max:60'],
            'infobox.*.value' => ['nullable', 'string', 'max:255'],
            'tags' => ['nullable', 'array', 'max:12'],
            'tags.*' => ['string', 'exists:tags,id'],
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
            'cover_image_source_url.url' => 'L’adresse de la page source de l’image n’est pas valide.',
            'references.max' => 'Vingt sources suffisent pour un article.',
            'references.*.url.url' => 'L’adresse de la source n’est pas valide.',
            'references.*.year.integer' => 'L’année de la source doit être un nombre.',
            'infobox.*.label.max' => 'Un libellé d’infobox ne dépasse pas 60 caractères.',
            'infobox.*.value.max' => 'Une valeur d’infobox ne dépasse pas 255 caractères.',
            'tags.max' => 'Douze étiquettes suffisent pour un article.',
            'tags.*.exists' => 'Cette étiquette n’existe pas.',
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

    /**
     * Sources saisies, dans l'ordre du formulaire — les lignes vides tombent.
     *
     * @return list<array{title: string, authors: string|null, publisher: string|null, year: int|null, url: string|null}>
     */
    public function references(): array
    {
        $rows = $this->input('references');

        if (! is_array($rows)) {
            return [];
        }

        $references = [];

        foreach ($rows as $row) {
            if (! is_array($row)) {
                continue;
            }

            $title = trim((string) ($row['title'] ?? ''));

            if ($title === '') {
                continue;
            }

            $year = trim((string) ($row['year'] ?? ''));

            $references[] = [
                'title' => mb_substr($title, 0, 255),
                'authors' => $this->nullable($row['authors'] ?? null),
                'publisher' => $this->nullable($row['publisher'] ?? null),
                'year' => $year === '' ? null : (int) $year,
                'url' => $this->nullable($row['url'] ?? null),
            ];
        }

        return $references;
    }

    /**
     * Infobox sous la forme stockée : libellé => valeur.
     *
     * @return array<string, string>|null
     */
    public function infobox(): ?array
    {
        $rows = $this->input('infobox');

        if (! is_array($rows)) {
            return null;
        }

        $pairs = [];

        foreach ($rows as $row) {
            if (! is_array($row)) {
                continue;
            }

            $label = trim((string) ($row['label'] ?? ''));
            $value = trim((string) ($row['value'] ?? ''));

            // Une paire incomplète est ignorée : l'auteur peut laisser des
            // lignes vides sans que l'enregistrement échoue.
            if ($label === '' || $value === '') {
                continue;
            }

            $pairs[mb_substr($label, 0, 60)] = mb_substr($value, 0, 255);
        }

        return $pairs === [] ? null : $pairs;
    }

    /**
     * Identifiants des étiquettes cochées.
     *
     * @return list<string>
     */
    public function tagIds(): array
    {
        /** @var array<int, string> $ids */
        $ids = array_values(array_filter((array) $this->input('tags', []), 'is_string'));

        return $ids;
    }

    private function nullable(mixed $value): ?string
    {
        $text = trim((string) $value);

        return $text === '' ? null : $text;
    }
}
