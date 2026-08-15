#!/usr/bin/env python3
"""Generate Pulse screen/flow/SQL dependency documentation from exported sources."""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import re
from collections import defaultdict
from pathlib import Path


BASELINE = "baseline_pulse_1_0_0_5.zip"
ANALYSED_ON = "2026-08-15"


def slug(value: str) -> str:
    value = re.sub(r"[^A-Za-z0-9._-]+", "-", value.strip())
    return value.strip("-") or "unnamed"


def md_list(values: list[str]) -> str:
    return "\n".join(f"- `{v}`" for v in values) if values else "- Ninguno observado."


def walk(obj):
    if isinstance(obj, dict):
        yield obj
        for value in obj.values():
            yield from walk(value)
    elif isinstance(obj, list):
        for value in obj:
            yield from walk(value)


def write(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content.rstrip() + "\n", encoding="utf-8")


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--app-src", required=True, type=Path)
    parser.add_argument("--workflows", required=True, type=Path)
    parser.add_argument("--schema-csv", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    out = args.output

    with args.schema_csv.open(encoding="utf-8-sig", newline="") as handle:
        sql_rows = list(csv.DictReader(handle))

    tables = {
        f"{r['SchemaName']}.{r['ObjectName']}": r
        for r in sql_rows if r["ObjectType"] == "TABLE"
    }
    procedures = {
        f"{r['SchemaName']}.{r['ObjectName']}": r
        for r in sql_rows if r["ObjectType"] == "STORED_PROCEDURE"
    }

    workflow_files = sorted(args.workflows.glob("*.json"))
    workflows = {}
    workflow_stems = {}
    for path in workflow_files:
        match = re.match(r"(.+)-[0-9A-F]{8}(?:-[0-9A-F]{4}){3}-[0-9A-F]{12}$", path.stem, re.I)
        name = match.group(1) if match else path.stem
        data = json.loads(path.read_text(encoding="utf-8-sig"))
        definition = data.get("properties", {}).get("definition", {})
        trigger_types = sorted({str(x.get("type", "Unknown")) for x in definition.get("triggers", {}).values()})
        operations = []
        connectors = set()
        called_procedures = set()
        queries = []
        for item in walk(definition.get("actions", {})):
            host = item.get("inputs", {}).get("host", {}) if isinstance(item.get("inputs"), dict) else {}
            operation = host.get("operationId")
            api = host.get("apiId")
            if operation:
                operations.append(str(operation))
            if api:
                connectors.add(str(api).split("/")[-1])
            params = item.get("inputs", {}).get("parameters", {}) if isinstance(item.get("inputs"), dict) else {}
            if isinstance(params, dict):
                proc = params.get("procedure")
                if isinstance(proc, str):
                    called_procedures.add(proc.replace("[", "").replace("]", ""))
                for key, value in params.items():
                    if "query" in key.lower() and isinstance(value, str):
                        queries.append(value)
        workflows[name] = {
            "name": name,
            "file": path.name,
            "triggers": trigger_types,
            "operations": sorted(set(operations)),
            "connectors": sorted(connectors),
            "procedures": sorted(called_procedures),
            "queries": sorted(set(queries)),
            "hash": hashlib.sha256(path.read_bytes()).hexdigest(),
        }
        workflow_stems[name.lower()] = name

    screens = {}
    components = {}
    apps = {}
    flow_consumers = defaultdict(set)
    navigation_in = defaultdict(set)
    unresolved_screen_flows = set()
    canvas_paths = sorted(args.app_src.glob("*.pa.yaml")) + sorted((args.app_src / "Components").glob("*.pa.yaml"))
    for path in canvas_paths:
        if path.name == "_EditorState.pa.yaml":
            continue
        text = path.read_text(encoding="utf-8-sig")
        root_match = re.search(r"^\s{2}([^:#\n]+):\s*$", text, re.M)
        name = root_match.group(1).strip() if root_match else path.stem.replace(".pa", "")
        flow_calls_raw = sorted(set(re.findall(r"\b([A-Za-z_][A-Za-z0-9_]*)\.Run\s*\(", text)))
        flow_calls = []
        for called in flow_calls_raw:
            canonical = workflow_stems.get(called.lower(), called)
            flow_calls.append(canonical)
            consumer_type = "component" if path.parent.name == "Components" else ("app" if path.name == "App.pa.yaml" else "screen")
            flow_consumers[canonical].add(f"{consumer_type}:{name}")
            if canonical not in workflows:
                unresolved_screen_flows.add(canonical)
        navigates = sorted(set(re.findall(r"\bNavigate\s*\(\s*([A-Za-z_][A-Za-z0-9_]*)", text, re.I)))
        for target in navigates:
            navigation_in[target].add(name)
        controls = len(re.findall(r"^\s+- [^:#\n]+:\s*$", text, re.M))
        record = {
            "name": name,
            "file": str(path.relative_to(args.app_src)),
            "flows": sorted(flow_calls),
            "navigates": navigates,
            "controls": controls,
            "hash": hashlib.sha256(path.read_bytes()).hexdigest(),
        }
        if path.parent.name == "Components":
            components[name] = record
        elif path.name == "App.pa.yaml":
            apps[name] = record
        else:
            screens[name] = record

    table_relations = []
    procedure_tables = defaultdict(list)
    for proc_name, row in procedures.items():
        definition = row["Definition"]
        lowered = definition.lower()
        for table_name in tables:
            schema, table = table_name.split(".", 1)
            patterns = [
                f"[{schema.lower()}].[{table.lower()}]",
                f"{schema.lower()}.{table.lower()}",
            ]
            if not any(pattern in lowered for pattern in patterns):
                continue
            escaped = rf"(?:\[{re.escape(schema)}\]|{re.escape(schema)})\s*\.\s*(?:\[{re.escape(table)}\]|{re.escape(table)})"
            write_pattern = rf"(?:insert\s+into|update|delete\s+from|merge(?:\s+into)?)\s+{escaped}"
            relation = "WRITES" if re.search(write_pattern, definition, re.I) else "READS"
            edge = {"source": proc_name, "target": table_name, "relation": relation, "confidence": "derived"}
            table_relations.append(edge)
            procedure_tables[proc_name].append(edge)

    nodes = []
    edges = []
    for name in sorted(screens):
        nodes.append({"id": f"screen:{name}", "type": "screen", "name": name})
        for flow in screens[name]["flows"]:
            edges.append({"source": f"screen:{name}", "target": f"flow:{flow}", "relation": "CALLS", "confidence": "observed", "evidence": screens[name]["file"]})
        for target in screens[name]["navigates"]:
            edges.append({"source": f"screen:{name}", "target": f"screen:{target}", "relation": "NAVIGATES_TO", "confidence": "observed", "evidence": screens[name]["file"]})
    for node_type, collection in (("component", components), ("app", apps)):
        for name in sorted(collection):
            nodes.append({"id": f"{node_type}:{name}", "type": node_type, "name": name})
            for flow in collection[name]["flows"]:
                edges.append({"source": f"{node_type}:{name}", "target": f"flow:{flow}", "relation": "CALLS", "confidence": "observed", "evidence": collection[name]["file"]})
    for name, flow in sorted(workflows.items()):
        nodes.append({"id": f"flow:{name}", "type": "flow", "name": name})
        for proc in flow["procedures"]:
            edges.append({"source": f"flow:{name}", "target": f"sp:{proc}", "relation": "EXECUTES", "confidence": "observed", "evidence": flow["file"]})
        for connector in flow["connectors"]:
            cid = f"connector:{connector}"
            edges.append({"source": f"flow:{name}", "target": cid, "relation": "USES_CONNECTOR", "confidence": "observed", "evidence": flow["file"]})
    connectors = sorted({e["target"].split(":", 1)[1] for e in edges if e["relation"] == "USES_CONNECTOR"})
    nodes.extend({"id": f"connector:{x}", "type": "connector", "name": x} for x in connectors)
    nodes.extend({"id": f"sp:{x}", "type": "stored_procedure", "name": x} for x in sorted(procedures))
    nodes.extend({"id": f"table:{x}", "type": "table", "name": x} for x in sorted(tables))
    for edge in table_relations:
        edges.append({"source": f"sp:{edge['source']}", "target": f"table:{edge['target']}", "relation": edge["relation"], "confidence": edge["confidence"], "evidence": args.schema_csv.name})

    known_node_ids = {n["id"] for n in nodes}
    for flow in sorted(unresolved_screen_flows):
        fid = f"flow:{flow}"
        if fid not in known_node_ids:
            nodes.append({"id": fid, "type": "flow", "name": flow, "status": "REFERENCED_NOT_IN_SOLUTION"})

    known_node_ids = {n["id"] for n in nodes}
    unresolved_navigation_targets = sorted({
        edge["target"].split(":", 1)[1]
        for edge in edges
        if edge["relation"] == "NAVIGATES_TO" and edge["target"] not in known_node_ids
    })
    for name in unresolved_navigation_targets:
        nodes.append({"id": f"screen:{name}", "type": "screen", "name": name, "status": "REFERENCED_NOT_IN_EXPORT"})

    known_node_ids = {n["id"] for n in nodes}
    unresolved_procedure_references = sorted({
        edge["target"].split(":", 1)[1]
        for edge in edges
        if edge["relation"] == "EXECUTES" and edge["target"] not in known_node_ids
    })
    for name in unresolved_procedure_references:
        nodes.append({"id": f"sp:{name}", "type": "stored_procedure", "name": name, "status": "REFERENCED_NOT_IN_WARROOM_CATALOG"})

    for name, screen in sorted(screens.items()):
        content = f"""# {name}

## Evidencia

- Source: `{screen['file']}`
- Baseline: `{BASELINE}`
- Hash SHA-256: `{screen['hash']}`
- Controles detectados: {screen['controls']}

## Flows invocados

{md_list(screen['flows'])}

## Navega hacia

{md_list(screen['navigates'])}

## Navegación entrante observada

{md_list(sorted(navigation_in.get(name, set())))}

Estado: `SOURCE_INVENTORIED`. Las llamadas dinámicas no demostrables por análisis estático requieren revisión manual.
"""
        write(out / "screens" / f"{slug(name)}.md", content)

    for node_type, collection, directory in (("component", components, "components"), ("app", apps, "app")):
        for name, item in sorted(collection.items()):
            content = f"""# {name}

## Evidencia

- Tipo: `{node_type}`
- Source: `{item['file']}`
- Baseline: `{BASELINE}`
- Hash SHA-256: `{item['hash']}`
- Controles detectados: {item['controls']}

## Flows invocados

{md_list(item['flows'])}

## Navegación observada

{md_list(item['navigates'])}

Estado: `SOURCE_INVENTORIED`.
"""
            write(out / directory / f"{slug(name)}.md", content)

    for name, flow in sorted(workflows.items()):
        consumers = sorted(flow_consumers.get(name, set()))
        status = "ACTIVE_OBSERVED" if consumers else "NO_CANVAS_REFERENCE_OBSERVED"
        content = f"""# {name}

## Evidencia

- Workflow: `{flow['file']}`
- Baseline: `{BASELINE}`
- Hash SHA-256: `{flow['hash']}`
- Estado de referencia Canvas: `{status}`

## Consumidores Canvas observados

{md_list(consumers)}

## Trigger

{md_list(flow['triggers'])}

## Procedimientos ejecutados

{md_list(flow['procedures'])}

## Conectores

{md_list(flow['connectors'])}

## Operaciones

{md_list(flow['operations'])}

## Consultas SQL directas detectadas

{md_list(flow['queries'])}

`NO_CANVAS_REFERENCE_OBSERVED` no significa que el flow sea innecesario: puede ser programado, hijo, administrativo o consumido fuera de la app.
"""
        write(out / "flows" / f"{slug(name)}.md", content)

    flow_by_proc = defaultdict(list)
    for flow_name, flow in workflows.items():
        for proc in flow["procedures"]:
            flow_by_proc[proc.lower()].append(flow_name)

    for name, row in sorted(procedures.items()):
        relations = procedure_tables.get(name, [])
        reads = sorted(x["target"] for x in relations if x["relation"] == "READS")
        writes = sorted(x["target"] for x in relations if x["relation"] == "WRITES")
        content = f"""# {name}

## Evidencia

- Catálogo: `{args.schema_csv.name}`
- Hash de definición: `{row['DefinitionHash']}`
- Baseline: `{BASELINE}`

## Flows consumidores observados

{md_list(sorted(flow_by_proc.get(name.lower(), [])))}

## Tablas leídas

{md_list(reads)}

## Tablas modificadas

{md_list(writes)}

Las relaciones con tablas son análisis estático `derived`; SQL dinámico y dependencias indirectas pueden requerir revisión manual.
"""
        write(out / "sql" / "stored-procedures" / f"{slug(name)}.md", content)

    procs_by_table = defaultdict(list)
    for edge in table_relations:
        procs_by_table[edge["target"]].append((edge["source"], edge["relation"]))
    for name, row in sorted(tables.items()):
        readers = sorted(p for p, rel in procs_by_table.get(name, []) if rel == "READS")
        writers = sorted(p for p, rel in procs_by_table.get(name, []) if rel == "WRITES")
        content = f"""# {name}

## Evidencia

- Catálogo: `{args.schema_csv.name}`
- Hash de definición: `{row['DefinitionHash']}`
- Baseline: `{BASELINE}`

## Procedimientos lectores detectados

{md_list(readers)}

## Procedimientos escritores detectados

{md_list(writers)}

Cobertura basada en el catálogo del esquema `warroom`; referencias desde otros esquemas o SQL dinámico pueden no aparecer.
"""
        write(out / "sql" / "tables" / f"{slug(name)}.md", content)

    screen_rows = [(s, f) for s, info in sorted(screens.items()) for f in info["flows"]]
    flow_proc_rows = [(f, p) for f, info in sorted(workflows.items()) for p in info["procedures"]]
    nav_rows = [(s, t) for s, info in sorted(screens.items()) for t in info["navigates"]]

    def table_md(headers, rows):
        lines = ["| " + " | ".join(headers) + " |", "|" + "|".join("---" for _ in headers) + "|"]
        lines += ["| " + " | ".join(f"`{v}`" for v in row) + " |" for row in rows]
        return "\n".join(lines)

    write(out / "mappings" / "screen-to-flow.md", "# Pantalla → flow\n\n" + table_md(["Pantalla", "Flow"], screen_rows))
    write(out / "mappings" / "flow-to-procedure.md", "# Flow → procedimiento\n\n" + table_md(["Flow", "Procedimiento"], flow_proc_rows))
    write(out / "mappings" / "procedure-to-table.md", "# Procedimiento → tabla\n\n" + table_md(["Procedimiento", "Relación", "Tabla"], [(x["source"], x["relation"], x["target"]) for x in sorted(table_relations, key=lambda v: (v["source"], v["target"]))]))
    write(out / "mappings" / "screen-navigation.md", "# Navegación entre pantallas\n\n" + table_md(["Origen", "Destino"], nav_rows))

    candidates = []
    for name, flow in sorted(workflows.items()):
        if flow_consumers.get(name):
            continue
        trigger = ", ".join(flow["triggers"]) or "Unknown"
        candidates.append((name, trigger, "Sin referencia Run observada en el source Canvas exportado", "REVIEW"))
    recommendations = """# Flows sin referencia Canvas observada

Esta lista es una cola de revisión, no una lista de eliminación.

Antes de retirar un flow hay que comprobar: ejecución programada, llamadas desde otros flows, consumidores externos, administración, historial de ejecuciones y ownership. Los catálogos de disciplinas y otros catálogos funcionales conocidos se mantienen.

""" + table_md(["Flow", "Trigger", "Motivo", "Decisión"], candidates)
    write(out / "recommendations" / "flows-to-review.md", recommendations)

    runtime_map = {
        "schemaVersion": "1.1",
        "product": "Pulse",
        "baseline": {"solution": BASELINE, "analysedOn": ANALYSED_ON, "coverage": "STATIC_FULL_EXPORT"},
        "summary": {
            "screens": len(screens), "components": len(components), "apps": len(apps), "flowsInSolution": len(workflows), "storedProcedures": len(procedures),
            "tables": len(tables), "connectors": len(connectors), "edges": len(edges),
            "flowsWithoutCanvasReference": len(candidates), "unresolvedScreenFlowReferences": len(unresolved_screen_flows),
            "unresolvedNavigationTargets": len(unresolved_navigation_targets),
            "unresolvedStoredProcedureReferences": len(unresolved_procedure_references),
        },
        "nodes": sorted(nodes, key=lambda x: x["id"]),
        "edges": sorted(edges, key=lambda x: (x["source"], x["relation"], x["target"])),
    }
    write(out / "generated" / "runtime-map.json", json.dumps(runtime_map, ensure_ascii=False, indent=2))
    with (out / "generated" / "runtime-map.csv").open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=["source", "target", "relation", "confidence", "evidence"])
        writer.writeheader()
        writer.writerows(runtime_map["edges"])

    summary = runtime_map["summary"]
    write(out / "README.md", f"""# Mapa de dependencias runtime de Pulse

Inventario estático completo de la solución exportada y del catálogo SQL `warroom`.

## Cobertura

| Elemento | Cantidad |
|---|---:|
| Pantallas | {summary['screens']} |
| Componentes Canvas | {summary['components']} |
| Objetos App | {summary['apps']} |
| Flows incluidos en la solución | {summary['flowsInSolution']} |
| Procedimientos almacenados | {summary['storedProcedures']} |
| Tablas | {summary['tables']} |
| Conectores | {summary['connectors']} |
| Relaciones | {summary['edges']} |
| Flows sin referencia Canvas observada | {summary['flowsWithoutCanvasReference']} |
| Referencias de pantalla no resueltas en la solución | {summary['unresolvedScreenFlowReferences']} |
| Destinos de navegación no incluidos en el export | {summary['unresolvedNavigationTargets']} |
| Procedimientos referenciados fuera del catálogo `warroom` | {summary['unresolvedStoredProcedureReferences']} |

## Cómo usarlo

- `screens/`: ficha de cada pantalla.
- `components/`: ficha de cada componente Canvas.
- `app/`: inicialización global y llamadas observadas en App.
- `flows/`: ficha de cada flow.
- `sql/stored-procedures/`: ficha de cada procedimiento.
- `sql/tables/`: ficha de cada tabla.
- `mappings/`: vistas humanas entre capas.
- `generated/runtime-map.json`: fuente principal para agentes y skills.
- `generated/runtime-map.csv`: relaciones filtrables.
- `recommendations/flows-to-review.md`: revisión manual, nunca eliminación automática.

## Límites

`STATIC_FULL_EXPORT` significa cobertura completa de los artefactos presentes en el ZIP y el catálogo, no demostración de uso en runtime. SQL dinámico, consumidores externos, child flows y llamadas construidas dinámicamente pueden requerir evidencia adicional.

El ZIP se usa como entrada temporal; no se almacena desempaquetado.
""")

    write(out / "SCHEMA.md", """# Contrato del mapa runtime

Tipos de nodo: `app`, `screen`, `component`, `flow`, `stored_procedure`, `table`, `connector`.

Relaciones: `CALLS`, `EXECUTES`, `READS`, `WRITES`, `NAVIGATES_TO`, `USES_CONNECTOR`.

Confianza:

- `observed`: aparece directamente en el source exportado.
- `derived`: se obtiene mediante análisis estático de una definición.
- `manual`: añadido y revisado por una persona.

Una ausencia de relación observada no demuestra ausencia de uso en runtime.
""")

    manifest = sorted(str(p.relative_to(out)) for p in out.rglob("*") if p.is_file())
    write(out / "generated" / "manifest.txt", "\n".join(manifest))
    print(json.dumps(summary, ensure_ascii=False))


if __name__ == "__main__":
    main()
