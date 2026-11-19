<?php

namespace App\Support;

use Illuminate\Support\Str;

/**
 * Rendu HTML d'un contenu Delta Quill (ADR-003) pour les pages d'articles
 * pré-rendues côté serveur.
 *
 * Le Delta reste la seule source : aucun HTML n'est stocké en base. Le texte
 * est toujours échappé avant d'être enveloppé dans nos propres balises, si
 * bien qu'une insertion `<script>` dans le contenu s'affiche en clair au lieu
 * de s'exécuter. Les blocs suivent la lecture de l'application Flutter
 * (`articleBlocks` / `delta_content.dart`) : premier paragraphe en chapeau,
 * titres ancrés, listes groupées et citations.
 */
final class DeltaHtml
{
    /**
     * @param  array<string, mixed>|null  $delta
     */
    public static function render(?array $delta): string
    {
        $html = '';
        $first = true;
        $list = null;

        foreach (self::blocks($delta) as $block) {
            $isLead = $first && $block['header'] === null && $block['list'] === null;
            $first = false;

            if ($block['header'] !== null) {
                if ($list !== null) {
                    $html .= "</{$list}>\n";
                    $list = null;
                }

                $level = $block['header'] <= 2 ? 2 : 3;
                $html .= sprintf(
                    '<h%d id="%s">%s</h%d>',
                    $level,
                    e(self::anchor($block['text'])),
                    self::inline($block['text']),
                    $level,
                )."\n";

                continue;
            }

            if ($block['list'] !== null) {
                $tag = $block['list'] === 'ordered' ? 'ol' : 'ul';

                if ($list !== $tag) {
                    if ($list !== null) {
                        $html .= "</{$list}>\n";
                    }

                    $html .= "<{$tag}>\n";
                    $list = $tag;
                }

                $html .= '  <li>'.self::inline($block['text'])."</li>\n";

                continue;
            }

            if ($list !== null) {
                $html .= "</{$list}>\n";
                $list = null;
            }

            if ($block['quote']) {
                $html .= '<blockquote><p>'.self::inline($block['text'])."</p></blockquote>\n";

                continue;
            }

            $class = $isLead ? ' class="lead"' : ($block['bold'] ? ' class="bold"' : '');
            $html .= '<p'.$class.'>'.self::inline($block['text'])."</p>\n";
        }

        if ($list !== null) {
            $html .= "</{$list}>\n";
        }

        return trim($html);
    }

    /**
     * Titres de sections, dans l'ordre d'apparition, avec leur ancre.
     *
     * @param  array<string, mixed>|null  $delta
     * @return list<array{title: string, anchor: string}>
     */
    public static function sections(?array $delta): array
    {
        $sections = [];

        foreach (self::blocks($delta) as $block) {
            if ($block['header'] !== null) {
                $sections[] = [
                    'title' => $block['text'],
                    'anchor' => self::anchor($block['text']),
                ];
            }
        }

        return $sections;
    }

    /**
     * Ancre identique à `sectionAnchor` de l'application : minuscules, sans
     * accents ni ponctuation (`Histoire ancienne` → `histoire-ancienne`).
     */
    public static function anchor(string $title): string
    {
        $ascii = Str::ascii(Str::lower($title));

        return trim((string) preg_replace('/[^a-z0-9]+/', '-', $ascii), '-');
    }

    /**
     * Échappe le texte puis transforme les appels de note `[1]` en liens vers
     * la référence correspondante.
     */
    private static function inline(string $text): string
    {
        $escaped = e($text);

        return (string) preg_replace(
            '/\[(\d{1,3})\]/',
            '<sup class="note"><a href="#reference-$1">[$1]</a></sup>',
            $escaped,
        );
    }

    /**
     * Découpe le Delta en blocs, comme `articleBlocks` côté Flutter : les
     * attributs d'une opération s'appliquent au bloc qu'elle termine.
     *
     * @param  array<string, mixed>|null  $delta
     * @return list<array{text: string, header: int|null, list: string|null, quote: bool, bold: bool}>
     */
    private static function blocks(?array $delta): array
    {
        /** @var list<array{text: string, header: int|null, list: string|null, quote: bool, bold: bool}> $blocks */
        $blocks = [];
        $ops = $delta['ops'] ?? [];

        if (! is_array($ops)) {
            return $blocks;
        }

        $buffer = '';
        /** @var array<string, mixed>|null $pending */
        $pending = null;

        $flush = function () use (&$blocks, &$buffer, &$pending): void {
            $text = trim(rtrim($buffer));
            $buffer = '';
            $attributes = $pending;
            $pending = null;

            if ($text === '') {
                return;
            }

            $header = $attributes['header'] ?? null;
            $list = $attributes['list'] ?? null;

            $blocks[] = [
                'text' => $text,
                'header' => is_int($header) ? $header : null,
                'list' => in_array($list, ['bullet', 'ordered'], true) ? $list : null,
                'quote' => ($attributes['blockquote'] ?? false) === true,
                'bold' => ($attributes['bold'] ?? false) === true,
            ];
        };

        foreach ($ops as $op) {
            if (! is_array($op)) {
                continue;
            }

            $insert = $op['insert'] ?? null;

            if (! is_string($insert)) {
                continue; // les embeds ne sont pas rendus au MVP
            }

            $attributes = $op['attributes'] ?? null;
            $lines = explode("\n", $insert);
            $last = count($lines) - 1;

            foreach ($lines as $index => $line) {
                $buffer .= $line;

                if ($index < $last) {
                    if (is_array($attributes)) {
                        $pending = $attributes;
                    }

                    $flush();
                } elseif (is_array($attributes) && $line !== '') {
                    $pending = $attributes;
                }
            }
        }

        $flush();

        return $blocks;
    }
}
