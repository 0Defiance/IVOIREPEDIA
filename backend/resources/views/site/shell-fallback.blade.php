<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>{{ $title }} — IVOIREPEDIA</title>
  <meta name="description" content="{{ $description }}">
  <link rel="canonical" href="{{ $canonical }}">
  @include('site.partials.social')
</head>
<body style="max-width: 720px; margin: 40px auto; padding: 0 20px; font-family: Inter, 'Segoe UI', system-ui, sans-serif; color: #16211B; line-height: 1.7;">
  <h1 style="font-size: 30px; line-height: 1.2;">{{ $title }}</h1>
  <p style="font-size: 17px; color: #5B6459;">{{ $description }}</p>
  <p><a href="{{ $canonical }}?html=1" style="color: #0E7B45;">Lire la version texte de cet article</a></p>
</body>
</html>
