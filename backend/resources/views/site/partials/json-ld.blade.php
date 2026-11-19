@php
    $authorName = $article?->author?->name;
    $organization = [
        '@type' => 'Organization',
        'name' => 'IVOIREPEDIA',
        'url' => $siteUrl,
    ];

    $structured = array_filter([
        '@context' => 'https://schema.org',
        '@type' => 'Article',
        'headline' => $title,
        'description' => $description,
        'url' => $canonical,
        'mainEntityOfPage' => ['@type' => 'WebPage', '@id' => $canonical],
        'inLanguage' => 'fr-CI',
        'isAccessibleForFree' => true,
        'license' => 'https://creativecommons.org/licenses/by-sa/4.0/deed.fr',
        'image' => $coverUrl,
        'datePublished' => $publishedAt?->toIso8601String(),
        'dateModified' => $modifiedAt?->toIso8601String(),
        'articleSection' => $section,
        'keywords' => $tags === [] ? null : implode(', ', $tags),
        'author' => $authorName === null
            ? $organization
            : ['@type' => 'Person', 'name' => $authorName],
        'publisher' => [...$organization, 'logo' => [
            '@type' => 'ImageObject',
            'url' => rtrim((string) $siteUrl, '/').'/logo.png',
        ]],
    ], static fn (mixed $value): bool => $value !== null && $value !== '' && $value !== []);
@endphp
@if ($article)
    <script type="application/ld+json">{!! json_encode($structured, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE | JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT) !!}</script>
@endif
