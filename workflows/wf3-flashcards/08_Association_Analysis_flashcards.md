# Flashcards — Association Analysis

| Front (Term/Question) | Back (Definition/Answer) |
|---|---|
| What is Association Rule Mining? | Finding rules that predict the occurrence of an item based on the occurrences of other items in a transaction. |
| What does implication mean in association rules? | Co-occurrence, **not** causality. |
| Is association rule mining supervised or unsupervised? | Unsupervised; it is a descriptive method. |
| Name three applications of association rule mining. | Market Basket Analysis, Web Usage Mining, Recommendation Systems. |
| What is an itemset? | A collection of one or more items (e.g., $\{Milk, Bread, Diaper\}$). |
| What is a k-itemset? | An itemset that contains exactly $k$ items. |
| Define support count ($\sigma$) of an itemset. | The number of transactions that contain the itemset. |
| Define support ($s$) of an itemset. | The fraction of transactions that contain the itemset: $s = \sigma(\text{itemset}) / \|T\|$. |
| What is a frequent itemset? | An itemset whose support is greater than or equal to a **minsup** threshold. |
| Define an association rule. | An implication $X \to Y$ where $X$ and $Y$ are itemsets. |
| Define support of a rule $X \to Y$. | Fraction of transactions containing both $X$ and $Y$: $s = \sigma(X \cup Y) / \|T\|$. |
| Define confidence of a rule $X \to Y$. | How often $Y$ appears in transactions containing $X$: $c = \sigma(X \cup Y) / \sigma(X)$. |
| What are the two conditions for a valid association rule? | $\text{support} \geq \text{minsup}$ **and** $\text{confidence} \geq \text{minconf}$. |
| Why is the brute-force approach to association mining prohibitive? | It must enumerate all $2^d$ candidate itemsets and compute support/confidence for every possible rule. |
| What is the complexity of brute-force frequent itemset identification? | $O(NMw)$ where $M = 2^d$, making it extremely expensive. |
| State the Apriori principle. | If an itemset is frequent, then **all of its subsets** must also be frequent. |
| State the anti-monotone property of support. | $\forall X, Y : (X \subseteq Y) \Rightarrow s(X) \geq s(Y)$ — support never increases when items are added. |
| What does the Apriori principle enable? | Pruning: if an itemset is infrequent, all its supersets can be eliminated without counting. |
| Outline the Apriori algorithm. | 1) Generate frequent 1-itemsets. 2) Repeat: generate $(k{+}1)$-candidates from $k$-frequent itemsets, prune candidates with infrequent $k$-subsets, count support, retain only frequent ones. Stop when no new frequent itemsets are found. |
| How does FP-growth differ from Apriori? | It compresses the database into an **FP-tree** and mines frequent itemsets via a recursive divide-and-conquer approach, avoiding candidate generation. |
| How is an FP-tree constructed? | Sort items in each transaction by descending frequency, then insert the sorted transaction into a prefix tree, sharing common prefixes and incrementing counts. |
| For a frequent itemset $L$ of size $k$, how many candidate rules exist? | $2^k - 2$ (excluding $L \to \varnothing$ and $\varnothing \to L$). |
| State the anti-monotone property of confidence for rule generation. | $c(ABC \to D) \geq c(AB \to CD) \geq c(A \to BCD)$ — confidence decreases as items move from the LHS to the RHS. |
| What is the drawback of using confidence alone? | It ignores the support of the consequent; a rule can have high confidence yet be misleading if the consequent is already very frequent. |
| Define lift (interest factor). | $Lift(X \to Y) = \dfrac{c(X \to Y)}{\sigma(Y)} = \dfrac{\sigma(X,Y)}{\sigma(X)\,\sigma(Y)}$. |
| What does a lift value greater than 1 indicate? | $X$ and $Y$ co-occur more often than expected — positive association. |
| What does a lift value less than 1 indicate? | $X$ and $Y$ co-occur less often than expected — negative association. |
| What does a lift value near 1 indicate? | $X$ and $Y$ appear together about as often as expected — no association. |
| What is a contingency table for a rule $X \to Y$? | A 2×2 table with cells $f_{11}$ (both $X$ and $Y$), $f_{10}$ ($X$ only), $f_{01}$ ($Y$ only), $f_{00}$ (neither), used to compute support, confidence, lift, Gini, etc. |
| Difference between objective and subjective interestingness measures. | **Objective**: based on statistics from data (e.g., support, confidence, lift, Gini). **Subjective**: based on user expectations — a pattern is interesting if it is unexpected or actionable. |
| What makes a pattern subjectively interesting (Silberschatz & Tuzhilin)? | It either **contradicts the user's expectation** or it is **actionable**. |
| How is a pattern classified as unexpected? | It is frequent when expected to be infrequent ($\square -$), or infrequent when expected to be frequent ($\bigcirc +$). |
