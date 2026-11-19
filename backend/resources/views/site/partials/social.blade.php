<meta property="og:site_name" content="IVOIREPEDIA">
<meta property="og:locale" content="fr_CI">
<meta property="og:type" content="article">
<meta property="og:title" content="{{ $title }}">
<meta property="og:description" content="{{ $description }}">
<meta property="og:url" content="{{ $canonical }}">
@if ($coverUrl)
    <meta property="og:image" content="{{ $coverUrl }}">
    @if ($article?->cover_image_alt)
        <meta property="og:image:alt" content="{{ $article->cover_image_alt }}">
    @endif
@endif
@if ($publishedAt)
    <meta property="article:published_time" content="{{ $publishedAt->toIso8601String() }}">
@endif
@if ($modifiedAt)
    <meta property="article:modified_time" content="{{ $modifiedAt->toIso8601String() }}">
@endif
@if ($section)
    <meta property="article:section" content="{{ $section }}">
@endif
@foreach ($tags as $tag)
    <meta property="article:tag" content="{{ $tag }}">
@endforeach
<meta name="twitter:card" content="{{ $coverUrl ? 'summary_large_image' : 'summary' }}">
<meta name="twitter:title" content="{{ $title }}">
<meta name="twitter:description" content="{{ $description }}">
@if ($coverUrl)
    <meta name="twitter:image" content="{{ $coverUrl }}">
@endif
