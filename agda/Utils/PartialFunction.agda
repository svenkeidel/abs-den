{-# OPTIONS --cubical #-}
module Utils.PartialFunction where

open import Cubical.Relation.Nullary.Base
open import Cubical.Foundations.Prelude hiding (_[_↦_])
open import Data.Maybe
open import Data.List 
open import Data.Product
open import Function.Base

_⇀_ : ∀ {ℓ} → Set ℓ → Set ℓ → Set ℓ
A ⇀ B = A → Maybe B
infix 1 _⇀_

empty-pfun : ∀{A B : Set} → A ⇀ B
empty-pfun _ = nothing

_[_↦_] : ∀{A B : Set} {{dec : {x y : A} → Dec (x ≡ y)}} → (A ⇀ B) → A → B → (A ⇀ B)
_[_↦_] {{dec}} ρ x b y with dec {x} {y}
... | yes _ = just b
... | no  _ = ρ y

idem-↦ : ∀{A B : Set} {f : A ⇀ B} {a : A} {b : B} {{dec : {x y : A} → Dec (x ≡ y)}} → f a ≡ just b → f [ a ↦ b ] ≡ f
idem-↦ {A} {_} {f} {a} {b} {{dec}} fa≡justb = funExt aux
  where
    aux : (x : A) → (f [ a ↦ b ]) x ≡ f x
    aux x with dec {a} {x}
    ... | no  np  = refl
    ... | yes a≡x = just b ≡⟨ sym fa≡justb ⟩ f a ≡⟨ cong f a≡x ⟩ f x ∎

-- idem-↦ : ∀{A B : Set} {f : A ⇀ B} {a : A} {b : B} {{dec : {x y : A} → Dec (x ≡ y)}} → f a ≡ just b → f [ a ↦ b ] ≡ f
-- idem-↦ {_} {_} {f} {a} {b} {{dec}} fa≡justb i x with dec {a} {x}
-- ... | yes a≡x  = (just b ≡⟨ sym fa≡justb ⟩ f a ≡⟨ cong f a≡x ⟩ f x ∎) i
-- ... | no  np = f x

_[_↦*_] : ∀{A B : Set} {{dec : {x y : A} → Dec (x ≡ y)}} → (A ⇀ B) → List A → List B → (A ⇀ B)
_[_↦*_] {A} {B} {{dec}} ρ xs as = aux (Data.List.zip xs as)
  where
    aux : List (A × B) → (A ⇀ B)
    aux []             y = ρ y
    aux ((x , b) ∷ xs) y with dec {x} {y}
    ... | yes _ = just b
    ... | no  _ = aux xs y

pmap : ∀ {A B : Set} → (A ⇀ B) → List A ⇀ List B
pmap f [] = just []
pmap {_} {B} f (a ∷ as) with f a 
... | nothing = nothing
... | just b  = aux b (pmap f as)
  where
    aux : B → Maybe (List B) → Maybe (List B)
    aux b nothing = nothing
    aux b (just bs) = just (b ∷ bs)

 