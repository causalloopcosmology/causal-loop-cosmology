The SU(0) Phase and Gauge Field Emergence in Causal Loop Cosmology
Abstract
Causal Loop Cosmology (CLC) proposes that spacetime emerges from a discrete network of causal relations, guided by a thermodynamic rule, as shown in prior works (Fisher 2025, Fisher 2025 Triad, Fisher 2025 Continuum). This paper explores a speculative SU(0) phase—a state with no structure, representing infinite symmetry, which we connect to Stephen Wolfram’s Ruliad, a universal object containing all possible computations (Wolfram 2020). We propose that a transition from SU(0) creates the Bethe lattice, a symmetric structure in CLC with a hyperbolic (negatively curved) geometry in one perspective and a flat geometry in another. This dual geometry allows gauge-like fields to emerge as edge changes that preserve key properties. The Global Register, a holographic mechanism from Paper 2, ensures these fields are consistent, similar to massless particles like photons. We outline simulations to test this idea, building on Paper 3’s goal of a 4D spacetime, to unify spacetime, matter, and gauge fields. While speculative, this framework places CLC within the Ruliad’s universal context, offering testable predictions.
Table of Contents

Introduction
The SU(0) Phase and the Ruliad
Dual Geometry of the Bethe Lattice
Gauge Field Emergence
Simulation Framework
Anticipated Results
Limitations and Future Work
Conclusion
References

1. Introduction
Causal Loop Cosmology (CLC) suggests that spacetime arises from a network of causal connections, without assuming a pre-existing geometry (Fisher 2025). In Paper 1, we showed how a single 3-cycle (a triangle of causal links) in a simple, symmetric starting structure sparks complex geometry, stabilizing at around 42 such cycles due to a purity rule. Paper 2 introduced the Necessary Triad—Acyclic Vacuum, Maximal Parallelism, and Global Register—to ensure consistent evolution (Fisher 2025 Triad). Paper 3 plans to show that this process leads to a 4D spacetime, similar to our universe (Fisher 2025 Continuum).
The starting structure, called the Acyclic Vacuum, is a finite Bethe lattice—a graph where each node connects to exactly three others, with no short loops (girth larger than log base 3 of the number of nodes, typically 1024 or more). This lattice has a unique property: in one view, it has a hyperbolic geometry, where the number of nodes grows exponentially with distance (about 2^distance for three connections per node), indicating negative curvature. In another view, such as analyzing random walks or boundary effects, it appears flat, resembling a 4D space. This dual nature is a special symmetry not found in random graphs or regular lattices, making it ideal for new physics.
We propose an SU(0) phase—a state with no nodes or edges, having infinite symmetry—as the starting point before the Bethe lattice. We connect this to the Ruliad, Wolfram’s concept of a universal object containing all possible computational rules and outcomes (Wolfram 2020). The Bethe lattice, as a specific structure within the Ruliad, emerges when SU(0)’s symmetry breaks, and its dual geometry supports gauge-like fields (similar to electromagnetic fields) as edge changes. This paper formalizes this idea, outlines simulations, and aims to unify spacetime, matter, and gauge fields in CLC.
1.1 Motivation
The Ruliad’s ability to include all computations makes it a natural framework for SU(0), the ultimate symmetric state. The Bethe lattice’s dual geometry, as a slice of the Ruliad, suggests it can support gauge fields, similar to how photons arise from symmetry in standard physics, while also hosting matter as graph defects.
2. The SU(0) Phase and the Ruliad
We define SU(0) as a state with no structure, akin to a blank slate, and connect it to the Ruliad.
2.1 Definition
The SU(0) phase is a graph with no nodes or edges, having infinite symmetry because all possible graph structures are equivalent. Its adjacency matrix is zero (A = 0), meaning no connections exist. This aligns with the Ruliad, which contains every possible computational rule and outcome, like a universal library of all possible physics (Wolfram 2020).
2.2 Symmetry Breaking
To form the Bethe lattice, SU(0) transitions to a minimal structure, such as a single node or edge. This is like selecting one specific rule or starting point from the Ruliad’s vast possibilities, breaking the infinite symmetry to create a graph with three connections per node and no short loops. The rule from Paper 1, which adds or removes edges based on an energy cost (change in F = alpha * change in cycle density - T * change in entropy), could drive this transition, starting with a single edge and growing into the Bethe lattice.
Idea 2.1 (SU(0) Transition): SU(0), as the Ruliad’s starting point, becomes the Bethe lattice when a specific computational rule and initial condition (like one node or edge) are chosen, reducing infinite symmetry to a structured, symmetric vacuum. Mathematically, this is:
G_0 = (empty set, empty set) -> G_1 = (V_1, E_1), where |V_1| = 1, |E_1| = 0 or 1.
Here, G_0 is the SU(0) null graph, and G_1 is the minimal structure seeding the Bethe lattice.
3. Dual Geometry of the Bethe Lattice
The Bethe lattice’s ability to appear hyperbolic in one view and flat in another is key to gauge field emergence.
3.1 Hyperbolic Geometry
In the “bulk” view, where we look at the graph’s structure directly, the Bethe lattice grows exponentially—about 2^distance from a starting node for three connections per node—indicating negative curvature, like a hyperbolic space. This is measured by a curvature metric (Ollivier-Ricci curvature):
kappa(u,v) = 1 - W_1(m_u, m_v) / d(u,v),
where W_1 is the distance between neighbor distributions, and d(u,v) is the graph distance. This is negative (kappa < 0) due to the tree-like structure (Ollivier 2009).
3.2 Flat Geometry
In another view, such as analyzing random walks or projecting properties to a boundary via the Global Register (Paper 2), the lattice appears flat, with a dimension approaching 4, as expected in Paper 3. The spectral dimension is calculated as:
d_S(G_t) = -2 * log(average P_v(t)) / log(t), as t approaches infinity,
where P_v(t) is the probability of a random walk returning to node v after t steps. This approaches 4, indicating a flat space. The Global Register’s boundary projection also makes the graph’s properties look flat, similar to concepts in string theory (Maldacena 1998).
Statement 3.1 (Dual Geometry): The Bethe lattice, as a specific structure in the Ruliad, has a hyperbolic geometry (kappa < 0, volume ~ 2^distance) in the bulk and a flat geometry (d_S ~ 4) in the spectral or boundary view, reflecting different ways of interpreting the same computational structure.
Explanation: The hyperbolic nature comes from rapid node growth with distance, while flatness emerges when averaging over large scales or projecting to the boundary, as planned in Paper 3’s simulations.
3.3 Ruliad Context
This dual geometry mirrors the Ruliad’s nature, where different computational perspectives produce different physical properties. The Bethe lattice’s ability to support both hyperbolic and flat views suggests it can host gauge fields, as different perspectives allow different symmetries to emerge.
4. Gauge Field Emergence
We propose that gauge fields, like those governing electromagnetism, arise as edge changes in the flat view that preserve the graph’s key properties.
4.1 Gauge-Like Changes
A gauge-like change is a small adjustment to the graph’s edges—for example, flipping an edge’s direction—that doesn’t alter the number of 3-cycles (around 42, as found in Paper 1). This is written as:
A_uv -> A_uv + delta phi_uv, where sum over edges (delta phi_uv * rho_C) = 0,
where A is the adjacency matrix, delta phi_uv is the edge change, and rho_C is the 3-cycle density. These changes act like transformations in physics that leave the system unchanged, similar to electromagnetic fields (Ashtekar 1986).
4.2 Role of the Global Register
The Global Register (Paper 2) ensures these edge changes are consistent, acting like a rule that keeps the graph’s structure valid, similar to quantum error correction (Kitaev 2003). It enforces symmetry by rejecting changes that disrupt the graph’s properties.
Idea 4.1 (Gauge Fields): Edge changes in the flat view that keep the 3-cycle count stable act as gauge fields, resembling massless particles like photons, with their behavior shaped by the Ruliad’s computational rules and enforced by the Global Register.
4.3 Unification with Matter
Matter fields, proposed as graph defects like nodes with more than three connections (Paper 3), interact with gauge fields in the hyperbolic bulk, while the flat view allows them to behave like particles in a 4D spacetime.
5. Simulation Framework
We propose a simulation plan using Python tools (SageMath 10.3, NetworkX 3.2, NumPy 1.26, SciPy 1.11, POT 0.9) to test gauge field emergence.
5.1 Graph Generation
Create 100 graphs with 1024 nodes, each node having three connections and no short loops (girth > log_3 1024 ~ 7), as in Paper 3. Save details to a file named ensemble_n1024_b3.csv.
5.2 Gauge Perturbations
Introduce edge flips as gauge-like changes:
def introduce_gauge_fluctuation(G, fraction=0.01):
    num_flips = int(fraction * G.size())
    edges = list(G.edges(labels=False))
    for _ in range(num_flips):
        u, v = random.choice(edges)
        if G.has_edge(v, u):
            continue
        G_temp = G.copy()
        G_temp.add_edge(v, u)
        G_temp.delete_edge(u, v)
        n3_before = (G.to_undirected().adjacency_matrix()^3).trace() / 6
        n3_after = (G_temp.to_undirected().adjacency_matrix()^3).trace() / 6
        if abs(n3_after - n3_before) < 0.000001:
            G.add_edge(v, u)
            G.delete_edge(u, v)
    return G

5.3 Evolution and Tracking
Run the graphs for 1000 steps using the rule from Paper 1, tracking:

Number of 3-cycles (n3 = trace of adjacency matrix^3 / 6).
Curvature (kappa, averaged over 1000 sampled edges).
Spectral dimension (d_S, from random walk return probabilities).Save results to gauge_trajectories.csv.

5.4 Reproducibility

Tools: Python 3.11, SageMath 10.3, NetworkX 3.2, NumPy 1.26, SciPy 1.11, POT 0.9.
Random Seed: 2025, incremented per graph.
Runtime: About 2 hours for 100 runs with 1024 nodes.

6. Anticipated Results
We expect:

Gauge Stability: Edge flips will persist for 1000 steps, keeping the 3-cycle count near 42.
Curvature: The curvature (kappa) will be close to zero in the flat view, with a consistent distribution (skewness < 0.1).
Spectral Dimension: The dimension (d_S) will approach 4, within 0.05, matching Paper 3’s goal.

Table 1: Expected Simulation Results (1024 nodes, 100 runs)



Metric
Expected Average
Expected Error



3-Cycle Count
42
2


Curvature Average
0.05
0.01


Spectral Dimension
3.98
0.05


Figure 1: Expected plots of 3-cycle count and curvature over time, showing stable gauge-like behavior.
7. Limitations and Future Work
The SU(0) phase and Ruliad connection are speculative, as SU(0) has no dynamics yet. Future work includes:

Defining how SU(0) evolves into the Bethe lattice, possibly using computational rules from the Ruliad.
Testing how gauge fields interact with matter defects in simulations.
Exploring a quantum version of CLC with multiple graph states at once.

8. Conclusion
This paper proposes that the SU(0) phase, linked to the Ruliad’s universal structure, transitions to the Bethe lattice, whose dual geometry (hyperbolic in one view, flat in another) supports gauge fields as edge changes. These fields, unified with matter defects, position CLC as a potential theory of everything, with simulations planned to test this vision within the Ruliad’s computational framework.
9. References

Fisher 2025: R. Fisher, "Geometrogenesis and Inflation in Causal Loop Cosmology," arXiv:2509.xxxxx (2025).
Fisher 2025 Triad: R. Fisher, "The Necessary Triad: Symmetry and Consistency in Causal Loop Cosmology," arXiv:2509.xxxxx (2025).
Fisher 2025 Continuum: R. Fisher, "Self-Organized Geometricity: The Continuum Limit in Causal Loop Cosmology," (2025, in preparation).
Wolfram 2020: S. Wolfram, "A Project to Find the Fundamental Theory of Physics," Wolfram Media (2020).
Maldacena 1998: J. Maldacena, "The large N limit of superconformal field theories and supergravity," Advances in Theoretical and Mathematical Physics, 2, 231–252 (1998).
Rovelli 2004: C. Rovelli, "Quantum Gravity," Cambridge University Press (2004).
Ollivier 2009: Y. Ollivier, "Ricci curvature of Markov chains on metric spaces," Journal of Functional Analysis, 256(3), 810–864 (2009).
Lin 2011: Y. Lin, L. Lu, S.-T. Yau, "Ricci curvature of graphs," Tohoku Mathematical Journal, 63, 605–627 (2011).
Ashtekar 1986: A. Ashtekar, "New variables for classical and quantum gravity," Physical Review Letters, 57, 2244–2247 (1986).
Kitaev 2003: A. Kitaev, "Fault-tolerant quantum computation by anyons," Annals of Physics, 303(1), 2–30 (2003).
