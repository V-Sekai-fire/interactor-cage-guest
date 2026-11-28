-- SPDX-FileCopyrightText: 2026 K. S. Ernest (iFire) Lee
--
-- SPDX-License-Identifier: MIT
/-!
# `Cage.GreenBind`: the cheap bind and two facts it rests on

The (1,3) bind turns a row `[h | bh]` of harmonic and biharmonic coordinates into weights `W = [h | bh] X`, with `X` the
solution of a dense constraint system (samples, Gram matrix, LU). The Green bind skips that system: `X = [I; 0]`, so
`W = h`. This file states that, and proves, in a model over `Int`, that weights summing to 1 make the deformed point
translation-equivariant (the property the winding test and the fit's rest reproduction rely on).
-/
namespace Cage.GreenBind

/-- The blend of a row `[h | bh]` with the selector `[I; 0]`: the biharmonic part is multiplied by zero. -/
def greenBlend (h bh : Nat → Int) : Nat → Int := fun j => h j + 0 * bh j

/-- The Green weights are exactly the harmonic part of the row. -/
theorem green_blend_eq_harmonic (h bh : Nat → Int) : greenBlend h bh = h := by
  funext j
  simp [greenBlend]

/-- Shifting every knot by `t` shifts the weighted sum by `(sum of weights) * t` (one weight per knot). -/
theorem sum_zip_shift : ∀ (w v : List Int), w.length = v.length → ∀ t : Int,
    (List.zipWith (· * ·) w (v.map (· + t))).sum = (List.zipWith (· * ·) w v).sum + w.sum * t
  | [], [], _, _ => by simp
  | [], _ :: _, h, _ => by simp at h
  | _ :: _, [], h, _ => by simp at h
  | a :: as, b :: bs, h, t => by
    have h' : as.length = bs.length := by simpa using h
    simp only [List.map_cons, List.zipWith_cons_cons, List.sum_cons]
    rw [sum_zip_shift as bs h' t, Int.mul_add, Int.add_mul]
    omega

/-- Weights that sum to 1 reproduce a translation of the knots exactly. -/
theorem translation_equivariant (w v : List Int) (hl : w.length = v.length) (t : Int) (hw : w.sum = 1) :
    (List.zipWith (· * ·) w (v.map (· + t))).sum = (List.zipWith (· * ·) w v).sum + t := by
  rw [sum_zip_shift w v hl t, hw, Int.one_mul]

end Cage.GreenBind
