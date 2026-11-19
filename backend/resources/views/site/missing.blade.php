@extends('site.layout')

@section('title', 'Article introuvable — IVOIREPEDIA')
@section('description', 'Cet article n’existe pas ou n’est pas publié.')
@section('robots', 'noindex, follow')
@section('canonical', $siteUrl.'/')

@section('content')
    <section class="missing">
        <p class="kicker">Page introuvable</p>
        <h1>Cet article n’existe pas ou n’est pas encore publié.</h1>
        <p>
            Vérifiez l’adresse, ou repartez de l’accueil pour explorer
            l’encyclopédie et ses sources.
        </p>
        <a class="button" href="{{ $siteUrl }}/">Revenir à l’accueil</a>
    </section>
@endsection
