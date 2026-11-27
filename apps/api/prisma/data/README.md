# Locality catalog

`benin-localities.json` is a minimal hierarchy snapshot prepared from the
Institut Géographique National du Bénin (IGN) catalogue. It contains only
place names and parent relationships; it does not include coordinates.

- [Localités et chefs-lieux de village](https://ign.bj/donnees/localites-et-chefs-lieux-de-village)
- [Limites des arrondissements](https://ign.bj/donnees/limites-des-arrondissements)
- [Limites communales](https://ign.bj/donnees/limites-communales)
- [Limites départementales](https://ign.bj/donnees/limites-departementales)

Source data was last updated on 20 September 2026 and is published under the
Licence Ouverte / Open Licence 2.0 (Etalab). Attribution: **Source : IGN Bénin,
catalogue national de données géographiques.**

The `localitiesWithoutVerifiedArrondissement` count records entries whose
coordinates did not identify a unique arrondissement in the IGN boundary layer.
Those names remain searchable under their commune rather than being assigned
to an unverified arrondissement.

The import is additive and safe to run again:

```sh
cd apps/api
npm run db:seed:locations
```

Use `npm run db:seed:locations -- --dry-run` to validate the bundled catalog
without connecting to a database.
