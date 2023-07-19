{-# OPTIONS --cubical --guarded #-}
module Semantics.Transition where

open import Utils.Later
open import Utils.PartialFunction
open import Syntax
open import Data.List
open import Data.List.Literals
open import Data.List.Membership.Propositional
open import Data.Maybe
open import Data.Bool
open import Cubical.Core.Everything hiding (_[_↦_])
open import Cubical.Foundations.Prelude hiding (_[_↦_]; _∎)
open import Cubical.Data.Nat
open import Cubical.Data.Prod
open import Cubical.Relation.Nullary.Base

Env = Var ⇀ Addr
Heap = Addr ⇀ Env × Exp

data Frame : Set where
  apply : Addr → Frame 
  select : Env → List Alt → Frame
  update : Addr → Frame

Cont = List Frame

State = Exp × Env × Heap × Cont

infix 4 _↪_

data _↪_ : State → State → Set where
  bind : ∀{x e₁ e₂ ρ μ κ a p} 
    → ((a , p) ≡ Addr.alloc μ)
    -------------------
    → (let' x e₁ e₂ , ρ , μ , κ) ↪ (e₂ , ρ [ x ↦ a ] , μ [ a ↦ (ρ [ x ↦ a ] , e₁) ] , κ)
  
  app1 : ∀{x e ρ μ κ a}     
    → (ρ x ≡ just a)
    → (app e x , ρ , μ , κ) ↪ (e , ρ , μ , apply a ∷ κ)
  
  case1 : ∀{e alts ρ μ κ}     
    → (case' e alts , ρ , μ , κ) ↪ (e , ρ , μ , select ρ alts ∷ κ)

  look : ∀{x a e ρ ρ' μ κ}     
    → (ρ x ≡ just a)
    → (μ a ≡ just (ρ' , e))
    → (ref x , ρ , μ , κ) ↪ (e , ρ' , μ , update a ∷ κ)
  
  app2 : ∀{x e ρ μ κ a}     
    → (lam x e , ρ , μ , apply a ∷ κ) ↪ (e , ρ [ x ↦ a ] , μ , κ)

  case2 : ∀{K xs addrs alts ys rhs ρ ρ' μ κ}     
    → (pmap ρ xs ≡ just addrs)
    → (findAlt K alts ≡ just (ys , rhs))
    → length xs ≡ length ys
    → (conapp K xs , ρ , μ , select ρ' alts ∷ κ) ↪ (rhs , ρ' [ ys ↦* addrs ] , μ , κ)
    
  upd : ∀{v ρ μ κ a}     
    → Val v
    → (v , ρ , μ , update a ∷ κ) ↪ (v , ρ , μ [ a ↦ (ρ , v) ] , κ)

infix  2 _↪*_
infix  1 begin_
infixr 2 _↪⟨_⟩_
infix  3 _∎

data _↪*_ : State → State → Set where
  _∎ : ∀ M
      ---------
    → M ↪* M

  _↪⟨_⟩_ : ∀ L {M N}
    → L ↪ M
    → M ↪* N
      ---------
    → L ↪* N
    
begin_ : ∀ {M N}
  → M ↪* N
    ------
  → M ↪* N
begin M↪*N = M↪*N


-- _↪≡⟨_⟩_ : ∀ L {M N}
    -- → L ≡ M
    -- → M ↪* N
      -- ---------
    -- → L ↪* N
-- L ↪≡⟨ p ⟩ M↪*N = cong (λ x → x ↪* N) p M↪*N    

example : (let' vi (lam vx (ref vx)) (app (ref vi) vi), empty-pfun , empty-pfun , []) 
      ↪* (lam vx (ref vx) , empty-pfun [ vi ↦ a0 ] , empty-pfun [ a0 ↦ (empty-pfun [ vi ↦ a0 ] , lam vx (ref vx)) ] , [])
example = 
  let a = fst (Addr.alloc empty-pfun) in
  let p = snd (Addr.alloc empty-pfun) in
  let ρ = empty-pfun [ vi ↦ a ] in
  let ρ₂ = ρ [ vx ↦ a ] in
  let μ = empty-pfun [ a ↦ (ρ , lam vx (ref vx)) ] in
  begin 
    (let' vi (lam vx (ref vx)) (app (ref vi) vi) , empty-pfun , empty-pfun , [])
  ↪⟨ bind refl ⟩
    (app (ref vi) vi , ρ , μ , [])
  ↪⟨ app1 refl ⟩
    (ref vi , ρ , μ , apply a ∷ [])
  ↪⟨ look refl ? ⟩
    (lam vx (ref vx) , ρ , μ , update a ∷ apply a ∷ [])
  ↪⟨ upd V-lam ⟩
    (lam vx (ref vx) , ρ , μ [ a ↦ (ρ , lam vx (ref vx)) ] , apply a ∷ [])
  ↪⟨ app2 ⟩
    (ref vx , ρ₂ , μ [ a ↦ (ρ , lam vx (ref vx)) ] , [])
  ↪⟨ look refl ? ⟩
    (lam vx (ref vx) , ρ , μ [ a ↦ (ρ , lam vx (ref vx)) ], update a ∷ [])
  ↪⟨ upd V-lam ⟩
    (lam vx (ref vx) , ρ , μ [ a ↦ (ρ , lam vx (ref vx)) ] , [])
  ∎