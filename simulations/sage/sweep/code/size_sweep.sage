#!/usr/bin/env sage
# -----------------------------------------------------------------------------
# Title:       Thermodynamic Graph Rewriting: A Category-Theoretic Model of Emergent Spacetime
# Subject:     Comparative Size Sweep
# Author:      R. Fisher
# Affiliation: Independent Researcher
# Date:        September 12, 2025
# Version:     1.0
# DOI:         [To be assigned upon publication]
# License:     MIT
# Description: 
# Dependencies: SageMath 10.4+, NumPy, tqdm (for progress bar)
# Outputs:     
# Reproducibility Checklist:
# -----------------------------------------------------------------------------

from sage.all import DiGraph, log, exp, random, set_random_seed, Infinity
import time
import csv
import os
import numpy as np
import matplotlib.pyplot as plt
try:
    from tqdm import tqdm
except ImportError:
    print("Warning: Install tqdm with 'sage -pip install tqdm' for progress bar.")
    tqdm = lambda x, **k: x

# --- CONFIGURATION ---
SWEEP_CONFIG = {
    "NODE_SIZES": [40, 80, 160, 320, 640, 800],
    "NUM_RUNS_PER_SETTING": 100,
    "SIMULATION_STEPS": 2000,
    "ALPHA": 1.0,
    "CONSTANT_TEMP": 0.2, # The constant temperature for Model B
    "SEED": 42,
    "VERSION_CHECK": "1.4-sweep",
    "OUTPUT_DIR": "./outputs",
    "CSV_OUTPUT": "comparative_sweep_results.csv",
    "PLOT_OUTPUT": "comparative_sweep_plot.pdf",
}

# --- CORE SIMULATION FUNCTIONS ---

def generate_zpi_vacuum(num_nodes_approx):
    if num_nodes_approx < 3: raise ValueError("num_nodes_approx must be at least 3")
    G = DiGraph(); root = "0"; G.add_vertex(root); levels = [[root]]; node_id = 1
    while G.order() < num_nodes_approx:
        next_level = []
        for parent in levels[-1]:
            num_children = 2 if parent != root else 3
            for _ in range(num_children):
                if G.order() >= num_nodes_approx: break
                child = str(node_id); G.add_vertex(child); G.add_edge(parent, child)
                next_level.append(child); node_id += 1
        if not next_level: break
        levels.append(next_level)
    return G, levels

def inject_energic_event(G, levels):
    if len(levels) < 3 or not levels[2]:
        from sage.graphs.graph_generators import CycleGraph
        G_new = CycleGraph(3).to_directed()
        G_new.relabel(dict(zip(G_new.vertices(sort=True), map(str, range(3)))))
        return G_new
    node_v, node_w, node_u = str(levels[0][0]), str(levels[1][0]), str(levels[2][0])
    G.add_edge(node_u, node_v)
    return G

def is_permissible_corrected(G, u, v, w):
    G.delete_edge(v, w)
    has_other_path = (G.distance(v, u) != Infinity)
    G.add_edge(v, w)
    return not has_other_path

def run_single_simulation(n_approx, max_steps, alpha, model_params):
    G_acyclic, levels = generate_zpi_vacuum(n_approx)
    G = inject_energic_event(G_acyclic, levels)
    N = G.order()
    
    # --- MODEL SELECTION LOGIC ---
    if model_params['type'] == 'scaling':
        T = float(1.0 / log(N)) if N > 1 else 1.0
    elif model_params['type'] == 'constant':
        T = float(model_params['temp'])
    else:
        raise ValueError(f"Unknown model type: {model_params['type']}")

    for step in range(max_steps):
        proposal_set = set()
        for v in G.vertices(sort=False):
            for w in G.neighbors_out(v):
                for u in G.neighbors_out(w):
                    if v == u or G.has_edge(u, v):
                        continue
                    if is_permissible_corrected(G, u, v, w):
                        delta_F = alpha - T
                        P = min(1.0, float(exp(-delta_F / T)))
                        if random() < P:
                            proposal_set.add((u, v))
        if not proposal_set:
            break
        G.add_edges(proposal_set)

    A = G.adjacency_matrix(sparse=True)
    return int(round(float((A**3).trace()) / 3.0))

# --- MAIN SWEEP RUNNER ---
def run_sweep(config):
    set_random_seed(config["SEED"])
    output_dir = config["OUTPUT_DIR"]
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    print("="*80)
    print(f"Running Comparative Size Sweep (v{config.get('VERSION_CHECK', 'unknown')})")
    print("="*80)
    
    results = []
    models_to_test = [
        {'type': 'scaling', 'label': 'T = 1/ln(N)'},
        {'type': 'constant', 'label': f"T = {config['CONSTANT_TEMP']}", 'temp': config['CONSTANT_TEMP']}
    ]

    for n_approx in config["NODE_SIZES"]:
        for model_params in models_to_test:
            print(f"\n--- Running N≈{n_approx}, Model: {model_params['label']} ---")
            n3_counts = []
            for _ in tqdm(range(config["NUM_RUNS_PER_SETTING"]), desc=f"N={n_approx}", ncols=80):
                n3 = run_single_simulation(
                    n_approx, 
                    config["SIMULATION_STEPS"], 
                    config["ALPHA"], 
                    model_params
                )
                n3_counts.append(n3)
            
            n3_array = np.array(n3_counts)
            stats = {
                "N_approx": n_approx,
                "model": model_params['label'],
                "mean_n3": np.mean(n3_array),
                "std_n3": np.std(n3_array),
                "median_n3": np.median(n3_array),
                "min_n3": np.min(n3_array),
                "max_n3": np.max(n3_array),
            }
            results.append(stats)

    # --- SAVE RESULTS & PLOT ---
    csv_path = os.path.join(output_dir, config["CSV_OUTPUT"])
    with open(csv_path, 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=results[0].keys())
        writer.writeheader()
        writer.writerows(results)
    
    print(f"\nSweep complete. All data saved to {csv_path}")

    # Plotting
    plt.style.use('seaborn-v0_8-whitegrid')
    fig, ax = plt.subplots(figsize=(10, 6))
    
    scaling_results = [r for r in results if r['model'] == 'T = 1/ln(N)']
    constant_results = [r for r in results if 'constant' in r['model']]
    
    ax.errorbar([r['N_approx'] for r in scaling_results], [r['mean_n3'] for r in scaling_results], 
                yerr=[r['std_n3']/np.sqrt(config["NUM_RUNS_PER_SETTING"]) for r in scaling_results],
                fmt='-o', capsize=4, label='Model A: T = 1/ln(N) (Scaling)')
    
    ax.errorbar([r['N_approx'] for r in constant_results], [r['mean_n3'] for r in constant_results], 
                yerr=[r['std_n3']/np.sqrt(config["NUM_RUNS_PER_SETTING"]) for r in constant_results],
                fmt='-s', capsize=4, label=f"Model B: T = {config['CONSTANT_TEMP']} (Constant)")

    ax.set_xlabel("Number of Initial Nodes (N)")
    ax.set_ylabel("Mean Final 3-Cycle Count ($N_3$)")
    ax.set_title("Comparative Size Sweep: Scaling vs. Constant Temperature")
    ax.set_xscale('log')
    ax.set_yscale('log')
    ax.legend()
    
    plot_path = os.path.join(output_dir, config["PLOT_OUTPUT"])
    plt.savefig(plot_path, dpi=300, bbox_inches='tight')
    print(f"Comparative plot saved to {plot_path}")
    return results


if __name__ == "__main__":
    run_sweep(SWEEP_CONFIG)