<!DOCTYPE html>
<html lang="fr">
<head>
  <base href="/">

  <meta charset="UTF-8">
  <meta content="IE=Edge" http-equiv="X-UA-Compatible">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="description" content="{{ $description }}">
  <meta name="theme-color" content="#FBF9F4">

  <!-- iOS meta tags & icons -->
  <meta name="mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-status-bar-style" content="default">
  <meta name="apple-mobile-web-app-title" content="Ivoirepedia">
  <link rel="apple-touch-icon" sizes="180x180" href="/icons/apple-touch-icon.png?v=2">

  <link rel="icon" href="/favicon.ico?v=2" sizes="any">
  <link rel="shortcut icon" href="/favicon.ico?v=2">
  <link rel="icon" type="image/png" sizes="32x32" href="/favicon.png?v=2">
  <link rel="icon" type="image/png" sizes="192x192" href="/icons/Icon-192.png?v=2">

  <title>{{ $title }} — IVOIREPEDIA</title>
  <link rel="canonical" href="{{ $canonical }}">
  @include('site.partials.social')
  <link rel="manifest" href="/manifest.json">

  <!--
    Couverture de lancement, reprise de app/web/index.html : Flutter charge
    son moteur avant de peindre, cette signature tient l'écran pendant ce
    temps. L'application la retire en fondu dès sa première image.
  -->
  <style>
    html, body {
      margin: 0;
      height: 100%;
      background: #FBF9F4;
    }

    #loading {
      position: fixed;
      inset: 0;
      z-index: 9999;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 24px;
      box-sizing: border-box;
      background-color: #FBF9F4;
      background-image:
        repeating-linear-gradient(90deg, rgba(14, 123, 69, 0.045) 0 1px, transparent 1px 104px),
        repeating-linear-gradient(0deg, rgba(180, 85, 44, 0.035) 0 1px, transparent 1px 132px);
      overflow: hidden;
      transition: opacity 260ms ease;
    }

    #loading img {
      display: block;
      width: min(84vw, 560px);
      height: auto;
    }

    #loading .progress {
      position: absolute;
      left: 0;
      bottom: 0;
      height: 3px;
      width: 38%;
      background: linear-gradient(90deg, #F07C00, #E7B34A, #0E7B45);
      animation: sweep 1.5s ease-in-out infinite;
    }

    #loading .hint {
      position: absolute;
      left: 12px;
      right: 12px;
      bottom: 16px;
      margin: 0 auto;
      max-width: 380px;
      font-family: "Inter", "Segoe UI", system-ui, -apple-system, sans-serif;
      font-size: 12.5px;
      line-height: 1.6;
      text-align: center;
      color: #4A463F;
      background: rgba(251, 249, 244, 0.92);
      border-radius: 8px;
      padding: 6px 10px;
      opacity: 0;
      transition: opacity 300ms ease;
    }

    #loading .hint.slow {
      opacity: 1;
    }

    #loading.gone {
      opacity: 0;
      pointer-events: none;
    }

    #loading .hint a {
      color: #0A5C34;
    }

    @keyframes sweep {
      0%   { transform: translateX(-100%); }
      100% { transform: translateX(320%); }
    }
  </style>
</head>
<body>
  <div id="loading" role="status" aria-live="polite">
    <picture>
      <source srcset="logo.webp" type="image/webp">
      <img src="logo.png" width="1200" height="282"
           alt="Ivoirepedia, l’encyclopédie libre de la Côte d’Ivoire">
    </picture>
    <div class="progress"></div>
    <div class="hint" id="hint"></div>
  </div>

  <noscript>
    <div style="max-width: 720px; margin: 40px auto; padding: 0 20px; font-family: Inter, 'Segoe UI', system-ui, sans-serif; color: #16211B; line-height: 1.7;">
      <h1 style="font-size: 30px; line-height: 1.2;">{{ $title }}</h1>
      <p style="font-size: 17px; color: #5B6459;">{{ $description }}</p>
      <p><a href="{{ $canonical }}?html=1" style="color: #0E7B45;">Lire la version texte de cet article</a></p>
    </div>
  </noscript>

  <script>
    (function () {
      var start = Date.now();
      var hint = document.getElementById('hint');

      function showHint(text) {
        if (!hint) return;
        hint.innerHTML = text;
        hint.classList.add('slow');
      }

      var slow = setTimeout(function () {
        showHint('Chargement de l’encyclopédie… Sur une connexion lente, comptez jusqu’à une minute.');
      }, 10000);

      function ready() {
        return document.querySelector('flt-glass-pane, flutter-view');
      }

      function clear() {
        var node = document.getElementById('loading');
        if (node) {
          node.classList.add('gone');
          setTimeout(function () { node.remove(); }, 300);
        }
        clearTimeout(slow);
      }

      var timer = setInterval(function () {
        if (ready()) {
          clearInterval(timer);
          clear();
        } else if (Date.now() - start > 90000) {
          clearInterval(timer);
          showHint('La page ne répond pas. Vérifiez la connexion, puis <a href="">rechargez</a>.');
        }
      }, 100);
    })();
  </script>

  <script src="flutter_bootstrap.js" async></script>
</body>
</html>
