IVOIREPEDIA — surveillance des sauvegardes

@if ($age === null)
Aucun dump de {{ $database }} n'existe dans {{ $directory }}.
@else
Dernier dump de {{ $database }} : il a {{ intdiv($age, 3600) }} h ({{ gmdate('Y-m-d H:i', (int) $lastAt) }} UTC).
@endif
Délai d'alerte : {{ intdiv($after, 3600) }} h.

À vérifier sur le serveur, dans ~/ivoirepedia/backend :
  1. ls -lt {{ $directory }} | head
  2. php artisan backup:run --keep=7      (lance un dump à la main)
  3. php artisan backup:offsite           (copie hors-site)
  4. tail -30 storage/logs/laravel.log

Procédure complète : docs/DEPLOIEMENT.md §8.
