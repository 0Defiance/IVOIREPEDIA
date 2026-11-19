<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="robots" content="noindex, nofollow">
    <title>@yield('title', 'Rédaction') — Ivoirepedia</title>
    <style>
        :root {
            --paper: #FBF9F4;
            --card: #FFFFFF;
            --ink: #16241C;
            --ink-soft: #3D4C43;
            --muted: #6B7A70;
            --line: #E4DFD3;
            --line-soft: #EFEBE2;
            --green: #0E7B45;
            --green-dark: #0A5C34;
            --green-wash: #EDF6F0;
            --orange: #E8720C;
            --orange-wash: #FDF1E3;
            --red: #B3261E;
            --red-wash: #FCEDEB;
            --blue: #1F5F9E;
            --blue-wash: #EDF3FA;
            --shadow: 0 1px 2px rgba(22, 36, 28, .05), 0 8px 24px rgba(22, 36, 28, .06);
            --radius: 14px;
            --sans: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            --serif: "Iowan Old Style", "Palatino Linotype", Palatino, Georgia, serif;
        }

        * { box-sizing: border-box; }

        body {
            margin: 0;
            background: var(--paper);
            color: var(--ink);
            font-family: var(--sans);
            font-size: 14.5px;
            line-height: 1.5;
            -webkit-font-smoothing: antialiased;
        }

        a { color: var(--green); text-decoration: none; }
        a:hover { text-decoration: underline; }

        .shell { display: grid; grid-template-columns: 244px 1fr; min-height: 100vh; }

        /* --- Colonne de navigation ------------------------------------- */
        .sidebar {
            background: #10231A;
            color: #E8EFE9;
            padding: 22px 16px 18px;
            display: flex;
            flex-direction: column;
            gap: 26px;
            position: sticky;
            top: 0;
            height: 100vh;
        }

        .brand { color: #FFF; text-decoration: none; display: block; padding: 0 6px; }
        .brand strong { font-family: var(--serif); font-size: 20px; letter-spacing: .04em; display: block; }
        .brand span { font-size: 11.5px; text-transform: uppercase; letter-spacing: .18em; color: #8FA99A; }

        .nav { display: flex; flex-direction: column; gap: 2px; }
        .nav-title {
            font-size: 10.5px; text-transform: uppercase; letter-spacing: .16em;
            color: #7C9487; margin: 0 0 8px 8px;
        }
        .nav a {
            display: flex; align-items: center; gap: 10px;
            padding: 9px 10px; border-radius: 9px;
            color: #D3DFD6; font-size: 14px; text-decoration: none;
        }
        .nav a:hover { background: rgba(255, 255, 255, .07); text-decoration: none; }
        .nav a.active { background: rgba(255, 255, 255, .12); color: #FFF; font-weight: 600; }
        .nav a .dot { width: 7px; height: 7px; border-radius: 50%; background: var(--orange); opacity: .85; }
        .nav a .dot.green { background: #4ECB8B; }

        .sidebar-foot { margin-top: auto; display: flex; flex-direction: column; gap: 12px; font-size: 12.5px; color: #93A99B; }
        .sidebar-foot .who { color: #E8EFE9; font-weight: 600; font-size: 13.5px; }
        .sidebar-foot form { margin: 0; }
        .sidebar-foot button {
            background: none; border: 1px solid rgba(255, 255, 255, .2);
            color: #D3DFD6; padding: 7px 10px; border-radius: 8px;
            font: inherit; font-size: 12.5px; cursor: pointer; width: 100%;
        }
        .sidebar-foot button:hover { background: rgba(255, 255, 255, .08); }

        /* --- Contenu --------------------------------------------------- */
        .main { padding: 26px 34px 60px; max-width: 1200px; width: 100%; }

        .topbar { display: flex; align-items: flex-end; justify-content: space-between; gap: 20px; margin-bottom: 22px; flex-wrap: wrap; }
        .eyebrow { margin: 0 0 4px; font-size: 11px; text-transform: uppercase; letter-spacing: .16em; color: var(--muted); }
        h1 { font-family: var(--serif); font-size: 30px; line-height: 1.15; margin: 0; font-weight: 600; }
        h2 { font-family: var(--serif); font-size: 19px; margin: 0 0 14px; font-weight: 600; }
        .lead { color: var(--ink-soft); margin: 6px 0 0; max-width: 68ch; }

        .flash { border-radius: 10px; padding: 11px 14px; margin: 0 0 18px; font-size: 14px; border: 1px solid; }
        .flash.ok { background: var(--green-wash); border-color: #C7E3D3; color: var(--green-dark); }
        .flash.ko { background: var(--red-wash); border-color: #F1C9C4; color: var(--red); }

        .stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 12px; margin-bottom: 24px; }
        .stat { background: var(--card); border: 1px solid var(--line); border-radius: var(--radius); padding: 14px 16px; }
        .stat .n { font-family: var(--serif); font-size: 27px; line-height: 1; }
        .stat .k { font-size: 11.5px; text-transform: uppercase; letter-spacing: .1em; color: var(--muted); margin-top: 7px; }
        .stat.hl { border-color: #BFDCCB; background: var(--green-wash); }

        .card { background: var(--card); border: 1px solid var(--line); border-radius: var(--radius); padding: 18px 20px; box-shadow: var(--shadow); }
        .card + .card { margin-top: 18px; }
        .cols { display: grid; grid-template-columns: 1.55fr 1fr; gap: 18px; align-items: start; }
        .cols > div > .card + .card { margin-top: 18px; }

        .table { width: 100%; border-collapse: collapse; }
        .table th {
            text-align: left; font-size: 10.5px; text-transform: uppercase; letter-spacing: .12em;
            color: var(--muted); font-weight: 600; padding: 0 10px 9px; border-bottom: 1px solid var(--line);
        }
        .table td { padding: 11px 10px; border-bottom: 1px solid var(--line-soft); vertical-align: top; }
        .table tr:last-child td { border-bottom: 0; }
        .table tbody tr:hover { background: #FBFAF6; }
        .table .t { font-weight: 600; color: var(--ink); }
        .table .t:hover { color: var(--green); }
        .meta { color: var(--muted); font-size: 12.5px; }

        .pill {
            display: inline-block; padding: 3px 9px; border-radius: 999px;
            font-size: 11px; font-weight: 600; letter-spacing: .02em; white-space: nowrap;
            border: 1px solid transparent;
        }
        .pill.draft, .pill.deleted { background: #F1F0EC; color: #5A665E; border-color: #E1DED4; }
        .pill.submitted { background: var(--orange-wash); color: #9B4B05; border-color: #F3D8BB; }
        .pill.in_review { background: var(--blue-wash); color: var(--blue); border-color: #C9DCF0; }
        .pill.revision_requested { background: var(--red-wash); color: var(--red); border-color: #F1C9C4; }
        .pill.approved { background: #F3F0FA; color: #5B3E9B; border-color: #DDD5F0; }
        .pill.published { background: var(--green-wash); color: var(--green-dark); border-color: #BFDCCB; }
        .pill.archived { background: #F4F1EA; color: #7A6A4F; border-color: #E6DECD; }

        .btn {
            display: inline-flex; align-items: center; gap: 7px;
            border-radius: 9px; border: 1px solid transparent; cursor: pointer;
            font: inherit; font-size: 13.5px; font-weight: 600; padding: 9px 14px;
            text-decoration: none; line-height: 1.2;
        }
        .btn:hover { text-decoration: none; }
        .btn.primary { background: var(--green); color: #FFF; }
        .btn.primary:hover { background: var(--green-dark); }
        .btn.ghost { background: #FFF; border-color: var(--line); color: var(--ink); }
        .btn.ghost:hover { border-color: #CFC8B8; }
        .btn.danger { background: var(--red-wash); border-color: #F1C9C4; color: var(--red); }
        .btn.small { padding: 6px 10px; font-size: 12.5px; }
        .btn[disabled] { opacity: .5; cursor: not-allowed; }

        .form-row { display: grid; gap: 6px; margin-bottom: 16px; }
        .form-row.two { grid-template-columns: 1fr 1fr; gap: 16px; }
        .form-row label { font-size: 12.5px; font-weight: 600; color: var(--ink-soft); }
        .form-row .hint { font-size: 12px; color: var(--muted); }
        input[type=text], input[type=email], input[type=password], input[type=url], input[type=number], select, textarea {
            width: 100%; font: inherit; color: var(--ink); background: #FFF;
            border: 1px solid var(--line); border-radius: 9px; padding: 10px 12px;
        }
        input:focus, select:focus, textarea:focus { outline: 2px solid #BBDCC8; outline-offset: 1px; border-color: #9BCBAF; }
        textarea { min-height: 320px; font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace; font-size: 13px; line-height: 1.6; }
        .error { color: var(--red); font-size: 12.5px; }

        .toolbar { display: flex; gap: 10px; align-items: center; flex-wrap: wrap; margin-bottom: 18px; }
        .toolbar form { display: flex; gap: 8px; align-items: center; margin: 0; }
        .toolbar input[type=text] { width: 240px; }
        .toolbar select { width: auto; }

        .empty { padding: 26px 6px; text-align: center; color: var(--muted); }
        .empty strong { display: block; color: var(--ink); font-family: var(--serif); font-size: 17px; margin-bottom: 4px; }

        .quality { list-style: none; margin: 0; padding: 0; }
        .quality li { display: flex; justify-content: space-between; gap: 12px; padding: 9px 0; border-bottom: 1px solid var(--line-soft); }
        .quality li:last-child { border-bottom: 0; }
        .quality .n { font-family: var(--serif); font-size: 17px; }
        .quality li.bad .n { color: var(--red); }
        .quality li.good .n { color: var(--green); }

        .activity { list-style: none; margin: 0; padding: 0; }
        .activity li { padding: 10px 0; border-bottom: 1px solid var(--line-soft); font-size: 13.5px; }
        .activity li:last-child { border-bottom: 0; }
        .activity .what { font-weight: 600; }
        .activity .when { color: var(--muted); font-size: 12px; }

        .article-head { margin-bottom: 18px; }
        .article-head .tags { display: flex; gap: 8px; align-items: center; flex-wrap: wrap; margin-bottom: 10px; }
        .prose { color: var(--ink-soft); white-space: pre-wrap; font-size: 14.5px; line-height: 1.7; }
        .refs { margin: 0; padding-left: 18px; color: var(--ink-soft); font-size: 13.5px; }
        .actions { display: flex; gap: 10px; flex-wrap: wrap; align-items: flex-start; }
        .actions form { margin: 0; }
        .comment-box { min-height: 0; height: 38px; font-family: var(--sans); font-size: 13.5px; padding: 8px 10px; }
        .short-box { min-height: 74px; font-family: var(--sans); font-size: 13.5px; line-height: 1.5; }

        .pair-row { display: grid; grid-template-columns: 1fr 1.4fr auto; gap: 10px; margin-bottom: 10px; }
        .ref-row { display: grid; grid-template-columns: 1.5fr 1fr 1fr 84px 1.4fr auto; gap: 10px; margin-bottom: 10px; }
        .check { display: inline-flex; align-items: center; gap: 7px; font-size: 13.5px; margin: 0 16px 8px 0; }
        .check input { width: auto; }
        .diff-chips { display: flex; gap: 8px; flex-wrap: wrap; margin: 8px 0 0; }

        .login-wrap { min-height: 100vh; display: grid; place-items: center; padding: 24px; }
        .login-card { background: var(--card); border: 1px solid var(--line); border-radius: 18px; box-shadow: var(--shadow); padding: 30px 28px; width: min(420px, 100%); }
        .login-card h1 { font-size: 25px; margin-bottom: 6px; }
        .login-card .lead { margin-bottom: 22px; font-size: 13.5px; }
        .login-card .brand { padding: 0; margin-bottom: 18px; }
        .login-card .brand strong { color: var(--ink); font-size: 17px; letter-spacing: .05em; }
        .login-card .brand span { color: var(--muted); font-size: 10.5px; }

        .pager { margin-top: 16px; }
        .pager nav { display: flex; gap: 6px; flex-wrap: wrap; font-size: 13px; }
        .pager a, .pager span { padding: 5px 9px; border-radius: 7px; border: 1px solid var(--line); color: var(--ink-soft); background: #FFF; }
        .pager span.current { background: var(--green); border-color: var(--green); color: #FFF; }

        @media (max-width: 980px) {
            .shell { grid-template-columns: 1fr; }
            .sidebar { position: static; height: auto; flex-direction: column; }
            .nav { flex-direction: row; flex-wrap: wrap; }
            .sidebar-foot { flex-direction: row; align-items: center; justify-content: space-between; }
            .sidebar-foot button { width: auto; }
            .cols { grid-template-columns: 1fr; }
            .main { padding: 20px 18px 48px; }
            .form-row.two { grid-template-columns: 1fr; }
            .pair-row, .ref-row { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
<div class="shell">
    <aside class="sidebar">
        <a class="brand" href="{{ route('admin.dashboard') }}">
            <strong>IVOIREPEDIA</strong>
            <span>Rédaction</span>
        </a>

        <nav class="nav">
            <p class="nav-title">Pilotage</p>
            <a href="{{ route('admin.dashboard') }}" class="{{ request()->routeIs('admin.dashboard') ? 'active' : '' }}">
                <span class="dot green"></span> Tableau de bord
            </a>
            <a href="{{ route('admin.articles.index') }}" class="{{ request()->routeIs('admin.articles.*') ? 'active' : '' }}">
                <span class="dot"></span> Articles
            </a>
            <a href="{{ route('admin.journal') }}" class="{{ request()->routeIs('admin.journal') ? 'active' : '' }}">
                <span class="dot"></span> Journal
            </a>
            <a href="{{ route('admin.messages.index') }}" class="{{ request()->routeIs('admin.messages.*') ? 'active' : '' }}">
                <span class="dot green"></span> Messages
            </a>
            @if (auth()->user()?->role->canReview())
                <a href="{{ route('admin.categories.index') }}" class="{{ request()->routeIs('admin.categories.*') ? 'active' : '' }}">
                    <span class="dot"></span> Catégories
                </a>
                <a href="{{ route('admin.tags.index') }}" class="{{ request()->routeIs('admin.tags.*') ? 'active' : '' }}">
                    <span class="dot"></span> Étiquettes
                </a>
            @endif
            @if (auth()->user()?->role->canManageUsers())
                <a href="{{ route('admin.users.index') }}" class="{{ request()->routeIs('admin.users.*') ? 'active' : '' }}">
                    <span class="dot"></span> Comptes
                </a>
            @endif
            <p class="nav-title" style="margin-top:18px">Lecture</p>
            <a href="{{ config('ivoirepedia.site_url') }}" target="_blank" rel="noopener">
                <span class="dot green"></span> Voir le site
            </a>
        </nav>

        <div class="sidebar-foot">
            <div>
                <div class="who">{{ auth()->user()?->name }}</div>
                <div>{{ auth()->user()?->role->label() }}</div>
            </div>
            <form method="post" action="{{ route('admin.logout') }}">
                @csrf
                <button type="submit">Se déconnecter</button>
            </form>
        </div>
    </aside>

    <main class="main">
        <header class="topbar">
            <div>
                <p class="eyebrow">@yield('eyebrow', 'Rédaction')</p>
                <h1>@yield('title', 'Tableau de bord')</h1>
                @hasSection('lead')
                    <p class="lead">@yield('lead')</p>
                @endif
            </div>
            <div>@yield('actions')</div>
        </header>

        @if (session('status'))
            <div class="flash ok">{{ session('status') }}</div>
        @endif

        @if (session('error'))
            <div class="flash ko">{{ session('error') }}</div>
        @endif

        @if ($errors->any())
            <div class="flash ko">
                @foreach ($errors->all() as $message)
                    <div>{{ $message }}</div>
                @endforeach
            </div>
        @endif

        @yield('content')
    </main>
</div>
@stack('scripts')
</body>
</html>
