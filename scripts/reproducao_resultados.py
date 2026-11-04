"""Reproduz, a partir de dados/ocorrencias_4279.csv, os numeros do artigo que nao dependem do arquivo bruto da SSP.

Nao reproduz o Indice de Atencao (precisa da coluna de periodo do arquivo bruto).
Uso: python scripts/reproducao_resultados.py
"""
import numpy as np, pandas as pd
from sklearn.cluster import DBSCAN
from scipy.spatial import cKDTree

d = pd.read_csv("dados/ocorrencias_4279.csv")
d["dt"] = pd.to_datetime(d.data_hora)
lat0 = np.radians(d.latitude.mean())
d["X"] = d.latitude * 111320                      # projecao local aproximada, em metros
d["Y"] = d.longitude * 111320 * np.cos(lat0)

def areas(df, eps=250, ms=20):
    lab = DBSCAN(eps=eps, min_samples=ms).fit_predict(df[["X", "Y"]].values)
    return lab, len(set(lab) - {-1}), int((lab >= 0).sum())

print("Registros:", len(d), "| com data do fato anterior a 2026:", int((d.dt < "2026-01-01").sum()))
lab, n, dentro = areas(d)
print(f"Base principal (4.279): {n} areas, {dentro} dentro ({dentro/len(d):.1%})")
x = d[d.dt >= "2026-01-01"]
lab2, n2, dentro2 = areas(x)
print(f"Complementar ({len(x)} datadas em jan-jun/2026): {n2} areas, {dentro2} dentro ({dentro2/len(x):.1%})")

tr = x[x.dt < "2026-04-01"]; te = x[x.dt >= "2026-04-01"]
Xt, Xe = tr[["X", "Y"]].values, te[["X", "Y"]].values
labt = DBSCAN(eps=250, min_samples=10).fit_predict(Xt)
c = Xt[labt >= 0]
dd, _ = cKDTree(c).query(Xe, distance_upper_bound=250)
print(f"Backtest: treino {len(tr)}, teste {len(te)}, {len(set(labt)-{-1})} areas, "
      f"treino dentro {(labt>=0).sum()} ({(labt>=0).mean():.1%}), teste dentro {np.isfinite(dd).sum()} ({np.isfinite(dd).mean():.1%})")

# baseline por densidade: celulas de 50 m mais densas do treino, ate cobrir a mesma area das areas do DBSCAN
step = 50
xs = np.arange(x.X.min(), x.X.max(), step); ys = np.arange(x.Y.min(), x.Y.max(), step)
G = np.array(np.meshgrid(xs, ys)).reshape(2, -1).T
gt = cKDTree(G)
A = len(set(np.concatenate(gt.query_ball_point(c, 250))))
dens = np.array([len(v) for v in cKDTree(Xt).query_ball_point(G, 250)])
order = np.argsort(-dens)[:20000]
cov, chosen = set(), []
for k, idx in zip(order, gt.query_ball_point(G[order], 250)):
    if len(set(idx) - cov) < 0.5 * len(idx):       # regra simples para evitar sobreposicao grande
        continue
    chosen.append(k); cov |= set(idx)
    if len(cov) >= A: break
d3, _ = cKDTree(G[chosen]).query(Xe, distance_upper_bound=250)
print(f"Area das areas DBSCAN: {A*step*step/1e6:.1f} km2 | baseline por densidade: {np.isfinite(d3).mean():.1%} das ocorrencias do teste")
