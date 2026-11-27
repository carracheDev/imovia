#!/usr/bin/env python3
"""Prepare a minimal location catalog from the four IGN Benin GeoJSON files.

The source files are intentionally not copied into the app. Pass the directory
containing departments.geojson, communes.geojson, arrondissements.geojson and
localities.geojson; the output contains names and hierarchy only.
"""

import argparse
import collections
import json
import re
import unicodedata
from pathlib import Path


def normalize(value: object) -> str:
    value = "".join(
        character
        for character in unicodedata.normalize("NFKD", str(value).strip()).casefold()
        if not unicodedata.combining(character)
    )
    return " ".join(value.replace("’", "'").split())


def slug(value: str) -> str:
    return re.sub(r"[^a-z0-9]+", "-", normalize(value)).strip("-")


def display_label(value: object) -> str:
    value = " ".join(str(value).strip().split())
    return value.title() if value.isupper() else value


def read_features(path: Path) -> list[dict]:
    return json.loads(path.read_text(encoding="utf-8"))["features"]


def polygons(feature: dict) -> list[list[list[list[float]]]]:
    geometry = feature["geometry"]
    if geometry["type"] == "Polygon":
        return [geometry["coordinates"]]
    if geometry["type"] == "MultiPolygon":
        return geometry["coordinates"]
    return []


def shape(feature: dict) -> tuple[tuple[float, float, float, float], list]:
    geometry = polygons(feature)
    points = [point for polygon in geometry for ring in polygon for point in ring]
    bounds = (
        min(x for x, _ in points),
        min(y for _, y in points),
        max(x for x, _ in points),
        max(y for _, y in points),
    )
    return bounds, geometry


def contains(point: tuple[float, float], ring: list[list[float]]) -> bool:
    x, y = point
    inside = False
    previous = len(ring) - 1
    for index, (current_x, current_y) in enumerate(ring):
        previous_x, previous_y = ring[previous]
        if (current_y > y) != (previous_y > y):
            crossing_x = (previous_x - current_x) * (y - current_y) / (
                previous_y - current_y
            ) + current_x
            if x < crossing_x:
                inside = not inside
        previous = index
    return inside


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("source_dir", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()

    localities = read_features(args.source_dir / "localities.geojson")
    departments = read_features(args.source_dir / "departments.geojson")
    communes = read_features(args.source_dir / "communes.geojson")
    arrondissements = read_features(args.source_dir / "arrondissements.geojson")

    source_communes: dict[str, collections.Counter] = collections.defaultdict(
        collections.Counter
    )
    source_departments: dict[str, collections.Counter] = collections.defaultdict(
        collections.Counter
    )
    for feature in localities:
        properties = feature["properties"]
        source_communes[normalize(properties["Commune"])][
            display_label(properties["Commune"])
        ] += 1
        source_departments[normalize(properties["Départeme"])][
            display_label(properties["Départeme"])
        ] += 1

    def preferred_label(labels: collections.Counter) -> str:
        return sorted(
            labels.items(), key=lambda item: (-item[1], item[0].isupper(), item[0])
        )[0][0]

    # The IGN layers use a few different spellings for the same commune.
    aliases = {
        "adjara": "adjarra",
        "boukoumbe": "boukombe",
        "djakotome": "djakotomey",
        "djoudjou": "djougou",
        "dogbo-tota": "dogbo",
        "klouekanme": "kloukanmey",
        "pehunco": "ouassa-pehunco",
        "zogbodome": "zogbodomey",
        "toucoutouna": "toukountouna",
        "seme-kpodji": "seme-podji",
        "dassa": "dassa-zoume",
        "tchaorou": "tchaourou",
    }
    source_commune_for_ign: dict[str, str] = {}
    for feature in communes:
        ign_name = normalize(feature["properties"]["NAME1_"])
        source_name = ign_name if ign_name in source_communes else aliases.get(ign_name)
        if source_name not in source_communes:
            raise ValueError(f"Commune IGN non rapprochée : {ign_name}")
        source_commune_for_ign[ign_name] = source_name
    if len(set(source_commune_for_ign.values())) != 77:
        raise ValueError("Le rapprochement ne couvre pas les 77 communes")

    department_labels = {
        normalize(feature["properties"]["NAME1_"]): display_label(
            feature["properties"]["NAME1_"]
        )
        for feature in departments
    }
    admin_arrondissements = []
    for feature in arrondissements:
        properties = feature["properties"]
        commune_name = normalize(properties["COMMUNE"])
        source_commune = (
            commune_name
            if commune_name in source_communes
            else aliases.get(commune_name)
        )
        if source_commune not in source_communes:
            raise ValueError(f"Commune d'arrondissement non rapprochée : {properties}")
        bounds, geometry = shape(feature)
        admin_arrondissements.append(
            {
                "properties": properties,
                "department": normalize(properties["DEPARTEMEN"]),
                "commune": source_commune,
                "bounds": bounds,
                "geometry": geometry,
            }
        )

    nodes: list[dict] = []
    node_keys: set[str] = set()

    def add_node(level: str, name: str, parent: str | None) -> str:
        name = " ".join(name.strip().split())
        name_slug = slug(name)
        key = f"{parent}/{level}:{name_slug}" if parent else f"{level}:{name_slug}"
        if key not in node_keys:
            node_keys.add(key)
            nodes.append(
                {
                    "key": key,
                    "parentKey": parent,
                    "level": level,
                    "name": name,
                    "slug": name_slug,
                }
            )
        return key

    department_keys = {
        name: add_node(
            "DEPARTMENT", department_labels.get(name, preferred_label(labels)), None
        )
        for name, labels in source_departments.items()
    }
    commune_keys: dict[str, str] = {}
    for feature in communes:
        ign_name = normalize(feature["properties"]["NAME1_"])
        source_name = source_commune_for_ign[ign_name]
        if source_name in commune_keys:
            continue
        parent_names = {
            normalize(item["properties"]["Départeme"])
            for item in localities
            if normalize(item["properties"]["Commune"]) == source_name
        }
        if len(parent_names) != 1:
            raise ValueError(f"Rattachement département ambigu : {source_name}")
        commune_keys[source_name] = add_node(
            "COMMUNE",
            preferred_label(source_communes[source_name]),
            department_keys[next(iter(parent_names))],
        )

    arrondissement_keys: set[str] = set()
    for item in admin_arrondissements:
        parent = commune_keys[item["commune"]]
        name = display_label(item["properties"]["ARRONDISSE"])
        key = f"{parent}/ARRONDISSEMENT:{slug(name)}"
        if key in arrondissement_keys:
            raise ValueError(f"Arrondissement en double : {item['properties']}")
        arrondissement_keys.add(key)
        nodes.append(
            {
                "key": key,
                "parentKey": parent,
                "level": "ARRONDISSEMENT",
                "name": name,
                "slug": slug(name),
            }
        )

    unverified_arrondissement = 0
    seen_localities: set[str] = set()
    for feature in localities:
        properties = feature["properties"]
        source_commune = normalize(properties["Commune"])
        candidates = []
        longitude, latitude = properties.get("Longitude"), properties.get("Latitude")
        if isinstance(longitude, (int, float)) and isinstance(latitude, (int, float)):
            for item in admin_arrondissements:
                left, bottom, right, top = item["bounds"]
                if not (left <= longitude <= right and bottom <= latitude <= top):
                    continue
                point = (longitude, latitude)
                for polygon in item["geometry"]:
                    if contains(point, polygon[0]) and not any(
                        contains(point, hole) for hole in polygon[1:]
                    ):
                        candidates.append(item)
                        break

        selected = candidates[0] if len(candidates) == 1 else None
        if len(candidates) > 1:
            source_arrondissement = normalize(properties.get("Arrondisst", ""))
            selected = next(
                (
                    item
                    for item in candidates
                    if normalize(item["properties"]["ARRONDISSE"])
                    == source_arrondissement
                ),
                None,
            )

        if selected:
            parent = (
                commune_keys[selected["commune"]]
                + "/ARRONDISSEMENT:"
                + slug(display_label(selected["properties"]["ARRONDISSE"]))
            )
        else:
            # The place stays searchable under its commune; we do not guess its arrondissement.
            parent = commune_keys[source_commune]
            unverified_arrondissement += 1

        name = " ".join(str(properties.get("Nom_LOC") or "").strip().split())
        if not name:
            continue
        key = f"{parent}/NEIGHBORHOOD:{slug(name)}"
        if key not in seen_localities:
            seen_localities.add(key)
            nodes.append(
                {
                    "key": key,
                    "parentKey": parent,
                    "level": "NEIGHBORHOOD",
                    "name": name,
                    "slug": slug(name),
                }
            )

    order = {"DEPARTMENT": 0, "COMMUNE": 1, "ARRONDISSEMENT": 2, "NEIGHBORHOOD": 3}
    nodes.sort(key=lambda node: (order[node["level"]], node["key"]))
    counts = collections.Counter(node["level"] for node in nodes)
    if counts["DEPARTMENT"] != 12 or counts["COMMUNE"] != 77 or counts["ARRONDISSEMENT"] != 546:
        raise ValueError(f"Comptages administratifs inattendus : {dict(counts)}")

    manifest = {
        "source": "Institut Géographique National du Bénin",
        "dataset": "Localités et chefs-lieux de village; Limites des arrondissements; Limites communales; Limites départementales",
        "sourceUpdated": "2026-09-20",
        "license": "Licence Ouverte / Open Licence 2.0 (Etalab)",
        "attribution": "Source : IGN Bénin, catalogue national de données géographiques (ign.bj/donnees).",
        "localitiesWithoutVerifiedArrondissement": unverified_arrondissement,
        "counts": dict(counts),
        "nodes": nodes,
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(
        json.dumps(manifest, ensure_ascii=False, separators=(",", ":")) + "\n",
        encoding="utf-8",
    )
    print(
        json.dumps(
            {
                "counts": dict(counts),
                "localitiesWithoutVerifiedArrondissement": unverified_arrondissement,
                "output": str(args.output),
            },
            ensure_ascii=False,
        )
    )


if __name__ == "__main__":
    main()
