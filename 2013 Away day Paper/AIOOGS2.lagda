
\AgdaHide{
\begin{code}
module AIOOGS2 where


open import AIOOG
open import Relation.Binary.PropositionalEquality 
open import Data.Product renaming (_,_ to _,,_)

\end{code}
}

There are some important notions which are missing but are derivable from the syntax. The groupoid laws on all levels should also be derivable using the J-terms. We will show some of them in this section.

Identity context morphism is not a primitive notion in this framework. To define it, we have to declare all the properties it should hold as an identity morphism. In other words, substitution with identity morphism should keep everything unchanged.


\begin{code}
IdCm : ∀ Γ → Γ ⇒ Γ

IC-T  : ∀ {Γ : Con}(A : Ty Γ) → A [ IdCm Γ ]T ≡ A
IC-v : ∀{Γ : Con}{A : Ty Γ}(x : Var A) →  x [ IdCm Γ ]V ≅ var x
IC-⊚ : ∀{Γ Δ : Con}(δ : Γ ⇒ Δ) → δ ⊚ IdCm Γ ≡ δ
IC-tm : ∀{Γ : Con}{A : Ty Γ}(a : Tm A) → a [ IdCm Γ ]tm ≅ a
\end{code}

\AgdaHide{
\begin{code}
IdCm ε = •
IdCm (Γ , A) = ((IdCm Γ) +S A) , wk-tm+ A (var v0 ⟦ wk-T (IC-T A) ⟫)

IC-T {Γ} * = refl
IC-T {Γ} (a =h b) = hom≡ (IC-tm a) (IC-tm b)

IC-v {.(Γ , A)} {.(A +T A)} (v0 {Γ} {A}) = wk-coh ∾ wk-coh+ ∾ cohOp (wk-T (IC-T A))

IC-v {.(Γ , B)} {.(A +T B)} (vS {Γ} {A} {B} x) = wk-coh ∾ [+S]V x ∾ cong+tm2 (IC-v x)

IC-⊚ • = refl
IC-⊚ {Γ} (_,_ δ {A} a) = cm-eq (IC-⊚ δ) (cohOp [⊚]T ∾ IC-tm a) 

IC-tm {Γ} {A} (var x) = IC-v x

IC-tm {Γ} {.(A [ δ ]T)} (JJ x δ A) = cohOp (sym [⊚]T) ∾ JJ-eq (IC-⊚ δ)


\end{code}
}