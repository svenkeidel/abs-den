%if style == newcode
> module Problem where
%endif

\section{Problem Statement}
\label{sec:problem}

%By way of the poster child example of a compositional definition of \emph{usage
%analysis}, we showcase how the operational detail available in traditional
%denotational semantics is too coarse to substantiate a correctness criterion,
%although the \emph{proof} of (a weaker notion of) correctness is simple and direct.
%While operational semantics observe sufficient detail to formulate a correctness
%criterion, it is quite complicated to come up with a suitable inductive
%hypothesis for the correctness proof.

\subsection{Usage Analysis and Deadness, Intuitively}
\label{sec:usage-intuition}

Let us begin by defining the object language of this work, a lambda
calculus with recursive let bindings and algebraic data types:
\[
\arraycolsep=3pt
\begin{array}{rrclcrrclcl}
  \text{Variables}    & \px, \py & ∈ & \Var        &     & \quad \text{Constructors} &        K & ∈ & \Con        &     & \text{with arity $α_K ∈ ℕ$} \\
  \text{Values}       &      \pv & ∈ & \Val        & ::= & \highlight{\Lam{\px}{\pe}} \mid K~\many{\px}^{α_K} \\
  \text{Expressions}  &      \pe & ∈ & \Exp        & ::= & \multicolumn{6}{l}{\highlight{\px \mid \pv \mid \pe~\px \mid \Let{\px}{\pe_1}{\pe_2}} \mid \Case{\pe}{\SelArity}}
\end{array}
\]
The form is reminiscent of \citet{Launchbury:93} and \citet{Sestoft:97} because
it is factored into \emph{A-normal form}, that is, the arguments of applications
are restricted to be variables, so the difference between call-by-name and
call-by-value manifests purely in the semantics of $\mathbf{let}$.
Note that $\Lam{x}{x}$ denotes syntax, whereas $\fn{x}{x+1}$ denotes a function
in math.
In this section, only the highlighted parts are relevant, but the interpreter
definition in \Cref{sec:interp} supports data types as well.
From hereon throughout, we assume that all bound program variables
are distinct.

\begin{figure}
\begin{minipage}[t]{0.48\textwidth}
\arraycolsep=0pt
\[\begin{array}{rcl}
  \multicolumn{3}{c}{ \ruleform{ \semscott{\wild}_{\wild} \colon \Exp → (\Var \to \ScottD) → \ScottD } } \\
  \\[-0.5em]
  \semscott{\px}_ρ & {}={} & ρ(\px) \\
  \semscott{\Lam{\px}{\pe}}_ρ & {}={} & \fn{d}{\semscott{\pe}_{ρ[\px ↦ d]}} \\
  \semscott{\pe~\px}_ρ & {}={} & \begin{cases}
     f(ρ(\px)) & \text{if $\semscott{\pe}_ρ = f$}  \\
     \bot      & \text{otherwise}  \\
   \end{cases} \\
  \semscott{\Letsmall{\px}{\pe_1}{\pe_2}}_ρ & {}={} &
    \begin{letarray}
      \text{letrec}~ρ'. & ρ' = ρ \mathord{⊔} [\px \mathord{↦} d_1] \\
                        & d_1 = \semscott{\pe_1}_{ρ'} \\
      \text{in}         & \semscott{\pe_2}_{ρ'}
    \end{letarray} \\
\end{array}\]
\caption{Denotational semantics after Scott}
  \label{fig:denotational}
\end{minipage}%
\quad
\begin{minipage}[t]{0.48\textwidth}
\arraycolsep=0pt
\[\begin{array}{c}
  \ruleform{ \dead{Γ}{\pe} }
  \\ \\[-0.5em]
  \inferrule[\textsc{Var}]{\px ∈ Γ}{\dead{Γ}{\px}}
  \quad
  \inferrule[\textsc{App}]{\dead{Γ}{\pe \quad \px ∈ Γ}}{\dead{Γ}{\pe~\px}}
  \quad
  \inferrule[\textsc{Lam}]{\dead{Γ, \px}{\pe}}{\dead{Γ}{\Lam{\px}{\pe}}}
  \\ \\[-0.5em]
  \inferrule[$\textsc{Let}_1$]{\dead{Γ, \py}{\pe_1} \quad \dead{Γ, \py}{\pe_2}}{\dead{Γ}{\Let{\py}{\pe_1}{\pe_2}}}
  \quad
  \inferrule[$\textsc{Let}_2$]{\dead{Γ}{\pe_2}}{\dead{Γ}{\Let{\py}{\pe_1}{\pe_2}}}
  \\[-0.5em]
\end{array}\]
\caption{Modular deadness analysis}
  \label{fig:deadness}
\end{minipage}
\end{figure}

We give a standard call-by-name denotational semantics $\semscott{\wild}$ in
\Cref{fig:denotational} \citep{ScottStrachey:71}, assigning meaning to our
syntax by means of the Scott domain $\ScottD$ defined as
\[
 \arraycolsep=3pt
 \begin{array}{rrclcl}
  \text{Scott Domain}      &  d & ∈ & \ScottD & =   & [\ScottD \to_c \ScottD]_\bot, \\
 \end{array}
\]
where $[X \to_c X]_\bot$ is
the topology of Scott-continuous endofunctions on $X$ together with a distinct
least element $\bot$, and the equation is to be interpreted as the least
fixpoint of the implied functional.

\Cref{fig:deadness} defines a static \emph{deadness analysis}.
Inuitively, when $\dead{Γ}{\pe}$ is derivable and no variable in $Γ$ evaluates
$\px$, then $\px$ is dead in $\pe$, \eg, what value is bound to $\px$ is
irrelevant to the value of $\pe$.
The context $Γ$ can be thought of as the set of assumptions (variables
that $\px$ is assumed dead in); the larger $Γ$ is, the more statements are
derivable.
Thus, a decision algorithm would always pick the largest permissible $Γ$,
which is used in the \textsc{Var} case to prove deadness of open terms.
Rules $\textsc{Let}_1$ and $\textsc{Let}_2$ handle the case where $\px$ can
be proven dead in $\pe_1$ or not, respectively; in the former case,
the let-bound variable $\py$ may be added to the context when analysing $\pe_2$.
Otherwise, evaluating $\py$ might transitively evaluate $\px$ and hence $\py$ is
not added to the context in $\textsc{Let}_2$.

Note that although the formulation of deadness analysis is so simple, it is
\emph{not} entirely naïve:
Because it is defined by structural recursion, its treatment of function
application makes use of a summary mechanism, with the hidden assumption
that every function deeply evaluates its argument.
Whenever $x \not∈ Γ$, $\dead{Γ}{f~x}$ is not derivable by the \textsc{App}
rule, even though $f$ might be dead in its argument.
On the other hand, rule \textsc{Lam} may in turn assume that any argument it
receives is dead, hence it adds the lambda-bound variable to the context.
We can formalise the summary mechanism with the following \emph{substitution
lemma} (where context extension $Γ[\px↦Γ(\py)]$ adds $\px$ to $Γ$ if and
only if $\py ∈ Γ$):%
\footnote{All proofs can be found in the Appendix; in case of the extended
version via clickable links.}

\begin{lemmarep}[Substitution]
If $\dead{Γ}{(\Lam{\px}{\pe})~\py}$ then $\dead{Γ[\px↦Γ(\py)]}{\pe}$.
\end{lemmarep}
\begin{proof}
  By cases on whether $\py ∈ Γ$.
  \begin{itemize}
    \item \textbf{Case }$\py ∈ Γ$:
      Then the assumption has a sub-derivation for $\dead{Γ,\px}{\pe}$, showing
      the goal.
    \item \textbf{Case }$\py \not∈ Γ$:
      The last applicable rule must have been \textsc{App},
      so we have $\py ∈ Γ$, contradiction.
  \end{itemize}
\end{proof}

The substitution lemma is instrumental in proving deadness analysis correct in
terms of semantic irrelevance, as in the following theorem:

\sg{TODO: Update the proof}
\begin{theoremrep}[Correct deadness analysis]
  \label{thm:deadness-correct}
  If $\dead{Γ}{\pe}$ and $\px \not∈ Γ$,
  then $\semscott{\pe}_{ρ[\px↦d_1]} = \semscott{\pe}_{ρ[\px↦d_2]}$.
\end{theoremrep}
\begin{proof}
  By induction on $\pe$, generalising $\tr_Δ$ in the assumption
  $\semusg{\pe}_{\tr_Δ}(\px) = 0$ to ``there exists a $\tr$
  such that $\tr(\px) \not⊑ \semusg{\pe}_{\tr}$''.
 \slpj{That is indeed a tricky statement.  What is the intuition?  Do you mean
    that this has to be true for \emph{every} $\tr$?  Or that $\px$ is dead if I can find \emph{some} $\tr$ for which
    the statement holds? It is surely not true in general because $\px$ might have bindings for variables nothing to do with $e$.}
 \sg{The ``some'' version is the correct notion. The $\tr$ becomes a witness of
     deadness. I don't understand your comment \wrt not being true in general. }

  It is $\tr_Δ(\px) \not⊑ \semusg{\pe}_{\tr_Δ}$:
  Let us assume $\semusg{\pe}_{\tr_Δ}(\px) = 0$.
  We know, by definition of $\tr_Δ$ that ${\tr_Δ(\px)(\px) = 1}$.
  Hence $\tr_Δ(\px)(\px) \not⊑ \semusg{\pe}_{\tr_Δ}(\px)$; and hence $\tr_Δ(\px) \not⊑ \semusg{\pe}_{\tr_Δ}$.
  \sg{I suppose we can be a little more explicit here, as you suggested.
  Ultimately I don't think that hand-written proofs will carry us very far
  and I'll try formalise the more important proofs in Agda.}

  We fix $\pe$, $\px$ and $\tr$ such that $\tr(\px) \not⊑ \semusg{\pe}_{\tr}$.
  The goal is to show that $\px$ is dead in $\pe$,
  so we are given an arbitrary $ρ$, $d_1$ and $d_2$ and have to show that
  $\semscott{\pe}_{ρ[\px↦d_1]} = \semscott{\pe}_{ρ[\px↦d_2]}$.
  By cases on $\pe$:
  \begin{itemize}
    \item \textbf{Case $\pe = \py$}: If $\px=\py$, then
      $\tr(\px) \not⊑ \semusg{\py}_{\tr} = \tr(\py) = \tr(\px)$, a contradiction.
      If $\px \not= \py$, then varying the entry for $\px$ won't matter; hence
      $\px$ is dead in $\py$.
    \item \textbf{Case $\pe = \Lam{\py}{\pe'}$}: The equality follows from
      pointwise equality on functions, so we pick an arbitrary $d$ to show
      $\semscott{\pe'}_{ρ[\px↦d_1][\py↦d]} = \semscott{\pe'}_{ρ[\px↦d_2][\py↦d]}$.

      This is simple to see if $\px=\py$. Otherwise, $\tr[\py↦\bot]$ witnesses the fact that
      \[
        \tr[\py↦\bot](\px) = \tr(\px) \not⊑
        \semusg{\Lam{\py}{\pe'}}_{\tr} = \semusg{\pe'}_{\tr[\py↦\bot]}
      \]
      so we can apply the induction hypothesis to see that $\px$ must be dead in
      $\pe'$, hence the equality on $\semscott{\pe'}$ holds.
    \item \textbf{Case $\pe = \pe'~\py$}:
      From $\tr(\px) \not⊑ \semusg{\pe'}_{\tr} + ω*\tr(\py)$ we can see that
      $\tr(\px) \not⊑ \semusg{\pe'}_{\tr}$ and $\tr(\px) \not⊑ \tr(\py)$ by
      monotonicity of $+$ and $*$.
      If $\px=\py$ then the latter inequality leads to a contradiction.
      Otherwise, $\px$ must be dead in $\pe'$, hence both cases of
      $\semscott{\pe'~\py}$ evaluate equally, differing only in
      the environment. It remains to be shown that
      $ρ[\px↦d_1](\py) = ρ[\px↦d_2](\py)$, and that is easy to see since
      $\px \not= \py$.
    \item \textbf{Case $\pe = \Let{\py}{\pe_1}{\pe_2}$}:
      We have to show that
      \[
        \semscott{\pe_2}_{ρ[\px↦d_1][\py↦d'_1]} = \semscott{\pe_2}_{ρ[\px↦d_2][\py↦d'_2]}
      \]
      where $d'_i$ satisfy $d'_i = \semscott{\pe_1}_{ρ[\px↦d_i][\py↦d'_i]}$.
      The case $\px = \py$ is simple to see, because $ρ[\px↦d_i](\px)$ is never
      looked at.
      So we assume $\px \not= \py$ and see that $\tr(\px) = \tr'(\px)$, where
      $\tr' = \operatorname{fix}(\fn{\tr'}{\tr ⊔ [\py ↦ [\py↦1]+\semusg{\pe_1}_{\tr'}]})$.

      We know that
      \[
        \tr'(\px) = \tr(\px) \not⊑ \semusg{\pe}_{\tr} = \semusg{\pe_2}_{\tr'}
      \]
      So by the induction hypothesis, $\px$ is dead in $\pe_2$.

      We proceed by cases over $\tr(\px) = \tr'(\px) ⊑ \semusg{\pe_1}_{\tr'}$.
      \begin{itemize}
        \item \textbf{Case $\tr'(\px) ⊑ \semusg{\pe_1}_{\tr'}$}: Then
          $\tr'(\px) ⊑ \tr'(\py)$ and $\py$ is also dead in $\pe_2$ by the above
          inequality.
          Both deadness facts together allow us to rewrite
          \[
            \semscott{\pe_2}_{ρ[\px↦d_1][\py↦d'_1]} = \semscott{\pe_2}_{ρ[\px↦d_1][\py↦d'_2]} = \semscott{\pe_2}_{ρ[\px↦d_2][\py↦d'_2]}
          \]
          as requested.
        \item \textbf{Case $\tr'(\px) \not⊑ \semusg{\pe_1}_{\tr'}$}:
          Then $\px$ is dead in $\pe_1$ and $d'_1 = d'_2$. The goal follows
          from the fact that $\px$ is dead in $\pe_2$.
      \end{itemize}
  \end{itemize}
\end{proof}

\subsection{Usage Analysis Infers Denotational Deadness}

The requirement (in the sense of informal specification) on an assertion
such as ``$x$ is dead'' in a program like $\Let{x}{\pe_1}{\pe_2}$ is that we
may rewrite to $\Let{x}{\mathit{panic}}{\pe_2}$ and even to $\pe_2$ without
observing any change in semantics. Doing so reduces code size and heap
allocation.

This can be made formal in the following definition of deadness in terms of
$\semscott{\wild}$:

\begin{definition}[Deadness]
  \label{defn:deadness}
  A variable $\px$ is \emph{dead} in an expression $\pe$ if and only
  if, for all $ρ ∈ \Var \to \ScottD$ and $d_1, d_2 ∈ \ScottD$, we have
  $\semscott{\pe}_{ρ[\px↦d_1]} = \semscott{\pe}_{ρ[\px↦d_2]}$.
  Otherwise, $\px$ is \emph{live}.
\end{definition}

Indeed, if we know that $x$ is dead in $\pe_2$, then the following equation
justifies our rewrite above: $\semscott{\Let{x}{\pe_1}{\pe_2}}_ρ =
\semscott{\pe_2}_{ρ[x↦d]} = \semscott{\pe_2}_{ρ[x↦ρ(x)]} =\semscott{\pe_2}_ρ$
(for all $ρ$ and the suitable $d$),
where we make use of deadness in the second $=$.
So our definition of deadness is not only simple to grasp, but also simple to
exploit.

We can now prove our usage analysis correct as a deadness analysis in
terms of this notion: \\

\begin{theoremrep}[$\semusg{\wild}$ is a correct deadness analysis]
  \label{thm:semusg-correct-live}
  Let $\pe$ be an expression and $\px$ a variable.
  If $\semusg{\pe}_{\tr_Δ}(\px) = 0$
  then $\px$ is dead in $\pe$.
\end{theoremrep}
\begin{proof}
  By induction on $\pe$, generalising $\tr_Δ$ in the assumption
  $\semusg{\pe}_{\tr_Δ}(\px) = 0$ to ``there exists a $\tr$
  such that $\tr(\px) \not⊑ \semusg{\pe}_{\tr}$''.
 \slpj{That is indeed a tricky statement.  What is the intuition?  Do you mean
    that this has to be true for \emph{every} $\tr$?  Or that $\px$ is dead if I can find \emph{some} $\tr$ for which
    the statement holds? It is surely not true in general because $\px$ might have bindings for variables nothing to do with $e$.}
 \sg{The ``some'' version is the correct notion. The $\tr$ becomes a witness of
     deadness. I don't understand your comment \wrt not being true in general. }

  It is $\tr_Δ(\px) \not⊑ \semusg{\pe}_{\tr_Δ}$:
  Let us assume $\semusg{\pe}_{\tr_Δ}(\px) = 0$.
  We know, by definition of $\tr_Δ$ that ${\tr_Δ(\px)(\px) = 1}$.
  Hence $\tr_Δ(\px)(\px) \not⊑ \semusg{\pe}_{\tr_Δ}(\px)$; and hence $\tr_Δ(\px) \not⊑ \semusg{\pe}_{\tr_Δ}$.
  \sg{I suppose we can be a little more explicit here, as you suggested.
  Ultimately I don't think that hand-written proofs will carry us very far
  and I'll try formalise the more important proofs in Agda.}

  We fix $\pe$, $\px$ and $\tr$ such that $\tr(\px) \not⊑ \semusg{\pe}_{\tr}$.
  The goal is to show that $\px$ is dead in $\pe$,
  so we are given an arbitrary $ρ$, $d_1$ and $d_2$ and have to show that
  $\semscott{\pe}_{ρ[\px↦d_1]} = \semscott{\pe}_{ρ[\px↦d_2]}$.
  By cases on $\pe$:
  \begin{itemize}
    \item \textbf{Case $\pe = \py$}: If $\px=\py$, then
      $\tr(\px) \not⊑ \semusg{\py}_{\tr} = \tr(\py) = \tr(\px)$, a contradiction.
      If $\px \not= \py$, then varying the entry for $\px$ won't matter; hence
      $\px$ is dead in $\py$.
    \item \textbf{Case $\pe = \Lam{\py}{\pe'}$}: The equality follows from
      pointwise equality on functions, so we pick an arbitrary $d$ to show
      $\semscott{\pe'}_{ρ[\px↦d_1][\py↦d]} = \semscott{\pe'}_{ρ[\px↦d_2][\py↦d]}$.

      This is simple to see if $\px=\py$. Otherwise, $\tr[\py↦\bot]$ witnesses the fact that
      \[
        \tr[\py↦\bot](\px) = \tr(\px) \not⊑
        \semusg{\Lam{\py}{\pe'}}_{\tr} = \semusg{\pe'}_{\tr[\py↦\bot]}
      \]
      so we can apply the induction hypothesis to see that $\px$ must be dead in
      $\pe'$, hence the equality on $\semscott{\pe'}$ holds.
    \item \textbf{Case $\pe = \pe'~\py$}:
      From $\tr(\px) \not⊑ \semusg{\pe'}_{\tr} + ω*\tr(\py)$ we can see that
      $\tr(\px) \not⊑ \semusg{\pe'}_{\tr}$ and $\tr(\px) \not⊑ \tr(\py)$ by
      monotonicity of $+$ and $*$.
      If $\px=\py$ then the latter inequality leads to a contradiction.
      Otherwise, $\px$ must be dead in $\pe'$, hence both cases of
      $\semscott{\pe'~\py}$ evaluate equally, differing only in
      the environment. It remains to be shown that
      $ρ[\px↦d_1](\py) = ρ[\px↦d_2](\py)$, and that is easy to see since
      $\px \not= \py$.
    \item \textbf{Case $\pe = \Let{\py}{\pe_1}{\pe_2}$}:
      We have to show that
      \[
        \semscott{\pe_2}_{ρ[\px↦d_1][\py↦d'_1]} = \semscott{\pe_2}_{ρ[\px↦d_2][\py↦d'_2]}
      \]
      where $d'_i$ satisfy $d'_i = \semscott{\pe_1}_{ρ[\px↦d_i][\py↦d'_i]}$.
      The case $\px = \py$ is simple to see, because $ρ[\px↦d_i](\px)$ is never
      looked at.
      So we assume $\px \not= \py$ and see that $\tr(\px) = \tr'(\px)$, where
      $\tr' = \operatorname{fix}(\fn{\tr'}{\tr ⊔ [\py ↦ [\py↦1]+\semusg{\pe_1}_{\tr'}]})$.

      We know that
      \[
        \tr'(\px) = \tr(\px) \not⊑ \semusg{\pe}_{\tr} = \semusg{\pe_2}_{\tr'}
      \]
      So by the induction hypothesis, $\px$ is dead in $\pe_2$.

      We proceed by cases over $\tr(\px) = \tr'(\px) ⊑ \semusg{\pe_1}_{\tr'}$.
      \begin{itemize}
        \item \textbf{Case $\tr'(\px) ⊑ \semusg{\pe_1}_{\tr'}$}: Then
          $\tr'(\px) ⊑ \tr'(\py)$ and $\py$ is also dead in $\pe_2$ by the above
          inequality.
          Both deadness facts together allow us to rewrite
          \[
            \semscott{\pe_2}_{ρ[\px↦d_1][\py↦d'_1]} = \semscott{\pe_2}_{ρ[\px↦d_1][\py↦d'_2]} = \semscott{\pe_2}_{ρ[\px↦d_2][\py↦d'_2]}
          \]
          as requested.
        \item \textbf{Case $\tr'(\px) \not⊑ \semusg{\pe_1}_{\tr'}$}:
          Then $\px$ is dead in $\pe_1$ and $d'_1 = d'_2$. The goal follows
          from the fact that $\px$ is dead in $\pe_2$.
      \end{itemize}
  \end{itemize}
\end{proof}

\emph{The main takeaway of this Section is the simplicity of this proof!}
Since $\semscott{\wild}$ and $\semusg{\wild}$ are so similar in structure,
a proof by induction on the program expression is possible.
The induction hypothesis needs slight generalisation and that admittedly
involves a bit of trial and error, but all in all, it is a simple and direct
proof, at just under a page of accessible prose.

Simplicity of proofs is a good property to strive for, so let us formulate an
explicit goal:

% It is surprising that the theorem does not need to relate $\tr_Δ$ to
% $ρ$; after all, $ρ(\py)$ (for $\py \not= \px$) might be bound to the
% \emph{meaning} of an expression that is potentially live in $\px$, such as
% $\semscott{\px}_{ρ'}$, and we have no way to observe the dependency on $\px$
% just through $ρ(\py)$.
% The key is to realise that our notion of deadness varies $ρ(\px)$ (the meaning
% of $\px$), but that does not vary $ρ(\py)$, because that only sees $ρ'(\px)$,
% so for all intents and purposes, the proof may assume that $ρ(\py)$ is dead in
% $\px$.
% The analysis, on the other hand, encodes transitive deadness relationships via
% $\tr(\px) ⊑ \tr(\py)$ in case $\px$ occurs in the RHS of a $\mathsf{let}$-bound
% $\py$ to encode that deadness of $\py$ is a necessary condition for deadness of
% $\px$, which requires generalisation of the inductive hypothesis.

\formgoal{1}{Give a semantics that makes correctness proofs similarly simple.}

This is a rather vague goal and should be seen as the overarching principle of
this work.
In support of this principle, we will formulate a few more concrete goals that
each require more context to make sense.

\subsection{Approximation Order and Safety Properties}
\label{sec:continuity}

% Nevermind our confidence in the ultimate correctness of $\semusg{\wild}$,
Our notion of deadness has a blind spot \wrt diverging computations:
$\semscott{\wild}$ denotes any looping program such as
$\pe_{\mathit{loop}} \triangleq \Let{\mathit{loop}}{\Lam{x}{\mathit{loop}~x}}{{\mathit{loop}~\mathit{loop}}}$ by $\bot$, the
same element that is meant to indicate partiality in the approximation order
of the domain (\eg, insufficiently specified input).
Hence any looping program is automatically dead in all its free variables, even
though any of them might influence which particular endless loop is taken.

This is not only a curiosity of $\semusg{\wild}$; it also applies to the original
control-flow analysis work~\citep[p. 23]{Shivers:91} where it is remedied
by the introduction of a \emph{non-standard semantic interpretation} that
assigns meaning to diverging programs where the denotational semantics only
says $\bot$.
The bottom element of the non-standard domain is the empty set of reached
program labels. So if the non-standard semantics were to assign the bottom
element to diverging programs like the denotational semantics does, it would
neglect that any part of the program before the loop was ever reached.
The non-standard semantic interpretation is far more reasonable, but credibility
of this approach solely rests on the structural similarity to the standard
denotational semantics.

Both usage analysis and control-flow analysis infer so called
\emph{safety properties}~\citep{Lamport:77,Cousot:21}.
When a diverging execution violates a safety property (\eg, evaluates a variable
or reaches a control-flow node), one of its finite prefixes will also violate
it.
Any analysis inferring a safety property that is not trivial on infinite traces
(\eg, there are infinite traces which have and which violate the property)
is impossible to verify correct \wrt a denotational semantics where diverging
computations are denoted with the bottom element of an approximation order,
because one of the infinite executions denoted by $\bot$ violates this property.

According to \citet[Section 2.3]{WrightFelleisen:94}, the approximation order
used in traditional denotational semantics and the resulting recurring need
to solve domain equations and prove continuity -- tedious manual processes --
contributed great arguments in favor of operational semantics.

%Furthermore, as is often done, $\semscott{\wild}$ abuses $\bot$ as a collecting
%pool for error cases.
%This shows in the following example:
%$x$ is dead in $(\Lam{y}{\Lam{z}{z}})~x$, but dropping the $\mathbf{let}$
%binding in $\Let{x}{\pe_1}{(\Lam{y}{\Lam{z}{z}})~x}$
%introduces a scoping error which is not observable under $\semscott{\wild}$.
%We could take inspiration in the work of \citet{Milner:78}
%and navigate around the issue by introducing a $\mathbf{wrong}$ denotation for
%errors which is propagated strictly; then we would notice when we optimise a
%looping program such as $\pe_{\mathit{loop}}$ into one that has a scoping error.

%We can try to apply that same trick to diverging programs and assign them a
%total domain element $\mathsf{div}$ distinct from all other elements.
%But then when would we go from $\bot$ to $\mathsf{div}$ in the least fixpoint in
%$\semscott{\Let{\wild}{\wild}{\wild}}$?
%There is no way to introduce $\mathsf{div}$ unless we make it a partial element
%that approximates every total element; but then we could have just chosen $\bot$
%as the denotation to begin with.
%Hence denoting diverging programs by a partial element $\bot$ or $\mathsf{div}$
%is a fundamental phenomenon of traditional denotational semantics and brings
%with it annoying pitfalls.
%To see one, consider the predicate ``Denotation $d$ will get stuck and not
%diverge''.
%This predicate is not \emph{admissable}~\citep{Abramsky:94}, because an
%admissable predicate that is at all satisfiable would need to be true for
%the partial elements $d=\bot$ and $d=\mathsf{div}$.
%A practical consequence is that such a predicate could not be proven about a
%recursive let binding because that would need admissability to apply fixpoint
%induction.

Hence we formulate the following goal:

\formgoal{2}{Find a semantic domain in which diverging programs can be denoted
by a total element.}

\subsection{Operational Detail}

Blind spots and annoyances notwithstanding, the denotational notion of deadness
above is quite reasonable and \Cref{thm:semusg-correct-live} is convincing.
But our usage analysis infers more detailed cardinality information;
for example, it can infer whether a binding is evaluated at most once.%
\footnote{Thus our usage analysis is a combination of deadness analysis
and \emph{sharing analysis}~\citep{Gustavsson:98}.}
This information can be useful to inline a binding that is not a value or
to avoid update frames under call-by-need~\citep{Gustavsson:98,cardinality-ext}.%
\footnote{A more useful application of the ``at most once'' cardinality is the
identification of \emph{one-shot} lambdas~\citep{cardinality-ext} --- functions which are
called at most once for every activation --- because it allows floating of heap
allocations from a hot code path into cold function bodies.
Simplicity prohibits $\semusg{\wild}$ from inferring such properties.}

Unfortunately, our denotational semantics does not allow us to express the
operational property ``$\pe$ evaluates $\px$ at most $u$ times'', so
we cannot prove that $\semusg{\wild}$ can be used for update avoidance.

\formgoal{3}{Find a semantics that can observe operational detail such as
usage cardinality.}

\subsection{Structural Mismatch}

\begin{figure}
\[\begin{array}{c}
 \begin{array}{rrclcl@@{\hspace{1.5em}}rrcrclcl}
  \text{Addresses}     & \pa & ∈ & \Addresses     & \simeq & ℕ
  &
  \text{States}        & σ   & ∈ & \States        & =      & \Exp \times \Environments \times \Heaps \times \Continuations
  \\
  \text{Environments}  & ρ   & ∈ & \Environments  & =      & \Var \pfun \Addresses
  &
  \text{Heaps}         & μ   & ∈ & \Heaps         & =      & \Addresses \pfun \Environments \times \Exp
  \\
  \text{Continuations} & κ   & ∈ & \Continuations & ::=    & \multicolumn{7}{l}{\StopF \mid \ApplyF(\pa) \pushF κ \mid \SelF(ρ,\SelArity) \pushF κ \mid \UpdateF(\pa) \pushF κ} \\
 \end{array} \\
 \\[-0.5em]
\end{array}\]

\newcolumntype{L}{>{$}l<{$}} % math-mode version of "l" column type
\newcolumntype{R}{>{$}r<{$}} % math-mode version of "r" column type
\newcolumntype{C}{>{$}c<{$}} % math-mode version of "c" column type
\resizebox{\textwidth}{!}{%
\begin{tabular}{LR@@{\hspace{0.4em}}C@@{\hspace{0.4em}}LL}
\toprule
\text{Rule} & σ_1 & \smallstep & σ_2 & \text{where} \\
\midrule
\LetIT & (\Let{\px}{\pe_1}{\pe_2},ρ,μ,κ) & \smallstep & (\pe_2,ρ',μ[\pa↦(ρ',\pe_1)], κ) & \pa \not∈ \dom(μ),\ ρ'\! = ρ[\px↦\pa] \\
\AppIT & (\pe~\px,ρ,μ,κ) & \smallstep & (\pe,ρ,μ,\ApplyF(\pa) \pushF κ) & \pa = ρ(\px) \\
\CaseIT & (\Case{\pe_s}{\Sel[r]},ρ,μ,κ) & \smallstep & (\pe_s,ρ,μ,\SelF(ρ,\Sel[r]) \pushF κ) & \\
\LookupT & (\px, ρ, μ, κ) & \smallstep & (\pe, ρ', μ, \UpdateF(\pa) \pushF κ) & \pa = ρ(\px),\ (ρ',\pe) = μ(\pa) \\
\AppET & (\Lam{\px}{\pe},ρ,μ, \ApplyF(\pa) \pushF κ) & \smallstep & (\pe,ρ[\px ↦ \pa],μ,κ) &  \\
\CaseET & (K'~\many{y},ρ,μ, \SelF(ρ',\Sel) \pushF κ) & \smallstep & (\pe_i,ρ'[\many{\px_i ↦ \pa}],μ,κ) & K_i = K',\ \many{\pa = ρ(\py)} \\
\UpdateT & (\pv, ρ, μ, \UpdateF(\pa) \pushF κ) & \smallstep & (\pv, ρ, μ[\pa ↦ (ρ,\pv)], κ) & \\
\bottomrule
\end{tabular}
} % resizebox
\caption{Lazy Krivine transition semantics $\smallstep$}
  \label{fig:lk-semantics}
\end{figure}

Let us try a different approach then and define a stronger notion of deadness
in terms of a small-step operational semantics such as the Mark II machine of
\citet{Sestoft:97} given in \Cref{fig:lk-semantics}, the semantic ground truth
for this work. (A close sibling for call-by-value would be a CESK machine
\citep{Felleisen:87} or a simpler derivative thereof.)
It is a Lazy Krivine (LK) machine implementing call-by-need, so for a meaningful
comparison to the call-by-name semantics $\semscott{\wild}$, we ignore rules
$\CaseIT, \CaseET, \UpdateT$ and the pushing of update frames in $\LookupT$ for
now to recover a call-by-name Krivine machine with explicit heap addresses.%
\footnote{Note that discarding update frames makes the heap entries immutable,
which makes the explicit heap unnecessary. Of course, for call-by-name we would
not need a heap to begin with, but the point is to get a glimpse at the effort
necessary for call-by-need.}

The configurations $σ$ in this transition system resemble abstract machine
states, consisting of a control expression $\pe$, an environment $ρ$ mapping
lexically-scoped variables to their current heap address, a heap $μ$ listing a
closure for each address, and a stack of continuation frames $κ$.

The notation $f ∈ A \pfun B$ used in the definition of $ρ$ and $μ$ denotes a
finite map from $A$ to $B$, a partial function where the domain $\dom(f)$ is
finite and $\rng(f)$ denotes its range.
The literal notation $[a_1↦b_1,...,a_n↦b_n]$ denotes a finite map with domain
$\{a_1,...,a_n\}$ that maps $a_i$ to $b_i$. Function update $f[a ↦ b]$
maps $a$ to $b$ and is otherwise equal to $f$.

The initial machine state for a closed expression $\pe$ is given by the
injection function $\inj(\pe) = (\pe,[],[],\StopF)$ and
the final machine states are of the form $(\pv,\wild,\wild,\StopF)$.
We bake into $σ∈\States$ the simplifying invariant of \emph{well-addressedness}:
Any address $\pa$ occuring in $ρ$, $κ$ or the range of $μ$ must be an element of
$\dom(μ)$.
It is easy to see that the transition system maintains this invariant and that
it is still possible to observe scoping errors which are thus confined to lookup
in $ρ$.

This machine allows us to observe variable lookups as $\LookupT$ transitions,
which enables a semantic characterisation of \emph{usage cardinality}:

\begin{definition}[Usage cardinality]
  \label{defn:deadness2}
  An expression $\pe$ \emph{evaluates} $\px$ \emph{at most $u$ times}
  if and only if for any evaluation context $(ρ,μ,κ)$ and expression $\pe'$,
  there are at most $u$ configurations $σ$ in the trace
  $(\Let{\px}{\pe'}{\pe},ρ,μ,κ) \smallstep (\pe,ρ[\px↦\pa],\wild,\wild) \smallstep^* σ$ such
  that $σ=(\py,ρ',\wild,\wild)$ and $ρ'(\py) = \pa$.
\end{definition}

In other words, the usage cardinality of a variable $\px$ is an upper bound to
the number of $\LookupT$ transitions that alias to the heap entry of $\px$,
assuming we start in a state where $\px$ is alias-free.

% Demonstrate that this is a safety property!

Intuitively, $\px$ is dead in $\pe$ if the usage cardinality of $\px$ is
0, given a suitable redefinition of deadness.
We will give such a definition in terms of the semantics' \emph{contextual
improvement} relation as in \citep{MoranSands:99}.
These are the \emph{contexts} $\pC$ with holes $\hole$ of our language
(excluding data types, for brevity):
\[\begin{array}{rcl}
  \pC & ::=  & \hole \mid \pC~\px \mid \Lam{\px}{\pC} \mid \Let{\px}{\pe}{\pC} \mid \Let{\px}{\pC}{\pe} \\
\end{array}\]
$\pC[\pe]$ denotes an expression where the hole in $\pC$ has been filled
with $\pe$, expressing that the bigger expression $\pC[\pe]$ is a function of
$\pe$.
\begin{abbreviation}[Bigstep]
  We write $\bigsteppn{n}{\pe}{\pv}$ to say that $\inj(\pe) \smallstep^n (\pv,\wild,\wild,\StopF)$.
  Likewise, $\bigsteppn{\leq n}{\pe}{\pv}$ implies $\bigsteppn{m}{\pe}{\pv}$ for
  some $m \leq n$; and $\bigstepp{\pe}{\pv}$ means that there is any $n$ at all
  such that $\bigsteppn{n}{\pe}{\pv}$.
\end{abbreviation}
\begin{definition}[Contextual improvement]
  An expression $\pe_1$ \emph{improves on} an expression $\pe_2$ (written $\pe_1 \lessequiv \pe_2$)
  if for all $\pC$ such that $\pC[\pe_i]$ are closed,
  \[
    \bigsteppn{n}{\pC[\pe_2]}{\wild} \Longrightarrow \bigsteppn{\leq n}{\pC[\pe_1]}{\wild}.
  \]
\end{definition}
We will write $\pe_1 \impequiv \pe_2$ if both $\pe_1 \lessequiv \pe_2$ and
$\pe_2 \lessequiv \pe_1$, in which case both expressions are also contextually
equivalent~\citep{MoranSands:99}.
\Cref{defn:deadness2} informally called triples $(ρ,μ,κ)$ \emph{evaluation contexts}.
They have a corresponding syntactic notion as well~\citep{Ariola:95}:
\[\begin{array}{rcl}
  \pE & ::=  & \hole \mid \pE~\px \mid \Let{\px}{\pe}{\pE} \mid \Let{\px}{\pE_1}{\pE_2[\px]} \\
\end{array}\]
\citeauthor{MoranSands:99} proved that it is sufficient to consider evaluation
contexts to show improvement:
\begin{lemma}[Context lemma]
  For all expressions $\pe_1$,$\pe_2$, if for all $\pE$ such that $\pE[\pe_i]$ are closed
  we have $\bigsteppn{n}{\pE[\pe_2]}{\wild} \Longrightarrow \bigsteppn{\leq n}{\pE[\pe_1]}{\wild}$,
  then $\pe_1 \lessequiv \pe_2$.
\end{lemma}
Now we can finally give a precise definition of deadness:
\begin{definition}[Deadness, operationally]
  \label{defn:deadness2}
  Let $\pe$ be an expression and $\px$ a variable.
  $\px$ is \emph{dead} in $\pe$ if and only if
  for any expressions $\pe_1,\pe_2$
  \[
    \Let{\px}{\pe_1}{\pe} \impequiv \Let{\px}{\pe_2}{\pe}.
  \]
\end{definition}
This definition improves upon \Cref{defn:deadness} in that it does not only
capture soundness of the implied rewrite but also that the program does not slow
down.
Furthermore, it guarantees that infinite executions will not get stuck and vice
versa.

In effect, \Cref{defn:deadness2} is an extensional condition of when a
particular \emph{transformation} is an optimisation.
We can connect it to our semantic definition of cardinality (\eg, what our
\emph{analysis} approximates) as follows:
\begin{lemma}[What is never used is dead]
  \label{thm:never-dead}
  If an expression $\pe$ evaluates a variable $\px$ at most $0$ times, $\px$ is
  dead in $\pe$.
\end{lemma}
Although this lemma should make intuitive sense, its proof is much less so
(annoyingly), for reasons we discuss in a bit.
Because it has such a mediocre effort-to-insight ratio, this part of proving an
analysis correct \wrt a transformation it enables is often neglected.
The following statement is more interesting to researchers of static analyses,
because it involves their specific analysis:
\begin{theorem}[Correctness of $\semusg{\wild}$]
  \label{thm:semusg-correct-2}
  Let $\pe$ be an expression, $\px$ a variable.
  If $\semusg{\pe}_{\tr_Δ}(\px) ⊑ u$
  then $\pe$ evaluates $\px$ at most $u$ times.
\end{theorem}
One would expect to be able to conclude that $\Let{y}{\pe_1}{\pe_2}$ never
evaluates $x$ if $\pe_1$ and $\pe_2$ never evaluate $x$, but unfortunately
that is not the case:
\[
  (\Let{x}{\pe'}{\Let{y}{\pe_1}{\pe_2}},ρ,μ,κ) \smallstep^2
  (\pe',ρ[x↦\pa_1,y↦\pa_2],μ[\pa_1↦(\wild,\pe'),\pa_2↦(\wild, \pe_1)],κ)
\]
Note that although $x$ is dead in $\pe_1$, it might still \emph{occur} in
$\pe_1$ (in a dead argument, for example), so it is impossible to derive this
state by starting from $\Let{x}{\pe'}{\pe_2}$.
Consequently, we can make no statement about the usage cardinality of
$\Let{y}{\pe_1}{\pe_2}$ and it is impossible to prove that $\semusg{\pe}$
satisfies \Cref{thm:semusg-correct-2} by direct structural induction on $\pe$
(in a way that would be useful to the proof).

Instead, such proofs are often conducted by induction over the reflexive
transitive closure of the transition relation.
For that it is necessary to give an inductive hypothesis that considers
environments, stacks and heaps.
One way is to extend the analysis function $\semusg{\wild}$ to entire
configurations and then prove that if $σ_1 \smallstep σ_2$ we have $\semusg{σ_2}
⊑ F(\semusg{σ_1})$, where $F$ is the abstraction of the particular transition
rule taken and is often left implicit.
This is a daunting task, for multiple reasons:
First off, $\semusg{\wild}$ might be quite complicated in practice and extending
it to entire configurations multiplies this complexity.
Secondly, $\semusg{\wild}$ makes use of fixpoints in the let case,
so $\semusg{σ_2} ⊑ F(\semusg{σ_1})$ relates fixpoints that are ``out of sync'',
implying a need for fixpoint induction.

In call-by-need, there will be a fixpoint between the heap and stack due to
update frames acting like heap bindings whose right-hand side is under
evaluation (a point that is very apparent in the semantics of
\citet{Ariola:95}), so fixpoint induction needs to be applied \emph{at every
case of the proof}, diminishing confidence in correctness unless the proof is
fully mechanised.

For an analogy with type systems: What we just tried is like attempting a proof
of preservation by referencing the result of an inference algorithm rather than
the declarative type system. So what is often done instead is to define a declarative and
more permissive \emph{correctness relation} $C(σ)$ to prove preservation $C(σ_1)
\Longrightarrow C(σ_2)$ (\eg, that $C$ is \emph{logical} \wrt $\smallstep$).
$C$ is chosen such that
  (1) it is strong enough to imply the property of interest (deadness)
  (2) it is weak enough that it is implied by the analysis result for an initial state ($\tr(\px) \not⊑ \semusg{\pe}_{\tr}$).
Examples of this approach are the
``well-annotatedness'' relation in \citep[Lemma 4.3]{cardinality-ext} or
$\sim_V$ in \citep[Theorem 2.21]{Nielson:99}), the correctness
relation for \Cref{thm:never-dead} and the soundness
relations we give in \Cref{sec:vanilla,sec:eventful}. % TODO
We found it quite hard to come up with a suitable ad-hoc correctness relation
for usage cardinality, though.

%Often, correctness proofs do not need the full operational detail of a
%CESK-style machine, in which case a simpler machine definition leads to simpler
%proof.
%If the correctness statement does not need to keep track about which address
%is an activation of which let-bound program variable, the distinction between
%addresses and variables is unnecessary and the environment component vanishes.
%The stack can often be reflected back into the premises of the judgment
%rules, distinguishing \emph{instruction transitions} from \emph{search
%transitions}, a distinction which is made explicit in a \emph{contextual
%semantics}.
%Applying both these transformations yields a CS machine~\citep{Felleisen:87}.
%However for call-by-need, the evaluation context corresponding to an update
%frame is neither obvious nor simple~\citep{Ariola:95}.
%For pure call-by-value and call-by-name calculi, the heap becomes
%immutable and variables can be substituted immediately for their right-hand
%sides/arguments rather than delaying lookup to the variable case, abolishing the
%need for the heap altogether and yielding a contextual semantics where
%states are a simple expression.
%
%These refactorings help in simplifying proofs:
%Instead of defining a coinductive well-formedness predicate on the heap, we
%prove a substitution lemma.
%Instead of a well-formedness predicate for the stack, we appeal to the
%well-formedness of the search transition rule.

We have just descended into a mire of complexity to appreciate the following
goal:

\formgoal{4}{Avoid structural mismatch between semantics and analysis.}

Goal 4 can be seen as a necessary condition for Goal 1:
Structural mismatch makes a simple proof impossible.
Since our analysis is compositional, we strive for a compositional semantics in
\Cref{sec:vanilla,sec:eventful}. %TODO

\subsection{Abstract Interpretation}

Where does \emph{Abstract Interpretation}~\citep{Cousot:21} fit into this?
Note first that the property ``$\pe$ evaluates $\px$ at most $u$ times'' can be
interpreted as a property of all the (potentially infinite) traces $τ$ generated by
$(\Let{\px}{\pe'}{\pe},ρ,μ,κ)$ for some $\pe',ρ,μ,κ$.
For a fixed $u$, this trace property is a safety property:
If $τ$ evaluates $\px$ more than $u$ times, then some finite prefix of $τ$ will
also evaluate $\px$ more than $u$ times.
Thus we can formulate usage cardinality of a trace as a mathematical function:
\[\begin{array}{lcl}
  \usg    & \colon & \mathbb{T} \to \UsgD \\
  \usg(τ) & =      & \begin{cases}
    [ \px ↦ 1 \mid ρ(\py) = ρ(\px) ] + \usg(τ') & τ = (\py,ρ,\wild,\wild) \smallstep τ' \\
    \usg(τ') & τ = σ \smallstep τ' \\
    \bot & τ = σ, σ \not\smallstep \\
    \Lub_{τ^* ∈ \mathit{pref}(τ)} \usg(τ^*) & \text{otherwise},
  \end{cases}
\end{array}\]
(where $\mathit{pref}(τ)$ enumerates the finite prefixes of $τ$.)
Furthermore, we can lift $\usg$ to sets of traces via
\emph{join homomorphic abstraction}~\citep[Exercise 11.8]{Cousot:21}
$α_{\usg}(T) \triangleq \Lub_{τ∈T} \{ \usg(τ) \mid τ ∈ T \}$,
yielding for free a Galois connection between inclusion on sets of traces and
$(\Usg,⊑)$.%
\footnote{\citeauthor{Nielson:99} calls $\usg$ a \emph{representation function}
and derive a Galois connection in the same way.}
Writing $\semsmall{σ}$ to denote the maximal small step trace starting from
$σ$, we can re-state \Cref{thm:semusg-correct-2} as
\[
  ∀\pe,ρ,μ,κ,\px,\pe'.\ α_{\usg}(\{\semsmall{(\Let{\px}{\pe'}{\pe},ρ,μ,κ)}\})(\px) ⊑ \semusg{\pe}_{\tr_Δ}(\px).
\]
The art of abstract interpretation is to massage this statement into a
form that it applies at the recursive invokations of $\semusg{\wild}$ (by
discarding the first transition, among other things) and relating the
environment parameter $\tr_Δ$ to $(ρ,μ)$ via $α_{\usg}$.
This process constructs a correctness relation in ``type-driven'' way, by
(in-)equational reasoning.

Alas, due to the structural mismatch between semantics and analysis, the
``massaging'' becomes much harder.
This is why related literature such as
\emph{Abstracting Abstract Machines}~\citep{aam} and
\emph{Abstracting Definitional Interpreters}~\citep{adi}
force the analysis structure to follow the semantics.

On the other hand, \citet{Cousot:21} gives a structurally recursive semantics
function, generating potentially infinite traces (understood topologically) for
an imperative, first-order language.
Consequently, all derived analyses are structurally-recursive in turn.%
\footnote{Computation of fixpoints can still happen on a control-flow graph, of
course, employing efficient worklist algorithms.}

This inspired us to find a similar semantics for a higher-order language.
By coincidence, this semantics has the form of definitional interpreter,
and can be abstracted enough to qualify as an abstract definitional interpreter.
In contrast to the work on abstract small-step and big-step
machines, this interpreter is \emph{total}, just like Cousot's semantics, and
hence qualifies as a denotational semantics that we can harness to prove
statements such as \Cref{thm:never-dead}.

% TODO: Forward reference to where we bring our semantics to bear

% An alternative to avoid structural mismatch is to follow Abstracting Abstract
% Machines~\citep{aam}.
% We will compare our approach to theirs in \Cref{sec:related-work}.

%\subsection{Abstracting Abstract Machines}
%
%Another way to work around the structural mismatch is to adopt the structure of
%the semantics in the analysis; this is done in the Abstracting Abstract Machines
%work \citep{aam}.
%The appeal is to piggy-back traditional and well-explored intraprocedural
%analysis techniques on the result of an interprocedural flow
%analysis~\citep{Shivers:91}.

\begin{comment}
\Cref{fig:usage} defines a static \emph{usage analysis}.
The idea is that $\semusg{\pe}_{ρ}$ is a function $d ∈ \UsgD$ whose domain
is the free variables of $\pe$; this function maps each free variable $\px$ of
$\pe$ to its \emph{usage cardinality} $u ∈ \Usg$, an upper bound on the
number of times that $\px$ will be evaluated when $\pe$ is evaluated (regardless
of context).
Thus, $\Usg$ is equipped with a total order that corresponds to the inclusion
relation of the denoted interval of cardinalities:
$\bot = 0 ⊏ 1 ⊏ ω = \top$, where $ω$ denotes \emph{any} number of evaluations.
This order extends pointwise to a partial ordering on $\UsgD$, so $d_1 ⊑
d_2$ whenever $d_1(\px) ⊑ d_2(\px)$, for all $\px$ and $\bot_{\UsgD} =
\constfn{\bot_\Usg}$.
We will often leave off the subscript of, \eg, $\bot_\UsgD$ when it can be
inferred from context.

So, for example $\semusg{x+1}_{ρ}$ is a function mapping $x$ to 1
and all other variables to 0 (for a suitable $ρ$ that we discuss in due course).
Any number of uses beyond $1$, such as $2$ for $x$ in $\semusg{x+x}_{ρ}$, are
collapsed to $d(x) = ω$.
Similarly $\semusg{\Lam{v}{v+z}}_{\rho}$
maps $z$ to $\omega$, since the lambda might be called many times.

For open expressions, we need a way to describe the denotations of its
free variables with a \emph{usage environment}\footnote{
Note that we will occassionally adorn with \textasciitilde{} to disambiguate
elements of the analysis domain from the semantic domain.}
$\tr ∈ \Var \to \UsgD$.
Given a usage environment $\tr$, $\tr(\px)(\py)$ models an upper bound
on how often the expression bound to $\px$ evaluates $\py$.

\begin{figure}
\begin{minipage}{\textwidth}
\[\begin{array}{c}
 \arraycolsep=3pt
 \begin{array}{rrclcl}
  \text{Scott Domain}      &  d & ∈ & \ScottD & =   & [\ScottD \to_c \ScottD]_\bot \\
  \text{Usage cardinality} &  u & ∈ & \Usg & =   & \{ 0, 1, ω \} \\
  \text{Usage Domain}      &  d & ∈ & \UsgD & =   & \Var \to \Usg \\
 \end{array} \quad
 \begin{array}{rcl}
   (ρ_1 ⊔ ρ_2)(\px) & = & ρ_1(\px) ⊔ ρ_2(\px) \\
   (ρ_1 + ρ_2)(\px) & = & ρ_1(\px) + ρ_2(\px) \\
   (u * ρ_1)(\px)   & = & u * ρ_1(\px) \\
 \end{array}
 \\[-0.5em]
\end{array}\]
\subcaption{Syntax of semantic domains}
  \label{fig:dom-syntax}
\newcommand{\scalefactordenot}{0.92}
\scalebox{\scalefactordenot}{%
\begin{minipage}{0.49\textwidth}
\arraycolsep=0pt
\[\begin{array}{rcl}
  \multicolumn{3}{c}{ \ruleform{ \semscott{\wild}_{\wild} \colon \Exp → (\Var \to \ScottD) → \ScottD } } \\
  \\[-0.5em]
  \semscott{\px}_ρ & {}={} & ρ(\px) \\
  \semscott{\Lam{\px}{\pe}}_ρ & {}={} & \fn{d}{\semscott{\pe}_{ρ[\px ↦ d]}} \\
  \semscott{\pe~\px}_ρ & {}={} & \begin{cases}
     f(ρ(\px)) & \text{if $\semscott{\pe}_ρ = f$}  \\
     \bot      & \text{otherwise}  \\
   \end{cases} \\
  \semscott{\Letsmall{\px}{\pe_1}{\pe_2}}_ρ & {}={} &
    \begin{letarray}
      \text{letrec}~ρ'. & ρ' = ρ \mathord{⊔} [\px \mathord{↦} d_1] \\
                        & d_1 = \semscott{\pe_1}_{ρ'} \\
      \text{in}         & \semscott{\pe_2}_{ρ'}
    \end{letarray} \\
\end{array}\]
\subcaption{\relscale{\fpeval{1/\scalefactordenot}} Denotational semantics after Scott}
  \label{fig:denotational}
\end{minipage}%
\quad
\begin{minipage}{0.56\textwidth}
\arraycolsep=0pt
\[\begin{array}{rcl}
  \multicolumn{3}{c}{ \ruleform{ \semusg{\wild}_{\wild} \colon \Exp → (\Var → \UsgD) → \UsgD } } \\
  \\[-0.5em]
  \semusg{\px}_ρ & {}={} & ρ(\px) \\
  \semusg{\Lam{\px}{\pe}}_ρ & {}={} & ω*\semusg{\pe}_{ρ[\px ↦ \bot]} \\
  \semusg{\pe~\px}_ρ & {}={} & \semusg{\pe}_ρ + ω*ρ(\px)
    \phantom{\begin{cases}
       f(ρ(\px)) & \text{if $\semusg{\pe}_ρ = f$}  \\
       \bot      & \text{otherwise}  \\
     \end{cases}} \\
  \semusg{\Letsmall{\px}{\pe_1}{\pe_2}}_ρ& {}={} & \begin{letarray}
      \text{letrec}~ρ'. & ρ' = ρ \mathord{⊔} [\px \mathord{↦} d_1] \\
                        & d_1 = [\px\mathord{↦}1] \mathord{+} \semusg{\pe_1}_{ρ'} \\
      \text{in}         & \semusg{\pe_2}_{ρ'}
    \end{letarray}
\end{array}\]
\subcaption{\relscale{\fpeval{1/\scalefactordenot}} Naïve usage analysis}
  \label{fig:usage}
\end{minipage}
}
\end{minipage}
  \label{fig:intro}
\vspace{-0.75em}
\caption{Connecting usage analysis to denotational semantics}
\end{figure}

\end{comment}

