\section{Semantics}
\label{sec:semantics}

\subsection{Transititon System}

\begin{itemize}
  \item Introduce syntax, labels, notation. $\StateD$ is not the exponential!
  \item Introduce transition system+states, clarifying that we don't care about
        $\StateD$ yet, only that we'll instantiate in a way that makes the
        semantics deterministic
\end{itemize}

\begin{figure}
\[\begin{array}{c}
 \begin{array}{rrclcl}
  \text{Variables}    & \px, \py & ∈ & \Var        &     & \\
  \text{Values}       &      \pv & ∈ & \Val        & ::= & \Lam{\px}{\pe} \\
  \text{Expressions}  &      \pe & ∈ & \Exp        & ::= & \slbl \px \mid \slbl \pv \mid \slbl \pe~\px \mid \slbl \Let{\px}{\pe_1}{\pe_2} \\
  \text{Addresses}    &      \pa & ∈ & \Addresses  &  ⊆  & ℕ \\
  \\
  \text{States}                             & σ      & ∈ & \States  & = & \Control \times \Environments \times \Heaps \times \Continuations \\
  \text{Control}                            & γ      & ∈ & \Control & = & \Exp ∪ (\Val \times \Values^\States) \\
  \text{Environments}                       & ρ      & ∈ & \Environments & = & \Var \pfun \Addresses \\
  \text{Heaps}                              & μ      & ∈ & \Heaps & = & \Addresses \pfun \Exp \times \Environments \times \StateD \\
  \text{Continuations}                      & κ      & ∈ & \Continuations & ::= & \StopF \mid \ApplyF(\pa) \pushF κ \mid \UpdateF(\pa) \pushF κ \\
  \\[-0.5em]
  \text{Stateful traces}                    & π      & ∈ & \STraces & ::=_{\gfp} & σ\straceend \mid σ; π \\
  \text{Domain of stateful trace semantics} & d      & ∈ & \StateD  & = & \States \to_c \STraces \\
  \text{Values}                             & v      & ∈ & \Values^\States & ::= & \FunV(\Addresses \to \StateD) \\
 \end{array} \\
 \\
 \begin{array}{c}
  \ruleform{ σ_1 \smallstep σ_2 } \\
  \\[-0.5em]
  \inferrule*
    [right=$\ValueT$]
    {\quad}
    {(\pv, ρ, μ, κ) \smallstep ((\pv, v), ρ, μ, κ)}
  \qquad
  \inferrule*
    [right=$\LookupT$]
    {\pa = ρ(\px) \quad (\pe,ρ',\wild) = μ(\pa)}
    {(\px, ρ, μ, κ) \smallstep (\pe, ρ', μ, \UpdateF(\pa) \pushF κ)}
  \\
  \inferrule*
    [right=$\UpdateT$]
    {\quad}
    {((\pv,v), ρ, μ, \UpdateF(\pa) \pushF κ) \smallstep ((\pv,v), ρ, μ[\pa ↦ (\pv,ρ,d)], κ)} \\
  \\[-0.5em]
  \inferrule*
    [right=$\AppIT$]
    {\pa = ρ(\px)}
    {(\pe~\px,ρ,μ,κ) \smallstep (\pe,ρ,μ,\ApplyF(\pa) \pushF κ)}
  \quad
  \inferrule*
    [right=$\AppET$]
    {\quad}
    {((\Lam{\px}{\pe},\wild),ρ,μ, \ApplyF(\pa) \pushF κ) \smallstep (\pe,ρ[\px ↦ \pa],μ,κ)} \\
  \\[-0.5em]
  \inferrule*
    [right=$\LetT$]
    {\fresh{\pa}{μ} \quad ρ' = ρ[\px↦\pa]}
    {(\Let{\px}{\pe_1}{\pe_2},ρ,μ,κ) \smallstep (\pe_2,ρ',μ[\pa↦(\pe_1,ρ',d_1)], κ)} \\
  \\
 \end{array} \\
 \begin{array}{rcl}
  \multicolumn{3}{c}{ \ruleform{ src_\States(π) = σ \qquad dst_\States(π) = σ } } \\
  \\[-0.5em]
  src_\States(σ\straceend)    & = & σ \\
  src_\States(σ; π) & = & σ \\
  \\[-0.5em]
  dst_\States(π)    & = & \begin{cases}
    undefined & \text{if $π$ infinite} \\
    σ         & \text{if $π = ...; σ \straceend$}
  \end{cases} \\
 \end{array} \quad
 \begin{array}{c}
  \ruleform{ π_1 \sconcat π_2 = π_3 } \\
  \\[-0.5em]
  π_1 \sconcat π_2 = \begin{cases}
    σ; (π_1' \sconcat π_2) & \text{if $π_1 = σ; π_1'$} \\
    π_2                    & \text{if $π_1 = σ\straceend$ and $src_\States(π_2) = σ$} \\
    undefined              & \text{if $π_1 = σ\straceend$ and $src_\States(π_2) \not= σ$} \\
  \end{cases} \\
 \end{array} \\
 \\
 \begin{array}{c}
  \ruleform{ \validtrace{π} } \\
  \\[-0.5em]
  \inferrule*
    {\quad}
    {\validtrace{σ\straceend}}
  \qquad
  \inferrule*
    {σ \smallstep src_\States(π) \quad \validtrace{π}}
    {\validtrace{σ; π}} \\
  \\
 \end{array} \\
\end{array}\]
\caption{Call-by-need CESK transition system $\smallstep$}
  \label{fig:cesk-syntax}
\end{figure}

% Note [On the role of labels]
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Simon does not like program labels; he'd much rather just talk about
% the expressions those labels are attached to. Yet it is important for
% the simplicity of analyses *not* to identify structurally equivalent
% sub-expressions, example below.
%
% Our solution is to assume that every expression is implicitly labelled
% (uniquely, so). When we use the expression as an index, we implicitly use the
% label as its identity rather than its structure. When labels are explicitly
% required, we can obtain them via the at() function.
%
% When do we *not* want structural equality on expressions? Example:
%
%   \g -> f a + g (f a)
%
% Now imagine that given a call to the lambda with an unknown `g`, we'd like to
% find out which subexpressions are evaluated strictly. We could annotate our
% AST like this
%
%   \g -> ((f^S a^L)^S + (g (f^L a^L)^L)^S)^S
%
% Note how the two different occurrences of `f a` got different annotations.
%
% For obvious utility (who wants to redefine the entire syntax for *every*
% analysis?), we might want to maintain the analysis information *outside* of
% the syntax tree, as a map `Expr -> Strictness`. But doing so would conflate
% the entries for both occurrences of `f a`! So what we rather do is assume
% that every sub-expression of the syntax tree is labelled with a unique token
% l∈Label and then use that to maintain our external map `Label -> Strictness`.
%
% We write ⌊Expr⌋ to denote the set of expressions where labels are "erased",
% meaning that structural equivalent expressions are identified.
% The mapping `Label -> Expr` is well-defined and injective; the mapping
% `Label -> ⌊Expr⌋` is well-defined and often *not* injective.
% Conversely, `at : Expr -> Label` extracts the label of an expression, whereas
% `⌊Expr⌋ -> Label` is not well-defined.
%
% Note that as long as a function is defined by structural recursion over an
% expression, we'll never see two concrete, structurally equivalent expressions,
% so it's OK to omit labels and use the expression we recurse over (and its immediate
% subexpressions captured as meta variables) as if it contained the omitted labels.
%
% Note [The use of a CESK trace semantics]
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Why is CESK trace semantics useful?
%
% 1. Its transition semantics (derivable by typical transition system
%    abstraction function) *is* CESK, if you leave out the denotational stuff!
%    An ideal test bed for a bisimulation proof.
% 2. It is generated by a compositional function
% 3. Conjecture: We can provide order isos to any other useful trace semantics
%
% Note [Influences on the semantics]
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   * It's a lazy semantics in ANF, hence inspired by Sestoft's Mark II machine
%   * The Val transition is key to line up with the trace-based semantics and is
%     inspired by CESK's \ddagger as well as STG's ReturnCon code.

\subsection{Domain Theory}

Here we need to prove that $\StateD$ is well-defined as a domain.
(Of course, we need the quotient where $src(f(σ)) = σ$.)

Caveat: The order on $\Exp$ is the (flat) one by Labels. A deep embedding.

1. Express $\States$ as a functor over occs of $\StateD$. Clearly well-defined.
2. Express $\STraces$ as a (signature) functor $F : \mathcal{Cont} \to \mathcal{Cont}$.
   For that, we have to prove that $F(D)$ is a cont domain for any continuous $D$.

Then the fixpoint of the composition of those functors is a cont domain.

Define directed-complete partial order on $F(D)$.

\begin{itemize}
  \item $\bot = λσ.σ\straceend$.
  \item pointwise, lifting the obv prefix order over $σ_1 ⊑ σ_2$.
  \item obv. partial order
  \item directed-complete? Yes. How to prove formally? Unsure!
\end{itemize}

\subsection{Informal Specification}

Let us start with an informal specification: Our goal is to give a
structural definition of a function $\semst{\pe}$ that produces a denotation
$d ∈ \StateD$ of $\pe$, with the following properties: For every CESK state $σ$
where the control is $\pe$, $d(σ)$ is a trace in the transition system
$\smallstep$ with $σ$ as its source state. In itself, that is a trivial
specification, because $d(σ) = σ \straceend$ is a valid but hardly
useful model. So we refine: Every such trace $d(σ)$ must follow the evaluation
of $\pe$. For example, given a (sub-)expression $\Lam{x}{x}$ of
some program $\pe$, we expect the following equation:
\[
  \semst{\Lam{x}{x}} (\Lam{x}{x}, ρ, μ, κ) = (\Lam{x}{x}, ρ, μ, κ); ((\Lam{x}{x},\FunV(f)), ρ, μ, κ) \straceend
\]
Note that even if $κ$ had an apply frame on top, we require $\semst{\wild}$ to
stop after the value transition. In general, each intermediate continuation
$κ_i$ in the produced trace will be an extension of the first $κ$, so
$κ_i = ... \pushF κ$. We call traces with this property \emph{balanced}, as in
\cite{sestoft}.

Why produce balanced traces rather than letting the individual traces eat their
evaluation contexts to completion? Ultimately, we think it is just a matter of
taste, but certainly it's simpler to identify and talk about the \emph{semantic
value} of $\Lam{x}{x}$ this way: It is always the second component of the final
state's control (if it exists), and the semantic value determines how evaluation
continues.

Unsurprisingly, the semantic value of $\Lam{x}{x}$ is a $\FunV(f)$-value, the
$f$ of which will involve the semantics of the sub-program $\semst{x}$. The
transition semantics is indifferent to which semantic value is put in the control,
but for $\semst{\wild}$ we specify that $f$ continues where our balanced trace
left off. More precisely, we expect the $f$ in a semantic value $\FunV(f)$ to
closely follow β-reduction of the syntactic value $\Lam{x}{x}$ with the address
of the argument variable $\pa$, as follows
\[
  f(\pa)((\Lam{x}{x},\FunV(f)), ρ, μ, \ApplyF(\pa) \pushF κ) = ((\Lam{x}{x},\FunV(f)), ρ, μ, \ApplyF(\pa) \pushF κ); \semst{x}(x, ρ[x ↦ \pa], μ, κ)
\]
That is, semantic values pop exactly one frame from the continuation
and then produce another balanced trace of the redex. This statement extends
to other kinds of values such as data constructors, as we shall see in
\cref{ssec:adts}.

There is another occurrence of semantic denotations $d$ in the heap that is
uninstantiated by the transition system. If $(\pa ↦ (\pe, ρ, d)) ∈ μ$, then we
specify that $d = \semst{\pe}$. Since $\UpdateT$ modifies heap entries,
the corresponding denotation $d$ of the heap entry will have to be updated
accordingly to maintain this invariant.

Finally, it is a matter of good hygiene that $\semst{\pe}$ continues \emph{only}
those states that have $\pe$ as control; it should produce a singleton trace on
any other expression of the program, indicating stuck-ness. So even if $x~x$ and
$y~y$ both structurally are well-scoped application expressions,
$\semst{x~x}(y~y,ρ,μ,κ) = (y~y,ρ,μ,κ)\straceend$. In other words, if $(\pe_i)_i$
enumerates the sub-expressions of a program $\pe$, then for every state
$σ$ that is not stuck in the transition semantics, there is at most one function
$\semst{\pe_i}$ that is not stuck on $σ$.%
\footnote{Particularly peculiar is the situation where two distinctly labelled
sub-expressions of the program share the same erasure. \sg{Give an example here?
Perhaps earlier, where we'll discuss labels.}}

\subsection{Formal Specification}

A stuck trace is one way in which $\semst{\wild}$ does not \emph{always} return
a balanced trace. The other way is when the trace diverges before yielding to
the initial continuation. We call a trace \emph{maximally-balanced} if it is a
valid CESK trace and falls in either of the three categories. More precisely:

\begin{definition}[Non-retreating and maximally-balanced traces]\ \\
  A CESK trace $π = (e_1,ρ_1,μ_1,κ_1); ... (e_i,ρ_i,μ_i,κ_i); ... $ is
  \emph{non-retreating} if
  \begin{itemize}
    \item $\validtrace{π}$, and
    \item Every intermediate continuation $κ_i$ extends $κ_1$ (so $κ_i = κ_1$ or $κ_i = ... \pushF κ_1$)
  \end{itemize}
  A non-retreating CESK trace $π$ is \emph{maximally-balanced} if it is either
  infinite or there is no $σ$ such that $π \sconcat (dst_\States(π); σ \straceend)$
  is non-retreating.
  We notate maximally-balanced traces as $\maxbaltrace{π}$.
\end{definition}

\begin{lemma}[Extension relation on continuations is prefix order]
  The binary relation on continuations
  \[
    (\contextendsflipped) = \{ (κ_1,κ_2) ∈ \Continuations \times \Continuations \mid \text{$κ_2 = κ_1$ or $κ_2 = ... \pushF κ_1$} \}
  \]
  is a prefix order.
\end{lemma}
\begin{proof}
  $(\contextendsflipped)$ is isomorphic to the usual prefix order on strings
  over the alphabet of continuation frames.
\end{proof}

\begin{definition}[Return and evaluation states]
  $σ$ is a \emph{return state} if its control is of the form $(\pv, v)$.
  Otherwise, the control is of the form $\pe$ and $σ$ is an \emph{evaluation} state.
\end{definition}

The final states of the CESK semantics are the return states with a $\StopF$
continuation.
A state $σ$ that cannot make a step (so there exists no $σ'$ such that $σ
\smallstep σ'$) and is not a final state is called \emph{stuck}.

\begin{example}[Stuck]
  \label{ex:stuck}
  The following trace is stuck because $x$ is not in scope:
  \[
    \semst{x~y}(x~y,[y↦\pa], [\pa↦...], κ) = (x~y,[y↦\pa], [\pa↦...], κ); (x,[y↦\pa], [\pa↦...], \ApplyF(\pa) \pushF κ)\straceend
  \]
\end{example}

A trace is stuck if its destination state is stuck.

\begin{lemma}[Characterisation of destination states of maximally-balanced traces]
  Let $π$ be a non-retreating trace. Then, $π$ is maximally-balanced if and
  only if
  \begin{itemize}
    \item $π$ is infinite, or
    \item $π$ is stuck, or
    \item $π$ is \emph{balanced}, meaning that $dst_\States(π)$ is a return
          state, the continuation of which is that of the initial state
          $src_\States(π)$.
  \end{itemize}
\end{lemma}
\begin{proof}
  =>:
  Let $π$ be maximally-balanced.
  If $π$ is infinite or stuck, we are done; so assume that $π$ is finite and not
  stuck. Let $σ_1 = src_\States(π)$, $σ_n = dst_\States(π)$ and let $κ_1$ denote
  the continuation of $σ_1$ and $κ_n$ that of $σ_n$.
  Our goal is to show that $κ_n = κ_1$ and that $σ_n$ is a return state.

  If $σ_n$ is a final state, then clearly $σ_n$ is a return state with $κ_n =
  \StopF = κ_1$, where the latter equality follows from $π$ non-retreating
  and the fact that $\StopF$ is the unique minimal element of
  $(\contextendsflipped)$.

  Now assume that $σ_n$ is neither stuck nor final.
  Then there is $σ_{n+1}$ such that $σ_n \smallstep σ_{n+1}$; let $π' = π
  \sconcat (σ_n; σ_{n+1} \straceend)$ be the continued trace.
  $π'$ forms a valid CESK trace, but since $π$ is maximally-balanced, it can't
  be non-retreating.
  Hence the continuation $κ_{n+1}$ of $σ_{n+1}$ cannot be an extension of $κ_1$,
  so $κ_{n+1} \not\contextends κ_1$.
  On the other hand, $κ_n \contextends κ_1$ because $π$ is non-retreating.

  We proceed by cases over $σ_n \smallstep σ_{n+1}$:
  \begin{itemize}
    \item \textbf{Case} $\ValueT$, $\LookupT$, $\AppIT$, $\LetT$:
      These are all non-retreating transitions, so
      $κ_{n+1} \contextends κ_n \contextends κ_1$; contradiction.
    \item \textbf{Case} $\UpdateT$, $\AppET$:
      In both cases we see that $σ$ is a return state and
      we have $κ_n \contextends κ_{n+1}$.

      But we also have $κ_n \contextends κ_1$ and by downward totality of the
      prefix order $(\contextendsflipped)$, we must have either $κ_{n+1}
      \contextends κ_1$ or $κ_1 \contextends κ_{n+1}$. The former leads to a
      contradiction, hence we have $κ_n \contextends κ_1 \contextendsstrict
      κ_{n+1}$, and the first inequality must be an equality because the
      difference between $κ_n$ and $κ_{n+1}$ is just a single frame.
  \end{itemize}
  <=: TODO
\end{proof}

In other words, a trace is maximally-balanced if it follows the transition
semantics, never leaves the initial evaluation context and is either infinite,
stuck, or successfully returns a value to its initial evaluation context.
The latter case intuitively corresponds to the existence of derivation in a
suitable big-step semantics.

For the initial state with an empty stack, the maximally-balanced trace is
exactly the result of running the transition semantics to completion.

Unsurprisingly, infinite traces are never stuck or balanced.
We could also show that no balanced trace is ever stuck, thus proving the three
categories disjoint. Unfortunately, the introduction of algebraic data types
gives rise to balanced but stuck traces, so we won't make use of that fact in
the theory that follows.

\Cref{ex:stuck} gives an example program that is stuck because of an
out-of-scope reference. This is in fact the only way in which our simple lambda
calculus without algebraic data types can get stuck; it is useful to limit such
out-of-scope errors to the lookup of program variables in the environment $ρ$
and require that lookups in the heap $μ$ are always well-defined, captured in
the following predicate:

\begin{definition}[Well-addressed]
  We say that
  \begin{itemize}
    \item An environment $ρ$ is \emph{well-addressed} \wrt
          a heap $μ$ if $\rng(ρ) ⊆ \dom(μ)$.
    \item A continuation $κ$ is \emph{well-addressed} \wrt
          a heap $μ$ if $\fa(κ) ⊆ \dom(μ)$, where
          \[\begin{array}{rcl}
            \fa(\ApplyF(\pa) \pushF κ) & = & \{ \pa \} ∪ \fa(κ) \\
            \fa(\UpdateF(\pa) \pushF κ) & = & \{ \pa \} ∪ \fa(κ) \\
            \fa(\StopF) & = & \{ \} \\
          \end{array}\]
    \item A heap $μ$ is \emph{well-addressed} if, for every entry $(\wild,ρ,\wild) ∈ μ$,
          $ρ$ is well-addressed \wrt $μ$.
    \item A state $(\wild, ρ, μ, κ)$ is \emph{well-addressed} if $ρ$
          and $κ$ are well-addressed with respect to $μ$.
  \end{itemize}
\end{definition}

\begin{lemma}[Transitions preserve well-addressedness]
  \label{lemma:preserve-well-addressed}
  Let $σ$ be a well-addressed state. If there exists $σ'$ such that $σ
  \smallstep σ'$, then $σ'$ is well-addressed.
\end{lemma}
\begin{proof}
  By cases over the transition relation.
\end{proof}

\begin{corollary}
  If $\validtrace{π}$ and $src_\States(π)$ is well-addressed, then every state
  in $π$ is well-addressed.
\end{corollary}

For $\semst{\wild}$ to continue a well-addressed state sensibly, we need to
relate the occurring denotations to their respective syntactic counterparts:

\begin{definition}[Well-elaborated]
  We say that a well-addressed state $σ$ is \emph{well-elaborated}, if
  \begin{itemize}
    \item For every heap entry $(\pe, ρ, d) ∈ \rng(μ)$, where $μ$ is the heap of
          $σ$, we have $d=\semst{\pe}$.
    \item If $σ$ is a return state with control $(\Lam{\px}{\pe}, \FunV(f))$,
          then for any state $σ'$ of the form $((\Lam{\px}{\pe}, \FunV(f)), ρ, μ, \ApplyF(\pa) \pushF κ)$,
          we have $f(\pa)(σ') = σ'; \semst{\pe}(\pe, ρ[\px ↦ \pa], μ, κ)$.
  \end{itemize}
\end{definition}
The initial state of $\smallstep$, $(\pe,[],[],\StopF)$, is well-elaborated,
because it is never a return state and its heap is empty.

Finally, we can give the specification for $\semst{\wild}$:

\begin{definition}[Specification of $\semst{\wild}$]
\label{defn:semst-spec}
Let $σ$ be a well-elaborated state and $\pe$ an arbitrary expression. Then
\begin{itemize}
  \item[(S1)] If the control of $σ$ is not $\pe$, then $\semst{\pe}(σ) = σ \straceend$.
  \item[(S2)] $σ$ is the source state of the trace $\semst{\pe}(σ)$.
  \item[(S3)] If the control of $σ$ is $\pe$, then
              $\maxbaltrace{\semst{\pe}(σ)}$ and all states in the trace
              $\semst{\pe}(σ)$ are well-elaborated.
\end{itemize}
\end{definition}
% Urgh, flesh it out when we know better what to do with S1-S3
%The purpose of $(S1)$ is to guarantee that $\semst{\pe}$ does not continue:
%to make the mapping $\pe \mapsto \semst{\pe}$ injective
%and thus invertible.
%\begin{lemma}
%  Let $E$ denote the set of the expression $\pe$ and its (labelled)
%  sub-expressions. Then the mapping $\fn{\pe}{\semst{\pe}}$ is injective.
%\end{lemma}
%\begin{proof}
%  It is simple to see that for every $\pe$ there exists $σ, σ'$ such that $\pe$
%  is the control of $σ$ and $σ \smallstep σ'$.
%  \sg{Do we need to prove this? I think not.}
%  Let $s(\pe)$ denote this state.
%  Then $\semst{\pe}(s(\pe)) \not= \semst{\pe'}(s(\pe))$ unless $\pe = \pe'$:
%
%\end{proof}
%Clearly, $(S3)$ is the key property for adequacy, but we can't prove it without
%the other 2 properties.

\subsection{Definition}

\Cref{fig:cesk-semantics} defines $\semst{\wild}$. Before we prove that
$\semst{\wild}$ satisfies the specification in \Cref{defn:semst-spec},
let us understand the function by way of evaluating the example program
$\pe \triangleq \Let{i}{\Lam{x}{x}}{i~i}$:
\[\begin{array}{l}
  \newcommand{\myleftbrace}[4]{\draw[mymatrixbrace] (m-#2-#1.west) -- node[right=2pt] {#4} (m-#3-#1.west);}
  \begin{tikzpicture}[baseline={-0.5ex},mymatrixenv]
      \matrix [mymatrix] (m)
      {
        1  & (\pe, [], [], \StopF); & \hspace{3.5em} & \hspace{3.5em} & \hspace{3.5em} & \hspace{4.5em} & \hspace{7.5em} \\
        2  & (i~i, ρ_1, μ, \StopF); & & & & & \\
        3  & (i, ρ_1, μ, κ_1); & & & & & \\
        4  & (\Lam{x}{x}, ρ_1, μ, κ_2); & & & & & \\
        5  & ((\Lam{x}{x}, \FunV(f)), ρ_1, μ, κ_2); & & & & & \\
        6  & ((\Lam{x}{x}, \FunV(f)), ρ_1, μ, κ_1); & & & & & \\
        7  & (x, ρ_2, μ, \StopF); & & & & & \\
        8  & (\Lam{x}{x}, ρ_1, μ, κ_3); & & & & & \\
        9  & ((\Lam{x}{x}, \FunV(f)), ρ_1, μ, κ_3); & & & & & \\
        10 & ((\Lam{x}{x}, \FunV(f)), ρ_1, μ, \StopF) \straceend & & & & & \\
      };
      % Braces, using the node name prev as the state for the previous east
      % anchor. Only the east anchor is relevant
      \foreach \i in {1,...,\the\pgfmatrixcurrentrow}
        \draw[dotted] (m.east||-m-\i-\the\pgfmatrixcurrentcolumn.east) -- (m-\i-2);
      \myleftbrace{3}{1}{10}{$\semst{\pe}$}
      \myleftbrace{4}{1}{2}{$let(\semst{\Lam{x}{x}})$}
      \myleftbrace{4}{2}{10}{$\semst{i~i}$}
      \myleftbrace{5}{2}{3}{$app_1(i~i)$}
      \myleftbrace{5}{3}{6}{$\semst{i}$}
      \myleftbrace{5}{6}{7}{$app_2(\Lam{x}{x},\pa_1)$}
      \myleftbrace{5}{7}{10}{$\semst{x}$}
      \myleftbrace{6}{3}{4}{$look(i)$}
      \myleftbrace{6}{4}{5}{$\semst{\Lam{x}{x}}$}
      \myleftbrace{6}{5}{6}{$upd$}
      \myleftbrace{6}{7}{8}{$look(x)$}
      \myleftbrace{6}{8}{9}{$\semst{\Lam{x}{x}}$}
      \myleftbrace{6}{9}{10}{$upd$}
      \myleftbrace{7}{4}{5}{$ret(\Lam{x}{x},\FunV(f))$}
      \myleftbrace{7}{8}{9}{$ret(\Lam{x}{x},\FunV(f))$}
  \end{tikzpicture} \\
  \quad \text{where} \quad \begin{array}{ll}
  ρ_1 = [i ↦ \pa_1] & κ_1 = \ApplyF(\pa_1) \pushF \StopF \\
  ρ_2 = [i ↦ \pa_1, x ↦ \pa_1] & κ_2 = \UpdateF(\pa_1) \pushF κ_1 \\
  μ = [\pa_1 ↦ (\Lam{x}{x},ρ_1,\semst{\Lam{x}{x}})] & κ_3 = \UpdateF(\pa_1) \pushF \StopF \\
  f = \pa \mapsto step(app_2(\Lam{\px}{\px},\pa)) \sfcomp \semst{\px} \\
  \end{array} \\
\end{array}\]
The annotations to the right of the trace can be understood as denoting the
``call graph'' of the $\semst{\pe}$, with the primitive transition $step$s such
as $let_1$, $app_1$, $look$ \etc as leaves, each \emph{elaborating} the
application of the corresponding transition rule $\LetT$, $\AppIT$, $\LookupT$,
and so on, in the transition semantics with a matching denotation where
necessary.

Evaluation begins by decomposing the let binding and continuing the let body in
the extended environment and heap, transitioning from state 1 to state 2.
Beyond recognising the expected application of the $\LetT$ transition rule,
it is interesting to see that indeed the $d$ in the heap is elaborated to
$\semst{\Lam{x}{x}}$, which ends up in $ρ_1$.

The auxiliary $step$ function and the forward composition operator $\sfcomp$
have been inlined everywhere, as all steps and compositions are well-defined.
One can find that $\sfcomp$ is quite well-behaved: It forms a monoid with
$\bot_\StateD$ (which is just $step$ applied to the function that is undefined
everywhere) as its neutral element.

Evaluation of the let binding recurses into $\semst{i~i}$ on state 2,
where an $\AppIT$ transition to state 3, on which $\semst{i}$ is run.
Note that the final state 6 of the call to $\semst{i}$ will later be fed
(via $\sfcomp$) into the auxiliary function $apply$.

$\semst{i}$ guides the trace from state 3 to state 6, during which we
observe a heap update for the first time: Not only does $look$ look up
the binding $\Lam{x}{x}$ of $i$ in the heap and push and update frame,
it also hands over control to the $d = \semst{\Lam{x}{x}}$ stored alongside it.
(And we make a mental note to pick up with $step(upd)$ when $d$ has finished.)
Crucially, that happens without $\semst{\Lam{x}{x}}$ occurring in the definition
of $\semst{i}$, thus the definition remains structural.

By comparison, the value transition governed by $\semst{\Lam{x}{x}}$ from state
4 to 5 is rather familiar from our earlier example, where we specified more or
less the same $\FunV(f)$.

$\semst{\Lam{x}{x}}$ finishes in state 5, where $upd$ picks up to guide the
$\UpdateT$ transition. Crucially, it also updates the $d$ stored in the heap
so that its semantics matches that of the updated value; take note of the
similarity to the lambda clause in the definition of $\semst{\wild}$. Since
$\Lam{x}{x}$ was a value to begin with, there is no observable change to the
heap.

After $\semst{i}$ concludes in state 6, the $apply$ function from $\semst{i~i}$
picks up. Since $apply$ is defined on state 6, it reduces to $f(\pa_1)$%
\footnote{We omitted $apply$ and $f(\pa_1)$ from the call graph for space reasons, but
their activation spans from state 7 to the final state 10.}.
$f(\pa_1)$ will perform an $\AppET$ transition to state 7, binding $x$ to $i$'s
address $\pa_1$ and finally entering the lambda body $\semst{x}$. Since $x$ is
an alias for $i$, steps 7 to 10 just repeat the same same heap update sequence
we observed in steps 3 to 6.

It is useful to review another example involving an observable heap update.
The following trace begins right before the heap update occurs in
$\Let{i}{(\Lam{y}{\Lam{x}{x}})~i}{i~i}$, that is, after reaching the value
in $\semst{(\Lam{y}{\Lam{x}{x}})~i}$:
\[\begin{array}{l}
  \newcommand{\myleftbrace}[4]{\draw[mymatrixbrace] (m-#2-#1.west) -- node[right=2pt] {#4} (m-#3-#1.west);}
  \begin{tikzpicture}[baseline={-0.5ex},mymatrixenv]
      \matrix [mymatrix] (m)
      {
        1  & ((\Lam{x}{x},\FunV(f)), ρ_2, μ_1, κ_2); & \hspace{3.5em} & \hspace{3.5em} & \hspace{4.5em} & \hspace{7.5em} \\
        2  & ((\Lam{x}{x},\FunV(f)), ρ_2, μ_2, κ_1); & & & & \\
        3  & (x, ρ_3, μ, \StopF); & & & & \\
        4  & (\Lam{x}{x}, ρ_2, μ, κ_3); & & & & \\
        5  & ((\Lam{x}{x}, \FunV(f)), ρ_2, μ, κ_3); & & & & \\
        6  & ((\Lam{x}{x}, \FunV(f)), ρ_1, μ, \StopF); & & & & \\
      };
      % Braces, using the node name prev as the state for the previous east
      % anchor. Only the east anchor is relevant
      \foreach \i in {1,...,\the\pgfmatrixcurrentrow}
        \draw[dotted] (m.east||-m-\i-\the\pgfmatrixcurrentcolumn.east) -- (m-\i-2);
      \myleftbrace{3}{1}{6}{$\semst{i~i}$}
      \myleftbrace{4}{1}{2}{$\semst{i}$}
      \myleftbrace{4}{2}{3}{$app_2(\Lam{x}{x},\pa_1)$}
      \myleftbrace{4}{3}{6}{$\semst{x}$}
      \myleftbrace{5}{1}{2}{$upd$}
      \myleftbrace{5}{3}{4}{$look(x)$}
      \myleftbrace{5}{4}{5}{$\semst{\Lam{x}{x}}$}
      \myleftbrace{5}{5}{6}{$upd$}
      \myleftbrace{6}{4}{5}{$ret(\Lam{x}{x},\FunV(f))$}
  \end{tikzpicture} \\
  \quad \text{where} \quad \begin{array}{ll}
  ρ_1 = [i ↦ \pa_1] & κ_1 = \ApplyF(\pa_1) \pushF \StopF \\
  ρ_2 = [i ↦ \pa_1, y ↦ \pa_1] & κ_2 = \UpdateF(\pa_1) \pushF κ_1 \\
  μ_1 = [\pa_1 ↦ ((\Lam{y}{\Lam{x}{x}})~i,ρ_1,\semst{(\Lam{y}{\Lam{x}{x}})~i})] & κ_3 = \UpdateF(\pa_1) \pushF \StopF \\
  μ_2 = [\pa_1 ↦ (\Lam{x}{x},ρ_2,\semst{\Lam{x}{x}})] & f = \pa \mapsto step(app_2(\Lam{\px}{\px},\pa)) \sfcomp \semst{\px} \\
  \end{array} \\
\end{array}\]
Note that both the environment \emph{and} the denotation in the heap is updated
in state 2, and that the new denotation is immediately visible on the next heap
lookup in state 3, so that $\semst{\Lam{x}{x}}$ takes control rather than
$\semst{(\Lam{y}{\Lam{x}{x}})~i}$, just as the transition system requires.

\subsection{Conformance}

Having a good grasp on the workings of $\semst{\wild}$ now, let us show that
$\semst{\wild}$ conforms to its specification in \Cref{defn:semst-spec}.

For the following three lemmas, let $σ$ denote a well-addressed state and $\pe$
an expression.

\begin{lemma}[(S1)]
  If the control of $σ$ is not $\pe$, then $\semst{\pe}(σ) = σ\straceend$.
\end{lemma}
\begin{proof}
  By the first clause of $\semst{\wild}$.
\end{proof}

\begin{lemma}[(S2)]
  $σ$ is the source state of $\semst{\pe}(σ)$.
\end{lemma}
\begin{proof}
  Trivial for the first clause of $\semst{\wild}$.
  Now, realising that $src_\States((l \sfcomp r)(σ)) = src_\States(l(σ))$
  and that $src_\States(step(f)(σ)) = σ$ for any $f$, we can see that the
  proposition follows for other clauses by applying these two rewrites to
  completion.
\end{proof}

\begin{lemma}[(S3)]
  If the control of $σ$ is $\pe$, then $\maxbaltrace{\semst{\pe}(σ)}$ and all
  states in the trace $\semst{\pe}(σ)$ are well-elaborated.
\end{lemma}
\begin{proof}
  Let us abbreviate the property of interest to
  \[
    OK(d) = ∀σ. σ\text{ well-addressed} \Longrightarrow \validtrace{d(σ)}
  \]
  Let $σ$ be a well-addressed state.
  For the first clause of $\semst{\wild}$, the proposition follows by
  $\validtraceTriv$.

  Every other clause of $\semst{\wild}$ is built from applications of
  $\sfcomp$, $step$ or $apply$ and it suffices to show that these combinators
  yield valid CESK traces when applied to $σ$.

  We can see that $OK(d_1 \sfcomp d_2)$ whenever $OK(d_1)$ and $OK(d_2)$ holds,
  because the destination state of $d_1(σ)$, if it exists, is well-addressed by
  \Cref{lemma:preserve-well-addressed} and $OK(d_2)$ can be usefully applied.
  An interesting case is when $d_1(σ)$ is infinite; then
  $(d_1 \sfcomp d_2)(σ) = d_1(σ)$ and $\validtrace{(d_1 \sfcomp d_2)(σ)}$ follows
  from $\validtrace{d_1(σ)}$.

  We can see that $\validtrace{step(f)(σ)}$ whenever $f(σ)$ is undefined
  (by $\validtraceTriv$) or $\validtrace{σ;f(σ)}$ (by $\validtraceTrans$).
  Enumerating the arguments to $step$, we can see that $val, upd, app_1, app_2$
  and $let$ follow $\ValueT, \UpdateT, \AppIT, \AppET$ and $\LetT$ closely by
  making exactly one transition. That leaves $loop$, which corresponds to doing
  one step with $\LookupT$ and then evaluating the heap-bound expression $\pe$
  as expressed by $d$.

  By (bi-)induction that is always the case.
\end{proof}

Let us begin by defining that a denotation $d$ is \emph{valid everywhere} when
for every initial $σ$, we have $\validtrace{σ}$. This definition lets us express
an important observation:

We can now formulate our correctness theorem as follows:

\begin{theorem}[Adequacy of the stateful trace semantics]
Let $d = \semst{\pe}$. Then for all $ρ,μ$ with $\vdash_\Heaps μ$, we have $μ
\vdash_\StateD \pe \sim_ρ d$.
\end{theorem}

\begin{corollary} Let $d = \semst{\pe}$. Then $π=d(\pe,[],[],\StopF)$ is a
maximally-balanced trace for the transition semantics starting at $(\pe,[],[],\StopF)$.
\end{corollary}

\begin{figure}
\[\begin{array}{c}
 \begin{array}{rcl}
  \multicolumn{3}{c}{ \ruleform{ \semst{\wild} \colon \Exp → \StateD } } \\
  \\[-0.5em]
  \bot_\StateD(σ) & = & \fn{σ}{σ\straceend} \\
  \\[-0.5em]
  (d_1 \sfcomp d_2)(σ) & = & d_1(σ) \sconcat d_2(dst_\States(d_1(σ))) \\
  \\[-0.5em]
  step(f)(σ) & = & \begin{cases}
    σ; f(σ)     & \text{if $f(σ)$ is defined} \\
    σ\straceend & \text{otherwise} \\
  \end{cases} \\
  \\[-0.5em]
  val(\pv,v)(\pv,ρ,μ,κ) & = & ((\pv,v),ρ,μ,κ) \straceend \\
  \\[-0.5em]
  look(\px)(\px,ρ,μ,κ) & = &
    \begin{letarray}
      \text{let} & \pa = ρ(\px) \\
                 & (\pe,ρ',d) = μ(\pa) \\
      \text{in}  & d(\pe,ρ',μ,\UpdateF(\pa) \pushF κ) \\
    \end{letarray} \\
  \\[-0.5em]
  upd((\pv,v),ρ,μ,\UpdateF(\pa) \pushF κ) & = & ((\pv,v),ρ,μ[\pa ↦ (\pv,ρ,step(val(v)))], κ)\straceend \\
  \\[-0.5em]
  app_1(\pe~\px)(\pe~\px,ρ,μ,κ) & = & (\pe,ρ,μ,\ApplyF(ρ(\px)) \pushF κ)\straceend \\
  \\[-0.5em]
  app_2(\Lam{\px}{\pe},\pa)((\Lam{\px}{\pe},\FunV(\wild)),ρ,μ, \ApplyF(\pa) \pushF κ) & = & (\pe,ρ[\px ↦ \pa],μ,κ) \straceend \\
  \\[-0.5em]
  let(d_1)(\Let{\px}{\pe_1}{\pe_2},ρ,μ,κ) & = &
    \begin{letarray}
      \text{let} & ρ' = ρ[\px ↦ \pa] \quad \text{where $\fresh{\pa}{μ}$} \\
      \text{in}  & (\pe_2,ρ',μ[\pa ↦ (\pe_1, ρ', d_1)],κ)\straceend \\
    \end{letarray} \\
  \\[-0.5em]
  apply(σ) & = & \begin{cases}
    f(\pa)(σ) & \text{if $σ=((\wild,\FunV(f)),\wild,\ApplyF(\pa) \pushF \wild)$} \\
    σ \straceend & \text{otherwise} \\
  \end{cases} \\
  \\[-0.5em]
  % We need this case, otherwise we'd continue e.g.
  %   S[x]((sv,v),ρ,μ,upd(a).κ) = ((sv,v),ρ,μ,upd(a).κ); ((sv,v),ρ,μ[a...],κ)
  % Because of how the composition operator works.
  \semst{\pe}(σ) & = & σ\straceend\ \text{if the control of $σ$ is not $\pe$} \\
  \\[-0.5em]
  \semst{\px} & = & step(look(\px)) \sfcomp step(upd) \\
  \\[-0.5em]
  \semst{\Lam{\px}{\pe}} & = & \begin{letarray}
    \text{let} & f = \pa \mapsto step(app_2(\Lam{\px}{\pe},\pa)) \sfcomp \semst{\pe} \\
    \text{in}  & step(val(\Lam{\px}{\pe},\FunV(f))) \\
  \end{letarray} \\
  \\[-0.5em]
  \semst{\pe~\px} & = & step(app_1(\pe~\px)) \sfcomp \semst{\pe} \sfcomp apply \\
  \\[-0.5em]
  \semst{\Let{\px}{\pe_1}{\pe_2}} & = & step(let(\semst{\pe_1})) \sfcomp \semst{\pe_2} \\
  \\
 \end{array} \\
\end{array}\]
\caption{Structural call-by-need stateful trace semantics $\semst{-}$}
  \label{fig:cesk-semantics}
\end{figure}
