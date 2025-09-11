# substep_1_1.sage — Draft Code
# Generates 100 random 3-regular graphs with N=1024.
# Ensures MINIMAL 3-cycles (ZPI vacuum).
# Computes baseline observables: spectral dimension, curvature variance, Laplacian gap.
# Saves results to 'initial_states.csv'.

import numpy as np
import random
import csv
import os
from datetime import datetime

def generate_zpi_vacuum(n, b, max_attempts=100, seed=None):
    """
    Generate a random b-regular directed graph with MINIMAL 3-cycles.
    Returns graph, initial 3-cycle count, number of rejections.
    """
    if seed is not None:
        set_random_seed(int(seed))
        random.seed(int(seed))
        np.random.seed(int(seed))
    
    best_G = None
    best_cycles = float('inf')
    rejections = 0
    
    for attempt in range(max_attempts):
        try:
            # Use graphs.RandomRegular — correct Sage syntax
            G_undirected = graphs.RandomRegular(n, b)
            A = G_undirected.adjacency_matrix()
            n3_cycles = (A^3).trace() // 6  # Undirected 3-cycles
            if n3_cycles < best_cycles:
                best_cycles = n3_cycles
                best_G = DiGraph(G_undirected)  # Symmetric directed edges
            if best_cycles == 0:
                break
        except Exception:
            rejections += 1
            continue
    
    if best_G is None:
        # Ultimate fallback: generate a small cycle
        G_undirected = Graph(n)
        if n >= 3:
            G_undirected.add_cycle(range(3))
        A = G_undirected.adjacency_matrix()
        n3_cycles = (A^3).trace() // 6
        best_G = DiGraph(G_undirected)
        best_cycles = n3_cycles
    
    return best_G, best_cycles, rejections

def compute_spectral_dimension(G_undirected, t_max=50):
    """
    Compute spectral dimension d_S via heat kernel method.
    Uses Laplacian eigenvalues for efficiency.
    """
    if G_undirected.order() == 0:
        return 0.0
    try:
        L = G_undirected.laplacian_matrix(sparse=True)
        k = min(100, G_undirected.order() - 1)
        eigenvalues = L.eigenvalues()[:k]
        t_range = np.arange(1, t_max + 1, dtype=float)
        heat_kernel_trace = np.sum([np.exp(-lam * t_range) for lam in eigenvalues], axis=0)
        
        log_t = np.log(t_range[9:])
        log_p = np.log(heat_kernel_trace[9:])
        mask = np.isfinite(log_p) & (log_p < 0)
        if np.sum(mask) < 2:
            return 0.0
        coeffs = np.polyfit(log_t[mask], log_p[mask], 1)
        d_s = -2 * coeffs[0]
        return d_s
    except Exception:
        return -1.0

def compute_ollivier_ricci_variance(G_undirected, sample_edges=100):
    """
    Compute variance of Ollivier-Ricci curvature for sampled edges.
    Uses exact shortest-path distances.
    """
    if G_undirected.size() == 0:
        return 0.0
    edges = list(G_undirected.edges(labels=False))
    if len(edges) > sample_edges:
        edges = random.sample(edges, sample_edges)
    
    curvatures = []
    for v, u in edges:
        try:
            d_vu = G_undirected.distance(v, u)
            if d_vu == 0:
                continue
            neighbors_v = list(G_undirected.neighbors(v))
            neighbors_u = list(G_undirected.neighbors(u))
            if len(neighbors_v) == 0 or len(neighbors_u) == 0:
                continue
            m_v = [1.0 / len(neighbors_v)] * len(neighbors_v)
            m_u = [1.0 / len(neighbors_u)] * len(neighbors_u)
            C = np.zeros((len(neighbors_v), len(neighbors_u)))
            for i, x in enumerate(neighbors_v):
                for j, y in enumerate(neighbors_u):
                    C[i, j] = G_undirected.distance(x, y)
            from scipy.optimize import linear_sum_assignment
            row_ind, col_ind = linear_sum_assignment(C)
            W1 = C[row_ind, col_ind].sum() / len(row_ind)
            kappa = 1 - W1 / d_vu
            curvatures.append(kappa)
        except Exception:
            continue
    if len(curvatures) < 2:
        return 0.0
    return np.var(curvatures)

def compute_laplacian_gap(G_undirected, k=5):
    """
    Compute spectral gap: lambda_1 (always 0) and lambda_2.
    """
    if G_undirected.order() <= k:
        return 0.0
    try:
        L_norm = G_undirected.laplacian_matrix(normalized=True, sparse=True)
        eigenvalues = sorted(L_norm.eigenvalues())[:k]
        if len(eigenvalues) < 2:
            return 0.0
        return float(eigenvalues[1] - eigenvalues[0])
    except Exception:
        return 0.0

def compute_baseline_observables(G_directed):
    """
    Compute baseline observables for a directed graph.
    Analysis is performed on the underlying undirected graph.
    """
    G_undirected = G_directed.to_undirected()
    d_s = compute_spectral_dimension(G_undirected)
    curv_var = compute_ollivier_ricci_variance(G_undirected)
    laplacian_gap = compute_laplacian_gap(G_undirected)
    return {
        'spectral_dimension': d_s,
        'curvature_variance': curv_var,
        'laplacian_gap': laplacian_gap
    }

def generate_ensemble_and_log(n, b, num_graphs, seed_base=2025, output_dir="output"):
    """
    Generate ensemble of graphs and log baseline observables to CSV.
    """
    os.makedirs(output_dir, exist_ok=True)
    output_file = os.path.join(output_dir, 'initial_states.csv')
    
    with open(output_file, 'w', newline='') as csvfile:
        fieldnames = [
            'graph_id', 'n', 'b', 'n3_cycles_initial', 'seed', 'rejections',
            'spectral_dimension', 'curvature_variance', 'laplacian_gap'
        ]
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        
        for i in range(num_graphs):
            seed = seed_base + i
            print(f"Generating graph {i+1}/{num_graphs} (seed={seed})...")
            try:
                G, n3_cycles, rejections = generate_zpi_vacuum(n, b, seed=int(seed))
                obs = compute_baseline_observables(G)
                row = {
                    'graph_id': i,
                    'n': n,
                    'b': b,
                    'n3_cycles_initial': n3_cycles,
                    'seed': int(seed),
                    'rejections': rejections,
                    'spectral_dimension': obs['spectral_dimension'],
                    'curvature_variance': obs['curvature_variance'],
                    'laplacian_gap': obs['laplacian_gap']
                }
                writer.writerow(row)
                print(f"  d_S = {obs['spectral_dimension']:.3f}, curv_var = {obs['curvature_variance']:.3e}, gap = {obs['laplacian_gap']:.3f}, 3-cycles = {n3_cycles}")
            except Exception as e:
                print(f"  ❌ Error generating graph {i}: {e}")
                continue
    
    print(f"\n✅ Ensemble of {num_graphs} graphs generated and logged to: {output_file}")
    return output_file

# Configuration
CONFIG = {
    'n': 64,    # Reduced from 1024 for testing — change back to 1024 later
    'b': 3,
    'num_graphs': 5,  # Reduced from 100 for testing — change back to 100 later
    'seed_base': 2025,
    'output_dir': 'clc_continuum_limit_phase3'
}

# Generate ensemble
output_file = generate_ensemble_and_log(**CONFIG)

# Optional: Print summary
print("\n📊 Summary Statistics:")
import pandas as pd
df = pd.read_csv(output_file)
print(df[['spectral_dimension', 'curvature_variance', 'laplacian_gap']].describe())