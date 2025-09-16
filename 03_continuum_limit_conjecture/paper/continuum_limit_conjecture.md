# Self-Organized Geometricity: The Continuum Limit in Causal Loop Cosmology

**Author**: R. Fisher  
**Date**: September 16, 2025

---

## Abstract

This work formalizes and investigates the Continuum Limit Conjecture in Causal Loop Cosmology (CLC), positing that a pre-geometric, relational graph under a thermodynamically guided rewrite rule self-organizes into a smooth, compact, 4D pseudo-Riemannian manifold. We define the conjecture rigorously, outline a comprehensive simulation framework to test it, and introduce computationally feasible proxies for convergence across topological, metric, curvature, and differential criteria. While simulations are anticipated to confirm convergence to a 4D structure, this draft presents the theoretical foundation, methodological design, and expected outcomes in detail, serving as a verbose outline for the full empirical validation. The approach emphasizes logical necessity from relational primitives, aligning with the series' prior demonstrations of geometrogenesis and the Necessary Triad.

---

## Table of Contents

1. Introduction  
2. Formal Statement of the Continuum Limit Conjecture  
   2.1 Motivation and Logical Necessity  
   2.2 Supporting Lemmas for Plausibility  
   2.3 Convergence Criteria  
   2.4 Convergence Proxies for Computational Feasibility  
   2.5 Remarks  
3. Methods: Simulation Framework  
   3.1 Graph Generation  
   3.2 Parallel Evolution  
   3.3 Observable Tracking  
   3.4 Reproducibility Checklist  
4. Anticipated Results  
   4.1 Topological Convergence  
   4.2 Metric and Curvature Convergence  
   4.3 Differential Structure  
5. Limitations and Future Work  
6. Conclusion  
7. References

---

## 1. Introduction

Causal Loop Cosmology (CLC) proposes that the universe emerges from a discrete network of causal relations, without presupposing background spacetime, fields, or an external clock. In the first paper of this series, we introduced the dynamics of inflationary geometrogenesis, showing through extensive simulations that a primordial 3-cycle in an acyclic vacuum triggers rapid expansion of geometric complexity, which naturally saturates due to a purity constraint. The second paper derived the Necessary Triad — the Acyclic Vacuum, Maximal Parallelism, and Global Register — as logically inevitable consequences of relational axioms, providing the foundational structure for consistent evolution.

This third paper extends the framework to address the ultimate emergence: the self-organization of the discrete, relational graph into a smooth, four-dimensional pseudo-Riemannian manifold, the arena of general relativity. We formalize this as the Continuum Limit Conjecture, positing that the rewrite rule R, governed by the triad, drives any non-geometric initial state toward a continuum limit. While full simulations are planned to empirically validate this conjecture — anticipated to show convergence across multiple metrics — this draft serves as a detailed, verbose outline of the intended paper. It includes rigorous mathematical definitions, proxy derivations, simulation protocols, and anticipated results based on preliminary analytical reasoning and napkin math extrapolations from prior simulations.

The outline is structured as follows: Section 2 states the conjecture formally, with lemmas supporting its plausibility; Section 3 details the simulation methods, emphasizing proxies for tractability; Section 4 describes expected results and interpretations; Section 5 discusses limitations and future work; and Section 6 concludes with the series' synthesis.

### 1.1 Motivation and Logical Necessity

The conjecture is motivated by the triad's interdependence: the Acyclic Vacuum provides a symmetric, featureless substrate; Maximal Parallelism ensures equitable evolution without external ordering; and the Global Register enforces global consistency holographically. Together, these are anticipated to yield a manifold-like state, as local 3-cycle formation (geometry quanta) under purity constraints should homogenize curvature and stabilize dimensionality.

Preliminary reasoning suggests 4D emergence: The b=3 branching in the vacuum implies hyperbolic latent structure, but saturation (N3 ≈ 42 from Paper 1) and parallelism are expected to flatten it to near-zero curvature, with spectral methods converging to d_S = 4. This aligns with holographic principles, where the register's boundary encodes bulk geometry.

---

## 2. Formal Statement of the Continuum Limit Conjecture

Let G_b,N,g denote the ensemble of finite, directed, simple, connected graphs G0 = (V0, E0) satisfying:

- b-regular: deg(v) = b >= 3 (sum of in- and out-degree) for all v in V0.
- Large girth: girth(G0) > log_b(N), ensuring local acyclicity.
- |V0| = N, typically large (N >= 1024).

This ensemble approximates the Zero-Point Information (ZPI) vacuum from Paper 2, a pre-geometric, acyclic, homogeneous substrate akin to a Bethe fragment. Directed edges encode causal relations, while the underlying undirected graph — obtained by symmetrizing the adjacency matrix: (u,v) in E_undirected if (u,v) in E_t or (v,u) in E_t — preserves metric and spectral structure for standard graph-theoretic analysis.

Let R be the CLC rewrite rule from Paper 1: a maximally parallel, stochastically accepted transformation enforcing the Geometric Purity Constraint (3-cycles only) and consistency via a holographic Global Register. The sequence {G_t} from t=0 to infinity is the stochastic process generated by R on G0 sampled from G_b,N,g.

> **Conjecture (Continuum Limit)**  
> As t, N → infinity (with t proportional to N^2), the sequence {G_t} converges to a smooth, compact, 4D pseudo-Riemannian manifold (M, g_mu_nu), with Lorentzian signature emerging from the causal structure of the boundary-projected state.

Convergence is anticipated to be verified across four independent criteria, ensuring topological, metric, curvature, and differential consistency. The joint limit reflects the expected computational complexity: full homogenization requires O(N^2) steps for pairwise interactions.

---

### 2.2 Supporting Lemmas for Plausibility

To motivate the conjecture analytically, we provide lemmas linking the triad to manifold-like properties.

> **Lemma 1 (Dimensional Stabilization from Branching)**  
> For a b-regular vacuum with b=3, the latent hyperbolicity (connectivity V(r) ~ 2^r) under saturation (N3 ≈ 42 from Paper 1) is expected to yield d_S → 4, as excessive branching is pruned by the purity constraint.

> *Proof (Sketch)*: The vacuum's exponential growth implies initial d_S ≈ 2 (tree-like). 3-cycle formation increases effective dimensionality by triangulating, with saturation capping at d_S = 4 via holographic bounds (register's code distance ~ sqrt(N), Paper 2). Full proof awaits simulations.

> **Lemma 2 (Curvature Homogenization)**  
> The Global Register's error correction is anticipated to enforce uniform Ollivier-Ricci curvature kappa ≈ 0, as inconsistencies (high-curvature regions) are corrected.

> *Proof (Sketch)*: High kappa regions correspond to error syndromes in the register's stabilizer code. Parallel correction (triad) flattens them, yielding unimodal rho(kappa) with skewness → 0.

These lemmas suggest the conjecture is plausible; simulations are expected to confirm numerical values (e.g., d_S = 3.98 ± 0.05 as anticipated).

---

### 2.3 Convergence Criteria

#### 2.3.1 Topological Convergence: Spectral Dimension

The spectral dimension d_S(G_t) is defined via the random walk return probability P_v(t) on the undirected graph of G_t:

d_S(G_t) := -2 * lim(t→∞) [ log( average_v P_v(t) ) / log(t) ]

**Criterion**: Expectation over G0 of d_S(G_t) → 4 ± 0.1. Simulations are anticipated to show initial d_S ≈ 2 (tree-like) rising to 4, reflecting manifold topology.

#### 2.3.2 Metric Convergence: Gromov-Hausdorff Distance

For the shortest-path metric d_graph on G_t and a 4D Riemannian manifold M (e.g., S^4), the Gromov-Hausdorff distance is:

d_GH(G_t, M) := inf over f, g, Z of max{ d_H^Z( f(V_t), g(M) ) }

where f, g are isometric embeddings into a metric space Z, and d_H^Z is the Hausdorff distance.

**Criterion**: Expectation over G0 of d_GH(G_t, M) < 0.01 * sqrt(N). We anticipate simulations to show decreasing d_GH, aligning with flat geometry from Paper 1.

#### 2.3.3 Curvature Convergence: Ollivier-Ricci Curvature

For edge (v, u) in E_t, the Ollivier-Ricci curvature is:

kappa(v, u) := 1 - [ W1(m_v, m_u) / d_graph(v, u) ]

where m_v is the uniform measure on v’s neighbors, and W1 is the Wasserstein-1 distance.

Let rho_t(kappa) be the curvature distribution.

**Criterion**: Expectation over G0 of || rho_t(kappa) - rho_M(kappa) ||_L1 → 0, with rho_t(kappa) unimodal (skewness < 0.1, kurtosis ≈ 3). Simulations are expected to show broadening then peaking at kappa ≈ 0.

#### 2.3.4 Differential Structure Convergence: Laplacian Spectrum

The normalized graph Laplacian is:

Delta_Gt f(v) := f(v) - (1/deg(v)) * sum_{u ~ v} f(u)

Let {lambda_k^(t)} be its eigenvalues, and {lambda_k^M} those of the Laplace-Beltrami operator on M.

**Criterion**: Expectation over G0 of |lambda_k^(t) - lambda_k^M| → 0 for fixed k, with spectral density rho_t(lambda) converging weakly to rho_M(lambda). Anticipated results include lambda_k proportional to k(k+3) for S^4-like M.

---

### 2.4 Convergence Proxies for Computational Feasibility

Direct computation of d_GH and rho_M(kappa) is intractable for large N. We use the following proxies, anticipated to converge as follows:

- **Spectral Embedding Distortion**: Embed G_t into R^4 using the first four non-trivial Laplacian eigenvectors phi_k. Compute:  
  distortion = (1/|E_t|) * sum_{(u,v) in E_t} | ||phi(u) - phi(v)||_2 - d_graph(u,v) |  
  **Criterion**: Expectation over G0 of distortion → 0. Simulations are expected to show distortion < 0.05 after t=1000 steps.

- **Curvature Variance**: Compute Var(kappa) over sampled edges.  
  **Criterion**: Expectation over G0 of Var(kappa) → 0, indicating a smooth manifold. Anticipated variance < 0.01, with unimodal distribution.

- **Spectral Gap Stability**: Compute the spectral gap lambda_2^(t) - lambda_1^(t) of Delta_Gt.  
  **Criterion**: Expectation over G0 of gap stabilizes, reflecting consistent manifold topology. Expected gap ≈ 0.03 for 4D.

---

### 2.5 Remarks

- Limits are joint (t proportional to N^2 ensures sufficient evolution, based on Paper 1's step scaling).
- M is emergent, hypothesized as S^4 or flat R^4 for simulation benchmarks.
- The Lorentzian signature is anticipated to emerge from causal depth to the boundary, via the triad's register.
- All criteria are independent, ensuring a robust continuum limit; failure in any (e.g., d_S ≠ 4) would falsify the conjecture.

---

## 3. Methods: Simulation Framework

To test the Continuum Limit Conjecture, we outline a Python-based framework using SageMath 10.3, NetworkX 3.2, NumPy 1.26, SciPy 1.11, and POT 0.9. Hardware: Intel i7-12700, 16GB RAM, CPU-only. The methods are designed to reuse and extend the simulation protocols from Paper 1, ensuring series consistency.

### 3.1 Graph Generation

We plan to generate 100 graphs from G_3,1024,g, with b=3, N=1024, girth g > ceil(log3(1024)) ≈ 7. Rejection sampling ensures high girth, with metadata (n, b, girth, seed, rejections) logged to `ensemble_n1024_b3.csv`. For alignment, we reuse Paper 1's Bethe fragment generation, anticipated to produce graphs with 90% 3-regularity.

### 3.2 Parallel Evolution

The rewrite rule R (parameters: alpha=1.0, T=1/ln(N)) applies 3-cycle-forming edge additions in parallel, enforcing purity (no 2-cycles or k>3 cycles) via a QECC-like Global Register. Evolution runs for T_max=2000 steps or until convergence (<1 edge added), as validated in Paper 1. The framework is expected to handle N=5120, with parallelism ensuring symmetry preservation (Paper 2).

### 3.3 Observable Tracking

We compute:

- d_S via the heat kernel method, fitting log( average_v P_v(t) ) ~ -d_S/2 * log(t) for t=10 to 100, anticipated to stabilize at 4.
- kappa(v, u) for 1000 sampled edges using Sinkhorn’s algorithm for W1, with skewness and kurtosis for unimodality, expected to peak at 0.
- First 5 Laplacian eigenvalues via Lanczos method, plus spectral gap, anticipated to match S^4 pattern lambda_k proportional to k(k+3).

Data is planned to be logged to `evolution_trajectories.csv`, with anticipated trends showing convergence after t=1000.

### 3.4 Reproducibility Checklist

- Software: Python 3.11, SageMath 10.3, NetworkX 3.2, NumPy 1.26, SciPy 1.11, POT 0.9.
- Seed: 2025 (incremented per graph).
- Outputs: CSVs (`ensemble_*.csv`, `evolution_trajectories.csv`).
- Anticipated Runtime: ~2h for N=1024, 100 runs.

---

## 4. Anticipated Results

While full simulations are pending, preliminary analytical reasoning and extrapolations from Paper 1 anticipate the following outcomes.

### 4.1 Topological Convergence

Simulations are expected to show d_S evolving from ≈ 2 (initial tree-like) to 3.98 ± 0.05 (final), converging to 4.

**Table: Anticipated final observables at N=1024 (100 runs)**

| Metric                 | Expected Mean | Expected SEM |
|------------------------|---------------|--------------|
| Spectral Dimension (d_S) | 3.98          | 0.05         |
| Curvature Mean (kappa)   | 0.05          | 0.01         |
| Curvature Skewness       | 0.1           | 0.02         |
| Distortion               | 0.03          | 0.005        |
| Spectral Gap             | 0.02          | 0.003        |

*Figure placeholder: Anticipated evolution of spectral dimension d_S over steps (mean ± SEM, 100 trajectories).*

### 4.2 Metric and Curvature Convergence

Distortion is anticipated to decrease to < 0.03, and curvature distribution to become unimodal with variance → 0, reflecting flat geometry.

### 4.3 Differential Structure

Eigenvalues are expected to stabilize to lambda_k proportional to k(k+3), with spectral gap ≈ 0.02, consistent with a 4-sphere-like manifold.

These anticipated results, if confirmed by simulations, would validate the conjecture and align with Paper 1's saturation leading to manifold emergence.

---

## 5. Limitations and Future Work

This outline acknowledges limitations: finite N may not fully capture infinite limits; proxies approximate direct metrics. Future simulations will scale to N=5120, add sensitivity to alpha and b, and incorporate noisy initials. Analytical proofs for lemmas will be pursued, potentially linking to holographic QECCs from Paper 2.

---

## 6. Conclusion

This verbose outline anticipates that CLC's dynamics, rooted in relational primitives and the Necessary Triad, yield a 4D manifold in the continuum limit. Simulations are expected to confirm this, completing the series' demonstration of emergent spacetime from first principles.

---

## 7. References

1. R. Fisher, “Geometrogenesis and Inflation in Causal Loop Cosmology,” arXiv:2509.xxxxx (2025).  
2. R. Fisher, “The Necessary Triad: Symmetry and Consistency in Causal Loop Cosmology,” arXiv:2509.xxxxx (2025).  
3. J. Ambjørn, D. Benedetti, J. Jurkiewicz, R. Loll, “The spectral dimension of discrete quantum gravity,” Phys. Rev. D 85, 124027 (2012).  
4. D. Burago, Y. Burago, S. Ivanov, “A Course in Metric Geometry,” AMS, 2001.  
5. Y. Ollivier, “Ricci curvature of Markov chains on metric spaces,” J. Funct. Anal. 256(3), 810–864 (2009).  
6. Y. Lin, L. Lu, S.-T. Yau, “Ricci curvature of graphs,” Tohoku Math. J. 63, 605–627 (2011).  
7. M. Belkin, P. Niyogi, “Convergence of Laplacian eigenmaps,” Adv. Neural Inf. Process. Syst. 21, 129–136 (2008).