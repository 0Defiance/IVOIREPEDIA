<?php

namespace App\Http\Requests\Admin;

use App\Models\Tag;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

/** Création et modification d'une étiquette depuis le panneau. */
class TagRequest extends FormRequest
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
        $tag = $this->route('tag');
        $ignore = $tag instanceof Tag ? $tag->getKey() : null;

        return [
            'name' => [
                'required', 'string', 'min:2', 'max:100',
                Rule::unique('tags', 'name')->ignore($ignore),
            ],
        ];
    }

    /**
     * @return array<string, string>
     */
    public function messages(): array
    {
        return [
            'name.required' => 'Donnez un nom à l’étiquette.',
            'name.min' => 'Le nom doit contenir au moins 2 caractères.',
            'name.unique' => 'Une étiquette porte déjà ce nom.',
        ];
    }
}
