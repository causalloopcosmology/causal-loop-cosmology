# **Thermodynamic Graph Rewriting: A Category-Theoretic Model of Emergent Spacetime**

**Author:** R. Fisher
**Date:** September 9, 2025

-----

## Abstract

> We present a rigorous, computationally implementable model of emergent spacetime, wherein a geometric universe arises from a discrete, pre-geometric causal network. The causal structure is formalized as a category in which the formation of 3-cycles introduces a metric. The dynamics are defined by a thermodynamically-guided graph rewrite rule. We demonstrate via extensive ensemble simulations across a wide range of system sizes that a singular "energic event" triggers a rapid, inflationary phase of geometrogenesis. This expansion naturally terminates due to a geometric purity constraint, causing the system's mean complexity to saturate at a stable, scale-invariant value. We conclude that in this framework, an inflationary epoch is a logically necessary consequence of the foundational axioms.

-----

## 1. Introduction

A primary challenge in fundamental physics is the reconciliation of general relativity and quantum mechanics, a pursuit which has led to numerous proposals for an underlying theory of quantum gravity. A recurring theme in such research is the concept of emergent spacetime, wherein spacetime is not a fundamental entity but a coarse-grained description of a deeper, discrete structure. This work contributes to that paradigm by proposing a model based on a network of causal relations.

This paper challenges the axiomatic assumption that a strictly acyclic causal structure, as posited in approaches like Causal Set Theory (CST) (Dowker, 2005), must be preserved at all scales. We posit that the foundational graph is a *pre-geometric but causal* substrate. The formation of microscopic 3-cycles is not a violation of this causality, but rather the mechanism by which *metric information* (a "clock") emerges. This view contrasts with formalisms that presuppose a metric structure rather than explain its origin. Herein, we detail the mathematical foundations of this structure, define its dynamics, and provide extensive computational evidence for its core claims.

-----

## 2. Foundations: The Causal Graph as a Category

### 2.1 The Pre-Geometric, Causal Substrate

We define the causal graph G\_t = (V\_t, E\_t) at discrete logical time t as a *finite directed acyclic graph (DAG)*. The vertex set V\_t represents a finite collection of discrete events. The edge set E\_t is a subset of V\_t x V\_t, and represents primitive causal relations: (v, w) being an element of E\_t implies that event v causally precedes event w. This establishes a fundamental "before and after" relationship. The initial state of the system, the Zero-Point Information (ZPI) vacuum, is a large but finite network of these causal links, structured as a Bethe fragment. Mathematically, this is a partially ordered set (poset) which is pre-geometric; it contains a well-defined causal order but lacks an inherent metric.

**Definition 2.1 (Causal Category C\_t)**

> The causal category C\_t associated with G\_t is defined as follows:
>
>   * **Objects**: Obj(C\_t) = V\_t, the set of events.
>   * **Morphisms**: For v, w in V\_t, a morphism p: v -\> w is a finite directed path from v to w in G\_t.
>   * **Identity**: For each v in V\_t, the identity morphism id\_v: v -\> v is the null path (a path of length 0).
>   * **Composition**: For morphisms p: u -\> v and q: v -\> w, their composition q o p: u -\> w is path concatenation.

### 2.2 The 3-Cycle as the Genesis of Metric

A 3-cycle in G\_t is a directed cycle of length three: (v, w), (w, u), (u, v). This is the smallest possible non-trivial, closed path in the graph. As a recurring, self-referential structure, it provides the first stable standard against which intervals can be quantified; it functions as the universe's first "clock." The formation of a 3-cycle is the moment that metric information is introduced into the purely causal network. Consequently, this is the moment geometry emerges. The density of such cycles is related to discrete notions of Ricci curvature (Ollivier, 2009).

**Proposition 2.1**

> The number of distinct directed 3-cycles in G\_t is given by N\_3 = (1/3) \* tr(A\_t^3), where A\_t is the adjacency matrix of G\_t.

-----

## 3. Dynamics: Inflationary Geometrogenesis

The evolution of the causal graph is governed by a set of local, parallel rewrite rules, driven by a thermodynamic principle inspired by the thermodynamics of spacetime (Jacobson, 1995).

### 3.1 The Initial Energic Event

The ZPI vacuum represents the ground state of the universe: maximally symmetric and inert. The formation of the first 3-cycle is a spontaneous symmetry-breaking event. This *initial energic event* raises the system from its ground state to an excited, unstable state. The excess free energy from this singular fluctuation is then dissipated through the inflationary dynamic. Our simulation protocol models this by algorithmically generating a large Bethe fragment and then embedding a single, primordial 3-cycle.

### 3.2 The Rewrite Rule

The evolution from G\_t to G\_(t+1) is governed by a state-dependent stochastic process.

**Definition 3.1 (Rewrite Rule R)**

> The rewrite rule R transforms G\_t into G\_(t+1) as follows:
>
> 1.  **Proposal**: For every directed path of length two, v -\> w -\> u, a new edge (u,v) is proposed to close the path into a 3-cycle.
> 2.  **Evaluation**: The proposal is accepted if it satisfies the Geometric Purity Constraint (Sec 3.3) and a thermodynamic probability check (Sec 3.4).
> 3.  **Application**: All accepted proposals are applied simultaneously to form G\_(t+1).

### 3.3 The Geometric Purity Constraint

To ensure the dynamics produce a clean geometric structure, a purity constraint is enforced. The creation of a 3-cycle via a new edge (u,v) is a "pure" quantum of geometrogenesis only if it does not simultaneously create any longer cycles. This is enforced by verifying that the only pre-existing path from v to u is the single 2-path v -\> w -\> u that prompted the proposal. This constraint serves a dual role: it ensures pure 3-cycle creation and acts as a self-limiting mechanism that provides a graceful exit from the inflationary phase. As the graph becomes more connected, it becomes increasingly difficult to satisfy this constraint, naturally arresting the reaction.

### 3.4 Thermodynamic Framework

The acceptance of a permissible proposal is governed by a probability derived from a free energy functional, Delta F = alpha \* Delta rho\_C - T \* Delta S.

**Definition 3.2 (Thermodynamic Quantities)**

> For the addition of an edge that forms a pure 3-cycle:
>
>   * Delta rho\_C = 1: One new 3-cycle is formed.
>   * Delta S = 1: One bit of information, consistent with the Bekenstein bound (Bekenstein, 1981).
>   * T = 1 / ln(N): An emergent temperature, where N is the total number of vertices.
>   * alpha: A scaling constant of order unity in natural units.
>
> The acceptance probability is P = min(1, exp(-Delta F / T)).

-----

## 4. Computational Methods and Results

### 4.1 Simulation Protocol & Parameter Justification

To investigate the dynamics of inflationary geometrogenesis, we developed a computational model in SageMath (v10.4+). The protocol for each simulation run consists of three stages: initialization of a pre-geometric vacuum state, injection of a primordial geometric seed, and evolution of the system via a thermodynamically-guided parallel rewrite rule. The specific parameters governing the simulations were determined through a series of preliminary validation experiments.

The ZPI vacuum is constructed as a finite DAG approximating a Bethe fragment. Starting from a single root node with three children, the graph is generated layer-by-layer, with all subsequent nodes having two children, until the graph order reaches a pre-specified approximate size N. The initial energic event is modeled by injecting a single 3-cycle, created by adding a directed edge from a node in the third layer to the root node.

The system evolves via the parallel rewrite rule R, continuing until a fixed point is reached where no further 3-cycles can be formed. Preliminary experiments confirmed that a maximum of 2,000 steps is sufficient to ensure all simulations reach this natural termination. To validate the choice of the size-dependent temperature T = 1/ln(N), it was tested against a constant-temperature model, which exhibited runaway growth, justifying our use of the self-regulating, scale-dependent formulation. The statistical robustness of our findings was confirmed via convergence analyses, which showed that an ensemble size of 5,000 runs is sufficient for stable and reproducible results.

The primary ensemble results presented in this paper were generated using a scaling constant of alpha = 1.0. The main sequence of simulations was initiated with a fixed pseudo-random seed of 42 to ensure reproducibility. As noted, convergence and robustness checks were also performed with an alternate seed (137) to confirm that the results are not dependent on this choice.

### 4.2 Ensemble Results and Scaling Analysis

To characterize the statistical properties and scaling behavior of the model, we performed large-scale ensemble simulations (5,000 runs each) across a comprehensive range of initial system sizes, from small graphs of N ≈ 40 to large networks of N ≈ 5120. This extensive survey, spanning over two orders of magnitude in system scale, allows for a definitive characterization of the geometrogenesis process.

#### 4.2.1 Saturation of Geometric Complexity at Scale

The primary result of the scaling analysis is the discovery that the mean final geometric complexity, mean N\_3, does not grow indefinitely with system size. As shown in **Table 1** and **Figure 1**, mean N\_3 increases for smaller systems but then **saturates**, reaching a stable plateau of approximately mean N\_3 ≈ 42 for all system sizes from N ≈ 300 upwards. This saturation is a critical finding, suggesting that the self-limiting nature of the Geometric Purity Constraint creates a characteristic, scale-invariant density of geometric information.

While the mean complexity saturates, the variance of outcomes continues to increase with system size. The standard deviation grows from 16.45 for N ≈ 40 to 43.00 for N ≈ 5120, indicating that larger systems can explore a much wider range of possible final states.

#### 4.2.2 The Shape of the Outcome Distribution

The shape of the probability distribution for the final N\_3 count reveals a consistent dynamical behavior. For all system sizes, the distribution is unimodal and exhibits a persistent **positive skew**. This indicates that while most runs terminate with a modest complexity near the median (which remains stable around 29-30), there is a long tail of rare "jackpot" events that produce exceptionally high geometric complexity.

Furthermore, the probability of the process "fizzling" (terminating with N\_3=1) consistently decreases as the system size grows, from over 10% in the smallest systems to under 2.5% in the largest. This suggests that while geometrogenesis is always stochastic, its likelihood of success and robust expansion becomes nearly certain in larger vacuum states.

**Table 1:** Detailed statistical summary for the final 3-cycle count (N\_3) from ensembles of 5,000 runs. The mean complexity (mean N\_3) saturates around a value of 42 for all N \>= 300, while the standard deviation continues to grow.

| Metric | N≈40 | N≈80 | N≈160 | N≈300 | N≈320 | N≈360 | N≈640 | N≈960 | N≈1280 | N≈1600 | N≈1920 | N≈2560 | N≈5120 |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| Mean (N\_3) | 24.29 | 31.70 | 37.32 | 41.31 | 41.33 | 41.97 | 42.43 | 41.67 | 42.27 | 42.37 | 41.56 | 41.53 | 42.68 |
| Std. Dev. (sigma) | 16.45 | 24.53 | 33.49 | 40.80 | 41.15 | 41.34 | 43.82 | 42.32 | 41.17 | 43.79 | 42.12 | 41.74 | 43.00 |
| Skewness | 0.81 | 1.34 | 1.81 | 2.15 | 2.21 | 2.32 | 2.95 | 2.88 | 2.97 | 2.97 | 2.98 | 3.45 | 3.46 |
| Median | 23.0 | 27.0 | 28.0 | 28.5 | 28.0 | 29.0 | 28.0 | 29.0 | 30.0 | 29.0 | 29.0 | 29.0 | 29.0 |
| P(N\_3=1) | 10.8% | 9.9% | 8.9% | 7.9% | 7.5% | 6.7% | 5.9% | 4.9% | 3.9% | 3.4% | 2.9% | 2.4% | 2.2% |
| Max (N\_3) | 78 | 124 | 198 | 281 | 330 | 323 | 435 | 370 | 315 | 416 | 416 | 381 | 301 |

\<br\>

**Figure 1:** Saturation of the mean final 3-cycle count (mean N\_3) as a function of initial system size (N). The y-axis shows the ensemble average of the final N\_3 count. The mean complexity grows for small N before reaching a stable plateau around mean N\_3 ≈ 42 for N \>= 300. Error bars represent the standard error of the mean.

-----

## 5. Discussion

### 5.1 Inflation and Complexity Saturation

The simulations provide definitive computational evidence that an inflationary epoch is not a fine-tuned or ad hoc feature of this model. It is the system's initial, explosive rush towards its geometric ground state. The subsequent saturation of the mean complexity is an equally necessary consequence of the Geometric Purity Constraint. This suggests that the universe, under these rules, naturally evolves towards a state with a stable, characteristic density of geometric information, a feature that is robust across multiple orders of magnitude in system scale.

### 5.2 Future Work and Open Challenges

The framework faces several profound challenges that are the focus of ongoing research:

  * **The Continuum Limit**: A rigorous proof that the graph dynamics self-organize into a manifold-like state.
  * **Lorentz Invariance**: A demonstration that an approximate Lorentz symmetry emerges at large scales.
  * **The Standard Model**: A mechanism for the emergence of particle content from topological features of the graph.

-----

## 6. Conclusion

We have presented a complete, self-contained model for emergent, inflationary spacetime. By positing a pre-geometric, causal substrate and a thermodynamically-driven rewrite rule, we have shown how a singular energic event necessarily leads to a rapid phase of geometrogenesis that naturally stabilizes. Extensive numerical ensemble simulations confirm that while the precise outcome of any single evolution is stochastic, the average final geometric complexity saturates at a scale-invariant value. This work establishes a rigorous, reproducible, and testable foundation for deriving the laws of physics from combinatorial first principles.

-----

## Acknowledgements

The author acknowledges the open-source community for providing the tools that enabled this computational exploration, particularly the developers of SageMath.

-----

## References

  * Bekenstein, J. D. (1981). Universal upper bound on the entropy-to-energy ratio for bounded systems. *Phys. Rev. D*, 23:287.
  * Dowker, F. (2005). Causal sets and the deep structure of spacetime. In *100 Years of Relativity*, World Scientific.
  * Jacobson, T. (1995). Thermodynamics of spacetime: The Einstein equation of state. *Phys. Rev. Lett.*, 75:1260.
  * Ollivier, Y. (2009). Ricci curvature of Markov chains on metric spaces. *Journal of Functional Analysis*, 256(3):810–864.