<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * Point annuel d'une série d'indicateur — une valeur par année.
 *
 * @property string $id
 * @property string $indicator_id
 * @property int $year
 * @property string $value
 */
#[Fillable(['indicator_id', 'year', 'value'])]
class CountryIndicatorPoint extends Model
{
    use HasUuids;

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'year' => 'integer',
            'value' => 'decimal:4',
        ];
    }

    /** @return BelongsTo<CountryIndicator, $this> */
    public function indicator(): BelongsTo
    {
        return $this->belongsTo(CountryIndicator::class, 'indicator_id');
    }
}
