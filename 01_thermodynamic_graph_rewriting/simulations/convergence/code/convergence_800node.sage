#!/usr/bin/env sage
# -----------------------------------------------------------------------------
# Title:       Thermodynamic Graph Rewriting: A Category-Theoretic Model of Emergent Spacetime
# Subject:     Convergence Analysis at N=800
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

from sage.all import DiGraph, log, exp, random, set_random_seed, Infinity, line
import time
import csv
import os
import numpy as np

try:
    from tqdm import tqdm
except ImportError:
    print("Warning: Install tqdm with 'sage -pip install tqdm' for progress bar.")
    tqdm = lambda x, **k: x

# --- CONFIGURATION ---
CONVERGENCE_CONFIG = {
    "NUM_NODES_APPROX": 800,
    "TOTAL_RUNS": 10240,
    "BATCH_SIZES": [40, 80, 160, 320, 640, 1280, 2560, 5120],
    "SIMULATION_STEPS": 2000,
    "ALPHA": 1.0,
    "SEED": 42,
    "OUTPUT_DIR": "./outputs",
    "CSV_OUTPUT": "convergence_N800.csv",
    "PLOT_OUTPUT": "convergence_N800.pdf",
}

# --- UTILITY CONVERSIONS ---

def _to_python_number(x):
    if x is None: return None
    if isinstance(x, bool): return x
    if isinstance(x, (int, float, str)): return x
    try:
        if hasattr(x, "is_integer"):
            try:
                if x.is_integer(): return int(x)
            except Exception: pass
        i = int(x)
        try:
            if float(x) == float(i): return i
            else: return float(x)
        except Exception: return i
    except Exception: pass
    try:
        f = float(x)
        return f
    except Exception: pass
    return str(x)

def convert_to_python_types(obj):
    if isinstance(obj, dict): return {k: convert_to_python_types(v) for k, v in obj.items()}
    if isinstance(obj, list): return [convert_to_python_types(v) for v in obj]
    if isinstance(obj, tuple): return tuple(convert_to_python_types(v) for v in obj)
    if isinstance(obj, (str, bool, type(None))): return obj
    return _to_python_number(obj)

# --- CORE SIMULATION FUNCTIONS ---

def generate_zpi_vacuum(num_nodes_approx):
    if num_nodes_approx < 3:
        raise ValueError("num_nodes_approx must be at least 3")
    G = DiGraph()
    root = "0"
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
                child = str(node_id)
                G.add_vertex(child)
                G.add_edge(parent, child)
                next_level.append(child)
                node_id += 1
        if not next_level:
            break
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

def run_single_simulation(config):
    G_acyclic, levels = generate_zpi_vacuum(config["NUM_NODES_APPROX"])
    G = inject_energic_event(G_acyclic, levels)
    N = G.order()
    T = float(1.0 / log(N)) if N > 1 else 1.0

    for step in range(config["SIMULATION_STEPS"]):
        proposal_set = set()
        for v in G.vertices(sort=False):
            for w in G.neighbors_out(v):
                for u in G.neighbors_out(w):
                    if v == u or G.has_edge(u, v):
                        continue
                    if is_permissible_corrected(G, u, v, w):
                        delta_F = config["ALPHA"] - T
                        P = min(1.0, float(exp(-delta_F / T)))
                        if random() < P:
                            proposal_set.add((u, v))
        if not proposal_set:
            A = G.adjacency_matrix(sparse=True)
            n3_val = int(round(float((A**3).trace()) / 3.0))
            return n3_val, step + 1

        G.add_edges(proposal_set)

    A = G.adjacency_matrix(sparse=True)
    n3_val = int(round(float((A**3).trace()) / 3.0))
    return n3_val, config["SIMULATION_STEPS"]

# --- CONVERGENCE ANALYSIS ---

def run_convergence_analysis(config):
    set_random_seed(config["SEED"])
    output_dir = config["OUTPUT_DIR"]
    if not os.path.exists(output_dir):
        os.makedirs(output_dir, exist_ok=True)

    print("="*80)
    print(f"Running Convergence Analysis at N={config['NUM_NODES_APPROX']}")
    print(f"Total Runs: {config['TOTAL_RUNS']}, Additive Batches: {config['BATCH_SIZES']}")
    print("="*80)

    all_n3 = []
    cumulative_stats = []

    run_index = 1
    for batch_size in config["BATCH_SIZES"]:
        if run_index + batch_size - 1 > config["TOTAL_RUNS"]:
            batch_size = config["TOTAL_RUNS"] - run_index + 1
            if batch_size <= 0:
                break

        print(f"\nRunning batch of {batch_size} runs (runs {run_index} to {run_index + batch_size - 1})...")

        mini_config = {
            "NUM_NODES_APPROX": config["NUM_NODES_APPROX"],
            "SIMULATION_STEPS": config["SIMULATION_STEPS"],
            "ALPHA": config["ALPHA"]
        }

        batch_n3 = []
        for _ in tqdm(range(batch_size), desc=f"Batch {len(cumulative_stats)+1}", ncols=90):
            n3, steps = run_single_simulation(mini_config)
            batch_n3.append(n3)

        all_n3.extend(batch_n3)
        current_total = len(all_n3)
        current_mean = np.mean(all_n3)
        current_std = np.std(all_n3)
        current_stderr = current_std / np.sqrt(current_total)

        stat_entry = {
            "total_runs": current_total,
            "mean_n3": current_mean,
            "std_n3": current_std,
            "stderr_n3": current_stderr
        }

        stat_entry = convert_to_python_types(stat_entry)
        cumulative_stats.append(stat_entry)

        pm = _to_python_number(current_mean)
        ps = _to_python_number(current_std)
        pe = _to_python_number(current_stderr)
        print(f" → Cumulative after {current_total} runs: mean={pm:.2f}, std={ps:.2f}, SE={pe:.3f}")

        run_index += batch_size
        if run_index > config["TOTAL_RUNS"]:
            break

    # --- SAVE RESULTS ---
    csv_path = os.path.join(output_dir, config["CSV_OUTPUT"])
    with open(csv_path, 'w', newline='') as f:
        fieldnames = ["total_runs", "mean_n3", "std_n3", "stderr_n3"]
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for row in cumulative_stats:
            writer.writerow(row)

    # --- PLOT CONVERGENCE — USING YOUR SAGE-NATIVE METHOD — NO MATPLOTLIB ---
    totals = [_to_python_number(s["total_runs"]) for s in cumulative_stats]
    means = [_to_python_number(s["mean_n3"]) for s in cumulative_stats]
    stderrs = [_to_python_number(s["stderr_n3"]) for s in cumulative_stats]

    # Create Sage line plot — just like your ensemble script
    mean_plot = line(
        list(zip(totals, means)),
        color='blue',
        legend_label='Mean Final_N3',
        title=f'Convergence of Mean N3 at N={config["NUM_NODES_APPROX"]}',
        axes_labels=['Number of Runs (Cumulative)', 'Mean Final 3-Cycle Count (N3)'],
        scale='loglog',
        gridlines=True,
        frame=True
    )

    # Add error bars as separate line plots (upper and lower bounds)
    upper_bounds = [m + e for m, e in zip(means, stderrs)]
    lower_bounds = [m - e for m, e in zip(means, stderrs)]

    upper_plot = line(list(zip(totals, upper_bounds)), color='red', linestyle='--', legend_label='Mean + SE')
    lower_plot = line(list(zip(totals, lower_bounds)), color='red', linestyle='--', legend_label='Mean - SE')

    final_plot = mean_plot + upper_plot + lower_plot

    # Save using Sage's native method — just like your original code
    fig = final_plot.matplotlib()
    fig.savefig(os.path.join(output_dir, config["PLOT_OUTPUT"]), dpi=300, bbox_inches='tight')

    print("\n" + "="*80)
    print("Convergence analysis complete.")
    print(f"Plot saved to: {os.path.join(output_dir, config['PLOT_OUTPUT'])}")
    print(f"Data saved to: {csv_path}")
    print("="*80)

    return [convert_to_python_types(s) for s in cumulative_stats]

# --- ENTRY POINT ---

if __name__ == "__main__":
    try:
        stats = run_convergence_analysis(CONVERGENCE_CONFIG)
        print("\n--- Final Convergence Summary ---")
        print(f"{'Total Runs':<12} {'Mean N3':<10} {'Std N3':<10} {'StdErr N3':<10}")
        print("-" * 55)
        for s in stats:
            print(f"{s['total_runs']:<12} {s['mean_n3']:<10.2f} {s['std_n3']:<10.2f} {s['stderr_n3']:<10.3f}")
    except Exception as e:
        import traceback
        print(f"\nFATAL ERROR during convergence analysis.")
        traceback.print_exc()