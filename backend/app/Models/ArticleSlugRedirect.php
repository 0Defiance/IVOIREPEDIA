<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

/**
 * Ancien slug d'article, redirigé en permanence vers son adresse actuelle.
 *
 * Voir la migration `create_article_slug_redirects_table` : la redirection
 * existe pour que les liens déjà partagés continuent de fonctionner après un
 * renommage.
 */
#[Fillable(['old_slug', 'new_slug'])]
class ArticleSlugRedirect extends Model
{
    use HasUuids;
}
