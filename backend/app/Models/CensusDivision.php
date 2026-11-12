<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

/**
 * Division administrative issue du RGPH 2021 (district, région ou ville).
 *
 * Les effectifs sont ceux publiés par l'ANStat : ils ne sont pas recalculés.
 *
 * @property string $id
 * @property string $level
 * @property string $name
 * @property string $slug
 * @property string|null $parent
 * @property int $population
 * @property int|null $men
 * @property int|null $women
 * @property int|null $households
 * @property string|null $average_size
 * @property int $position
 */
#[Fillable([
    'level', 'name', 'slug', 'parent', 'population', 'men', 'women',
    'households', 'average_size', 'position',
])]
class CensusDivision extends Model
{
    use HasUuids;

    public const DISTRICT = 'district';

    public const REGION = 'region';

    public const CITY = 'city';

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'population' => 'integer',
            'men' => 'integer',
            'women' => 'integer',
            'households' => 'integer',
            'average_size' => 'decimal:1',
            'position' => 'integer',
        ];
    }

    /** @param  Builder<CensusDivision>  $query */
    public function scopeOfLevel(Builder $query, string $level): void
    {
        $query->where('level', $level);
    }
}
