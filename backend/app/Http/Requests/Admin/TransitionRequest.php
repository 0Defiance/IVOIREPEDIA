<?php

namespace App\Http\Requests\Admin;

use App\Services\Workflow;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

/** Action de workflow demandée depuis le panneau. */
class TransitionRequest extends FormRequest
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
            'action' => ['required', 'string', Rule::in(array_keys(Workflow::RULES))],
            'comment' => ['nullable', 'string', 'max:1000'],
        ];
    }

    /**
     * @return array<string, string>
     */
    public function messages(): array
    {
        return [
            'action.required' => 'Aucune action demandée.',
            'action.in' => 'Cette action n’existe pas.',
            'comment.max' => 'Le commentaire ne peut pas dépasser 1 000 caractères.',
        ];
    }
}
