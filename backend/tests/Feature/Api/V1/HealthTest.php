<?php

/**
 * Contrat minimal du Sprint 0 : l'API répond en JSON sous /api/v1 (CONTEXT §11).
 */
it('returns a json health payload under /api/v1', function () {
    $this->getJson('/api/v1/health')
        ->assertOk()
        ->assertJson([
            'status' => 'ok',
            'service' => 'ivoirepedia-api',
            'version' => 'v1',
        ]);
});
