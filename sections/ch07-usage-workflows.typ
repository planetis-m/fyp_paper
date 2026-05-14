#import "../lib.typ": apa-figure

= End-to-End Workflow Evaluation <chap:workflows>

The workflows are evaluated against the objectives defined by the `study-assistant` and supporting tool instructions: outputs should be grounded in prepared source material, appropriate to the selected study mode, useful for exam preparation, and operationally reproducible enough for repeated use. The assessment therefore distinguishes serious errors from acceptable transformations required by the workflow. A flashcard deck, for example, is not expected to preserve every slide verbatim; a transcription or RAG source ingest is held to a stricter fidelity standard.

== WF1: OCR-Grounded Essay Practice


*Prompt.*

```text
Use the study-assistant in essay mode on the lecture
slides at `08_Association_Analysis.pdf` for exam preparation
```


The recorded output is an essay-mode workflow rather than a strict transcription workflow. Under the `study-assistant` contract, essay mode should produce three to four exam-style prompts, include conceptual and applied questions, provide sample answers of roughly 200 words, and remain grounded in the prepared source text. Judged against that objective, the workflow is largely successful.

The OCR stage extracted the Association Analysis slides into structured Markdown. Key concepts and formulas were preserved sufficiently for downstream generation, including transaction tables, support, confidence, Apriori, lift, and subjective interestingness. Representative OCR evidence includes:

$ s = frac(sigma("Milk, Diaper, Beer"), |T|) = frac(2, 5) = 0.4 $

$ c = frac(sigma("Milk, Diaper, Beer"), sigma("Milk, Diaper")) = frac(2, 3) = 0.67 $

The generated essay set covered the main examinable ideas in the lecture: Apriori pruning, support and confidence, lift, association-rule generation, and interestingness measures. A representative prompt and answer excerpt were:

```text
Discuss the Apriori principle and explain how it reduces the computational
cost of frequent itemset mining.

The Apriori principle states that if an itemset is frequent, then all of its
subsets must also be frequent. Equivalently, if an itemset is infrequent, all
of its supersets must be infrequent. This follows from the anti-monotone
property of support...
```


This is a strong match to the essay-mode objective. The answer asks for explanation rather than recall alone, uses formal academic verbs, and connects the principle to computational pruning. The Tea-Coffee answer is also well-grounded: it uses the source example where confidence is `150/200 = 0.75` but the base coffee probability is `800/1000 = 0.80`, leading to lift `0.9375` and a slight negative association.

The limitations are modest relative to the task. OCR introduced small local errors, such as truncating "Make offers, personalize" to "Make offers, persona". Diagram interpretation also produced occasional awkward wording in the Apriori lattice explanation. These issues would matter more for a verbatim transcription than for essay practice. For the recorded objective, they did not materially prevent correct exam-style generation, but they indicate that transcription-quality outputs should be retained separately when later workflows require exact provenance.

== WF2: RAG-Based Exam Revision


*Storage prompt.*

```text
Use the OCR tool to extract pages 358-402 from
Introduction to Data Mining, then use the RAG tool to
store the extracted text so I can search it later
for exam revision
```


*Search prompt.*

```text
Use the RAG tool to search my stored notes for
how does the Naive Bayes classifier handle zero probability conditions
```


The intended RAG workflow is to convert source material into coherent chunks and retrieve relevant source content later. The store output reports successful OCR extraction, cleaning, and storage of the textbook section as 26 semantic chunks. The chunking is broadly appropriate for exam revision: chunks are organised around topics such as nearest-neighbour classification, Bayes' theorem, the Naive Bayes assumption, zero conditional probability, Bayesian networks, and inference.

The relevant stored chunk is directly aligned with the later query:

```text
<chunk page=379 label="Zero Conditional Probability">
Handling Zero Conditional Probabilities: If the conditional probability for
any attribute is zero, the entire class-conditional probability becomes zero.
This happens when the number of training instances is small and the number of
possible attribute values is large.

Two alternate estimates to avoid vanishing probabilities:
Laplace estimate: P(Xi=c|y) = (nc + 1) / (n + v) ...
m-estimate: P(Xi=c|y) = (nc + m*p) / (n + m) ...
```


The search result answered the query accurately:

```text
If the conditional probability for any attribute is zero,
the entire class-conditional probability becomes zero.

Example (Loan Default Prediction): For class Yes, no
training instance has Marital Status=Married, so
P(Status=Married|Yes) = 0, which zeroes out the entire product P(x|Yes).

Two alternate estimates to avoid vanishing probabilities:
- Laplace estimate: P(Xi=c|y) = (nc + 1) / (n + v)
- m-estimate: P(Xi=c|y) = (nc + m.p) / (n + m)
```


This demonstrates the value of RAG for the study-assistant objective. The answer is not only generally correct; it is grounded in the course-specific loan-default example and retrieves both smoothing methods discussed in the source. Compared with a naive prompt about Naive Bayes, the RAG workflow materially improves alignment with the assigned material.

The main limitation is not answer quality but traceability. The `rag-tool` search instructions prefer verbatim returned chunks, while the recorded answer is a concise synthesis. For a student, this synthesis is useful and sufficient for revision. For strict evaluation, it weakens the ability to separate retrieved evidence from generated wording. A future version should record the retrieved chunks alongside the final answer rather than replacing the answer with raw chunks only.

Preprocessing quality is adequate for the demonstrated query. Some OCR formula fragments in the broader Naive Bayes section are malformed, but the chunk used for zero-probability retrieval preserves the essential explanation and estimates. The extra ingest artefact spanning pages 402-458 creates some provenance ambiguity, but it did not affect the observed search result. The appropriate conclusion is that WF2 is sufficient for targeted exam revision, while stronger metadata and retrieval logs are needed for rigorous reproducibility.

== WF3: Flashcard Generation


*Prompt.*

```text
Use the study-assistant in flashcard mode on the
lecture slides at `07_Anomaly_Detection.pdf` for
exam revision
```


The flashcard mode requires a two-column Markdown table of high-value terms, definitions, formulas, distinctions, and core concepts. The generated deck contains 25 cards and satisfies this objective well. It covers anomaly definitions, causes, point/contextual/collective anomalies, supervised, semi-supervised and unsupervised detection, label versus score outputs, statistical tests, proximity-based methods, density-based methods, LOF, cluster-based detection, real-world issues, and applications.

Representative output:

#apa-figure(
  table(
    columns: (2.35in, 3.65in),
    table.header([Front (Term/Question)], [Back (Definition/Answer)]),
    [What is an anomaly (outlier)?],
    [An object that is different from most other objects in the dataset.],
    [What are the three main causes of anomalies?],
    [Data from a different class/mechanism; natural variation; measurement/collection errors.],
    [Contextual anomaly],
    [An instance that is anomalous only within a specific context. Requires a notion of context.],
    [Label vs. Score output in anomaly detection],
    [*Label:* each instance is tagged normal or anomaly. *Score:* each instance gets a numeric anomaly score allowing ranking; requires an additional threshold.],
    [LOF (Local Outlier Factor)],
    [A relative density score comparing the average density of #emph[k] neighbours with the density of the point.],
  ),
  caption: [Representative anomaly-detection flashcards],
  placement: none,
)<tbl:workflow-flashcards>


The cards are factually consistent with the lecture and suitable for active recall. They are concise without being merely keyword-based, and they include both definitions and method limitations. This aligns with the prompt rule to include high-value distinctions rather than duplicate low-level details.

The output is less suitable for calculation practice or deep derivations, but that is not the primary purpose of flashcard mode. A small number of cards compress technical content, such as LOF and Grubbs' test, into revision-level answers. This is acceptable for flashcards, provided they are not presented as a replacement for full notes or worked examples.

A second flashcard artefact for Association Analysis shows similar strengths. It covers support count, support, confidence, Apriori, FP-growth, rule generation, lift, contingency tables, and interestingness measures. One formula preserves the source notation for lift:

```text
Lift(X -> Y) = c(X -> Y) / sigma(Y)
```


Because the slides elsewhere use `sigma` for support count, this notation is potentially ambiguous. The issue is inherited from the source representation rather than invented by the model. For the study objective, the surrounding cards and examples make the concept understandable, but a validation pass could improve clarity by rewriting the denominator as `support(Y)`.

Overall, WF3 is sufficient for the study-assistant objective of exam-ready active recall. The main improvement would be automated checks for duplicate cards, formula ambiguity, and coverage against slide headings.

#pagebreak()

== WF4: Study Notes and Text-to-Speech


*Prompt.*

```text
Use the study-assistant in study-notes mode on the
lecture slides at `06_Clustering_Density_Validation.pdf`,
then use the TTS tool to convert the notes to audio
so I can listen while revising
```


This workflow combines two objectives: study-note generation and speech preparation. The notes should prioritise understanding, relationships, and exam relevance; the TTS input should remove Markdown and mathematical syntax that would sound unnatural when spoken.

The generated notes cover the central lecture content: DBSCAN, core/border/noise points, algorithm steps, DBSCAN strengths and limitations, cluster validation, validity indices, similarity-matrix inspection, SSE, cohesion, separation, entropy, and purity. Representative study-note output:

```text
DBSCAN groups points by local density rather than by distance to centroids
or by merging clusters hierarchically. Two parameters control the algorithm:

- Eps: the radius that defines the neighbourhood around a point.
- MinPts: the minimum number of points that must fall within the Eps-radius
  for a point to qualify as dense.
```


The TTS rewrite is a meaningful modality transformation rather than a direct file conversion. It rewrites headings, bullets, formulas, and table-like content into spoken prose:

```text
DBSCAN, Density-Based Spatial Clustering. DBSCAN groups points by local
density rather than by distance to centroids or by merging clusters
hierarchically. Two parameters control the algorithm. Eps, written epsilon,
is the radius that defines the neighbourhood around a point.
```


For mathematical content, the rewrite is appropriate for listening:

```text
p sub i j equals m sub i j divided by m sub j
```


This satisfies the TTS objective. The speech input is coherent, listenable, and avoids raw Markdown or LaTeX. It is also chunked into spoken units with `<bk>` markers, which supports the downstream audio tool.

There are minor technical shifts. The notes use "at least MinPts" for a core point, while the slide text says "more than MinPts"; the generated version is consistent with common DBSCAN terminology, but it is not a verbatim rendering of the local slide wording. The entropy formula is also normalised to the standard negative-sum form after OCR recorded it without the negative sign. For study notes, these choices are defensible because they improve conceptual correctness. For strict source auditing, they should be marked as normalisations.

WF4 is sufficient for passive revision. It should not be treated as a replacement for visual slide study, because examples, plots, and table details are necessarily condensed for audio. The operational record is also positive: OCR used a cache hit, `chunktts` completed, and no stderr failures were recorded.

== Cross-Workflow Assessment


The recorded workflows meet the practical objectives of the study-assistant: they transform course PDFs into exam-oriented essays, searchable source notes, flashcards, written notes, and speech-ready revision material. The outputs are mostly grounded in the original course material and are pedagogically useful for the intended modes.

The limitations are best understood as engineering improvements rather than workflow failures:

- source-preserving artefacts should be retained when later stages depend on exact provenance;
- RAG should record retrieved chunks and final synthesis together;
- OCR cleanup should flag formula and diagram uncertainty instead of silently relying on manual judgement;
- generated flashcards and notes would benefit from lightweight validation for coverage, duplication, and formula ambiguity;
- run manifests should link source PDFs, OCR cache entries, generated text, TTS input, and final audio.

The stderr logs for the recorded workflows are empty, and inspected OCR cache entries report successful page extraction with `status="ok"` and `attempts=1`. This supports the conclusion that the recorded runs were operationally stable. It does not prove robustness under all provider, rate-limit, or document conditions, but it is sufficient evidence that the current implementation can complete the demonstrated study workflows.
