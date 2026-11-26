import assert from 'node:assert/strict';
import { access, readFile } from 'node:fs/promises';
import test from 'node:test';

const pageUrl = new URL('../src/index.html', import.meta.url);
const html = await readFile(pageUrl, 'utf8');
const imageTags = [...html.matchAll(/<img\b[^>]*>/g)].map(([tag]) => tag);

test('uses the local real-estate images in the mockups', async () => {
  const sources = imageTags.map((tag) => tag.match(/\bsrc="([^"]+)"/)?.[1]);
  assert.ok(sources.every(Boolean), 'Every mockup image must have a source');
  assert.ok(sources.length >= 12, 'The mockups should contain their property photos');
  assert.deepEqual(
    [...new Set(sources)].sort(),
    [
      '../images/Large-Modern-Living-Room.jpg',
      '../images/best-luxury-villa-lucknow_0.jpg',
      '../../apps/mobile/assets/images/nouveau_logo.png',
      '../images/villa_exterior.webp',
    ].sort(),
  );

  await Promise.all(sources.map((source) => access(new URL(source, pageUrl))));
});

test('starts the MVP screens section with the researcher discovery screen', () => {
  const mvpSection = html.match(/<section class="mvp-screens"[\s\S]*?<\/section>/)?.[0];
  assert.ok(mvpSection, 'The MVP screens section must be present in the existing board');
  assert.match(mvpSection, /<h2 id="mvp-screens-title">Écrans MVP<\/h2>/);
  assert.match(mvpSection, /Écran CH-01/);
  assert.match(mvpSection, /Accueil \/ découverte/);
  assert.match(mvpSection, /class="mvp-home-hero"/);
  assert.match(mvpSection, /alt="Famille béninoise devant sa maison"/);
  assert.match(mvpSection, /Trouvez votre<br>bien idéal au Bénin/);
  assert.match(mvpSection, /aria-label="Rechercher un bien, une ville"/);
  for (const category of ['À vendre', 'À louer', 'Terrains', 'Services']) {
    assert.ok(
      html.includes(`>${category}`),
      `The reference category ${category} must be present`,
    );
  }
  assert.match(html, /Nos biens en vedette/);
  assert.match(html, /Voir tout →/);
  assert.match(html, /alt="Villa contemporaine avec piscine et jardin"/);
  assert.match(html, /250 000 FCFA \/ mois/);
  assert.match(html, /Villa contemporaine à Cotonou/);
  assert.match(mvpSection, /Données de démonstration/);
});

test('documents and renders the interactive researcher search screen', () => {
  assert.match(html, /Écran CH-02/);
  assert.match(html, /02 · Recherche et filtres/);
  assert.match(html, /<h4>Trouver un bien<\/h4>/);
  assert.match(html, /mvp-search-status/);
  assert.match(html, /aria-label="Options de recherche"/);
  assert.match(html, /mvp-home-indicator/);
  assert.match(html, /<legend class="mvp-search-legend">/);
  assert.match(html, /class="mvp-type-option" type="button" aria-pressed="true"><svg/);
  assert.match(html, /id="mvp-property-search"/);
  assert.match(html, /data-search-operation="Vente"/);
  assert.match(html, /data-search-operation="Location"/);
  assert.match(html, /Type de bien/);
  assert.match(html, /name="location" type="text" list="mvp-location-suggestions"/);
  assert.match(html, /name="minimum" type="number"/);
  assert.match(html, /name="maximum" type="number"/);
  assert.match(html, /name="radius"/);
  assert.match(html, /name="available"/);
  assert.match(html, /Afficher les biens/);
  assert.match(html, /Effacer les critères/);
  assert.match(html, /Critères prêts.*aperçu uniquement/);
  assert.match(html, /Le budget maximum doit être supérieur au minimum/);
});

test('documents and renders researcher search results without invented counts', () => {
  const resultsStart = html.indexOf('id="mvp-screen-three-title"');
  const detailStart = html.indexOf('id="mvp-screen-four-title"');
  const resultsScreen = html.slice(resultsStart, detailStart);
  assert.match(html, /Écran CH-03/);
  assert.match(html, /03 · Résultats de recherche/);
  assert.match(html, /aria-label="Maquette mobile IMOVIA : résultats de recherche"/);
  assert.match(html, /Achat · Maison · Cotonou/);
  assert.match(html, /aria-label="Trier les annonces"/);
  assert.match(html, /Prix croissant/);
  assert.match(html, /class="pill verified-badge" aria-label="Informations vérifiées">Vérifié<\/span>/);
  assert.equal((resultsScreen.match(/class="pill mvp-availability-badge">Disponible<\/span>/g) ?? []).length, 2);
  assert.match(html, /\.mvp-results-screen\{[^}]*background:#f7f8fa;font-family:'Plus Jakarta Sans'/);
  assert.match(html, /\.mvp-result-card\{[^}]*background:#fff;box-shadow:0 12px 28px/);
  assert.match(html, /\.mvp-result-card:hover\{[^}]*translateY\(-2px\)/);
  assert.match(html, /\.mvp-result-name\{[^}]*font-size:14px/);
  assert.match(html, /\.pill\{[^}]*background:#e8f4ec/);
  assert.match(html, /\.pill::before\{[^}]*background:#20a34a/);
  assert.match(html, /\.pill\.verified-badge::before\{[^}]*background:#20a34a/);
  assert.match(html, /Prix sur demande/);
  assert.match(html, /class="mvp-verification-note"/);
  assert.match(html, /Vérification non indiquée/);
  assert.match(html, /class="mvp-results-empty" role="status"/);
  assert.match(html, /Annonces fictives/);
  assert.match(html, /aria-label="Navigation principale"/);
  assert.match(html, /mvp-results-home-indicator/);
  assert.doesNotMatch(resultsScreen, /\b\d+\s+(?:biens trouvés|résultats)\b/i);
});

test('documents and renders the researcher property detail screen', () => {
  const detailScreen = html.slice(html.indexOf('id="mvp-screen-four-title"'));
  assert.match(html, /Écran CH-04/);
  assert.match(html, /04 · Détail d’un bien/);
  assert.match(html, /aria-label="Maquette mobile IMOVIA : détail d’un bien"/);
  assert.match(detailScreen, /Galerie publique du bien/);
  assert.match(detailScreen, /class="mvp-detail-gallery-wrap"/);
  assert.doesNotMatch(detailScreen, /mvp-detail-thumbnails/);
  assert.match(detailScreen, /Voir toutes les photos/);
  assert.match(detailScreen, /1 \/ 12/);
  assert.match(detailScreen, /Prix affiché par l’annonceur/);
  assert.match(html, /data-detail-operation="sale" aria-pressed="true">Vente<\/button>/);
  assert.match(html, /data-detail-operation="rent" aria-pressed="false">Location<\/button>/);
  assert.match(detailScreen, /<span data-detail-operation-label>À vendre<\/span>/);
  assert.match(detailScreen, /<span data-detail-price>85 000 000<\/span> FCFA<span data-detail-period><\/span>/);
  assert.match(detailScreen, /data-detail-rental-conditions hidden/);
  assert.match(detailScreen, /aria-expanded="false" aria-controls="mvp-detail-conditions-full" data-expand-conditions/);
  assert.match(detailScreen, /Lire les conditions complètes/);
  assert.match(detailScreen, /mvp-detail-conditions-extra" id="mvp-detail-conditions-full" hidden/);
  assert.match(detailScreen, /Caution de garantie<\/dt><dd>Non précisée<\/dd>/);
  assert.match(detailScreen, /Avance de loyer<\/dt><dd>Non précisée<\/dd>/);
  assert.match(detailScreen, /Charges \(eau, électricité\)<\/dt><dd>Non précisées<\/dd>/);
  assert.match(detailScreen, /Frais d’agence<\/dt><dd>Non précisés<\/dd>/);
  assert.match(html, /querySelector\('\[data-detail-price\]'\)\.textContent = rental \? '500 000' : '85 000 000'/);
  assert.match(html, /querySelector\('\[data-detail-period\]'\)\.textContent = rental \? ' \/ mois' : ''/);
  assert.match(html, /querySelector\('\[data-detail-rental-conditions\]'\)/);
  assert.match(html, /conditionsToggle\.setAttribute\('aria-expanded', 'false'\)/);
  assert.match(detailScreen, /class="mvp-detail-feature"/);
  assert.match(detailScreen, /aria-expanded="false" aria-controls="mvp-detail-description"/);
  assert.match(detailScreen, /class="mvp-description-toggle"/);
  assert.match(detailScreen, /Localisation approximative/);
  assert.match(detailScreen, /adresse exacte non affichée/);
  assert.match(detailScreen, /class="pill verified-badge" type="button" aria-label="Annonceur vérifié : afficher les détails" aria-haspopup="dialog"/);
  assert.match(detailScreen, /class="mvp-detail-verification" type="button"[^>]*data-open-verification-dialog/);
  assert.match(detailScreen, /class="mvp-detail-verification-icon"[^>]*><svg/);
  assert.match(detailScreen, /class="mvp-detail-verification-info"/);
  assert.match(detailScreen, /<span>Voir le profil<\/span>\s*<svg viewBox="0 0 24 24" aria-hidden="true"><path d="m9 18 6-6-6-6"\/><\/svg>/);
  assert.match(html, /\.pill\.verified-badge::before\{content:"✓";width:11px;height:11px;display:grid;place-items:center;border-radius:50%;background:#20a34a;color:#fff/);
  assert.match(html, /<dialog class="mvp-verification-dialog" id="mvp-verification-dialog"/);
  assert.match(html, /L’équipe IMOVIA a effectué les contrôles prévus pour cette annonce/);
  assert.match(html, /querySelectorAll\('\[data-open-verification-dialog\]'\)/);
  assert.match(html, /trigger\.addEventListener\('click', \(\) => verificationDialog\.showModal\(\)\)/);
  assert.match(detailScreen, /Contacter l’annonceur/);
  assert.match(detailScreen, /Signaler cette annonce/);
  assert.match(detailScreen, /aucune coordonnée privée n’est exposée/i);
});

test('documents and renders the researcher favorites screen with an empty state', () => {
  const favoritesScreen = html.slice(html.indexOf('id="mvp-screen-five-title"'));
  assert.match(html, /\.mvp-favorite-card\{[^}]*border-radius:16px;background:#fff;box-shadow:0 12px 28px rgba\(15,23,42,\.10\),0 3px 8px rgba\(15,23,42,\.045\);transition:transform \.18s ease,box-shadow \.18s ease\}/);
  assert.match(html, /\.mvp-favorite-card:hover\{[^}]*translateY\(-2px\);box-shadow:0 15px 32px rgba\(15,23,42,\.12\),0 3px 8px rgba\(15,23,42,\.05\)\}/);
  assert.match(html, /Écran CH-05/);
  assert.match(html, /05 · Favoris/);
  assert.match(favoritesScreen, /aria-label="Maquette mobile IMOVIA : favoris"/);
  assert.match(favoritesScreen, /aria-label="Biens favoris"/);
  assert.match(favoritesScreen, /Villa contemporaine avec jardin/);
  assert.match(favoritesScreen, /aria-label="Annonce vérifiée">Vérifié/);
  assert.match(favoritesScreen, /Prix sur demande/);
  assert.match(favoritesScreen, /Indisponible/);
  assert.match(favoritesScreen, /data-remove-favorite/);
  assert.match(favoritesScreen, /Pas encore de favoris/);
  assert.match(favoritesScreen, /Relancer la recherche/);
  assert.match(favoritesScreen, /aria-current="page"><svg[^>]*>[\s\S]*?<\/svg>Favoris/);
  assert.match(html, /button\.closest\('\.mvp-favorite-card'\)\.remove\(\)/);
  assert.match(html, /list\.nextElementSibling\.classList\.add\('is-visible'\)/);
});

test('provides meaningful alt text and does not reference missing image assets', () => {
  for (const tag of imageTags) {
    assert.match(tag, /\balt="[^"]+"/, `Image is missing alternative text: ${tag}`);
  }
  assert.doesNotMatch(html, /src="assets\//);
  assert.doesNotMatch(html, /avatar-[12]\.jpg/);
});

test('matches the reference status badges and dashboard counters', () => {
  const badgeExample = html.match(/<div class="pills" aria-label="Exemples de badges">([\s\S]*?)<\/div>/)?.[1] ?? '';
  const badges = [...badgeExample.matchAll(/<button class="pill ([^"]+)"[^>]*>([^<]+)<\/button>/g)]
    .filter(([, classes]) => classes.includes('status-badge'))
    .map(([, classes, label]) => [classes, label.trim()]);

  assert.deepEqual(badges, [
    ['status-badge', 'Disponible'],
    ['verified-badge status-badge', 'Vérifié'],
    ['new-badge status-badge', 'Nouveau'],
    ['featured-badge status-badge', 'En vedette'],
  ]);
  assert.match(html, /<strong>12<\/strong><small>Annonces publiées<\/small>/);
  assert.match(html, /<strong>8\.5k<\/strong><small>Vues<\/small>/);
  assert.match(html, /<strong>48<\/strong><small>Visites<\/small>/);
  assert.match(html, /<strong>312<\/strong><small>Favoris<\/small>/);
  assert.match(html, /class="unread-counter"[^>]*>3<\/span>/);
  assert.match(html, /class="unread-counter"[^>]*>2<\/span>/);
});

test('provides keyboard-accessible interactive prototype controls', () => {
  assert.doesNotMatch(html, /theme-toggle|is-dark/);
  assert.match(html, /class="pill status-badge" type="button" aria-pressed="false"/);
  assert.match(html, /class="category" type="button" aria-pressed="false"/);
  assert.match(html, /class="demo-toast" role="status" aria-live="polite"/);
  assert.match(html, /addEventListener\('click'/);
});

test('uses the IMOVIA mark and a bell icon for notifications', () => {
  assert.match(html, /<title>IMOVIA — Design System<\/title>/);
  assert.doesNotMatch(html, /CARANOVA/);
  assert.match(html, /class="phone-brand"><svg class="logo-mark-light"/);
  assert.match(html, /class="side-brand"><svg class="logo-mark-light"/);
  assert.match(html, /class="notification-button"[^>]*aria-label="Notifications"/);
  assert.match(html, /<svg class="notification-bell" viewBox="0 0 24 24"/);
  assert.match(html, /class="notification-dot"/);
  assert.doesNotMatch(html, /aria-label="Notifications"[^>]*>♧/);
});

test('uses the approved monochrome palette on a light-only board', () => {
  for (const color of ['#0B0B0B', '#1F1F1F', '#6B7280', '#E5E7EB', '#FFFFFF', '#101114']) {
    assert.ok(html.toUpperCase().includes(color), `Missing approved palette color ${color}`);
  }
  assert.match(html, /body\{margin:0;background:#E5E7EB/);
  assert.doesNotMatch(html, /theme-toggle|is-dark/);
});

test('uses the outline profile icon consistently instead of a text symbol', () => {
  assert.doesNotMatch(html, /♙/);
  assert.equal((html.match(/class="profile-icon"/g) ?? []).length, 5);
  assert.match(html, /<svg class="profile-icon" viewBox="0 0 24 24"/);
});
