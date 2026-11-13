<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

/**
 * Cumul de pluie d'une année pour une ville — la variabilité interannuelle,
 * qui explique pourquoi une « moyenne » ne décrit jamais une saison.
 *
 * @property int $year
 * @property string $rain_mm
 */
#[Fillable(['climate_city_id', 'year', 'rain_mm'])]
class ClimateYear extends Model
{
    use HasUuids;

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'year' => 'integer',
            'rain_mm' => 'decimal:1',
        ];
    }
}
