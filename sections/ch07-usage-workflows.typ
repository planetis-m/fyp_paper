#import "../lib.typ": apa-figure

= Usage Scenarios and Workflow Evaluation <chap:workflows>

== Workflow 1: Essay Practice from Lecture Slides


*Goal and input.* A student preparing for a Data Mining examination requested essay-style practice from the Association Analysis lecture slides. The input was `08_Association_Analysis.pdf`, covering frequent itemsets, the Apriori principle, support, confidence, lift, and rule interestingness.

*User query*

```text
Use the study-assistant in essay mode on the lecture
slides at `08_Association_Analysis.pdf` for exam preparation
```


*Essential actions.* The agent identified the request as an essay-practice workflow, extracted the slide text through the OCR workflow, and generated examination-style questions from the extracted lecture content. The recorded output shows that the generation step was performed after the full slide text had been extracted, rather than from the file path alone.

*Result.* The output contained four essay questions with sample answers. The question set covered: the Apriori principle and support-based pruning; support, confidence, and lift using the Tea-Coffee example; two-stage association-rule mining and confidence pruning; and objective versus subjective interestingness measures. The answers were written in an exam-preparation style and used equations and examples from the lecture material.

*Representative essay output*

```text
Essay 1: Discuss the Apriori principle and explain how it reduces the computational cost of frequent itemset mining.

The Apriori principle states that if an itemset is frequent, then all of its subsets must also be frequent. Equivalently, if an itemset is infrequent, all of its supersets must be infrequent. This follows from the anti-monotone property of support: for any itemsets X and Y where X ⊆ Y, the support of X is always greater than or equal to the support of Y (s(X) ≥ s(Y)). This property allows pruning of the candidate space without evaluating every possible itemset.
```

The artefact provides source-grounded transformation from lecture slides into long-form revision practice. The generated answers require explanation and comparison, not only definition recall, which matches the requested essay mode.

== Workflow 2: RAG-Based Exam Revision


*Goal and input.* A student wanted a reusable searchable knowledge base from a textbook section, followed by a targeted revision query. The input was pages 358--402 of \*Introduction to Data Mining\*, covering classifier material including nearest-neighbour methods, Naive Bayes, Bayesian networks, and logistic regression.

*Storage query*

```text
Use the OCR tool to extract pages 358-402 from
*Introduction to Data Mining*, then use the RAG tool to
store the extracted text so I can search it later
for exam revision
```


*Essential actions.* The agent selected a two-phase OCR-to-RAG workflow. The store log records a cache miss, OCR extraction over 45 pages, cleaning of headers, footers, page numbers, and decorative boilerplate, semantic chunk preparation, and storage through the vector-store tool. The resulting document identifier was `intro-data-mining-ch4`.

*Storage result.* The processed textbook section was stored as 26 semantic chunks. The stored labels covered nearest-neighbour classifiers, Naive Bayes probability concepts, Bayes' theorem, conditional independence, zero-probability handling, Bayesian-network representation and inference, and logistic-regression training. The ingest artefact preserves explicit chunk boundaries using `<chunk page=... label="...">` markers, allowing stored passages to remain auditable after ingestion.

*Example stored evidence*

```text
<chunk page=404 label="Logistic Regression">
Logistic regression is a probabilistic discriminative model
that directly estimates the odds of a data instance using
its attribute values.
```


*Search query*

```text
Use the RAG tool to search my stored notes for
'how does the Naive Bayes classifier handle
zero probability conditions'
```


*Search result.* The retrieved answer matched the requested concept and returned the relevant smoothing methods:

*Representative search result*

```text
If the conditional probability for any attribute is zero, the entire class-conditional probability becomes zero. This happens when the number of training instances is small and the number of possible attribute values is large.

Example (Loan Default Prediction): For class Yes, no training instance has Marital Status=Married, so P(Status=Married|Yes) = 0, which zeroes out the entire product P(x|Yes).

Two alternate estimates to avoid vanishing probabilities:

- Laplace estimate: P(Xi=c|y) = (nc + 1) / (n + v), where v is the total number of values Xi can take.
- m-estimate: P(Xi=c|y) = (nc + m p) / (n + m), where p is a prior estimate of P(Xi|y) and m is a hyper-parameter indicating confidence in p.
```

The evidence supports persistence and reuse. The initial operation produced a searchable store from OCR-prepared textbook pages; the later operation retrieved a specific explanation without reprocessing the PDF.

== Workflow 3: Flashcard Generation for Active Recall


*Goal and input.* A student requested flashcards from the Anomaly Detection lecture for active recall and exam revision. The input was `07_Anomaly_Detection.pdf`, covering anomaly types, supervised and unsupervised settings, statistical tests, proximity methods, density-based scoring, Local Outlier Factor, and cluster-based outlier detection.

*User query*

```text
Use the study-assistant in flashcard mode on the
lecture slides at `07_Anomaly_Detection.pdf` for
exam revision
```


*Essential actions.* The agent loaded the study-assistant and OCR workflow rules, checked the OCR cache, recorded a cache miss, ran OCR over the lecture slides, and then generated flashcards from the extracted text. Only after OCR completion did the flashcard generation step proceed, which is relevant because the output was derived from the slide content rather than from a topic label.

*Result.* The output contained 25 flashcards in a two-column Front/Back table. The cards covered definitions, detection settings, scoring outputs, mathematical measures, method limitations, and application domains. #ref(<tbl:workflow-flashcards>) gives representative rows.


#apa-figure(
  table(
    columns: (2.35in, 3.65in),
    table.header([Front], [Back]),
    [What is an anomaly (outlier)?],
    [An object that is different from most other objects in the dataset.],
    [What are the three main causes of anomalies?],
    [Data from a different class or mechanism; natural variation; measurement or collection errors.],
    [Contextual anomaly],
    [An instance that is anomalous only within a specific context, such as 28 °C being normal in summer but anomalous in winter.],
    [Mahalanobis distance],
    [A multivariate generalisation of distance from the mean that accounts for correlations between variables.],
    [LOF (Local Outlier Factor)],
    [A relative density score comparing the average density of #emph[k] neighbours with the density of the point.],
    [Proximity-based outlier detection],
    [An outlier score based on distance to the #emph[k]-th nearest neighbour, with sensitivity to the choice of #emph[k].],
  ),
  caption: [Representative anomaly-detection flashcards],
  placement: none,
)<tbl:workflow-flashcards>


The output is structurally appropriate for active recall because each row separates the prompt from the expected answer. It also preserves technical breadth: simple definitions appear alongside formula-based concepts and method limitations.

#pagebreak()

== Workflow 4: Study Notes to Audio for Passive Revision

*Goal and input.* A student requested written notes and an audio version for listening-based revision. The input was `06_Clustering_Density_Validation.pdf`, covering DBSCAN, cluster validation, SSE, cohesion, separation, entropy, and purity.

*User query*

```text
Use the study-assistant in study-notes mode on the
lecture slides at `06_Clustering_Density_Validation.pdf`,
then use the TTS tool to convert the notes to audio
so I can listen while revising
```


*Essential actions.* The agent selected a multi-stage workflow: OCR extraction, study-note generation, speech rewriting, chunk marking, and audio synthesis. The recorded run shows that `pdfocr` and `chunktts` were both available, the OCR cache was hit for the slide extraction, notes were written first, the notes were then rewritten into TTS-oriented text, and audio generation was started after the `<bk>`-marked input had been prepared.

*Intermediate artefacts.* The notes artefact was `06_clustering_study_notes.md` (7,310 bytes). The TTS input was `06_clustering_tts_input.txt` (7,217 bytes), showing that the written notes were transformed rather than passed unchanged. The final audio artefact was `06_clustering_study_notes.opus` (2.1 MB), generated from 24 speech chunks.

*Representative study-note output*

```text
DBSCAN: Density-Based Spatial Clustering

DBSCAN groups points by local density rather than by distance to centroids or by merging clusters hierarchically. Two parameters control the algorithm:

- Eps (ε): the radius that defines the neighbourhood around a point.
- MinPts: the minimum number of points that must fall within the Eps-radius for a point to qualify as dense.
```

*Representative TTS-prepared output*

```text
DBSCAN, Density-Based Spatial Clustering. DBSCAN groups
points by local density rather than by distance to centroids
or by merging clusters hierarchically. Two parameters
control the algorithm. Eps, written epsilon, is the radius
that defines the neighbourhood around a point. MinPts is
the minimum number of points that must fall within the
Eps radius for a point to qualify as dense.
<bk>
Every data point is labelled as exactly one of three types.
```


The evidence shows a modality transformation rather than simple file conversion. Markdown headings, bullets, and mathematical notation were rewritten into speakable prose, then segmented for audio generation. The final result consisted of both a readable revision document and a listenable `.opus` artefact.
