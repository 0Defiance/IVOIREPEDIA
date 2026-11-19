<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

/**
 * Formulaire de contact public.
 *
 * Le champ `website` est un piège à robots : il reste invisible pour un
 * humain, et un message qui le remplit est refusé. Le plafond de longueur
 * évite qu'on se serve du formulaire comme d'un espace de stockage.
 */
class ContactRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * @return array<string, array<int, string>>
     */
    public function rules(): array
    {
        return [
            'name' => ['nullable', 'string', 'max:80'],
            'email' => ['nullable', 'email', 'max:255'],
            'message' => ['required', 'string', 'min:20', 'max:4000'],
            'website' => ['nullable', 'string', 'max:0'],
        ];
    }

    /**
     * @return array<string, string>
     */
    public function messages(): array
    {
        return [
            'name.max' => 'Votre nom ne peut pas dépasser 80 caractères.',
            'email.email' => 'Cette adresse électronique n’est pas valide.',
            'message.required' => 'Écrivez votre message.',
            'message.min' => 'Décrivez votre demande en quelques mots (20 caractères au moins).',
            'message.max' => 'Le message ne peut pas dépasser 4 000 caractères.',
            'website.max' => 'Ce champ doit rester vide.',
        ];
    }

    /**
     * @return array<string, string>
     */
    public function attributes(): array
    {
        return [
            'name' => 'nom',
            'email' => 'adresse électronique',
            'message' => 'message',
        ];
    }
}
