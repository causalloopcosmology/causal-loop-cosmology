#!/usr/bin/env sage
# -------------------------------------------------------------------------
# Causal Loop Cosmology — Statistical Ensemble Analysis (Paper 1)
#
# Title:       Thermodynamic Graph Rewriting: A Category-Theoretic Model of Emergent Spacetime
# Author:      R. Fisher
# Affiliation: Independent Researcher
# Date:        September 14, 2025
# Version:     1.1
# DOI:         [To be assigned upon publication]
# License:     MIT
# Description: Simulates geometrogenesis via thermodynamic 3-cycle formation in a 
#              statistical ensemble of directed graphs. Validates inflationary phase 
#              transition from a ZPI vacuum. Outputs histogram, time-series, CSV/JSON.
# Dependencies: SageMath 10.4, NumPy 1.26.4, tqdm 4.66.5
# Outputs:     - Histogram: './outputs/figure_n3_distribution.pdf'
#              - Time-series: './outputs/inflation_time_series.pdf'
#              - CSV: './outputs/ensemble_results.csv'
#              - JSON: './outputs/simulation_metadata.json'
# Reproducibility: Seed 42; ~2s for 1000 runs (N=100) on Ryzen 5/16GB.
# -------------------------------------------------------------------------


from sage.all import DiGraph, log, exp, random, set_random_seed, histogram, line
import time
import csv
import json
import os
import matplotlib.pyplot as plt
from datetime import datetime
import numpy as np
try:
    from tqdm import tqdm
except ImportError:
    print("Warning: Install tqdm with 'sage -pip install tqdm' for progress bar.")
    tqdm = lambda x, **k: x

# --- CONFIGURATION ---
ENSEMBLE_CONFIG = {
    "NUM_RUNS": int(2000),
    "NUM_NODES_APPROX": int(80),
    "SIMULATION_STEPS": int(1000),
    "ALPHA": 1.0,
    "VERSION_CHECK": "1.1",
    "SEED": int(42),
    "OUTPUT_FIGURE": "./outputs/figure_n3_distribution.pdf",
    "TIME_SERIES_FIGURE": "./outputs/inflation_time_series.pdf",
    "CSV_OUTPUT": "./outputs/ensemble_results.csv",
    "JSON_OUTPUT": "./outputs/simulation_metadata.json"
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

# --- CONFIGURATION VALIDATION ---
def ensure_python_types_config(config):
    cfg = config.copy()
    int_keys = ["NUM_RUNS", "NUM_NODES_APPROX", "SIMULATION_STEPS", "SEED"]
    float_keys = ["ALPHA"]
    for k in int_keys:
        if k in cfg:
            converted = _to_python_number(cfg[k])
            if not isinstance(converted, int):
                if isinstance(converted, float) and converted.is_integer():
                    converted = int(converted)
                else:
                    raise ValueError(f"{k} must be an integer (got {type(cfg[k])})")
            cfg[k] = converted
    for k in float_keys:
        if k in cfg:
            converted = _to_python_number(cfg[k])
            if isinstance(converted, int): converted = float(converted)
            elif not isinstance(converted, float):
                raise ValueError(f"{k} must be numeric (got {type(cfg[k])})")
            cfg[k] = converted
    output_dir = os.path.dirname(cfg.get("CSV_OUTPUT", ""))
    if output_dir and not os.path.exists(output_dir):
        os.makedirs(output_dir, exist_ok=True)
    return cfg

def validate_config(config):
    required = ["NUM_RUNS", "NUM_NODES_APPROX", "SIMULATION_STEPS"]
    for k in required:
        if k not in config: raise KeyError(f"{k} missing in config")
    if not isinstance(config["NUM_RUNS"], int) or config["NUM_RUNS"] <= 0:
        raise ValueError("NUM_RUNS must be a positive integer")
    if not isinstance(config["NUM_NODES_APPROX"], int) or config["NUM_NODES_APPROX"] < 3:
        raise ValueError("NUM_NODES_APPROX must be at least 3")
    if not isinstance(config["SIMULATION_STEPS"], int) or config["SIMULATION_STEPS"] <= 0:
        raise ValueError("SIMULATION_STEPS must be a positive integer")
    if config.get("ALPHA", 0) < 0:
        raise ValueError("ALPHA must be non-negative")

# --- CORE SIMULATION FUNCTIONS ---
def generate_zpi_vacuum(num_nodes_approx):
    if num_nodes_approx < 3: raise ValueError("num_nodes_approx must be at least 3")
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
                if G.order() >= num_nodes_approx: break
                child = str(node_id)
                G.add_vertex(child)
                G.add_edge(parent, child)
                next_level.append(child)
                node_id += 1
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

def is_permissible(G, u, v):
    if G.has_edge(v, u):
        return False
    successors_of_v = set(G.neighbors_out(v))
    predecessors_of_u = set(G.neighbors_in(u))
    return len(successors_of_v.intersection(predecessors_of_u)) == 1

def run_single_simulation(config):
    G_acyclic, levels = generate_zpi_vacuum(config["NUM_NODES_APPROX"])
    G = inject_energic_event(G_acyclic, levels)
    N = G.order()
    T = float(1.0 / log(N)) if N > 1 else 1.0
    steps_taken = 0
    for step in range(config["SIMULATION_STEPS"]):
        proposal_set = set()
        for v, w in G.edges(labels=False):
            for u in G.neighbors_out(w):
                if v != u and not G.has_edge(u, v) and is_permissible(G, u, v):
                    delta_F = config["ALPHA"] - T
                    P = min(1.0, float(exp(-delta_F / T)))
                    if random() < P:
                        proposal_set.add((u, v))
        if not proposal_set:
            steps_taken = step
            break
        G.add_edges(proposal_set)
        steps_taken = step + 1
    A = G.adjacency_matrix(sparse=True)
    trace_val = (A**3).trace()
    n3_val = int(round(float(trace_val) / 3.0))
    return n3_val, steps_taken

# --- ENSEMBLE RUNNER ---
def run_ensemble(raw_config):
    config = ensure_python_types_config(raw_config)
    validate_config(config)
    set_random_seed(config["SEED"])
    
    print(f"Running ensemble.sage version {config.get('VERSION_CHECK', 'unknown')}")
    print("="*80)
    print(f"Running Ensemble of {config['NUM_RUNS']} Simulations (N≈{config['NUM_NODES_APPROX']}, Max Steps={config['SIMULATION_STEPS']})")
    print("="*80)
    
    final_n3_counts, run_times, steps_list, early_terminations = [], [], [], 0
    
    for i in tqdm(range(config['NUM_RUNS']), desc="Simulations", ncols=80):
        start_run = time.time()
        n3, steps = run_single_simulation(config)
        end_run = time.time()
        run_times.append(end_run - start_run)
        final_n3_counts.append(n3)
        steps_list.append(int(steps))
        if steps < config["SIMULATION_STEPS"]:
            early_terminations += 1
            
    print("Ensemble complete.")
    
    # Data saving and statistics (your original code)
    try:
        with open(config["CSV_OUTPUT"], 'w', newline='') as f:
            writer = csv.writer(f)
            writer.writerow(["Run", "Final_N3", "Steps_Taken", "Runtime_sec"])
            for i, (n3, steps, rt) in enumerate(zip(final_n3_counts, steps_list, run_times), 1):
                writer.writerow([i, int(n3), int(steps), f"{float(rt):.3f}"])
    except IOError as e:
        print(f"Error writing CSV: {e}"); raise
        
    n3_list = [int(x) for x in final_n3_counts]
    n3_array = np.array(n3_list, dtype=int) if n3_list else np.array([], dtype=int)
    stats = {
        "Mean_N3": float(np.mean(n3_array)) if n3_array.size > 0 else 0.0,
        "Std_N3": float(np.std(n3_array)) if n3_array.size > 0 else 0.0,
        "Median_N3": float(np.median(n3_array)) if n3_array.size > 0 else 0.0,
        "Min_N3": float(np.min(n3_array)) if n3_array.size > 0 else 0.0,
        "Max_N3": float(np.max(n3_array)) if n3_array.size > 0 else 0.0,
        "Early_Termination_Rate": float(early_terminations / config["NUM_RUNS"])
    }
    
    try:
        from sage.misc.banner import version
        metadata = {
            "metadata_version": "1.0", "timestamp": datetime.now().isoformat(),
            "software": {"sage_version": version(), "numpy_version": np.__version__},
            "config": config, "results": stats,
            "total_runtime_seconds": float(sum(run_times))
        }
        with open(config["JSON_OUTPUT"], 'w') as f:
            json.dump(convert_to_python_types(metadata), f, indent=2)
    except IOError as e:
        print(f"Error writing JSON: {e}"); raise
    
    # Plotting (your original code)
    try:
        heights, _ = np.histogram(n3_list, bins='auto', density=True)
        max_y = np.max(heights) if heights.size > 0 else 1.0
        h = histogram(n3_list, bins='auto', density=True,
                      title=f"Distribution of Final $N_3$ ({config['NUM_RUNS']} Runs)\nMean = {stats['Mean_N3']:.2f} ± {stats['Std_N3']:.2f}",
                      axes_labels=['Final 3-Cycle Count ($N_3$)', 'Probability Density'], fontsize=12)
        mean_line = line([(stats["Mean_N3"], 0), (stats["Mean_N3"], max_y)],
                         linestyle='--', thickness=2, legend_label=f'Mean = {stats["Mean_N3"]:.2f}')
        plot = h + mean_line
        fig = plot.matplotlib()
        fig.gca().grid(True)
        fig.savefig(config['OUTPUT_FIGURE'], dpi=300, bbox_inches='tight')
        plt.close(fig)
    except Exception as e:
        print(f"Warning: could not create histogram: {e}")
        
    try:
        G_acyclic, levels = generate_zpi_vacuum(config["NUM_NODES_APPROX"])
        G = inject_energic_event(G_acyclic, levels)
        N, T, n3_history = G.order(), float(1.0 / log(G.order())) if G.order() > 1 else 1.0, []
        for step in range(config["SIMULATION_STEPS"]):
            A = G.adjacency_matrix(sparse=True)
            n3_history.append(int(round(float((A**3).trace()) / 3.0)))
            proposal_set = set()
            for v, w in G.edges(labels=False):
                for u in G.neighbors_out(w):
                    if v != u and not G.has_edge(u, v) and is_permissible(G, u, v):
                        if random() < min(1.0, float(exp(-(config["ALPHA"] - T) / T))):
                            proposal_set.add((u, v))
            if not proposal_set: break
            G.add_edges(proposal_set)
        line_plot = line(list(zip(range(len(n3_history)), n3_history)),
                         title="3-Cycle Growth (Representative Run)",
                         axes_labels=['Step', '$N_3$'], fontsize=12, frame=True)
        fig = line_plot.matplotlib()
        fig.gca().grid(True)
        fig.savefig(config['TIME_SERIES_FIGURE'], dpi=300, bbox_inches='tight')
        plt.close(fig)
    except Exception as e:
        print(f"Warning: could not create time series plot: {e}")
        
    return stats

# --- ENTRY POINT ---
if __name__ == "__main__":
    try:
        start_time = time.time()
        final_stats = run_ensemble(ENSEMBLE_CONFIG)
        end_time = time.time()
        print("\n" + "="*80)
        print("STATISTICAL ANALYSIS OF FINAL 3-CYCLE COUNT ($N_3$)")
        print(f"Total time for {ENSEMBLE_CONFIG['NUM_RUNS']} runs: {end_time - start_time:.2f} seconds")
        print("="*80)
        print(f"{'Metric':<20} {'Value':>10}")
        print("-"*80)
        for key, value in final_stats.items():
            print(f"{key:<20} {value:>10.2f}")
        print("-"*80)
        print(f"\nOutputs saved to '{os.path.dirname(ENSEMBLE_CONFIG['CSV_OUTPUT'])}'")
    except Exception as e:
        import traceback
        print(f"\nFATAL ERROR: An exception occurred during the simulation.")
        traceback.print_exc()