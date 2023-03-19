\section{Applications}
\label{sec:applications}

\begin{figure}
\[\begin{array}{c}
 \begin{array}{rrclcl}
  \text{Liveness Domain} & d^{∃l} & ∈ & \LiveD & = & \poset{\Var} \times \Values^{∃l} \\
 \end{array} \\
 \\
 \begin{array}{rcl}
  \multicolumn{3}{c}{ \ruleform{ \semlive{\wild} \colon \Exp → (\Var → \LiveD) → \LiveD } } \\
  \\[-0.5em]
  \bot_{∃l} & = & (\varnothing, \bot_{\Values^{∃l}}) \\
  \\[-0.5em]
  L_1 ∪_1 (L_2,v) & = & (L_1 ∪ L_2,v) \\
  \\[-0.5em]
  %L_1 \fcomp^l L_2 & = & α^{∃l}_φ(γ^{∃l}_φ(L_1) \fcomp γ^{∃l}_φ(L_2)) ⊑ L_1 ∪ L_2 \\
  %\\[-0.5em]
  %shortcut^l & = & α^{∃l}_φ \circ shortcut \circ γ^{∃l}_φ = id \\
  %\\[-0.5em]
  \semlive{\px}_ρ & = & ρ(\px) \\
  \\[-0.5em]
  \semlive{\Lam{\px}{\pe}}_ρ & = & (\varnothing, \FunV(\fn{d^l}{\semlive{\pe}_{ρ[\px↦d^l]}})) \\
  \\[-0.5em]
  \semlive{\pe~\px}_ρ & = &
    \begin{letarray}
      \text{let} & (L_1,v_1) = \semlive{\pe}_ρ \\
      \text{in}  & L_1 ∪_1 \begin{cases}
                     f(ρ(\px)) & \text{if $v = \FunV(f)$} \\
                     \bot_{∃l} & \text{otherwise}
                   \end{cases} \\
    \end{letarray} \\
  \\[-0.5em]
  \semlive{\Let{\px}{\pe_1}{\pe_2}}_ρ& = & \begin{letarray}
      \text{letrec}~ρ'. & ρ' = ρ ⊔ [\px ↦ \{\px\} ∪_1 \semlive{\pe_1}_{ρ'}] \\
      \text{in}         & \semlive{\pe_2}_{ρ'}
    \end{letarray} \\
 \end{array} \\
 \\
 \begin{array}{c}
  \ruleform{ v_1 ⊑ v_2 \qquad d_1 ⊑ d_2 } \\
  \\[-0.5em]
  \inferrule*
    {\quad}
    {\bot_{\Values^{∃l}} ⊑ v}
  \qquad
  \inferrule*
    {\forall d.\ f_1(d) ⊑ f_2(d)}
    {\FunV(f_1) ⊑ \FunV(f_2)} \\
  %TODO: We want the gfp, I think
  \\[-0.5em]
  \inferrule*
    {L_1 ⊆ L_2 \qquad v_1 ⊑ v_2}
    {(L_1,v_1) ⊑ (L_2,v_2)}
  \qquad
  \inferrule*
    {L_1 ⊆ L_2 \quad (\forall L,v.\ L_2 ⊆ L \Rightarrow f_1(L,v) ⊑ f_2(L,v)) }
    {(L_1,\FunV(f_1)) ⊑ (L_2,\FunV(f_2))} \\
  %TODO: We want the gfp, I think
 \end{array} \\
 \\
 \begin{array}{rcl}
  \multicolumn{3}{c}{ \ruleform{ α^{∃l}_\SSD \colon \SSD → \LiveD \qquad α^{∃l}_φ \colon (\Configurations \to \SSTraces^{+\infty}) → \poset{\Var} \qquad α^{∃l}_{\Values^\Sigma} \colon \Values^\Sigma → \Values^{∃l} } } \\
  \\[-0.5em]
  α^{∃l}(σ) & = & \{ \px \in \Var \mid ∃i.\ σ_i = (\wild, \px, \wild, \wild) \wedge σ_{i+1}\ \text{exists} \} \\
  α^{∃l}_φ(φ) & = & \bigcup_{κ∈\Configurations}\{ α^{∃l}(φ(κ)) \} \\
  α^{∃l}_{\Values^\Sigma}(\FunV(f)) & = & \FunV(α^{∃l}_\SSD \circ f \circ γ^{∃l}_\SSD) \\
  α^{∃l}_{\Values^\Sigma}(\bot_{\Values^{\Sigma}}) & = & \bot_{\Values^{∃l}} \\
  α^{∃l}_\SSD(φ,v) & = & (α^{∃l}_φ(φ), α^{∃l}_{\Values^\Sigma}(v)) \\
  \dot{α}^{∃l}(ρ) & = & λx. α^{∃l}_\SSD(ρ(x)) \\
  \ddot{α}^{∃l}(S) & = & λρ. α^{∃l}_\SSD(S_{\dot{α}^{∃l}(ρ)}) \\
  \ddot{α}^{∃l}(\semss{e}) & ⊑ & \semlive{e} \\
 \end{array} \\
 \\
 \begin{array}{rcl}
  \multicolumn{3}{c}{ \ruleform{ γ^{∃l}_\SSD \colon \LiveD → \poset{\SSD} \qquad γ^{∃l}_φ \colon \poset{\Var} → \poset{\Configurations \to \SSTraces^{+\infty}} \qquad γ^{∃l}_{\Values^\Sigma} \colon \Values^{∃l} → \poset{\Values^\Sigma} } } \\
  \\[-0.5em]
  γ^{∃l}(L) & = & \{ σ \mid ∀\px ∈ L.\ ∃i.\ σ_i = (\wild, \px, \wild, \wild) \wedge σ_{i+1}\ \text{exists}  \} \\
  γ^{∃l}_φ(L) & = & \{ (κ,σ) \mid σ ∈ γ^{∃l}(L) \} \\
  γ^{∃l}_\SSD(L,v) & = & \{ (φ,v') \mid φ ∈ γ^{∃l}_φ(L) \wedge v' ∈ γ'^{∃l}_{\Values^\Sigma}(L,v) \} \\
  γ^{∃l}_{\Values^\Sigma}(v) & = & γ'^{∃l}_{\Values^\Sigma}(\varnothing,v) \\
  γ'^{∃l}_{\Values^\Sigma}(\wild,\bot_{\Values^{\Sigma}}) & = & \{ \bot_{\Values^{∃l}} \} \\
  γ'^{∃l}_{\Values^\Sigma}(L_1,\FunV(f^\sharp)) & = & \{ \bot_{\Values^{∃l}} \} ∪ \{ \FunV(f) \mid \forall L_2,v.\ L_1 ⊆ L_2 \Rightarrow α^{∃l}_\SSD(f(γ^{∃l}_\SSD(L_2,v))) ⊑ f^\sharp(L_2,v) \} \\
  %     α(γ(L,fun(f#))) ⊑ (L,fun(f#))
  %    ⊔{ (α(φ),α(v)) | φ∈γ(L), v∈γ(L,fun(f#)) } ⊑ (L,fun(f#))
  %    forall φ v. φ∈γ(L) n v∈γ(L,fun(f#)) => (α(φ),α(v)) ⊑ (L,fun(f#))
  %    (case v=bottom => trivial)
  %    forall φ f. φ∈γ(L) n fun(f)∈γ(L,fun(f#)) => (α(φ),α(fun(f))) ⊑ (L,fun(f#))
  %    forall φ f. φ∈γ(L) n (forall L' v. L ⊆ L' => f(γ(L',v)) ⊆ γ(f#(L',v))) => (α(φ),α(fun(f))) ⊑ (L,fun(f#))
  %    forall φ f. φ∈γ(L) n (forall L' v. L ⊆ L' => f(γ(L',v)) ⊆ γ(f#(L',v))) => (α(φ),fun(α.f.γ)) ⊑ (L,fun(f#))
  %    (special rule)
  %    forall φ f. φ∈γ(L) n (forall L' v. L ⊆ L' => f(γ(L',v)) ⊆ γ(f#(L',v))) => α(φ) ⊑ L n (forall L' v. L⊆L' => (α.f.γ)(L',v) ⊑ f#(L',v))
  %    (α(γ(L)) ⊑ L)
  %    forall f. (forall L' v. L ⊆ L' => f(γ(L',v)) ⊆ γ(f#(L',v))) => (forall L' v. L⊆L' => (α.f.γ)(L',v) ⊑ f#(L',v))
  %    (rearrange)
  %    forall f L' v. L⊆L' => (forall L' v. L ⊆ L' => f(γ(L',v)) ⊆ γ(f#(L',v))) => (α.f.γ)(L',v) ⊑ f#(L',v)
  %    forall f L' v. L⊆L' => f(γ(L',v)) ⊆ γ(f#(L',v)) => (α.f.γ)(L',v) ⊑ f#(L',v)
  %    forall f L' v. L⊆L' => f(γ(L',v)) ⊆ γ(f#(L',v)) => (α.f.γ)(L',v) ⊑ f#(L',v)
  %
  %    Urgh, we need (α.f.γ)(L',v) ⊑ f#(L',v), not f(γ(L',v)) ⊆ γ(f#(L',v))!
  %
  %
  %    α(φ,v) ⊑ (L,v#) => (φ,v) ∈ γ(L,v#)
  %    α(φ,v) ⊑ (L,v#) => φ∈γ(L) n v∈γ(L,v#)
  %    (v = bot is trivial; consider v=fun(f),v#=fun(f#))
  %    α(φ,fun(f)) ⊑ (L,fun(f#)) => φ∈γ(L) n (forall L' v. L⊆L' => f(γ(L',v)) ⊆ γ(f#(L',v)))
  %    (α(φ),α(fun(f))) ⊑ (L,fun(f#)) => φ∈γ(L) n (forall L' v. L⊆L' => f(γ(L',v)) ⊆ γ(f#(L',v)))
  %    α(φ) ⊆ L n (forall L' v. L⊆L' => (γ.f.α)(L',v) ⊑ f#(L',v)) => φ∈γ(L) n (forall L' v. L⊆L' => f(γ(L',v)) ⊆ γ(f#(L',v)))
  %    (α(φ) ⊆ L <=> φ∈γ(L) Galois, eta)
  %    forall L' v. L⊆L' => (γ.f.α)(L',v) ⊑ f#(L',v) => f(γ(L',v)) ⊆ γ(f#(L',v))
  %
  %    Again, we need (α.f.γ)(L',v) ⊑ f#(L',v), not f(γ(L',v)) ⊆ γ(f#(L',v))!
 \end{array}
\end{array}\]
\caption{Potential liveness}
  \label{fig:liveness-abstraction}
\end{figure}

\begin{figure}
\[\begin{array}{c}
 \begin{array}{rrclcl}
  \text{Symbolic variables} & X & ∈ & \SVar &   & \\
  \text{Symbolic Liveness Domain} & d^{sl} & ∈ & \LiveSD & = & \poset{\Var ∪ \SVar} \times \Values^{sl} \\
  \text{Symbolic Liveness Values} & v^{sl} & ∈ & \Values^{sl} & = & \FunV_{\Values^{sl}}(X.\ d^{sl}) \mid \bot_{\Values^{sl}} \\
 \end{array} \\
 \\
 \begin{array}{rcl}
  \multicolumn{3}{c}{ \ruleform{ \semslive{\wild} \colon \Exp → (\Var → \LiveSCD) → \LiveSCD } } \\
  \\[-0.5em]
  \bot_{sl} & = & (\varnothing, \bot_{\Values^{sl}}) \\
  \\[-0.5em]
  L_1 ∪_1 \wild & = & \fn{(L_2,v)}{(L_1 ∪ L_2, v)} \\
  \\[-0.5em]
  sym(X) & = & (\{ X \}, inert_{\Values^{sl}}) \\
  \\[-0.5em]
  \semslive{\px}_ρ & = & ρ(\px) \\
  \\[-0.5em]
  \semslive{\Lam{\px}{\pe}}_ρ & = & (\varnothing, \FunV(X_\px.\ \semslive{\pe}_{ρ[\px↦sym(X_\px)]})) \\
  \\[-0.5em]
  \semslive{\pe~\px}_ρ & = &
    \begin{letarray}
      \text{let} & (L_1,v_1) = \semslive{\pe}_ρ \\
      \text{in}  & L_1 ∪_1 \begin{cases}
                     d[ρ(\px) \mapsfrom X] & \text{if $v = \FunV(X.\ d)$} \\
                     \bot_{∃l}             & \text{otherwise}
                   \end{cases} \\
    \end{letarray} \\
  \\[-0.5em]
  \semslive{\Let{\px}{\pe_1}{\pe_2}}_ρ& = & \begin{letarray}
      \text{letrec}~ρ'. & ρ' = ρ ⊔ [\px ↦ \{\px\} ∪_1 \semslive{\pe_1}_{ρ'}] \\
      \text{in}         & \semslive{\pe_2}_{ρ'}
    \end{letarray} \\
  \\
 \end{array}
 \\
 \begin{array}{rcl}
  \multicolumn{3}{c}{ \ruleform{ α^{sl}_{\Values^{∃l}} \colon \Values^{∃l} → \Values^{sl}} } \\
  \\[-0.5em]
  α^{sl}_{\Values^{∃l}}(\FunV(f)) & = & \FunV(X.\ f(X)) \\
  γ^{sl}_{\Values^{∃l}}(\FunV(X,d)) & = & \FunV(\fn{d'}{d[d' \mapsfrom X]}) \\
  \\[-0.5em]
  (L,v)[(L',v') \mapsfrom X] & = & (L \setminus \{X\} ∪ \{ deep(L',v') \mid X ∈ L \}, v[(L',v') \mapsfrom X]) \\
  \FunV(f)[d' \mapsfrom X] & = & \FunV({\fn{d^{sl}}{f(d^{sl})[d' \mapsfrom X]}}) \\
  \\[-0.5em]
  deep_{\LiveSD}(L',v') & = & L' ∪ deep_{\Values^{sl}}(v') \\
  deep_{\Values^{sl}}(\FunV(f)) & = & \bigcup_v\{deep_{\LiveSD}(f(\varnothing,v))\} \\  % TODO: Think harder. Not correct I think
  inert_{\Values^{sl}} & = & \FunV(\fn{d^{sl}}{(deep(d^{sl}),inert_{\Values^{sl}})}) \\
 \end{array} \\
\end{array}\]
\begin{theorem}
  $(L,v) ⊑ (deep(L,v),inert_{\Values^{sl}})$
\end{theorem}
\begin{theorem}
  $\semslive{e}_{ρ[x↦d]} ⊑ \semslive{e}_{ρ[x↦sym(X)]}[d \mapsfrom X]$
\end{theorem}
\caption{Potential liveness, symbolic}
  \label{fig:liveness-abstraction-symb}
\end{figure}

\begin{figure}
\[\begin{array}{c}
 \begin{array}{rrclcl}
  \text{Contextual Small-Step Domain} & d^{c\Sigma} & ∈ & \SSCD & = & \Values^{c\Sigma} \times (\Configurations \to \SSTraces^{+\infty}) \to \Values^{c\Sigma} \times (\Configurations \to \SSTraces^{+\infty}) \\
  \text{Contextual Liveness Domain} & d^{cl} & ∈ & \LiveCD & = & \Values^{cl} \times \poset{\Var} \to \Values^{cl} \times \poset{\Var} \\
 \end{array} \\
 \\
 \begin{array}{rcl}
  \multicolumn{3}{c}{ \ruleform{ α^{c}_\AbsD \colon \AbsD → \AbsCD \qquad α^{c\Sigma}_\SSD \colon \SSD → \SSCD \qquad α^{cl}_\SSD \colon \SSD → \LiveCD} } \\
  \\[-0.5em]
  α^{c}_\AbsD(d) & = & \fn{c}{c(d)} \\
  γ^{c}_\AbsD(f) & = & f(id) \\
  α^{c}_{\Values}(\FunV(f)) & = & \FunV(α^{c}_\AbsD \circ f \circ γ^{c}_\AbsD) \\
  α^{c}_{\Values}(\bot_{\Values}) & = & \bot_{\Values^{c}} \\
  \\[-0.5em]
  α^{c\Sigma}_\SSD(v,φ) & = & \fn{c}{c(α^{c\Sigma}_{\Values^\Sigma}(v),φ)} \\
  α^{cl}_\SSD(v,φ) & = & \fn{c}{c(α^{c}_{\Values^{∃l}}(v),α^{∃l}(φ))} \\
 \end{array} \\
 \\
 \begin{array}{rcl}
  \multicolumn{3}{c}{ \ruleform{ \semclive{\wild} \colon \Exp → (\Var → \LiveCD) → \LiveCD } } \\
  \\[-0.5em]
  \bot_{cl} & = & \fn{c}{c (\bot_{\Values^{cl}}, \varnothing)} \\
  \\[-0.5em]
  L_1 ∪_1 \wild & = & \fn{(L_2,v)}{(L_1 ∪ L_2, v)} \\
  \\[-0.5em]
  apply(d^{cl},c) & = & \fn{(v_1,L_1)}{\begin{cases}
      f(d^{cl})~(c \circ (L_1 ∪_1 \wild)) & \text{if $v_1 = \FunV(f)$} \\
      \bot_{cl}~(c \circ (L_1 ∪_1 \wild)) & \text{otherwise}
    \end{cases}} \\
  \\[-0.5em]
  \semclive{\px}_ρ~c & = & ρ(\px)~c \\
  \\[-0.5em]
  \semclive{\Lam{\px}{\pe}}_ρ~c & = & c(\FunV(\fn{d^{cl}}{\semclive{\pe}_{ρ[\px↦d^{cl}]}}), \varnothing) \\
  \\[-0.5em]
  \semclive{\pe~\px}_ρ~c & = & \semclive{\pe}_ρ~(apply(ρ(\px),c)) \\
  \\[-0.5em]
  \semclive{\Let{\px}{\pe_1}{\pe_2}}_ρ~c& = & \begin{letarray}
      \text{letrec}~ρ'. & ρ' = ρ ⊔ [\px ↦ \fn{c}{~\semclive{\pe_1}_{ρ'}~(c \circ (\{\px\} ∪_1 \wild))}] \\
      \text{in}         & \semclive{\pe_2}_{ρ'}~c
    \end{letarray} \\
  \\
 \end{array}
\end{array}\]
\begin{theorem} About pushing/reifying continuations
  \[
  f(α^{c}_\AbsD(d)(c')) = f(c'(d)) = α^{c}_\AbsD(d)(f \circ c')
  \]
\end{theorem}
\caption{Potential liveness, contextual}
  \label{fig:liveness-abstraction}
\end{figure}

\begin{figure}
\[\begin{array}{c}
 \begin{array}{rrclcl}
  \text{Symbolic variables} & X & ∈ & \SVar &   & \\
  \text{Symbolic call} & sc & ∈ & \SCall & = & X(c) \\
  \text{Symbolic Liveness Domain} & d^{sl} & ∈ & \LiveSD & = & \poset{\Var ∪ \SCall} \times \Values^{sl} \\
  \text{Symbolic Liveness Values} & v^{sl} & ∈ & \Values^{sl} & = & \FunV_{\Values^{sl}}(X,d^{sl}) \mid \bot_{\Values^{sl}} \\
 \end{array} \\
 \\
 \begin{array}{c}
  \ruleform{ sc_1 ⊑ sc_2 \qquad L_1 ⊑ L_2 \qquad d_1 ⊑ d_2 } \\
  \\[-0.5em]
  \inferrule*
    {L_1 ∩ \Var ⊆ L_2 ∩ \Var \qquad ∀X(c_1)∈(L_1∩\SCall).\ ∃X(c_2)∈(L_1∩\SCall).\ c_1 ⊑ c_2}
    {L_1 ⊑ L_2}
  \qquad
  \inferrule*
    {L_1 ∩ \Var ⊆ L_2 ∩ \Var \qquad ∀X(c_1)∈(L_1∩\SCall).\ ∃X(c_2)∈(L_1∩\SCall).\ c_1 ⊑ c_2}
    {L_1 ⊑ L_2}
  \\[-0.5em]
  \inferrule*
    {L_1 ⊆ L_2 \qquad v_1 ⊑ v_2}
    {(L_1,v_1) ⊑ (L_2,v_2)}
  \qquad
  \inferrule*
    {L_1 ⊆ L_2 \quad (\forall L,v.\ L_2 ⊆ L \Rightarrow f_1(L,v) ⊑ f_2(L,v)) }
    {(L_1,\FunV(f_1)) ⊑ (L_2,\FunV(f_2))} \\
  %TODO: We want the gfp, I think
 \end{array} \\
 \\
 \begin{array}{rcl}
  \multicolumn{3}{c}{ \ruleform{ α^{sl}_{\Values^{∃l}} \colon \Values^{∃l} → \Values^{sl}} } \\
  \\[-0.5em]
  α^{sl}_{\Values^{∃l}}(\FunV(f)) & = & \FunV(X,f(X)) \\
  γ^{sl}_{\Values^{∃l}}(\FunV(X,d)) & = & \FunV(\fn{d'}{d[d' \mapsfrom X]}) \\
  %α^{sl}_{\Values^{∃l}}(\bot_{\Values^{∃l}}) & = & \bot_{\Values^{c}} \\
 \end{array} \\
 \\
 \begin{array}{rcl}
  \multicolumn{3}{c}{ \ruleform{ \semsclive{\wild} \colon \Exp → (\Var → \LiveSCD) → \LiveSCD } } \\
  \\[-0.5em]
  \bot_{sl} & = & (\varnothing, \bot_{\Values^{sl}}) \\
  \\[-0.5em]
  L_1 ∪_1 \wild & = & \fn{(L_2,v)}{(L_1 ∪ L_2, v)} \\
  \\[-0.5em]
  inert_{\Values^{scl}} & = & \FunV(\fn{d^{scl}}{\fn{c}{c(inert_{\Values^{scl}}, snd(d^{scl}~\top_{c}))}}) \\
  %TODO: is inert well-defined???
  \\[-0.5em]
  sym(X) & = & \fn{c}{c (inert_{\Values^{scl}}, \{ X(c) \})} \\
  \\[-0.5em]
  apply(d^{scl},c) & = & \fn{(v_1,L_1)}{\begin{cases}
      f(d^{scl})~(c \circ (L_1 ∪_1 \wild)) & \text{if $v_1 = \FunV(f)$} \\
      \bot_{scl}~(c \circ (L_1 ∪_1 \wild)) & \text{otherwise}
    \end{cases}} \\
  \\[-0.5em]
  \semslive{\px}_ρ~c & = & ρ(\px)~c \\
  \\[-0.5em]
  \semslive{\Lam{\px}{\pe}}_ρ~c & = & c(\FunV(\fn{d^{scl}}{~(\semslive{\pe}_{ρ[\px↦sym(X_\px)]})[X_\px \mapsfrom d^{scl}]}), \varnothing) \\
  \\[-0.5em]
  \semslive{\pe~\px}_ρ~c & = & \semslive{\pe}_ρ~(apply(ρ(\px),c)) \\
  \\[-0.5em]
  \semslive{\Let{\px}{\pe_1}{\pe_2}}_ρ~c& = & \begin{letarray}
      \text{letrec}~ρ'. & ρ' = ρ ⊔ [\px ↦ \fn{c}{~\semslive{\pe_1}_{ρ'}~(c \circ look(\px))}] \\
      \text{in}         & \semslive{\pe_2}_{ρ'}~c
    \end{letarray} \\
  \\
 \end{array}
\end{array}\]
\begin{theorem}
  $(\semslive{e}_{ρ[x↦d]}~c)$ ⊑ $(\semslive{e}_{ρ[x↦sym(X)]}~c)[d \mapsfrom X]$
\end{theorem}
\caption{Potential liveness, symbolic}
  \label{fig:liveness-abstraction-symb}
\end{figure}

\begin{figure}
\[\begin{array}{c}
 \begin{array}{rrclcl}
  \text{Abstract stack} &   \lS & ∈ & \lStacks & ::= & \lSBot \mid \lSAp{\lS} \mid \lSTop \\
  \text{Liveness}       &     l & ∈ & \lLiveness & ::= & \lAbs \mid \lUsed{\lS} \\
 \end{array} \\
 \\
 \begin{array}{c}
   \\[-0.5em]
   \inferrule*
     {\quad}
     {\lSBot ⊑ \lS} \qquad
   \inferrule*
     {\lS_1 ⊑ \lS_2}
     {\lSAp{\lS_1} ⊑ \lSAp{\lS_2}} \qquad
   \inferrule*
     {\quad}
     {\lS ⊑ \lSTop} \\
   \\[-0.5em]
   \inferrule*
     {\quad}
     {\lAbs ⊑ l} \qquad
   \inferrule*
     {\lS_1 ⊑ \lS_2}
     {\lUsed{\lS_1} ⊑ \lUsed{\lS_2}} \\
   \\
 \end{array} \\
 \\
 \begin{array}{rcl}
  \multicolumn{3}{c}{ \ruleform{ α^{∃l}_\SSD \colon \SSD → \LiveD \qquad α^{∃l}_φ \colon (\Configurations \to \SSTraces^{+\infty}) → \poset{\Var} \qquad α^{∃l}_{\Values^\Sigma} \colon \Values^\Sigma → \Values^{∃l} } } \\
  \\[-0.5em]
  α^{∃l}_\Stacks(\StopF) & = & \lSBot \\
  α^{∃l}_\Stacks(\UpdateF(\pa) \pushF \lS) & = & α^{∃l}_\Stacks(\lS) \\
  α^{∃l}_\Stacks(\ApplyF(\pa) \pushF \lS) & = & \lSAp{α^{∃l}_\Stacks(\lS)} \\
 \end{array} \\
 \\
 \begin{array}{rcl}
  \multicolumn{3}{c}{ \ruleform{ \semlive{\wild} \colon \Exp → (\Var → \LiveD) → \LiveD } } \\
  \\[-0.5em]
  \bot_{∃l} & = & (\bot_{\Values}, \varnothing) \\
  \\[-0.5em]
  L_1 \fcomp^l L_2 & = & α^{∃l}_φ(γ^{∃l}_φ(L_1) \fcomp γ^{∃l}_φ(L_2)) ⊑ L_1 ∪ L_2 \\
  \\[-0.5em]
  shortcut^l & = & α^{∃l}_φ \circ shortcut \circ γ^{∃l}_φ = id \\
  \\[-0.5em]
  \semlive{\px}_ρ & = & ρ(\px) \\
  \\[-0.5em]
  \semlive{\Lam{\px}{\pe}}_ρ & = & (\FunV(\fn{d^l}{\semlive{\pe}_{ρ[\px↦d^l]}}, \varnothing) \\
  \\[-0.5em]
  \semlive{\pe~\px}_ρ & = &
    \begin{letarray}
      \text{let} & (v_1,L_1) = \semlive{\pe}_ρ \\
                 & (v_2,L_2) = \begin{cases}
                     f(ρ(\px)) & \text{if $v = \FunV(f)$} \\
                     \bot_{∃l} & \text{otherwise}
                   \end{cases} \\
      \text{in}  & (v_2, L_1 ∪ L_2) \\
    \end{letarray} \\
  \\[-0.5em]
  \semlive{\Let{\px}{\pe_1}{\pe_2}}_ρ& = & \begin{letarray}
      \text{letrec}~ρ'. & (v_1,L_1) = \semlive{\pe_1}_{ρ'} \\
                        & ρ' = ρ ⊔ [\px ↦ (v_1,\{\px\} ∪ L_1))] \\
      \text{in}         & \semlive{\pe_2}_{ρ'}
    \end{letarray} \\
  \\
 \end{array}
 \\
\end{array}\]
\caption{Potential liveness}
  \label{fig:liveness-abstraction}
\end{figure}


\begin{figure}
\[
\begin{array}{ll}
  & \text{Let } ρ_x = \lfp(λρ. [x ↦ cons(\LookupT,\semss{\slbln{2}(\Lam{y}{\slbln{3}y})\slbln{4}}_ρ]) \\
  & \text{and } ρ_{x,y} = ρ_x[y ↦ ρ_1(x)] \\
  & \text{and } f = d ↦ cons(\AppET,\semss{\slbln{3}y}_{ρ[y↦d]}) \\
  & \text{Evaluate }\Let{x}{\Lam{y}{y}}{x~x~x)} \\
  & \\
  & \semss{\slbln{1}\Let{x}{\slbln{2}(\Lam{y}{\slbln{3}y})\slbln{4}}{\slbln{5}(\slbln{6}(\slbln{7}x~x)~x)}}_\bot(\lbln{1}) \\
  & \\[-0.9em]
  ⇒ & \lbln{1} \act{\BindA} \semss{\slbln{5}(\slbln{6}(\slbln{7}x~x)~x)}_{ρ_x}(\lbln{1} \act{\BindA} \lbln{5}) \\
  & \\[-0.9em]
  ⇒ & \lbln{1} \act{\BindA} \lbln{5} \act{\AppIA} \semss{\slbln{6}(\slbln{7}x~x)}_{ρ_x}(\lbln{1} \act{\BindA} \lbln{5} \act{\AppIA} \lbln{6}) \\
  & \\[-0.9em]
  ⇒ & \lbln{1} \act{\BindA} \lbln{5} \act{\AppIA} \lbln{6} \act{\AppIA} \semss{\slbln{7}x}_{ρ_x}(\overbrace{\lbln{1} \act{\BindA} \lbln{5} \act{\AppIA} \lbln{6} \act{\AppIA} \lbln{7}}^{π_1}) \\
  & \\[-0.9em]
  ⇒ & π_1 \act{\LookupA} \semss{\slbln{2}(\Lam{y}{\slbln{3}y})\slbln{4}}_{ρ_x}(π_1 \act{\LookupA} \lbln{2}) \\
  & \\[-0.9em]
  ⇒ & π_1 \act{\LookupA} \lbln{2} \act{\ValA(\FunV(f))} f(ρ_x(x))(π_1 \act{\LookupA} \lbln{2} \act{\ValA(\FunV(f))} \lbln{4}) \\
  & \\[-0.9em]
  ⇒ & π_1 \act{\LookupA} \lbln{2} \act{\ValA(\FunV(f))} \lbln{4} \act{\AppEA} \semss{\slbln{3}y}_{ρ_{x,y}}(\overbrace{π_1 \act{\LookupA} \lbln{2} \act{\ValA(\FunV(f))} \lbln{4} \act{\AppEA} \lbln{3}}^{π_2}) \\
  & \\[-0.9em]
  ⇒ & π_2 \act{\LookupA} \semss{\slbln{2}(\Lam{y}{\slbln{3}y})\slbln{4}}_{ρ_x}(π_2 \act{\LookupA} \lbln{2}) \\
  & \\[-0.9em]
  ⇒ & π_2 \act{\LookupA} \lbln{2} \act{\ValA(\FunV(f))} f(ρ_x(x))(π_2 \act{\LookupA} \lbln{2} \act{\ValA(\FunV(f))} \lbln{4}) \\
  & \\[-0.9em]
  ⇒ & π_2 \act{\LookupA} \lbln{2} \act{\ValA(\FunV(f))} \lbln{4} \act{\AppEA} \semss{\slbln{3}y}_{ρ_{x,y}}(\overbrace{π_2 \act{\LookupA} \lbln{2} \act{\ValA(\FunV(f))} \lbln{4} \act{\AppEA} \lbln{3}}^{π_3}) \\
  & \\[-0.9em]
  ⇒ & π_3 \act{\LookupA} \semss{\slbln{2}(\Lam{y}{\slbln{3}y})\slbln{4}}_{ρ_x}(π_3 \act{\LookupA} \lbln{2}) \\
  & \\[-0.9em]
  ⇒ & π_3 \act{\LookupA} \lbln{2} \act{\ValA(\FunV(f))} \lbln{4} \\
  & \\[-0.9em]
  & \\
  = \lbln{1} & \act{\BindA} \lbln{5} \act{\AppIA} \lbln{6} \act{\AppIA} \lbln{7} \\
             & \act{\LookupA} \lbln{2} \act{\ValA(\FunV(f))} \lbln{4} \act{\AppEA} \lbln{3} \\
             & \act{\LookupA} \lbln{2} \act{\ValA(\FunV(f))} \lbln{4} \act{\AppEA} \lbln{3} \\
             & \act{\LookupA} \lbln{2} \act{\ValA(\FunV(f))} \lbln{4}
\end{array}
\]
\caption{Evalation of $\semss{\wild}$}
\end{figure}

\begin{figure}
\[\begin{array}{c}
 \begin{array}{rrclcl}
  \text{Data Type Constructors}  & T & ∈ & \TyCon & \subseteq & \Nat \\
  \text{Types}                   & τ & ∈ & \Type & ::= & τ_1 \ArrowTy τ_2 \mid T \\
  \text{Constructor families}    & φ & ∈ & \multicolumn{3}{l}{\Con \twoheadrightarrow \TyCon} \\
  \text{Constructor field types} & σ & ∈ & \multicolumn{3}{l}{\Con \to \Pi_{i=1}^{A_K} \Type_i} \\
 \end{array} \\
 \\
 \begin{array}{rcl}
  \multicolumn{3}{c}{ \ruleform{ α_τ : (\Traces^+ \to \poset{\Traces^{+\infty}}) \to \poset{\Type} \qquad γ_τ : \poset{\Type} \to (\Traces^+ \to \poset{\Traces^{+\infty}})} } \\
  \\[-0.5em]
  single(S)   & = & \begin{cases}
    S & S = \{ \pe \} \\
    \varnothing & \text{otherwise} \\
  \end{cases} \\
  \\[-0.5em]
  α_τ(S) & = & \{ α_v(v) \mid \exists π_i^+, π.\  (π \act{\ValA(v)} \wild) ∈ S(π_i^+) \wedge \balanced{π} \}  \\
  α_v(\FunV(f)) & = & single(\{ τ_1 \ArrowTy τ_2 \mid τ_2 \in α_τ(f(γ_τ(τ_1))) \})  \\
  α_v(\ConV(K,\many{d})) & = & \{ φ(K) \mid \many{σ(i) \in α_τ(d_i)}^i \}  \\
  \\[-0.5em]
  γ_τ(A)(π_i^+) & = & \{ π \act{\ValA(v)} \wild \mid \balanced{π} \wedge v ∈ γ_v(A) \}  \\
  γ_v(A) & = &   \{ \ConV(K,\many{d}) \mid φ(K) ∈ A \wedge \many{d_i = γ_τ(σ(i))}^i \} \\
         &   & ∪ \{ \FunV(f) \mid \forall (τ_1 \ArrowTy τ_2) ∈ A.\  f(γ_τ(τ_1)) \subseteq γ_τ(τ_2)  \}  \\
  \\
 \end{array} \\
 \begin{array}{rcl}
  \multicolumn{3}{c}{ \ruleform{ \seminf{\wild} \colon \Exp → (\Var → \poset{\Type}) → \poset{\Type} } } \\
  \\[-0.5em]
  cons(a,\lbl,S)(π_i^+)   & = & dst(π_i^+) \act{a} S(π_i^+ \act{a} \lbl) \\
  \\[-0.5em]
  \seminf{\slbl \pe}_ρ    (π_i^+)   & = & \varnothing \qquad \text{if $dst(π_i^+) \not= \lbl$} \\
  \\[-0.9em]
  \seminf{\slbl \px}_ρ    (π_i^+)   & = & ρ(\px)(π_i^+) \\
  \\[-0.5em]
  \seminf{\slbln{1}(\Lam{\px}{\pe})\slbln{2}}_ρ(π_i^+) & = &
    \begin{letarray}
      \text{let} & f = d ↦ cons(\AppEA,\atlbl{\pe},\seminf{\pe}_{ρ[\px↦d]}) \\
      \text{in}  & α_v(\FunV(f)) \\
    \end{letarray} \\
  \\[-0.5em]
  \seminf{\slbl(\pe~\px)}_ρ(π_i^+) & = &
    \begin{letarray}
      \text{let} & π_e = \seminf{\pe}_ρ(π_i^+ \act{\AppIA} \atlbl{\pe}) \\
      \text{in}  & \begin{cases}
                     \lbl \act{\AppIA} π_e \concat f(ρ(\px))(π_i^+ \act{\AppIA} π_e) & \text{if $π_e = \wild \act{\ValA(\FunV(f))} \wild$}  \\
                     \lbl \act{\AppIA} π_e & \text{otherwise}  \\
                   \end{cases} \\
    \end{letarray} \\
  \\[-0.5em]
  \seminf{\slbl(\Let{\px}{\pe_1}{\pe_2})}_ρ(π_i^+) & = &
    \begin{letarray}
      \text{letrec}~ρ'. & ρ' = ρ ⊔ [\px ↦ \seminf{\pe_1}_{ρ'}] \\
      \text{in}         & cons(\BindA,\atlbl{\pe_2},\seminf{\pe_2}_{ρ'})(π_i^+)
    \end{letarray} \\
  \\
  \seminf{\slbln{1}(K~\many{\px})\slbln{2}}_ρ(π_i^+) & = & \lbln{1} \act{\ValA(\ConV(K,\many{ρ(\px)}))} \lbln{2} \\
  \\[-0.5em]
  \seminf{\slbl(\Case{\pe_s}{\Sel})}_ρ(π_i^+) & = & \begin{cases}
      π_s \concat Rhs(K,\many{d})(π_i^+ \concat π_s) & \text{if $π_s = \wild \act{\ValA(\ConV(K,\many{d}))} \wild$}  \\
      π_s & \text{otherwise}  \\
    \end{cases} \\
    & & \text{where} \begin{array}{lcl}
                       π_s & = & cons( \CaseIA, \atlbl{\pe_s},\seminf{\pe_s}_ρ)(π_i^+) \\
                       Rhs(K,\many{d}) & = & cons(\CaseEA,\atlbl{\pe_K},\seminf{\pe_K}_{ρ[\many{\px↦d}]}) \\
                     \end{array} \\
  \\
 \end{array} \\
\end{array}\]
\caption{Simple type inference as abstract interpretation}
  \label{fig:semantics}
\end{figure}

