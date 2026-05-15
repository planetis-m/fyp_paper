# Density-Based Clustering and Cluster Validation

## DBSCAN: Density-Based Spatial Clustering

DBSCAN groups points by local density rather than by distance to centroids or by merging clusters hierarchically. Two parameters control the algorithm:

- **Eps (ε):** the radius that defines the neighbourhood around a point.
- **MinPts:** the minimum number of points that must fall within the Eps-radius for a point to qualify as dense.

### Point Classification

Every data point is labelled as exactly one of three types:

- **Core point** — has at least MinPts neighbours within distance Eps. Core points sit in the interior of a cluster.
- **Border point** — has fewer than MinPts neighbours within Eps, but falls within the Eps-neighbourhood of at least one core point.
- **Noise point** — neither a core point nor reachable from any core point. Noise points are excluded from all clusters.

### Algorithm Steps

1. Find the Eps-neighbours of every point. Identify all core points (those with at least MinPts neighbours).
2. Build a neighbour graph over the core points alone. Find the connected components of this graph — each component becomes one cluster.
3. For each non-core point, assign it to a cluster if it lies within Eps of a core point in that cluster. Otherwise label it as noise.

### Strengths

- Naturally resistant to noise — outliers become noise points.
- Discovers clusters of arbitrary shape and size, not just convex blobs.

### Limitations

- Struggles when clusters have **varying densities** because a single Eps/MinPts pair cannot adapt to both sparse and dense regions.
- Performs poorly on **high-dimensional data** where distance concentrations make neighbourhoods less meaningful.

---

## Cluster Validation

Cluster validation asks whether the clusters we found are meaningful or just artefacts of the algorithm. Unlike supervised classification (where we have accuracy, precision, recall), clustering has no ground truth by default, making evaluation harder.

### Why Validate Clusters?

- To avoid finding patterns in random noise.
- To compare different clustering algorithms.
- To compare two sets of clusters or two individual clusters.
- To estimate the correct number of clusters.

### Aspects of Validation

1. **Clustering tendency** — does the data contain non-random structure at all?
2. **External validation** — compare cluster labels to known class labels.
3. **Internal validation** — assess fit using only the data itself.
4. **Relative validation** — compare two clusterings to decide which is better.
5. **Determining K** — find the correct number of clusters.

### Types of Validity Indices

| Type | Definition | Example |
|---|---|---|
| **External Index** | Measures agreement between cluster labels and externally supplied class labels | Entropy |
| **Internal Index** | Measures goodness of clustering structure without external information | SSE |
| **Relative Index** | Compares two different clusterings | SSE or Entropy reused for comparison |

The terms "criterion" and "index" are sometimes used interchangeably; strictly, the criterion is the strategy and the index is the numerical measure that implements it.

---

## Validation Via Correlation

Construct two matrices over all pairs of data points:

- **Proximity matrix** — contains the pairwise distances (or similarities).
- **Incidence matrix** — 1 if two points belong to the same cluster, 0 otherwise.

Compute the correlation between these two matrices. A **high negative correlation** (for distance) or **high positive correlation** (for similarity) means that points in the same cluster tend to be close together — a good sign.

This approach works well for compact, centroid-based clusters but is **not reliable** for density-based or contiguity-based clusters, where points in the same cluster may be far apart in absolute distance.

### Similarity Matrix (Heatmap) Inspection

Order the similarity matrix rows and columns by cluster label and inspect visually:

- **Well-separated clusters** produce sharp, dense blocks of high similarity along the diagonal.
- **Random data** produces a diffuse heatmap with no clear block structure.

This visual check works for any clustering algorithm but is qualitative.

---

## Internal Measures: SSE, Cohesion, and Separation

### Sum of Squared Error (SSE)

$$WSS = \sum_{i} \sum_{x \in C_i} (x - m_i)^2$$

SSE measures the total squared distance of every point to its cluster centroid. It is a pure internal measure — no external labels needed.

- **Lower SSE** means tighter clusters.
- SSE can compare two clusterings on the same data or help estimate the number of clusters by looking for an "elbow" in the SSE-vs-K curve.

### Cohesion and Separation

- **Cohesion** — how closely related objects within a cluster are (within-cluster sum of squares, WSS).
- **Separation** — how distinct a cluster is from other clusters (between-cluster sum of squares, BSS).

$$BSS = \sum_{i} |C_i| (m - m_i)^2$$

where $|C_i|$ is the size of cluster $i$ and $m$ is the global mean.

A good clustering has **high cohesion** and **high separation**. These two are related: as cohesion decreases (WSS goes down), separation tends to increase (BSS goes up).

### Graph-Based Cohesion and Separation

Instead of squared error, use a proximity graph:

- **Cohesion** = sum of edge weights **within** a cluster.
- **Separation** = sum of edge weights **between** nodes in the cluster and nodes outside it.

---

## External Measures: Entropy and Purity

When true class labels are available, we can measure how well clusters align with known classes.

### Entropy

For each cluster $j$, compute the class distribution:

$$p_{ij} = \frac{m_{ij}}{m_j}$$

where $m_{ij}$ is the number of points of class $i$ in cluster $j$ and $m_j$ is the total size of cluster $j$.

The entropy of cluster $j$:

$$e_j = -\sum_{i=1}^{L} p_{ij} \log_2 p_{ij}$$

The **overall entropy** is the size-weighted average:

$$e = \sum_{j=1}^{K} \frac{m_j}{m} \, e_j$$

- **Lower entropy** means the cluster is dominated by a single class — desirable.
- Entropy is 0 when a cluster contains points from only one class.

### Purity

$$\text{purity}_j = \max_i \, p_{ij}$$

The **overall purity** is the size-weighted average:

$$\text{purity} = \sum_{j=1}^{K} \frac{m_j}{m} \, \text{purity}_j$$

- **Higher purity** means the cluster is dominated by a single class.
- Purity is 1 when every cluster contains points from only one class.

### Relationship Between Entropy and Purity

They measure the same thing from opposite directions: entropy penalises mixed clusters (lower is better) while purity rewards homogeneous ones (higher is better). Both require external class labels.

---

## Key Takeaways

- DBSCAN identifies clusters by local density, handles noise naturally, and finds arbitrary shapes — but fails with varying densities and high dimensions.
- Cluster validation is essential because algorithms will always produce clusters, even on random data.
- Internal measures (SSE, cohesion/separation, correlation) evaluate structure from the data alone.
- External measures (entropy, purity) evaluate alignment with known class labels.
- Visual tools like ordered similarity matrices give a quick qualitative check on cluster quality.
