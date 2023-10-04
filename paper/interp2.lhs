%include custom.fmt
\section{A Denotational Interpreter}
\label{sec:interp}

\lstset{language=Haskell,style=hsyl}

\begin{lstlisting}
type D m = m (Value m)
data Value m
  = Stuck
  | Fun (D m -> D m)
  | Con ConTag [D m]
type Env = S.Map Name

class Monad m => MonadTrace m where
  lookup :: Name -> m v -> m v
  app1,app2,bind,case1,case2,let_,update :: m v -> m v

class Monad m => IsValue m v where
  stuck :: m v
  injFun :: (m v -> m v) -> m v
  apply :: v -> m v -> m v
  injCon :: ConTag -> [m v] -> m v
  select :: v -> [(ConTag, [m v] -> m v)] -> m v

class MonadTrace m => MonadAlloc m v where
  alloc :: (m v -> m v) -> m (m v)

eval :: forall m v. (MonadTrace m, IsValue m v, MonadAlloc m v)
     => Expr -> Env (m v) -> m v
eval e env = case e of
  Var x -> S.findWithDefault stuck x env
  App e x -> case S.lookup x env of
    Nothing -> stuck
    Just d  -> app1 (eval e env) >>= \v -> apply v d
  Lam x e -> injFun (\d -> app2 (eval e (S.insert x d env)))
  Let x e1 e2 -> do
    let ext d = S.insert x (lookup x d) env
    d1 <- alloc (\d1 -> eval e1 (ext d1))
    bind (eval e2 (ext d1))
  ConApp k xs -> case traverse (env S.!?) xs of
    Just ds
      | length xs == conArity k
      -> injCon k ds
    _ -> stuck
  Case e alts -> case1 $ eval e env >>= \v ->
    select v [ (k, alt_cont xs rhs) | (k,xs,rhs) <- alts ]
    where
      alt_cont xs rhs ds
        | length xs == length ds = case2 (eval rhs (insertMany env xs ds))
        | otherwise              = stuck
      insertMany :: Env (m v) -> [Name] -> [m v] -> Env (m v)
      insertMany env xs ds = foldr (uncurry S.insert) env (zip xs ds)
\end{lstlisting}
