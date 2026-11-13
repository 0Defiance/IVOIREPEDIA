<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

/**
 * Normale mensuelle d'une ville : cumul moyen de pluie, jours de pluie et
 * température moyenne sur la période de référence.
 *
 * @property int $month
 * @property string $rain_mm
 * @property string|null $rain_days
 * @property string|null $temperature_c
 */
#[Fillable(['climate_city_id', 'month', 'rain_mm', 'rain_days', 'temperature_c'])]
class ClimateMonth extends Model
{
    use HasUuids;

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'month' => 'integer',
            'rain_mm' => 'decimal:1',
            'rain_days' => 'decimal:1',
            'temperature_c' => 'decimal:1',
        ];
    }
}
