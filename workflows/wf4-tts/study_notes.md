# Density-Based Clustering and Cluster Validation

## 1. DBSCAN: Density-Based Spatial Clustering

DBSCAN clusters points based on local density rather than distance to a centroid. It requires two parameters:

- **Eps ($\varepsilon$)**: the radius that defines the neighbourhood around a point.
- **MinPts**: the minimum number of points that must fall within the Eps-neighbourhood for a point to be considered dense.

### Point Classification

Every point in the dataset is labelled as one of three types:

- **Core point** — has at least MinPts neighbours within Eps. Core points lie in the interior of a cluster.
- **Border point** — has fewer than MinPts neighbours within Eps but falls within the Eps-neighbourhood of at least one core point.
- **Noise point** — neither a core point nor a border point. These are outliers that do not belong to any cluster.

### DBSCAN Algorithm Steps

1. Find the Eps-neighbours of every point and identify all core points (those with at least MinPts neighbours).
2. Form connected components of core points on the shared-neighbourhood graph. All non-core points are temporarily ignored in this step.
3. Assign each non-core point to a nearby cluster if that cluster is within Eps distance; otherwise, mark the point as noise.

### Strengths and Limitations

**Strengths:**
- Resistant to noise — outliers are explicitly identified rather than forced into clusters.
- Can discover clusters of arbitrary shape and size, not just spherical groups.

**Limitations:**
- Struggles when clusters have varying densities. A single Eps value cannot simultaneously suit both dense and sparse regions.
- Performance degrades in high-dimensional data where distance-based neighbourhoods become less meaningful.

---

## 2. Cluster Validation

### Why Validate Clusters?

Clustering is unsupervised, so there is no direct label-based metric analogous to classification accuracy. Validation is needed to:

- Avoid finding patterns in random noise.
- Compare different clustering algorithms.
- Compare two sets of clusters or two individual clusters.
- Estimate the correct number of clusters.

As Jain and Dubes noted, cluster validation is the most difficult part of cluster analysis; without it, the process remains subjective.

### Aspects of Cluster Validation

1. **Clustering tendency** — does the data contain any non-random structure at all?
2. **External validation** — compare cluster labels against known class labels.
3. **Internal validation** — evaluate fit using only the data itself, with no external reference.
4. **Relative comparison** — decide which of two clusterings is better (often using an external or internal index for this purpose).
5. **Determining the number of clusters** — use an index across multiple values of $k$ and look for an elbow or optimum.

Aspects 2–4 can evaluate either the entire clustering or individual clusters.

---

## 3. Types of Validity Indices

### External Index

Measures how well cluster labels match externally supplied class labels.

- **Entropy** — quantifies the class-label mix within each cluster. Lower entropy means purer clusters.
- **Purity** — the fraction of the dominant class in each cluster. Higher purity is better.

Both are computed per-cluster and then combined into an overall score weighted by cluster size.

### Internal Index

Measures clustering quality using only the data, with no external labels.

- **Sum of Squared Error (SSE)** — the most common internal measure for centroid-based methods.

### Relative Index

Compares two clusterings. Often an external or internal index (such as SSE or entropy) is repurposed for this role.

The terms "index" and "criterion" are sometimes used interchangeably, though "criterion" can refer to the general strategy while "index" refers to the numerical measure that implements it.

---

## 4. Measuring Validity via Correlation

This approach compares two matrices:

- **Proximity matrix** — contains pairwise distances (or similarities) between all points.
- **Incidence matrix** — binary matrix where an entry is 1 if the two points are in the same cluster and 0 otherwise.

The correlation between these two matrices is computed. A high negative correlation (when using distances) or high positive correlation (when using similarities) indicates that points in the same cluster are close to each other.

**Limitation:** This approach is not effective for some density-based or contiguity-based clusters, where within-cluster distances can vary widely.

---

## 5. Similarity Matrix for Visual Validation

Ordering the rows and columns of the similarity matrix by cluster label produces a heatmap that can be inspected visually:

- **Well-separated clusters** appear as dark/high-similarity blocks along the diagonal.
- **Poorly separated or random data** shows no clear block structure.

This visual method works alongside numerical indices and can quickly reveal whether a clustering algorithm has found meaningful structure or is fitting noise.

---

## 6. Internal Measures: Cohesion and Separation

### Cohesion

Measures how closely related the objects within a single cluster are.

- **Within-cluster Sum of Squares (WSS):**

$$WSS = \sum_{i} \sum_{x \in C_i} (x - m_i)^2$$

where $m_i$ is the centroid of cluster $i$. SSE is a specific case of cohesion.

### Separation

Measures how distinct a cluster is from other clusters.

- **Between-cluster Sum of Squares (BSS):**

$$BSS = \sum_{i} |C_i| (m - m_i)^2$$

where $m$ is the overall mean and $|C_i|$ is the size (number of points) of cluster $i$.

**Relationship:** Total sum of squares equals WSS plus BSS. A good clustering minimises WSS (tight clusters) and maximises BSS (well-separated clusters).

### Proximity Graph Approach

Cohesion and separation can also be defined using a graph where nodes are data points and edge weights represent proximity:

- **Cohesion** = sum of the weights of all edges within a cluster.
- **Separation** = sum of the weights of edges connecting nodes inside the cluster to nodes outside it.

---

## 7. External Measures: Entropy and Purity

### Entropy

1. For each cluster $j$, compute the class distribution: $p_{ij} = m_{ij} / m_j$, where $m_{ij}$ is the number of points of class $i$ in cluster $j$ and $m_j$ is the total number of points in cluster $j$.
2. Entropy of cluster $j$: $e_j = -\sum_{i=1}^{L} p_{ij} \log_2 p_{ij}$, where $L$ is the number of classes.
3. Overall entropy: $e = \sum_{j=1}^{K} \frac{m_j}{m} e_j$, where $K$ is the number of clusters and $m$ is the total number of data points.

Lower entropy means each cluster contains predominantly one class.

### Purity

1. Purity of cluster $j$: $\text{purity}_j = \max_i \, p_{ij}$ — the proportion of the most frequent class.
2. Overall purity: $\text{purity} = \sum_{j=1}^{K} \frac{m_j}{m} \, \text{purity}_j$.

Higher purity indicates better alignment between clusters and class labels. Purity ranges from 0 to 1, where 1 means every cluster is perfectly pure.

### Example

In the LA Document Data Set clustered with K-means (6 clusters, 6 classes), the overall entropy was 1.1450 and the overall purity was 0.7203, showing moderate alignment between discovered clusters and true document categories.
