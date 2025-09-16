#!/usr/-bin/env sage
# causal_loop_symmetry_analysis.sage
# SageMath script for symmetry, 3-regularity, and scheduler variance analysis
# v2.1 - Corrected dictionary keys for robust f-string parsing in Sage

from sage.all import Graph, floor
import time
import csv
import os
import random
import numpy as np

try:
    from tqdm import tqdm
except ImportError:
    print("Warning: tqdm not found. For a progress bar, run: sage -pip install tqdm")
    tqdm = lambda x, **kwargs: x

def generate_bethe_fragment(depth=5):
    """
    Generates a finite Bethe fragment of degree 3.
    """
    G = Graph(multiedges=False, loops=False)
    if depth < 1:
        raise ValueError("Depth must be at least 1")

    node_id = 0
    root = node_id
    node_id += 1
    G.add_vertex(root)
    levels = [[root]]

    for d in range(depth):
        next_level = []
        for parent in levels[-1]:
            num_children = 3 if parent == root else 2
            for _ in range(num_children):
                child = node_id
                node_id += 1
                G.add_vertex(child)
                G.add_edge(parent, child)
                next_level.append(child)
        if next_level:
            levels.append(next_level)

    total_nodes = G.order()
    if total_nodes == 0:
        return G, 0, 0, 0

    regular_count = sum(1 for v in G.vertices() if G.degree(v) == 3)
    regularity_fraction = regular_count / total_nodes

    boundary_nodes = len(levels[-1])
    analytical_fraction = (total_nodes - boundary_nodes) / total_nodes

    return G, total_nodes, regularity_fraction, analytical_fraction

def _apply_simplified_rewrite(G, vertices_to_update):
    """Helper function for the simplified rewrite rule."""
    edges_to_add = []
    for v in vertices_to_update:
        if G.degree(v) < 3:
            potential_neighbors = [u for u in G.vertices() if u != v and not G.has_edge(v, u)]
            if potential_neighbors:
                new_neighbor = random.choice(potential_neighbors)
                edges_to_add.append((v, new_neighbor))
    G.add_edges(edges_to_add)

def simulate_scheduler_variance(G0, scheduler_type='parallel', num_steps=10, num_trials=20, seed=43):
    """
    Simulates degree variance under different schedulers.
    """
    random.seed(int(seed))
    
    all_trial_variances = []
    for _ in range(num_trials):
        G = G0.copy()
        trial_variances = []
        for _ in range(num_steps):
            vertices = list(G.vertices())
            
            if scheduler_type == 'parallel':
                _apply_simplified_rewrite(G, vertices)
            elif scheduler_type == 'serial':
                random.shuffle(vertices)
                for v in vertices: # Iterating individually modifies the graph state mid-step
                    _apply_simplified_rewrite(G, [v])
            elif scheduler_type == 'partial': # Represents block-staggered
                random.shuffle(vertices)
                block_size = floor(len(vertices) / 2)
                block1 = vertices[:block_size]
                block2 = vertices[block_size:]
                _apply_simplified_rewrite(G, block1)
                _apply_simplified_rewrite(G, block2)

            degrees = G.degree_sequence()
            var = np.var(degrees)
            trial_variances.append(var)
        all_trial_variances.append(trial_variances)
        
    return all_trial_variances

def main():
    print("Causal Loop Cosmology — Computational Symmetry Analysis (v2.1)")
    print("=" * 70)
    
    output_dir = "outputs"
    os.makedirs(output_dir, exist_ok=True)
    
    # --- Part 1: Bethe Fragment Analysis ---
    print("Analyzing Bethe fragments (depths 3-7)...")
    symmetry_results = []
    depths = [3, 4, 5, 6, 7]
    for depth in depths:
        start_time = time.time()
        G, n_nodes, reg_frac, an_frac = generate_bethe_fragment(depth)
        runtime = time.time() - start_time
        
        # FIX: Renamed keys to be valid Python identifiers to avoid f-string parsing issues.
        symmetry_results.append({
            'Graph_Type': f'Bethe Fragment (d={depth})',
            'Is_Acyclic': G.is_forest(),
            'Nodes': n_nodes,
            'Edges': G.size(),
            'Frac_3_Regular': float(reg_frac),
            'Frac_3_Regular_Analytical': float(an_frac),
            'Runtime_s': runtime
        })

    # Export symmetry results
    symmetry_csv_path = os.path.join(output_dir, 'symmetry_results.csv')
    with open(symmetry_csv_path, 'w', newline='') as f:
        fieldnames = symmetry_results[0].keys()
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(symmetry_results)
    print(f"Symmetry data saved to '{symmetry_csv_path}'")

    # --- Part 2: Scheduler Variance Analysis ---
    print("\nRunning scheduler variance simulations (N≈124)...")
    G_124, _, _, _ = generate_bethe_fragment(depth=4)
    variances_data = {}
    
    for sched in ['parallel', 'serial', 'partial']:
        print(f"  Simulating '{sched}' scheduler...")
        all_vars = simulate_scheduler_variance(G_124, scheduler_type=sched, num_steps=10, num_trials=100, seed=43)
        mean_vars_per_step = [np.mean(step_vars) for step_vars in zip(*all_vars)]
        variances_data[sched] = mean_vars_per_step

    # Export scheduler results
    scheduler_csv_path = os.path.join(output_dir, 'scheduler_variances.csv')
    with open(scheduler_csv_path, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(['Step', 'Parallel_Mean_Variance', 'Serial_Mean_Variance', 'Partial_Mean_Variance'])
        for i in range(10):
            writer.writerow([
                i + 1,
                variances_data['parallel'][i],
                variances_data['serial'][i],
                variances_data['partial'][i]
            ])
    print(f"Scheduler data saved to '{scheduler_csv_path}'")

    # --- Print Summaries ---
    print("\n" + "="*80)
    print("BETHE FRAGMENT SYMMETRY AND REGULARITY ANALYSIS")
    print("="*80)
    print(f"{'Graph Type':<20} {'Nodes':<8} {'3-Reg Frac':<12} {'Analytical Frac':<18} {'Runtime (s)':<10}")
    print("-"*80)
    for row in symmetry_results:
        # FIX: Using the corrected, valid key names.
        print(f"{row['Graph_Type']:<20} {row['Nodes']:<8} {row['Frac_3_Regular']:.2%}{'':<5} {row['Frac_3_Regular_Analytical']:.2%}{'':<9} {row['Runtime_s']:.2f}")
    print("-"*80)

    print("\nSCHEDULER VARIANCE SUMMARY (Final Mean Variance after 10 Steps)")
    print("="*50)
    for sched, data in variances_data.items():
        print(f"  {sched.capitalize():<10}: {data[-1]:.4f}")
    print("="*50)

if __name__ == "__main__":
    main()