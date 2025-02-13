{-# LANGUAGE DerivingVia #-}
module Sergey14 where

import Prelude hiding ((+))
import qualified Prelude
import Exp
import Order
import Interpreter
import Abstractions
import Data.Functor.Identity
import Control.Monad.Trans.Writer
import Control.Monad.Trans.Reader
import qualified Data.Map as Map
import Data.Set (Set)
import qualified Data.Set as Set
-- import Debug.Trace


-- data U = U0 | U1 | Uω -- defined in Abstractions, including ⊔ and +
type UNonAbs  = U -- Not U0
type UNonOnce = U -- Not U1

data Demand = Abs | UNonAbs :* SubDemand deriving Eq
data SubDemand
  = Seq
  | Top
  | Call UNonAbs SubDemand
  | Prod [Demand]

mkCall :: U -> SubDemand -> SubDemand
mkCall U0 _   = Seq
mkCall Uω Top = Top
mkCall n  sd  = Call n sd

mkProd :: [Demand] -> SubDemand
mkProd ds | all (== absDmd) ds = Seq
          | all (== topDmd) ds = Top
          | otherwise          = Prod ds

absDmd = Abs
topDmd = Uω :* Top

instance Lat Demand where
  bottom = Abs
  Abs ⊔ d = d
  d ⊔ Abs = d
  (u1:*sd1) ⊔ (u2:*sd2) = (u1⊔u2) :* (sd1⊔sd2)
instance Eq SubDemand where
  Seq == Seq = True
  Top == Top = True
  Call n1 sd1 == Call n2 sd2 = n1 == n2 && sd1 == sd2
  Prod dmds1 == Prod dmds2 = dmds1 == dmds2
  Top == Call n sd = n == Uω && sd == Top
  Top == Prod dmds = all (== topDmd) dmds
  Seq == Prod dmds = all (== absDmd) dmds
  _   == _         = False
instance Lat SubDemand where
  bottom = Seq
  Top ⊔ _ = Top
  _ ⊔ Top = Top
  Seq ⊔ sd = sd
  sd ⊔ Seq = sd
  Call n1 sd1 ⊔ Call n2 sd2 = mkCall (n1⊔n2) (sd1⊔sd2)
  Prod dmds1 ⊔ Prod dmds2 = mkProd (dmds1⊔dmds2)
  _ ⊔ _ = Top

instance Plussable Demand where
  Abs + d = d
  d + Abs = d
  (_u1:*sd1) + (_u2:*sd2) = Uω :* (sd1+sd2)

instance Plussable SubDemand where
  Top + _ = Top
  _ + Top = Top
  Seq + sd = sd
  sd + Seq = sd
  Call _n1 sd1 + Call _n2 sd2 = mkCall Uω (sd1 ⊔ sd2)
  Prod dmds1 + Prod dmds2 | length dmds1 == length dmds2 = mkProd (zipWith (+) dmds1 dmds2)
  _ + _ = Top

instance Show SubDemand where
  show Seq = "HU"
  show Top = "U"
  show (Call n sd) = "C^"++show n ++ "(" ++ show sd ++ ")"
  show (Prod ds) = "U(" ++ showSep (showString ",") (map shows ds) ")"

instance Show Demand where
  show Abs = "A"
  show (n :* sd) = show n ++ "*" ++ show sd

type DmdEnv = Name :-> Demand
instance Semigroup Demand where
  d1 <> d2 = d1 + d2
instance Monoid Demand where
  mempty = absDmd

newtype DmdT a = DT { unDT :: Set Name -> SubDemand -> (a, DmdEnv) }
  deriving (Functor,Applicative,Monad) via ReaderT (Set Name) (ReaderT SubDemand (Writer DmdEnv))

type DmdD = DmdT DmdVal
data DmdVal = DmdFun Demand DmdVal | DmdNop | DmdBot

mkDmdFun :: Demand -> DmdVal -> DmdVal
mkDmdFun d v | d == topDmd, DmdNop <- v = DmdNop
             | d == absDmd, DmdBot <- v = DmdBot
             | otherwise                = DmdFun d v

instance Show DmdVal where
  show DmdBot = "\\bottom"
  show DmdNop = "\\bullet"
  show (DmdFun d v) = show d ++ "\\rightarrow" ++ show v

instance Eq DmdVal where
  DmdFun d1 v1 == DmdFun d2 v2 = d1 == d2 && v1 == v2
  DmdNop == DmdNop = True
  DmdNop == DmdFun d2 v2 = topDmd == d2 && DmdNop == v2
  DmdNop == DmdBot = False
  DmdBot == DmdBot = True
  DmdBot == DmdFun d2 v2 = absDmd == d2 && DmdBot == v2
  l      == r      = r == l

instance Lat DmdVal where
  bottom = DmdBot
  DmdNop ⊔ _ = DmdNop
  _ ⊔ DmdNop = DmdNop
  DmdBot ⊔ v = v
  v ⊔ DmdBot = v
  DmdFun d1 v1 ⊔ DmdFun d2 v2 = mkDmdFun (d1 ⊔ d2) (v1 ⊔ v2)

mapDmdEnv :: (DmdEnv -> DmdEnv) -> DmdT v -> DmdT v
mapDmdEnv f (DT m) = DT $ \ns sd -> case m ns sd of (v,φ) -> (v, f φ)

instance Trace (DmdT v) where
  step (Lookup x) (DT m) = DT $ \ns sd ->
    let (a, φ) = m ns sd in (a, φ + ext emp x (U1 :* sd))
  step _ τ = τ

isProd :: Tag -> Bool
isProd Pair = True
isProd _    = False -- TT,FF,Some,None,S,Z

squeezeSubDmd :: Set Name -> DmdD -> SubDemand -> DmdEnv
squeezeSubDmd ns (DT f) sd = snd (f ns sd)

squeezeDmd :: Set Name -> DmdD -> Demand -> DmdEnv
squeezeDmd _  _ Abs = emp
squeezeDmd ns d (n :* sd)
  | U1 <- n = squeezeSubDmd ns d sd
  | Uω <- n = squeezeSubDmd ns d sd + squeezeSubDmd ns d Seq
  | otherwise = error "UNonAbs"

fresh :: Set Name -> (Name, Set Name)
fresh ns = (x, Set.insert x ns) where x = "X" ++ show (Set.size ns)

freshs :: Int -> Set Name -> ([Name], Set Name)
freshs n ns = (xs, foldr Set.insert ns xs) where xs = take n (map (("X" ++) . show) [Set.size ns ..])

instance Domain (DmdT DmdVal) where
  stuck = return DmdBot
  fun _ f = DT $ \ns sd ->
    let (x,ns') = fresh ns in
    let sentinel = step (Lookup x) (pure DmdNop) in
    let (n,sd') = case sd of
          Call n sd' -> (n, sd')
          Seq        -> (U0, Seq)
          _          -> (Uω, Top) in
    if n == U0
      then (DmdBot, emp)
      else
        let (v,φ) = unDT (f sentinel) ns' sd' in
        let (d,φ') = (Map.findWithDefault absDmd x φ,Map.delete x φ) in
        (multDmdVal n (mkDmdFun d v), multDmdEnv n φ')
  con _ k ds = DT $ \ns sd ->
    let dmds = case sd of
          Prod dmds | length dmds == length ds, isProd k -> dmds
          Seq -> replicate (length ds) absDmd
          _   -> replicate (length ds) topDmd in
    (DmdNop, foldr (+) emp (zipWith (squeezeDmd ns) ds dmds))
  apply (DT f) arg = DT $ \ns sd ->
    case f ns (Call U1 sd) of
      (DmdFun dmd v', φ) -> (v',     φ + squeezeDmd ns arg dmd)
      (DmdNop       , φ) -> (DmdNop, φ + squeezeDmd ns arg topDmd)
      (DmdBot       , φ) -> (DmdBot, φ + emp)
  select (DT scrut) fs = DT $ \ns sd -> case Map.assocs fs of
    [(k,f)] | k == Pair ->
      let (xs,ns')  = freshs (conArity k) ns in
      let sentinels = map (\x -> step (Lookup x) (pure DmdNop)) xs in
      let (v,φ)     = unDT (f sentinels) ns' sd in
      let (ds,φ')   = (map (\x -> Map.findWithDefault absDmd x φ) xs,foldr Map.delete φ xs) in
      case scrut ns (mkProd ds) of
        (_v,φ'') -> (v,φ''+φ')
    fs ->
      let (_v,φ) = scrut ns Top in
      let (v,φ') = lub (map (alt ns sd) fs) in
      (v, φ+φ')
      where
        alt ns sd (k,f) =
          let (xs,ns')  = freshs (conArity k) ns in
          let sentinels = map (\_ -> pure DmdNop) xs in
          let (v,φ)     = unDT (f sentinels) ns' sd in
          let φ'        = foldr Map.delete φ xs in
          (v,φ')

-- | Very hacky way to see the arity of a function
arity :: Set Name -> DmdD -> Int
arity ns (DT m) = go 0
  where
    go n
      | n > 100                       = n
      | φ /= emp                      = n
      | v /= DmdBot                   = n
      | otherwise                     = go (n Prelude.+ 1)
      where
        sd = iterate (Call U1) Seq !! n
        (v,φ) = m ns sd

nopD' :: DmdD
nopD' = DT $ \_ _ -> (DmdNop, emp)

peelManyCalls :: Int -> SubDemand -> (U, SubDemand)
peelManyCalls 0 sd = (U1,sd)
peelManyCalls _ Seq = (U0, Seq)
peelManyCalls _ Top = (Uω, Top)
peelManyCalls _ Prod{} = (Uω, Top)
peelManyCalls n (Call u sd) | (u',sd') <- peelManyCalls (n-1) sd = (u `mult` u', sd')
  where
    mult U0 _  = U0
    mult _  U0 = U0
    mult Uω _  = Uω
    mult _  Uω = Uω
    mult U1 U1 = U1

multDmdEnv :: U -> DmdEnv -> DmdEnv
multDmdEnv U0 _ = emp
multDmdEnv U1 φ = φ
multDmdEnv Uω φ = φ+φ

multDmdVal :: U -> DmdVal -> DmdVal
multDmdVal U0 _ = DmdNop
multDmdVal Uω (DmdFun d v) = mkDmdFun (d+d) (multDmdVal Uω v)
multDmdVal _  v = v

type DmdSummary = (DmdVal, DmdEnv)

concDmdSummary :: Int -> DmdSummary -> DmdD
concDmdSummary arty (v,φ) = DT $ \_ns sd ->
  let (u,_body_sd) = peelManyCalls arty sd in
  (multDmdVal u v, multDmdEnv u φ)


-- | A single call with n args in an otherwise unknown context
callSd :: Int -> SubDemand
callSd arity = iterate (Call U1) Top !! arity

absDmdSummary :: Int -> Set Name -> DmdD -> DmdSummary
absDmdSummary arty ns (DT d) = d ns (callSd arty)

instance HasBind DmdD where
  bind _x rhs body = DT $ \ns sd ->
    let arty = arity ns (rhs nopD') in
--    if trace (show arty) arty == 0
    if arty == 0
      then
        let (x,ns') = fresh ns in
        let sentinel = step (Lookup x) (pure DmdNop) in
        case unDT (body sentinel) ns' sd of -- LetUp
          (v,φ) ->
            case Map.findWithDefault absDmd x φ of
              Abs -> (v,Map.delete x φ)
              _n :* sd -> let (_sd2,_v2,φ2) = kleeneFix (letup x rhs ns' sd) in (v,Map.delete x (φ + φ2))
      else
        let d1 = concDmdSummary arty (kleeneFix (absDmdSummary arty ns . rhs . concDmdSummary arty)) in
        unDT (body d1) ns sd
    where
      letup x rhs ns' sd (sd',v,_φ) =
        let sd'' = sd ⊔ sd' in
        case unDT (rhs (step (Lookup x) (pure v))) ns' sd'' of
          (v',φ') ->
            case Map.findWithDefault absDmd x φ' of
              Abs -> (sd'',v',φ')
              _n :* sd''' -> (sd'' ⊔ sd''',v',φ')

runDmd :: SubDemand -> DmdD -> (DmdVal, DmdEnv)
runDmd sd (DT d) = d Set.empty sd

anyCtx :: String -> (DmdVal, DmdEnv)
anyCtx s = runDmd Top $ eval (read s) emp

call :: Int -> String -> (DmdVal, DmdEnv)
call n s = runDmd (callSd n) $ eval (read s) emp

{-
>>> call 1 "let id = λx.x in id"

-- >>> call 2 "let const = λx.λy.y in const"
-}
