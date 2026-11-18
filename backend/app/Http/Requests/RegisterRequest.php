<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

/**
 * Inscription d'un lecteur (Sprint 1 — EF-AUTH-01).
 *
 * Le rôle n'est jamais accepté depuis la requête : tout compte créé ici est
 * un READER. Les rôles éditoriaux s'attribuent en back-office.
 */
class RegisterRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'min:2', 'max:100'],
            'email' => ['required', 'string', 'email', 'max:255', 'unique:users,email'],
            'password' => ['required', 'string', 'min:8', 'max:255', 'confirmed'],
        ];
    }

    /**
     * @return array<string, string>
     */
    public function messages(): array
    {
        return [
            'name.required' => 'Indiquez votre nom.',
            'name.min' => 'Le nom doit contenir au moins 2 caractères.',
            'name.max' => 'Le nom ne peut pas dépasser 100 caractères.',
            'email.required' => 'Indiquez votre adresse électronique.',
            'email.email' => 'Cette adresse électronique n’est pas valide.',
            'email.unique' => 'Un compte existe déjà avec cette adresse.',
            'password.required' => 'Choisissez un mot de passe.',
            'password.min' => 'Le mot de passe doit contenir au moins 8 caractères.',
            'password.confirmed' => 'Les deux mots de passe ne correspondent pas.',
        ];
    }

    /** Normalise l'adresse : la comparaison d'unicité est insensible à la casse. */
    protected function prepareForValidation(): void
    {
        if (is_string($this->email)) {
            $this->merge(['email' => mb_strtolower(trim($this->email))]);
        }
    }
}
