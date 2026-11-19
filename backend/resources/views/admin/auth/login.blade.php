<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="robots" content="noindex, nofollow">
    <title>Connexion à la rédaction — Ivoirepedia</title>
    <style>
        :root {
            --paper: #FBF9F4; --card: #FFF; --ink: #16241C; --ink-soft: #3D4C43;
            --muted: #6B7A70; --line: #E4DFD3; --green: #0E7B45; --green-dark: #0A5C34;
            --red: #B3261E; --red-wash: #FCEDEB;
            --shadow: 0 1px 2px rgba(22,36,28,.05), 0 10px 30px rgba(22,36,28,.08);
            --sans: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            --serif: "Iowan Old Style", "Palatino Linotype", Palatino, Georgia, serif;
        }
        * { box-sizing: border-box; }
        body {
            margin: 0; min-height: 100vh; display: grid; place-items: center; padding: 24px;
            background: var(--paper); color: var(--ink); font-family: var(--sans); font-size: 14.5px; line-height: 1.5;
        }
        .card { background: var(--card); border: 1px solid var(--line); border-radius: 18px; box-shadow: var(--shadow); padding: 32px 28px; width: min(420px, 100%); }
        .brand strong { font-family: var(--serif); font-size: 17px; letter-spacing: .05em; display: block; }
        .brand span { font-size: 10.5px; text-transform: uppercase; letter-spacing: .18em; color: var(--muted); }
        h1 { font-family: var(--serif); font-size: 25px; margin: 18px 0 6px; font-weight: 600; }
        p.lead { color: var(--ink-soft); font-size: 13.5px; margin: 0 0 22px; }
        .row { display: grid; gap: 6px; margin-bottom: 16px; }
        label { font-size: 12.5px; font-weight: 600; color: var(--ink-soft); }
        input {
            width: 100%; font: inherit; padding: 10px 12px; border: 1px solid var(--line);
            border-radius: 9px; background: #FFF; color: var(--ink);
        }
        input:focus { outline: 2px solid #BBDCC8; outline-offset: 1px; border-color: #9BCBAF; }
        button {
            width: 100%; font: inherit; font-weight: 600; font-size: 14px; cursor: pointer;
            background: var(--green); color: #FFF; border: 0; border-radius: 10px; padding: 11px 14px;
        }
        button:hover { background: var(--green-dark); }
        .flash { background: var(--red-wash); border: 1px solid #F1C9C4; color: var(--red); border-radius: 10px; padding: 10px 12px; margin-bottom: 16px; font-size: 13.5px; }
        .ok { background: #EDF6F0; border-color: #C7E3D3; color: var(--green-dark); }
        .foot { margin-top: 18px; font-size: 12.5px; color: var(--muted); }
        .foot a { color: var(--green); }
    </style>
</head>
<body>
<div class="card">
    <div class="brand">
        <strong>IVOIREPEDIA</strong>
        <span>Rédaction</span>
    </div>

    <h1>Connexion</h1>
    <p class="lead">Cet espace est réservé aux contributeurs, éditeurs et administrateurs.</p>

    @if (session('status'))
        <div class="flash ok">{{ session('status') }}</div>
    @endif

    @if ($errors->any())
        <div class="flash">{{ $errors->first() }}</div>
    @endif

    <form method="post" action="{{ route('admin.login.store') }}">
        @csrf
        <div class="row">
            <label for="email">Adresse électronique</label>
            <input id="email" name="email" type="email" value="{{ old('email') }}" required autofocus autocomplete="username">
        </div>
        <div class="row">
            <label for="password">Mot de passe</label>
            <input id="password" name="password" type="password" required autocomplete="current-password">
        </div>
        <button type="submit">Entrer dans la rédaction</button>
    </form>

    <p class="foot">
        Mot de passe oublié ? <a href="{{ config('ivoirepedia.site_url') }}/mot-de-passe-oublie">Le réinitialiser</a>.
    </p>
</div>
</body>
</html>
