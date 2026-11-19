@php($site = rtrim((string) ($siteUrl ?? config('ivoirepedia.site_url')), '/'))
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>@yield('title', 'IVOIREPEDIA — l’encyclopédie libre de la Côte d’Ivoire')</title>
    <meta name="description" content="@yield('description', 'IVOIREPEDIA, l’encyclopédie libre de la Côte d’Ivoire : histoire, géographie, culture et institutions, avec des sources.')">
    <meta name="robots" content="@yield('robots', 'index, follow')">
    <link rel="canonical" href="@yield('canonical', $site.'/')">
    @yield('social')
    <style>
        :root {
            --canvas: #F7F4ED;
            --paper: #FFFFFF;
            --ink: #16211B;
            --body: #2C3830;
            --muted: #5B6459;
            --faint: #828A7E;
            --line: #D9D3C5;
            --line-soft: #EAE5D9;
            --green: #0E7B45;
            --green-deep: #0A5C34;
            --orange: #C35F00;
            --highlight: #FFF3E0;
            --serif: "Iowan Old Style", "Palatino Linotype", Palatino, Georgia, serif;
            --sans: Inter, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
        }

        * { box-sizing: border-box; }

        body {
            margin: 0;
            background: var(--canvas);
            color: var(--body);
            font-family: var(--sans);
            font-size: 15.5px;
            line-height: 1.75;
            -webkit-font-smoothing: antialiased;
        }

        a { color: var(--green); text-decoration: none; }
        a:hover { text-decoration: underline; }

        .skip {
            position: absolute; left: -999px; top: 0;
            background: var(--green); color: #FFF; padding: 8px 12px; z-index: 10;
        }
        .skip:focus { left: 8px; top: 8px; }

        .wrap { width: min(1080px, 100% - 40px); margin: 0 auto; }

        .masthead {
            background: var(--paper);
            border-bottom: 1px solid var(--line-soft);
        }
        .masthead-inner {
            display: flex; align-items: center; justify-content: space-between;
            gap: 24px; padding: 14px 0; flex-wrap: wrap;
        }
        .brand { display: inline-flex; flex-direction: column; color: var(--ink); }
        .brand:hover { text-decoration: none; }
        .brand strong {
            font-family: var(--serif); font-size: 21px; letter-spacing: .05em;
            font-weight: 600; line-height: 1.1;
        }
        .brand span {
            font-size: 10.5px; text-transform: uppercase; letter-spacing: .16em;
            color: var(--faint); margin-top: 3px;
        }
        .nav { display: flex; gap: 20px; flex-wrap: wrap; font-size: 13.5px; }
        .nav a { color: var(--muted); }
        .nav a:hover { color: var(--green-deep); }

        main { display: block; padding: 34px 0 64px; }

        .article { max-width: 760px; margin: 0 auto; }

        .kicker {
            margin: 0 0 6px; font-size: 11px; letter-spacing: 1.2px;
            text-transform: uppercase; font-weight: 700; color: var(--orange);
        }

        h1 {
            font-family: var(--serif); font-size: clamp(30px, 5vw, 42px);
            line-height: 1.15; font-weight: 600; color: var(--ink); margin: 0 0 14px;
        }

        .summary { font-size: 18px; line-height: 1.7; color: var(--muted); margin: 0 0 16px; }

        .meta {
            padding: 10px 0; margin: 0 0 26px;
            border-top: 1px solid var(--line); border-bottom: 1px solid var(--line-soft);
            font-size: 13px; color: var(--faint);
        }

        figure { margin: 0 0 28px; }
        figure img {
            width: 100%; height: auto; max-height: 430px; object-fit: cover;
            border-radius: 4px; background: var(--line-soft); display: block;
        }
        figcaption { font-size: 12px; color: var(--faint); padding-top: 7px; line-height: 1.5; }

        .toc {
            background: var(--paper); border: 1px solid var(--line-soft);
            border-radius: 4px; padding: 14px 18px; margin: 0 0 28px; font-size: 13.5px;
        }
        .toc p { margin: 0 0 6px; font-weight: 700; color: var(--ink); font-size: 12.5px; }
        .toc ol { margin: 0; padding-left: 20px; }
        .toc li { margin: 3px 0; }

        .prose p { margin: 0 0 16px; }
        .prose p.lead { font-size: 17px; color: var(--ink); }
        .prose p.bold { font-weight: 600; color: var(--ink); }
        .prose h2 {
            font-family: var(--serif); font-size: 24px; line-height: 1.3;
            font-weight: 600; color: var(--ink);
            margin: 34px 0 10px; padding-bottom: 8px; border-bottom: 1px solid var(--line-soft);
        }
        .prose h3 {
            font-family: var(--serif); font-size: 19px; line-height: 1.35;
            font-weight: 600; color: var(--ink); margin: 26px 0 8px;
        }
        .prose ul, .prose ol { margin: 0 0 18px; padding-left: 24px; }
        .prose li { margin: 5px 0; }
        .prose blockquote {
            margin: 8px 0 22px; padding: 2px 0 2px 16px;
            border-left: 2px solid var(--line); color: var(--muted); font-style: italic;
        }
        .prose blockquote p { margin: 0; }
        .note { font-size: 11px; }
        .note a { font-weight: 600; }

        .references {
            margin-top: 40px; padding-top: 18px; border-top: 1px solid var(--line);
        }
        .references h2 { font-family: var(--serif); font-size: 21px; color: var(--ink); margin: 0 0 12px; }
        .references ol { list-style: none; margin: 0; padding: 0; font-size: 13.5px; }
        .references li { margin: 0 0 9px; padding-left: 34px; position: relative; line-height: 1.55; }
        .ref-number { position: absolute; left: 0; color: var(--faint); }
        .references a { word-break: break-word; }

        .tags {
            margin: 34px 0 0; padding-top: 14px; border-top: 1px solid var(--line-soft);
            font-size: 12.5px; color: var(--muted);
        }
        .tags span {
            display: inline-block; margin: 3px 6px 3px 0; padding: 2px 9px;
            background: var(--highlight); border: 1px solid var(--line-soft);
            border-radius: 12px; color: var(--green-deep); font-size: 12px;
        }

        .license {
            margin: 24px 0 0; padding: 14px 16px; background: var(--paper);
            border: 1px solid var(--line-soft); border-radius: 4px;
            font-size: 12.5px; color: var(--muted);
        }

        .footer {
            border-top: 1px solid var(--line-soft); background: var(--paper);
            padding: 22px 0; font-size: 12.5px; color: var(--faint);
        }
        .footer-inner { display: flex; justify-content: space-between; gap: 18px; flex-wrap: wrap; }
        .footer p { margin: 0; }
        .footer nav { display: flex; gap: 16px; flex-wrap: wrap; }

        .missing { max-width: 640px; margin: 40px auto; text-align: center; }
        .missing h1 { font-size: 32px; }
        .missing p { color: var(--muted); }
        .button {
            display: inline-block; margin-top: 10px; padding: 10px 18px;
            border: 1px solid var(--line); border-radius: 20px; background: var(--paper);
            color: var(--green-deep); font-size: 13.5px; font-weight: 600;
        }
        .button:hover { text-decoration: none; border-color: var(--green); }

        @media (max-width: 640px) {
            .wrap { width: min(1080px, 100% - 28px); }
            main { padding-top: 24px; }
            .nav { gap: 14px; font-size: 13px; }
        }
    </style>
</head>
<body>
<a class="skip" href="#contenu">Aller au contenu</a>

<header class="masthead">
    <div class="wrap masthead-inner">
        <a class="brand" href="{{ $site }}/">
            <strong>IVOIREPEDIA</strong>
            <span>L’encyclopédie libre de la Côte d’Ivoire</span>
        </a>
        <nav class="nav" aria-label="Navigation principale">
            <a href="{{ $site }}/">Accueil</a>
            <a href="{{ $site }}/lieux">Lieux</a>
            <a href="{{ $site }}/sources">Sources</a>
            <a href="{{ $site }}/a-propos">À propos</a>
        </nav>
    </div>
</header>

<main id="contenu" class="wrap">
    @yield('content')
</main>

<footer class="footer">
    <div class="wrap footer-inner">
        <p>
            IVOIREPEDIA — encyclopédie libre de la Côte d’Ivoire.
            Textes sous licence
            <a href="https://creativecommons.org/licenses/by-sa/4.0/deed.fr" rel="license noopener">CC BY-SA 4.0</a>.
        </p>
        <nav aria-label="Pages de confiance">
            <a href="{{ $site }}/charte">Charte</a>
            <a href="{{ $site }}/contact">Contact</a>
            <a href="{{ $site }}/confidentialite">Confidentialité</a>
        </nav>
    </div>
</footer>
</body>
</html>
