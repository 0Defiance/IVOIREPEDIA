<?php

namespace App\Http\Requests\Admin;

use App\Models\Category;
use Closure;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

/**
 * Création et modification d'une catégorie depuis le panneau.
 *
 * Le slug n'est pas saisi : il découle du nom, et le contrôleur refuse de le
 * changer dès qu'un article l'utilise (les adresses publiques ne bougent pas).
 */
class CategoryRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->role->canReview() === true;
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        $category = $this->route('category');
        $ignore = $category instanceof Category ? $category->getKey() : null;

        return [
            'name' => [
                'required', 'string', 'min:2', 'max:100',
                Rule::unique('categories', 'name')->ignore($ignore),
            ],
            'description' => ['nullable', 'string', 'max:1000'],
            'position' => ['nullable', 'integer', 'min:0', 'max:999'],
            'parent_id' => [
                'nullable', 'string', 'exists:categories,id',
                function (string $attribute, mixed $value, Closure $fail) use ($category): void {
                    if ($category instanceof Category && $value === $category->getKey()) {
                        $fail('Une catégorie ne peut pas être sa propre catégorie mère.');
                    }
                },
            ],
        ];
    }

    /**
     * @return array<string, string>
     */
    public function messages(): array
    {
        return [
            'name.required' => 'Donnez un nom à la catégorie.',
            'name.min' => 'Le nom doit contenir au moins 2 caractères.',
            'name.unique' => 'Une catégorie porte déjà ce nom.',
            'description.max' => 'La description ne peut pas dépasser 1 000 caractères.',
            'position.integer' => 'La position doit être un nombre entier.',
            'parent_id.exists' => 'Cette catégorie mère n’existe pas.',
        ];
    }

    /**
     * Attributs prêts à écrire.
     *
     * @return array{name: string, description: string|null, position: int, parent_id: string|null}
     */
    public function attributes(): array
    {
        $description = trim((string) $this->input('description'));
        $parent = trim((string) $this->input('parent_id'));

        return [
            'name' => trim((string) $this->input('name')),
            'description' => $description === '' ? null : $description,
            'position' => (int) $this->input('position', 0),
            'parent_id' => $parent === '' ? null : $parent,
        ];
    }
}
