Now I need to extract the text from the PDF first. Let me use the OCR skill.Now I have the full extracted text. Let me generate the essay-mode output.

---

# Association Analysis — Essay Questions for Exam Preparation

---

## Essay 1

**Discuss the Apriori principle and explain how it reduces the computational cost of frequent itemset mining. Illustrate with a concrete example.**

### Sample Answer

The Apriori principle states that if an itemset is frequent, then all of its subsets must also be frequent. Equivalently, if an itemset is infrequent, all of its supersets must be infrequent. This follows from the anti-monotone property of support: for any itemsets $X$ and $Y$ where $X \subseteq Y$, the support of $X$ is always greater than or equal to the support of $Y$ ($s(X) \geq s(Y)$). This property allows pruning of the candidate space without evaluating every possible itemset.

The Apriori algorithm exploits this principle in a level-wise fashion. It begins by scanning the database to find all frequent 1-itemsets. These are then combined to generate candidate 2-itemsets, and any candidate whose subsets are infrequent is pruned before the next database scan. This process repeats for $k = 3, 4, \ldots$ until no new frequent itemsets are found.

Consider a dataset with six items where minsup = 3. Without pruning, the number of candidates up to size 3 would be $^6C_1 + ^6C_2 + ^6C_3 = 41$. With Apriori pruning, items like Coke and Eggs (with support below 3) are eliminated at level 1, which prevents generating any 2-itemsets or 3-itemsets involving them. The total candidates drop to $6 + 6 + 1 = 13$. This reduction becomes dramatic for real-world datasets: a supermarket with thousands of products would have $2^d$ potential itemsets, making brute-force infeasible. The Apriori principle thus transforms an exponential problem into one that is tractable by dramatically cutting the search space at each level.

---

## Essay 2

**Compare and contrast support and confidence as rule evaluation metrics. Why is confidence alone insufficient, and how does the lift measure address its limitations? Use the Tea-Coffee example to support your argument.**

### Sample Answer

Support measures the fraction of transactions that contain both the antecedent and consequent of a rule, while confidence measures the conditional probability that the consequent appears given that the antecedent appears. Formally, for a rule $X \to Y$: support is $s = \sigma(X \cup Y) / |T|$ and confidence is $c = \sigma(X \cup Y) / \sigma(X)$.

Confidence alone is insufficient because it ignores the base frequency of the consequent. A rule can have high confidence yet be misleading if the consequent already occurs very frequently in the dataset. The Tea-Coffee example demonstrates this clearly. With the rule $\text{Tea} \to \text{Coffee}$, confidence is $150/200 = 0.75$, suggesting a strong relationship. However, the overall probability of coffee consumption is $800/1000 = 0.80$, meaning that tea drinkers are actually *less* likely to drink coffee than the general population. The rule appears strong under confidence but is in fact a slight negative correlation.

The lift (or interest factor) addresses this by normalising confidence against the expected co-occurrence under statistical independence: $\text{Lift}(X \to Y) = c(X \to Y) / s(Y) = s(X,Y) / (s(X) \cdot s(Y))$. A lift greater than 1 indicates positive association, less than 1 indicates negative association, and near 1 indicates independence. In the Tea-Coffee example, lift $= (1000 \times 150) / (800 \times 200) = 0.9375$, correctly revealing the slight negative correlation. Lift is thus essential for distinguishing genuine associations from spurious ones driven by high-frequency items.

---

## Essay 3

**Explain the two-step approach for mining association rules from transaction data. Discuss the role of each step and describe how rules are generated from frequent itemsets, including how the anti-monotone property of confidence enables pruning.**

### Sample Answer

Association rule mining proceeds in two steps. First, frequent itemset identification finds all itemsets whose support meets or exceeds a minimum support threshold (minsup). Second, rule generation takes each frequent itemset and produces high-confidence rules by partitioning the itemset into antecedent and consequent.

The first step is the computationally expensive part because the number of candidate itemsets grows exponentially with the number of items ($2^d$). The Apriori algorithm addresses this with level-wise candidate generation and support-based pruning. Alternatives such as FP-growth use a compressed FP-tree structure and a divide-and-conquer strategy to avoid candidate generation entirely.

In the second step, given a frequent itemset $L$ of size $k$, there are $2^k - 2$ candidate rules (excluding the trivial $L \to \emptyset$ and $\emptyset \to L$). For example, $\{A, B, C, D\}$ yields 14 candidate rules, ranging from 1-item consequents (e.g., $ABC \to D$) to 3-item consequents (e.g., $A \to BCD$).

The anti-monotone property of confidence enables efficient pruning during rule generation. For rules derived from the same itemset, confidence decreases as items are moved from the left-hand side to the right-hand side: $c(ABC \to D) \geq c(AB \to CD) \geq c(A \to BCD)$. If a rule fails the minimum confidence threshold, all rules with a larger consequent (i.e., more items moved to the right side) can be pruned immediately without evaluation. This hierarchical pruning significantly reduces the number of rules that must be tested, analogous to how the anti-monotone property of support prunes itemset candidates.

---

## Essay 4

**Evaluate the role of interestingness measures in association rule mining. Distinguish between objective and subjective measures, and explain why relying solely on support and confidence can lead to uninteresting or misleading patterns.**

### Sample Answer

Association rule algorithms typically produce a very large number of rules, many of which are redundant, trivial, or misleading. Interestingness measures are applied as a post-processing step to prune and rank derived patterns, converting raw patterns into actionable knowledge.

Relying solely on support and confidence is problematic. As demonstrated by the Tea-Coffee example, a rule with high confidence (0.75) can actually reflect a negative correlation once the base rate of the consequent is taken into account ($P(\text{Coffee}) = 0.80$). This occurs because confidence ignores the marginal frequency of the consequent. Support alone filters for frequency but says nothing about the strength or direction of association.

Objective measures address these shortcomings by computing statistics from the data using a contingency table. Lift (interest factor) normalises confidence by the expected co-occurrence under independence, correctly identifying positive, negative, and neutral associations. Other objective measures include the Gini index, J-measure, mutual information, and Jaccard coefficient — each capturing different aspects of rule quality. These measures are computed purely from data and do not require domain knowledge.

Subjective measures go further by incorporating user expectations and domain knowledge. A pattern is subjectively interesting if it either contradicts a user's expectations (unexpectedness) or suggests a concrete action (actionability). For example, a pattern that is expected to be frequent but turns out infrequent — or one expected to be infrequent but found frequent — is flagged as unexpected and potentially valuable. Subjective measures require modelling user expectations, making them more complex but more aligned with real-world decision-making. Both types complement each other: objective measures provide a data-driven filter, while subjective measures ensure that surviving patterns are meaningful to the analyst.

---Four essay questions with ~200-word sample answers, covering conceptual (Apriori principle, two-step approach), applied (support/confidence/lift with Tea-Coffee example), and integrative (interestingness measures — objective vs subjective) perspectives. All content is grounded strictly in the lecture slides.
