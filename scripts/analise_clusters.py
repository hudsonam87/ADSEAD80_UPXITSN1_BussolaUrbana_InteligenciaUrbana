"""
Bússola Urbana — pipeline de análise
Sorocaba/SP, dados reais SSP-SP (jan-jun/2026)

Entrada: CSV de ocorrências (furto, roubo, tráfico) baixado do portal de
dados abertos da SSP-SP.

Saída: clusters_index.json — áreas de atenção identificadas, com índice
explicável e recomendação por regra.

Fonte dos dados: https://www.ssp.sp.gov.br/estatistica/consultas
"""

import pandas as pd
import numpy as np
import json
from sklearn.cluster import DBSCAN

CSV_PATH = "SSP_Dados_Criminais_2026.csv"
OUTPUT_PATH = "clusters_index.json"


def parse_coord(x):
    """Converte coordenada em formato brasileiro (vírgula decimal) para float."""
    try:
        if pd.isna(x) or x in ("0", "-", "NULL", ""):
            return None
        return float(str(x).replace(",", "."))
    except Exception:
        return None


def faixa_horario(periodo):
    return {
        "De madrugada": "0h–6h",
        "Pela manhã": "6h–12h",
        "A tarde": "12h–18h",
        "A noite": "18h–24h",
    }.get(periodo, periodo)


def recomendacao(indice, periodo_pico, pct_hora_incerta):
    """Recomendação gerada por regra condicional transparente — não é modelo de IA."""
    if periodo_pico == "não disponível":
        return "Volume relevante, mas sem horário confiável no boletim."
    fx = faixa_horario(periodo_pico).lower()
    if indice >= 70:
        base = f"Recomenda-se avaliar reforço preventivo no período {fx}."
    elif indice >= 45:
        base = f"Área com concentração moderada — monitorar, especialmente {fx}."
    else:
        base = "Concentração dentro da faixa comum da região."
    if pct_hora_incerta >= 20:
        base += f" ({pct_hora_incerta:.0f}% dos casos sem horário preciso.)"
    return base


def main():
    df = pd.read_csv(CSV_PATH, encoding="utf-8")

    df["lat"] = df["LATITUDE"].apply(parse_coord)
    df["lon"] = df["LONGITUDE"].apply(parse_coord)

    # Recorte validado com o grupo: furto, roubo e tráfico (inclui furto/roubo de carga)
    mask = df["NATUREZA_APURADA"].str.contains("FURTO|ROUBO|TR[AÁ]FICO", na=False, regex=True)
    valid = df[
        mask & df["lat"].notna() & df["lon"].notna()
        & df["lat"].between(-23.65, -23.35) & df["lon"].between(-47.60, -47.30)
    ].copy()

    # Projeção local em km, para o DBSCAN trabalhar com distância real
    lat_avg = valid["lat"].mean()
    cos_lat = np.cos(np.radians(lat_avg))
    valid["wx"] = valid["lon"] * (111.320 * cos_lat)
    valid["wy"] = valid["lat"] * 110.574

    # Clustering espacial: eps=250m, mínimo de 20 ocorrências por área
    db = DBSCAN(eps=0.25, min_samples=20).fit(valid[["wx", "wy"]].values)
    valid["cluster"] = db.labels_

    clusters = []
    for c in sorted(set(db.labels_)):
        if c == -1:
            continue  # ruído: sem concentração espacial suficiente
        g = valid[valid["cluster"] == c]
        n = len(g)

        # "Em hora incerta" nunca vira horário de pico — ver metodologia
        g_conhecido = g[g["DESC_PERIODO"] != "Em hora incerta"]
        if len(g_conhecido) > 0:
            per_counts = g_conhecido["DESC_PERIODO"].value_counts()
            periodo_pico = per_counts.idxmax()
            concentracao_pico = per_counts.max() / len(g_conhecido)
            pct_hora_incerta = round((n - len(g_conhecido)) / n * 100, 1)
        else:
            periodo_pico, concentracao_pico, pct_hora_incerta = "não disponível", 0, 100.0

        clusters.append({
            "id": int(c),
            "bairro": g["BAIRRO"].value_counts().idxmax() if g["BAIRRO"].notna().any() else "não informado",
            "n": n,
            "periodo_pico": periodo_pico,
            "faixa_horario": faixa_horario(periodo_pico),
            "concentracao_pico": round(concentracao_pico * 100, 1),
            "pct_hora_incerta": pct_hora_incerta,
            "lat": round(g["lat"].mean(), 6),
            "lon": round(g["lon"].mean(), 6),
        })

    # Índice de atenção: 50% percentil de volume + 50% percentil de concentração temporal
    ns = [c["n"] for c in clusters]
    concs = [c["concentracao_pico"] for c in clusters]
    for c in clusters:
        pct_vol = sum(1 for v in ns if v <= c["n"]) / len(ns)
        pct_conc = sum(1 for v in concs if v <= c["concentracao_pico"]) / len(concs)
        c["score_volume"] = round(pct_vol * 50)
        c["score_temporal"] = round(pct_conc * 50)
        c["indice"] = c["score_volume"] + c["score_temporal"]
        c["recomendacao"] = recomendacao(c["indice"], c["periodo_pico"], c["pct_hora_incerta"])

    clusters.sort(key=lambda c: -c["indice"])

    with open(OUTPUT_PATH, "w", encoding="utf-8") as f:
        json.dump(clusters, f, ensure_ascii=False, indent=2)

    print(f"{len(clusters)} áreas de atenção identificadas → {OUTPUT_PATH}")


if __name__ == "__main__":
    main()
