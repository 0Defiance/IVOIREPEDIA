<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

/**
 * Ville dont on publie la climatologie (normales ERA5 1991-2020).
 *
 * @property string $id
 * @property string $slug
 * @property string $name
 * @property string $annual_rain_mm
 * @property int $period_start
 * @property int $period_end
 * @property int $position
 */
#[Fillable([
    'slug', 'name', 'latitude', 'longitude', 'annual_rain_mm', 'period_start',
    'period_end', 'source_name', 'source_url', 'source_licence', 'position',
])]
class ClimateCity extends Model
{
    use HasUuids;

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'latitude' => 'decimal:4',
            'longitude' => 'decimal:4',
            'annual_rain_mm' => 'decimal:1',
            'period_start' => 'integer',
            'period_end' => 'integer',
            'position' => 'integer',
        ];
    }

    /** @return HasMany<ClimateMonth, $this> */
    public function months(): HasMany
    {
        return $this->hasMany(ClimateMonth::class)->orderBy('month');
    }

    /** @return HasMany<ClimateYear, $this> */
    public function years(): HasMany
    {
        return $this->hasMany(ClimateYear::class)->orderBy('year');
    }
}
