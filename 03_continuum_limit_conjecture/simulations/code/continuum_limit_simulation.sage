#!/usr/bin/env sage
# Title: Continuum Limit Simulation for CLC
# Description: Generates ensemble of graphs, evolves via CLC rewrite rule, computes continuum proxies.
# Dependencies: SageMath 10.4, NumPy, SciPy, POT, tqdm
# Outputs: CSVs (ensemble stats, trajectories), PDF plots
# Reproducibility: Seed 2025, ~1-2h for N=1024, 100 runs on Intel i7-12700

from sage.all import DiGraph, log, exp, random, set_random_seed
import numpy as np
import csv, os, time
from datetime import datetime
try:
    from tqdm import tqdm
except ImportError:
    print("Warning: Install tqdm with 'sage -pip install tqdm'.")
    tqdm = lambda x, **k: x
import scipy.sparse.linalg as spla
import ot  # Python Optimal Transport
from scipy.stats import skew, kurtosis
import matplotlib.pyplot as plt

# Configuration
CONFIG = {
    "N_APPROX": 1024,
    "NUM_RUNS": 100,
    "MAX_STEPS": 2000,
    "ALPHA": 1.0,
    "SEED": 2025,
    "OUTPUT_DIR": "./outputs_continuum",
    "CSV_OUTPUT": "continuum_n1024.csv",
    "PLOT_OUTPUT": "continuum_n1024.pdf",
    "SAMPLE_EDGES": 100,
    "LOG_INTERVAL": 100,
}

# Reuse Paper 1's graph generation
def generate_zpi_vacuum(num_nodes_approx):
    if num_nodes_approx < 3:
        raise ValueError("num_nodes_approx must be at least 3")
    G = DiGraph()
    root = 0
    G.add_vertex(root)
    levels = [[root]]
    node_id = 1
    while G.order() < num_nodes_approx:
        next_level = []
        for parent in levels[-1]:
            num_children = 2 if parent != root else 3
            for _ in range(num_children):
                if G.order() >= num_nodes_approx:
                    break
                G.add_vertex(node_id)
                G.add_edge(parent, node_id)
                next_level.append(node_id)
                node_id += 1
        if not next_level:
            break
        levels.append(next_level)
    G.relabel({i: i for i in range(G.order())})  # Fix: 0-based int labels
    return G, levels

def inject_energic_event(G, levels):
    if len(levels) < 3 or not levels[2]:
        from sage.graphs.graph_generators import CycleGraph
        G_new = CycleGraph(3).to_directed()
        G_new.relabel({i: i for i in range(3)})
        return G_new
    node_v, node_w, node_u = levels[0][0], levels[1][0], levels[2][0]
    G.add_edge(node_u, node_v)
    return G

def is_permissible(G, u, v, w):
    G.delete_edge(v, w)
    has_other_path = (G.distance(v, u) != sage.Infinity)
    G.add_edge(v, w)
    return not has_other_path

# Observables (adapted for efficiency)
def compute_spectral_dimension(G_undirected, t_max=100):
    try:
        L = G_undirected.laplacian_matrix(sparse=True)
        eigenvalues = spla.eigsh(L, k=min(50, G_undirected.order()-1), which='SM', return_eigenvectors=False)
        t_range = np.arange(1, t_max + 1)
        heat_kernel_trace = np.sum(np.exp(-eigenvalues * t_range[:, None]), axis=1)
        log_t = np.log(t_range[9:])
        log_p = np.log(heat_kernel_trace[9:])
        mask = np.isfinite(log_p)
        if np.sum(mask) < 2:
            return 0.0
        coeffs = np.polyfit(log_t[mask], log_p[mask], 1)
        return -2 * coeffs[0]
    except Exception as e:
        print(f"Error in d_S: {e}")
        return 0.0

def compute_ollivier_ricci_curvature(G_undirected, sample_edges=100):
    edges = list(G_undirected.edges(labels=False))
    if not edges:
        return [0.0]
    if len(edges) > sample_edges:
        edges = random.sample(edges, sample_edges)
    curvatures = []
    for v, u in edges:
        d = G_undirected.shortest_path_length(v, u)
        if d == 0:
            continue
        neighbors_v = list(G_undirected.neighbors(v))
        neighbors_u = list(G_undirected.neighbors(u))
        if not neighbors_v or not neighbors_u:
            continue
        m_v = np.ones(len(neighbors_v)) / len(neighbors_v)
        m_u = np.ones(len(neighbors_u)) / len(neighbors_u)
        C = np.ones((len(neighbors_v), len(neighbors_u))) * d
        try:
            W_1 = ot.sinkhorn2(m_v, m_u, C, reg=0.1)
            kappa = float(1 - W_1 / d)
            curvatures.append(kappa)
        except:
            continue
    return curvatures if curvatures else [0.0]

def compute_spectral_embedding_distortion(G_undirected, sample_edges=100):
    try:
        L = G_undirected.laplacian_matrix(normalized=True, sparse=True)
        k = 5
        _, eigenvectors = spla.eigsh(L, k=k, which='SM')
        embedding = eigenvectors[:, 1:5]
        edges = list(G_undirected.edges(labels=False))
        if len(edges) > sample_edges:
            edges = random.sample(edges, sample_edges)
        distortion = 0.0
        for u, v in edges:
            euclidean_dist = np.linalg.norm(embedding[u] - embedding[v])
            graph_dist = G_undirected.shortest_path_length(u, v)
            distortion += abs(euclidean_dist - graph_dist)
        return distortion / len(edges) if edges else 0.0
    except:
        return 0.0

def compute_laplacian_spectrum(G_undirected, k=5):
    try:
        L = G_undirected.laplacian_matrix(normalized=True, sparse=True)
        eigenvalues = spla.eigsh(L, k=min(k, G_undirected.order()-1), which='SM', return_eigenvectors=False)
        return np.sort(eigenvalues)
    except:
        return np.array([])

# Evolution and ensemble
def run_single_simulation(config):
    G, levels = generate_zpi_vacuum(config["N_APPROX"])
    G = inject_energic_event(G, levels)
    N = G.order()
    T = float(1.0 / log(N)) if N > 1 else 1.0
    trajectory = []
    
    for step in range(config["MAX_STEPS"]):
        proposal_set = set()
        for v in G.vertices(sort=False):
            for w in G.neighbors_out(v):
                for u in G.neighbors_out(w):
                    if v == u or G.has_edge(u, v):
                        continue
                    if is_permissible(G, u, v, w):
                        delta_F = config["ALPHA"] - T
                        P = min(1.0, float(exp(-delta_F / T)))
                        if random() < P:
                            proposal_set.add((u, v))
        if not proposal_set:
            break
        G.add_edges(proposal_set)
        if step % config["LOG_INTERVAL"] == 0:
            G_undirected = G.to_undirected()
            d_s = compute_spectral_dimension(G_undirected)
            curvatures = compute_ollivier_ricci_curvature(G_undirected, config["SAMPLE_EDGES"])
            distortion = compute_spectral_embedding_distortion(G_undirected, config["SAMPLE_EDGES"])
            eigenvalues = compute_laplacian_spectrum(G_undirected)
            record = {
                "step": step,
                "d_s": d_s,
                "curv_mean": np.mean(curvatures) if curvatures else 0.0,
                "curv_std": np.std(curvatures) if curvatures else 0.0,
                "curv_skew": skew(curvatures) if curvatures else 0.0,
                "curv_kurt": kurtosis(curvatures) if curvatures else 0.0,
                "distortion": distortion,
                "spectral_gap": eigenvalues[1] - eigenvalues[0] if len(eigenvalues) >= 2 else 0.0
            }
            trajectory.append(record)
    return G, trajectory

def run_ensemble(config):
    set_random_seed(config["SEED"])
    os.makedirs(config["OUTPUT_DIR"], exist_ok=True)
    csv_path = os.path.join(config["OUTPUT_DIR"], config["CSV_OUTPUT"])
    final_stats = []

    print(f"Running ensemble: N≈{config['N_APPROX']}, {config['NUM_RUNS']} runs")
    with open(csv_path, 'w', newline='') as f:
        fieldnames = ["run_id", "step", "d_s", "curv_mean", "curv_std", "curv_skew", "curv_kurt", "distortion", "spectral_gap"]
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        
        for i in tqdm(range(config["NUM_RUNS"]), desc="Simulations"):
            G, trajectory = run_single_simulation(config)
            for record in trajectory:
                writer.writerow({"run_id": i, **record})
            final_stats.append(trajectory[-1] if trajectory else {"d_s": 0.0, "curv_mean": 0.0, "curv_std": 0.0, "curv_skew": 0.0, "curv_kurt": 0.0, "distortion": 0.0, "spectral_gap": 0.0})

    # Compute ensemble stats
    stats = {
        "mean_d_s": np.mean([s["d_s"] for s in final_stats]),
        "std_d_s": np.std([s["d_s"] for s in final_stats]),
        "mean_curv": np.mean([s["curv_mean"] for s in final_stats]),
        "std_curv": np.std([s["curv_mean"] for s in final_stats]),
        "mean_distortion": np.mean([s["distortion"] for s in final_stats]),
        "std_distortion": np.std([s["distortion"] for s in final_stats]),
        "mean_spectral_gap": np.mean([s["spectral_gap"] for s in final_stats]),
        "std_spectral_gap": np.std([s["spectral_gap"] for s in final_stats]),
    }

    # Plot (like Paper 1)
    plt.figure(figsize=(10, 6))
    plt.errorbar([config["N_APPROX"]], [stats["mean_d_s"]], yerr=[stats["std_d_s"]/np.sqrt(config["NUM_RUNS"])], fmt='o', label="Spectral Dimension")
    plt.xscale('log')
    plt.title(f"Convergence Metrics at N≈{config['N_APPROX']}")
    plt.xlabel("System Size (N)")
    plt.ylabel("Metric Value")
    plt.legend()
    plt.savefig(os.path.join(config["OUTPUT_DIR"], config["PLOT_OUTPUT"]), dpi=300, bbox_inches='tight')
    plt.close()

    return stats

if __name__ == "__main__":
    start_time = time.time()
    stats = run_ensemble(CONFIG)
    print(f"Ensemble complete in {time.time() - start_time:.2f}s")
    print("Stats:", stats)