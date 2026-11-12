<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

/**
 * Indicateur statistique du pays — une valeur datée, sa source, sa série.
 *
 * La valeur est stockée brute ; la mise en forme française (espace comme
 * séparateur de milliers, virgule décimale) est faite à l'affichage, côté API
 * et côté application, à partir de `decimals`.
 *
 * @property string $id
 * @property string $code
 * @property string $label
 * @property string $theme
 * @property string|null $unit
 * @property int $decimals
 * @property string|null $value
 * @property string|null $value_text
 * @property int|null $year
 * @property string $source_name
 * @property string|null $source_url
 * @property string|null $source_licence
 * @property string|null $note
 * @property int $position
 * @property-read Collection<int, CountryIndicatorPoint> $points
 */
#[Fillable([
    'code', 'label', 'theme', 'unit', 'decimals', 'value', 'value_text', 'year',
    'source_name', 'source_url', 'source_licence', 'note', 'position',
])]
class CountryIndicator extends Model
{
    use HasUuids;

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'decimals' => 'integer',
            'value' => 'decimal:4',
            'year' => 'integer',
            'position' => 'integer',
        ];
    }

    /** @return HasMany<CountryIndicatorPoint, $this> */
    public function points(): HasMany
    {
        return $this->hasMany(CountryIndicatorPoint::class, 'indicator_id')->orderBy('year');
    }

    /** @param  Builder<CountryIndicator>  $query */
    public function scopeInTheme(Builder $query, string $theme): void
    {
        $query->where('theme', $theme);
    }

    /** Valeur mise en forme à la française, unité comprise. */
    public function displayValue(): ?string
    {
        if ($this->value_text !== null) {
            return $this->value_text;
        }

        if ($this->value === null) {
            return null;
        }

        $number = number_format(
            (float) $this->value,
            $this->decimals,
            ',',
            ' ',
        );

        return $this->unit === null ? $number : $number.' '.$this->unit;
    }
}
