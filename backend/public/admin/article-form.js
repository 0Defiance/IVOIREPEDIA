/*
 * Lignes ajoutées et retirées du formulaire d'article.
 *
 * Ce code vivait dans un <script> au bas du Blade. La CSP bloquante
 * (docs/SECURITE.md) refuse les scripts en ligne : servi par la même origine,
 * ce fichier permet de garder `script-src 'self'` sans 'unsafe-inline'. Les
 * compteurs partent du nombre de lignes déjà rendues — une valeur lue dans le
 * DOM plutôt qu'injectée par PHP, pour que la page n'ait plus une seule ligne
 * de script en ligne.
 */
(function () {
    'use strict';

    var counters = {};

    ['infobox', 'references'].forEach(function (kind) {
        var target = document.getElementById(kind + '-rows');
        var selector = kind === 'infobox' ? '.pair-row' : '.ref-row';

        counters[kind] = target ? target.querySelectorAll(selector).length : 0;
    });

    document.querySelectorAll('[data-add-row]').forEach(function (button) {
        button.addEventListener('click', function () {
            var kind = button.getAttribute('data-add-row');
            var template = document.getElementById(kind + '-template');
            var target = document.getElementById(kind + '-rows');

            if (!template || !target) {
                return;
            }

            target.insertAdjacentHTML(
                'beforeend',
                template.innerHTML.replace(/__INDEX__/g, String(counters[kind]++))
            );
        });
    });

    document.addEventListener('click', function (event) {
        if (!(event.target instanceof Element)) {
            return;
        }

        var button = event.target.closest('[data-remove-row]');

        if (!button) {
            return;
        }

        var row = button.closest('.pair-row, .ref-row');

        if (row) {
            row.remove();
        }
    });
})();
