/*
 * Couverture de lancement et chargement du moteur Flutter.
 *
 * Ce code était un <script> en ligne de index.html, avec des attributs
 * `onload`/`onerror` sur la balise du chargeur. La CSP bloquante
 * (docs/SECURITE.md) refuse les deux. Servi par la même origine, ce fichier
 * laisse `script-src 'self'` intact : c'est lui qui crée la balise du chargeur
 * et s'abonne à ses événements.
 */
(function () {
    var start = Date.now();
    var node = document.getElementById('loading');
    var status = document.getElementById('status');
    var actions = document.getElementById('actions');
    var elapsed = document.getElementById('elapsed');
    var retry = document.getElementById('retry');
    var finished = false;

    function setStep(name, text) {
        var items = node ? node.querySelectorAll('.steps li') : [];
        for (var i = 0; i < items.length; i++) {
            var step = items[i].getAttribute('data-step');
            items[i].classList.remove('on');
            if (step === name) items[i].classList.add('on');
            else if (step === 'connect' || (step === 'engine' && name === 'ready')) {
                items[i].classList.add('done');
            }
        }
        if (status && text) status.textContent = text;
    }

    function showActions(text) {
        if (status && text) status.textContent = text;
        if (actions) actions.hidden = false;
    }

    // Compteur réel : le temps déjà passé à attendre le moteur.
    var counter = setInterval(function () {
        if (finished || !elapsed) return;
        elapsed.textContent = String(Math.floor((Date.now() - start) / 1000));
    }, 1000);

    // Le chargeur est arrivé et s'exécute : c'est lui qui télécharge le
    // moteur (plusieurs Mo). Le premier cadre peint reste le vrai signal.
    window.__ivoireLoading = {
        engine: function () {
            setStep('engine', 'Téléchargement du moteur de lecture (plusieurs Mo sur connexion lente)…');
        },
        failed: function () {
            clearInterval(timer);
            finished = true;
            setStep('engine', 'Le moteur n’a pas pu être téléchargé.');
            showActions('Vérifiez la connexion, puis rechargez la page.');
        }
    };

    if (retry) retry.addEventListener('click', function () {
        window.location.reload();
    });

    // Message honnête quand la connexion est lente : le moteur ne peint rien
    // tant qu'il n'est pas arrivé.
    var slow = setTimeout(function () {
        showActions('Le moteur tarde à arriver. Sur une connexion lente, comptez jusqu’à une minute.');
    }, 10000);

    function ready() {
        return document.querySelector('flt-glass-pane, flutter-view');
    }

    function clear() {
        finished = true;
        clearInterval(counter);
        if (node) {
            node.classList.add('gone');
            setTimeout(function () { if (node.parentNode) node.parentNode.removeChild(node); }, 300);
        }
        clearTimeout(slow);
    }

    var timer = setInterval(function () {
        if (ready()) {
            clearInterval(timer);
            setStep('ready');
            clear();
        } else if (Date.now() - start > 90000) {
            clearInterval(timer);
            finished = true;
            setStep('engine', 'La page ne répond toujours pas.');
            showActions('Vérifiez la connexion, puis rechargez la page.');
        }
    }, 100);

    // Le chargeur Flutter est créé ici, comme un élément : plus d'attribut
    // en ligne sur la balise, donc rien que la CSP ait à refuser.
    var bootstrap = document.createElement('script');
    bootstrap.src = 'flutter_bootstrap.js';
    bootstrap.async = true;
    bootstrap.addEventListener('load', function () {
        if (window.__ivoireLoading) window.__ivoireLoading.engine();
    });
    bootstrap.addEventListener('error', function () {
        if (window.__ivoireLoading) window.__ivoireLoading.failed();
    });
    document.body.appendChild(bootstrap);
})();
