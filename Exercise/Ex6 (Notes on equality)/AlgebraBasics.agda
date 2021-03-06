{-# OPTIONS --universe-polymorphism #-}
module AlgebraBasics where


open import Level hiding (zero)
open import Relation.Binary.Core
open import Function
open import Data.Nat as ℕ hiding (zero ; _*_) renaming (_+_ to _ℕ+_)
open import Data.Integer as ℤ hiding (suc ; _+_; _*_)
open import Data.Product using (∃ ; _,_)
open import Relation.Binary.PropositionalEquality as PropEq
  using (_≡_; refl; sym; trans; cong; cong₂)

infixl 3 _>=<_

_>=<_ : ∀ {A : Set}{a b c : A} → a ≡ b → b ≡ c → a ≡ c
_>=<_ refl refl = refl

[_] : ∀ {A : Set}{a b : A} → a ≡ b → b ≡ a
[ refl ] = refl

-- better to define * by

infixl 7 _*_
_*_ : ℕ → ℕ → ℕ
0  * n = 0
suc m * n = ℕ._+_ (m * n) n

Op : ℕ → Set → Set
Op 0 = λ t → t
Op (suc n) = λ t → (t → Op n t)
 
record Ωnumb : Set₁ where
  field
    carrier : Set
    zero : carrier
    one : carrier
    _+_ : Op 2 carrier
    _×_ : Op 2 carrier

ΩnumbNat : Ωnumb
ΩnumbNat = record { carrier = ℕ; zero = 0; one = 1; _+_ = ℕ._+_; _×_ = _*_ }

ΩnumbInt : Ωnumb
ΩnumbInt = record { carrier = ℤ; zero = + 0 ; one = + 1; _+_ = ℤ._+_; _×_ = ℤ._*_ }


record Opt (from to : Set)  : Set where
  constructor opt
  field
    pr : from → to
    ij : to → from


bint : {from to : Set} → Opt from to → Op 2 from → Op 2 to
bint (opt pr ij) op = λ a b → pr (op (ij a) (ij b))

data Mod4 : Set where
  zero : Mod4
  one : Mod4
  two : Mod4
  three : Mod4

mod4 : ℕ → Mod4
mod4 0 = zero
mod4 1 = one
mod4 2 = two
mod4 3 = three
mod4 (suc (suc (suc (suc n)))) = mod4 n

inj : Mod4 → ℕ
inj zero = 0
inj one = 1
inj two = 2
inj three = 3

mapn4 = opt mod4 inj

ΩnumbMod4 : Ωnumb
ΩnumbMod4 = record { carrier = Mod4; zero = zero; one = one; _+_ = bint mapn4 ℕ._+_ ; _×_ = bint mapn4 ℕ._*_ }


data Mod2 : Set where
  zero : Mod2
  one : Mod2

mod2 : ℕ → Mod2
mod2 0 = zero
mod2 1 = one
mod2 (suc (suc n)) = mod2 n

inj2 : Mod2 → ℕ
inj2 zero = 0
inj2 one = 1


f42 : Mod4 → Mod2
f42 n = mod2 (inj n)

mapn2 = opt mod2 inj2

ΩnumbMod2 : Ωnumb
ΩnumbMod2 = record { carrier = Mod2; zero = zero; one = one; _+_ = bint mapn2 ℕ._+_ ; _×_ = bint mapn2 ℕ._*_ }


record HomSet (A B : Set) : Set where
  field
    f : A → B

record HomAlg (A B : Ωnumb)(f : (Ωnumb.carrier A) → (Ωnumb.carrier B)) : Set where
  field
    z : f (Ωnumb.zero A) ≡ Ωnumb.zero B
    o : f (Ωnumb.one A) ≡ Ωnumb.one B
    p : ∀ a b → f ((Ωnumb._+_ A) a b) ≡ (Ωnumb._+_ B) (f a) (f b)
    m : ∀ a b → f ((Ωnumb._×_ A) a b) ≡ (Ωnumb._×_ B) (f a) (f b)

record IsoAlg (A B : Ωnumb)(f :  (Ωnumb.carrier A) → (Ωnumb.carrier B))(g :  (Ωnumb.carrier B) → (Ωnumb.carrier A)) : Set where
  field
    ab : HomAlg A B f
    cd : HomAlg B A g

-- example

inv : ∀ b → b ≡ mod4 (inj b)
inv zero = refl
inv one = refl
inv two = refl
inv three = refl

suc' : Mod4 → Mod4
suc' zero = one
suc' one = two
suc' two = three
suc' three = zero

s : ∀ a → mod4 (suc a) ≡ suc' (mod4 a)
s 0 = refl
s 1 = refl
s 2 = refl
s 3 = refl
s (suc (suc (suc (suc n)))) = s n

s' : ∀ a → mod4 (suc (inj (mod4 a))) ≡ suc' (mod4 a)
s' a = s (inj (mod4 a)) >=< cong suc' [ inv (mod4 a) ]


pl : ∀ a b → mod4 (a ℕ+ b) ≡ (Ωnumb._+_ ΩnumbMod4) (mod4 a)  (mod4 b)
pl 0 b = inv (mod4 b)
pl 1 b = s b >=< cong suc' (pl 0 b) >=< [ s (inj (mod4 b)) ]
pl 2 b = s (suc b) >=< cong suc' (pl 1 b) >=< [ s (suc (inj (mod4 b))) ]
pl 3 b = s (suc (suc b)) >=< cong suc' (pl 2 b) >=<
                                  [ s (suc (suc (inj (mod4 b)))) ]
pl (suc (suc (suc (suc n)))) b = pl n b



ms : ∀ a {b} → (a ℕ+ (suc b)) ≡ suc (a ℕ+ b)
ms 0 = refl
ms (suc a) = cong suc (ms a)

m4-l : ∀ a b → (4 * (suc a)) ℕ+ b ≡ suc (suc (suc (suc (4 * a ℕ+ b))))
m4-l a b = cong suc {!ms a >=< ?!}

m4 : {a b : ℕ} → (∃ λ x → ℕ._+_ (4 * x) a ≡ b) → mod4 a ≡ mod4 b
m4 (0 , refl) = refl
m4 (suc n , refl) = {!n!}

ml : ∀ a b → mod4 ((_*_) a b) ≡ (Ωnumb._×_ ΩnumbMod4) (mod4 a)  (mod4 b)
ml 0 b = refl
ml (suc a) b = {!!}

ha : HomAlg ΩnumbNat ΩnumbMod4 mod4
ha = record { z = refl; o = refl; p = pl; m = ml }

inv2 : ∀ b → b ≡ mod2 (inj2 b)
inv2 zero = refl
inv2 one = refl

pl2 : (a b : Mod4) →
      mod2 (inj (mod4 (inj a ℕ+ inj b))) ≡
      mod2 (inj2 (mod2 (inj a)) ℕ+ inj2 (mod2 (inj b)))
pl2 zero b = cong (mod2 ∘ inj) [ inv b ] >=< inv2 (mod2 (inj b))
pl2 one b = {!b!}
pl2 two b = {!!}
pl2 three b = {!!}

ha2 :  HomAlg ΩnumbMod4 ΩnumbMod2 f42
ha2 = record { z = refl; o = refl; p = {!!} ; m = {!!} }