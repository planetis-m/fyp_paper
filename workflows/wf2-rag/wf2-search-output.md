Let me load the RAG skill first, then search your stored notes.The user wants to **search** stored notes. Let me read the search mode reference.Now let me check for the tools and run the search.**Zero Conditional Probability Problem**

If the conditional probability for any attribute is zero, the entire class-conditional probability becomes zero. This happens when the number of training instances is small and the number of possible attribute values is large.

**Example (Loan Default Prediction):** For class Yes, no training instance has Marital Status=Married, so P(Status=Married|Yes) = 0, which zeroes out the entire product P(x|Yes).

**Two alternate estimates to avoid vanishing probabilities:**

- **Laplace estimate:** P(Xi=c|y) = (nc + 1) / (n + v), where v is the total number of values Xi can take.
- **m-estimate:** P(Xi=c|y) = (nc + m·p) / (n + m), where p is a prior estimate of P(Xi|y) and m is a hyper-parameter indicating confidence in p.

Both provide non-zero values even when nc = 0, making them more robust than raw fractions.
