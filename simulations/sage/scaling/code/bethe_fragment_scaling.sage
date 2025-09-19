#!/usr/bin/env sage
# bethe_fragment_scaling_fast.sage
# v1.1 - Corrected for performance by removing the slow automorphism group calculation.

from sage.all import Graph, floor, infinity
import time
import csv
import os
import numpy as np

try:
    from tqdm import tqdm
except ImportError:
    print("Warning: tqdm not found. For a progress bar, run: sage -pip install tqdm")
    tqdm = lambda x, **kwargs: x

def generate_bethe_fragment(depth=5, b=3):
    G = Graph(multiedges=False, loops=False)
    if depth < 1 or b < 3:
        raise ValueError("Depth must be at least 1 and coordination number b must be at least 3.")

    node_id = 0
    root = node_id
    node_id += 1
    G.add_vertex(root)
    levels = [[root]]

    for d in range(depth):
        next_level = []
        for parent in levels[-1]:
            num_children = b if parent == root else b - 1
            for _ in range(num_children):
                child = node_id
                node_id += 1
                G.add_vertex(child)
                G.add_edge(parent, child)
                next_level.append(child)
        if not next_level:
            break
        if next_level:
            levels.append(next_level)

    total_nodes = G.order()
    if total_nodes == 0:
        return G, {}

    regular_nodes = [v for v in G.vertices() if G.degree(v) == b]
    regularity_fraction = len(regular_nodes) / total_nodes
    
    boundary_nodes = len(levels[-1])
    analytical_fraction = (total_nodes - boundary_nodes) / total_nodes
    
    metrics = {
        'depth': depth,
        'b': b,
        'nodes': total_nodes,
        'edges': G.size(),
        'girth': G.girth(),
        # The following line is the bottleneck and has been removed for this run.
        # 'automorphism_group_order': G.automorphism_group().order(),
        'frac_b_regular': float(regularity_fraction),
        'frac_b_regular_analytical': float(analytical_fraction)
    }
    return G, metrics

def main():
    print("Causal Loop Cosmology — Bethe Fragment Scaling Analysis (v1.1 - Fast)")
    print("=" * 70)
    
    output_dir = "outputs"
    os.makedirs(output_dir, exist_ok=True)
    
    configs_to_test = []
    for depth in range(3, 13):
        configs_to_test.append({'depth': depth, 'b': 3})
    for b in [4, 5, 6]:
        configs_to_test.append({'depth': 5, 'b': b})
        
    results = []
    
    print("Running simulations...")
    for config in tqdm(configs_to_test, desc="Configurations"):
        depth = config['depth']
        b = config['b']
        _, metrics = generate_bethe_fragment(depth=depth, b=b)
        results.append(metrics)

    csv_path = os.path.join(output_dir, 'bethe_scaling_results_fast.csv')
    with open(csv_path, 'w', newline='') as f:
        fieldnames = results[0].keys()
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(results)
    print(f"\nAnalysis complete. Data saved to '{csv_path}'")

    print("\n" + "="*80)
    print("BETHE FRAGMENT SCALING ANALYSIS")
    print("="*80)
    print(f"{'Depth':<8} {'b':<5} {'Nodes':<10} {'Girth':<8} {'b-Reg Frac':<12} {'Analytical Frac':<18}")
    print("-"*80)
    for row in results:
        girth_str = str(row['girth']) if row['girth'] != infinity else 'inf'
        print(f"{row['depth']:<8} {row['b']:<5} {row['nodes']:<10} {girth_str:<8} {row['frac_b_regular']:.2%}{'':<5} {row['frac_b_regular_analytical']:.2%}")
    print("-"*80)

if __name__ == "__main__":
    main()