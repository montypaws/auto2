theory Real_Auto2
imports Seq_Thms Equiv_Rel_Thms Conditionally_Complete_Lattices
begin

subsection {* Preliminaries *}

theorem obtain_pos_sum [backward]:
  "(r::('a::linordered_field)) > 0 \<Longrightarrow> \<exists>s t. s > 0 \<and> t > 0 \<and> r = s + t"
  by (tactic {* auto2s_tac @{context} (OBTAIN "r = r/2 + r/2") *})

theorem obtain_pos_sum2 [backward2]:
  "(r::('a::linordered_field)) > 0 \<Longrightarrow> a > 0 \<and> b > 0 \<Longrightarrow> \<exists>s t. s > 0 \<and> t > 0 \<and> r = a * t + b * s"
  by (tactic {* auto2s_tac @{context}
    (CHOOSE "u, v, u > 0, v > 0, r = u + v" THEN
     OBTAIN "r = a * (u/a) + b * (v/b)") *})

theorem exists_max3 [resolve]: "\<exists>d::nat. d \<ge> a \<and> d \<ge> b \<and> d \<ge> c"
  by (tactic {* auto2s_tac @{context} (OBTAIN "max (max a b) c \<ge> a") *})

lemma abs_sum_upper_bound [backward1]:
  "\<bar>(x::('a::linordered_idom))\<bar> < s \<Longrightarrow> \<bar>y\<bar> < t \<Longrightarrow> \<bar>x + y\<bar> < s + t" by arith

theorem abs_cancel_diff1 [backward1]:
  "\<bar>(x::('a::linordered_idom)) - y\<bar> < s \<Longrightarrow> \<bar>y - z\<bar> \<le> t \<Longrightarrow> \<bar>x - z\<bar> < s + t" by simp
theorem abs_cancel_diff2 [backward1]:
  "\<bar>(x::('a::linordered_idom)) - y\<bar> < s \<Longrightarrow> \<bar>y - z\<bar> < t \<Longrightarrow> \<bar>x - z\<bar> < s + t" by simp

lemma abs_prod_upper_bound [backward1]:
  "\<bar>(x::('a::linordered_idom))\<bar> < s \<Longrightarrow> \<bar>y\<bar> < t \<Longrightarrow> \<bar>x * y\<bar> < s * t" by (simp add: abs_mult abs_mult_less)

lemma abs_prod_upper_bound2 [backward2]:
  "\<bar>(x::('a::linordered_field))\<bar> < s / t \<Longrightarrow> \<bar>y\<bar> < t \<Longrightarrow> \<bar>x * y\<bar> < s"
  by (tactic {* auto2s_tac @{context} (OBTAIN "t > 0" THEN OBTAIN "s = s * t / t") *})

lemma abs_prod_lower_bound [backward1]:
  "s > 0 \<and> t > 0 \<and> \<bar>(x::('a::linordered_idom))\<bar> > s \<Longrightarrow> \<bar>y\<bar> > t \<Longrightarrow> \<bar>x * y\<bar> > s * t"
  by (metis abs_mult abs_of_pos abs_prod_upper_bound)

lemma abs_div_upper_bound [backward2]:
  "\<bar>x::('a::linordered_field)\<bar> < a \<Longrightarrow> b > 0 \<and> \<bar>y\<bar> > b \<Longrightarrow> \<bar>x\<bar> / \<bar>y\<bar> < a / b"
  using abs_ge_zero frac_less less_imp_le by blast

lemma abs_div_upper_bound2 [backward2]:
  "\<bar>(x::('a::linordered_field))\<bar> < s * t \<Longrightarrow> \<bar>y\<bar> > t \<and> t > 0 \<Longrightarrow> \<bar>x\<bar> / \<bar>y\<bar> < s"
  using abs_div_upper_bound by fastforce

lemma bound_diff_concl [resolve]:
  "\<bar>(a::('a::linordered_field)) - b\<bar> < c \<Longrightarrow> \<bar>a\<bar> < \<bar>b\<bar> + c" by simp

subsection {* Boundedness on sequences *}

definition bounded :: "('a::linordered_idom) seq \<Rightarrow> bool" where
  "bounded X = (\<exists>r>0. \<forall>n. \<bar>X\<langle>n\<rangle>\<bar> \<le> r)"

(* Basic introduction and elimination rules for bounded. *)
setup {* add_rewrite_rule @{thm bounded_def} *}
lemma bounded_intro [forward]: "\<forall>n. \<bar>X\<langle>n\<rangle>\<bar> \<le> r \<Longrightarrow> bounded X"
  by (tactic {* auto2s_tac @{context} (OBTAIN "\<forall>n. \<bar>X\<langle>n\<rangle>\<bar> \<le> max r 1") *})
setup {* del_prfstep_thm @{thm bounded_def} #> add_resolve_prfstep (equiv_forward_th @{thm bounded_def}) *}

(* Less than version of intro and elim rules. *)
lemma bounded_intro_less [forward]: "\<forall>n. \<bar>X\<langle>n\<rangle>\<bar> < r \<Longrightarrow> bounded X"
  by (tactic {* auto2s_tac @{context} (OBTAIN "\<forall>n. \<bar>X\<langle>n\<rangle>\<bar> \<le> r") *})

lemma bounded_elim_less [resolve]: "bounded X \<Longrightarrow> \<exists>r>0. \<forall>n. \<bar>X\<langle>n\<rangle>\<bar> < r"
  by (tactic {* auto2s_tac @{context}
    (CHOOSE "r, r > 0, \<forall>n. \<bar>X\<langle>n\<rangle>\<bar> \<le> r" THEN OBTAIN "\<forall>n. \<bar>X\<langle>n\<rangle>\<bar> < r + 1") *})

lemma bounded_on_tail [forward]: "\<forall>n\<ge>k. \<bar>X\<langle>n\<rangle>\<bar> \<le> r \<Longrightarrow> bounded X"
  by (tactic {* auto2s_tac @{context}
    (OBTAIN_FORALL "n, \<bar>X\<langle>n\<rangle>\<bar> \<le> max r (Max ((\<lambda>i. \<bar>X\<langle>i\<rangle>\<bar>) ` {..<k}))" WITH
      (CASE "n < k" WITH OBTAIN "\<bar>X\<langle>n\<rangle>\<bar> \<le> Max ((\<lambda>i. \<bar>X\<langle>i\<rangle>\<bar>) ` {..<k})")) *})

theorem bounded_def_less_on_tail [forward]: "\<forall>n\<ge>k. \<bar>X\<langle>n\<rangle>\<bar> < r \<Longrightarrow> bounded X"
  by (tactic {* auto2s_tac @{context} (OBTAIN "\<forall>n\<ge>k. \<bar>X\<langle>n\<rangle>\<bar> \<le> r") *})

subsection {* Vanishes condition on sequences *}

definition vanishes :: "('a::linordered_field) seq \<Rightarrow> bool" where
  "vanishes X = (\<forall>r>0. \<exists>k. \<forall>n\<ge>k. \<bar>X\<langle>n\<rangle>\<bar> < r)"
setup {* add_backward_prfstep (equiv_backward_th @{thm vanishes_def})*}

theorem vanishes_elim [backward2]:
  "vanishes X \<Longrightarrow> r > 0 \<Longrightarrow> \<exists>k. \<forall>n\<ge>k. \<bar>X\<langle>n\<rangle>\<bar> < r" by (simp add: vanishes_def)

lemma vanishes_const [rewrite]: "vanishes {c}\<^sub>S \<longleftrightarrow> c = 0"
  by (tactic {* auto2s_tac @{context}
    (CASE "vanishes {c}\<^sub>S" WITH (CHOOSE "k, \<forall>n\<ge>k. \<bar>{c}\<^sub>S\<langle>n\<rangle>\<bar> < \<bar>c\<bar>" THEN OBTAIN "\<bar>{c}\<^sub>S\<langle>k\<rangle>\<bar> < \<bar>c\<bar>") THEN
     CASE "c = 0" WITH (CHOOSE "r, r > 0, \<not>(\<exists>k. \<forall>n\<ge>k. \<bar>{c}\<^sub>S\<langle>n\<rangle>\<bar> < r)" THEN OBTAIN "\<forall>n\<ge>0. \<bar>{c}\<^sub>S\<langle>n\<rangle>\<bar> < r")) *})

lemma vanishes_minus [backward]: "vanishes X \<Longrightarrow> vanishes (-X)"
  by (tactic {* auto2s_tac @{context}
    (CHOOSE "r, r > 0, \<not>(\<exists>k. \<forall>n\<ge>k. \<bar>(-X)\<langle>n\<rangle>\<bar> < r)" THEN
     CHOOSE "k, \<forall>n\<ge>k. \<bar>X\<langle>n\<rangle>\<bar> < r" THEN OBTAIN "\<forall>n\<ge>k. \<bar>(-X)\<langle>n\<rangle>\<bar> < r") *})

lemma vanishes_add [backward2]: "vanishes X \<Longrightarrow> vanishes Y \<Longrightarrow> vanishes (X + Y)"
  by (tactic {* auto2s_tac @{context}
    (CHOOSE "r, r > 0, \<not>(\<exists>k. \<forall>n\<ge>k. \<bar>(X + Y)\<langle>n\<rangle>\<bar> < r)" THEN
     CHOOSE "s, t, s > 0, t > 0, r = s + t" THEN
     CHOOSE "k1, \<forall>n\<ge>k1. \<bar>X\<langle>n\<rangle>\<bar> < s" THEN
     CHOOSE "k2, \<forall>n\<ge>k2. \<bar>Y\<langle>n\<rangle>\<bar> < t" THEN
     OBTAIN "\<forall>n\<ge>max k1 k2. \<bar>(X + Y)\<langle>n\<rangle>\<bar> < r") *})

lemma vanishes_diff [backward1]: "vanishes X \<Longrightarrow> vanishes Y \<Longrightarrow> vanishes (X - Y)" by auto2

lemma vanishes_diff' [rewrite]: "vanishes (X - Y) \<Longrightarrow> vanishes X \<longleftrightarrow> vanishes Y"
  by (tactic {* auto2s_tac @{context}
    ((CASE "vanishes X" WITH OBTAIN "X - (X - Y) = Y") THEN
     (CASE "vanishes Y" WITH OBTAIN "Y + (X - Y) = X")) *})

lemma vanishes_mult_bounded [backward2]: "bounded X \<Longrightarrow> vanishes Y \<Longrightarrow> vanishes (X * Y)"
  by (tactic {* auto2s_tac @{context}
    (CHOOSE "a, a > 0, \<forall>n. \<bar>X\<langle>n\<rangle>\<bar> < a" THEN
     CHOOSE "r, r > 0, \<not>(\<exists>k. \<forall>n\<ge>k. \<bar>(X * Y)\<langle>n\<rangle>\<bar> < r)" THEN
     CHOOSE "k, \<forall>n\<ge>k. \<bar>Y\<langle>n\<rangle>\<bar> < r/a" THEN
     OBTAIN "\<forall>n\<ge>k. \<bar>(X * Y)\<langle>n\<rangle>\<bar> < r") *})

subsection {* Cauchy condition on sequences *}

definition cauchy :: "('a::linordered_field) seq \<Rightarrow> bool" where
  "cauchy X = (\<forall>r>0. \<exists>k. \<forall>m\<ge>k. \<forall>n\<ge>k. \<bar>X\<langle>m\<rangle> - X\<langle>n\<rangle>\<bar> < r)"
setup {* add_resolve_prfstep (equiv_backward_th @{thm cauchy_def}) *}

theorem cauchy_elim [backward2]:
  "cauchy X \<Longrightarrow> r > 0 \<Longrightarrow> \<exists>k. \<forall>m\<ge>k. \<forall>n\<ge>k. \<bar>X\<langle>m\<rangle> - X\<langle>n\<rangle>\<bar> < r" by (simp add: cauchy_def)

lemma cauchy_elim2 [backward2]: "cauchy X \<Longrightarrow> r > 0 \<Longrightarrow> \<exists>k. \<forall>n\<ge>k. \<bar>X\<langle>n\<rangle> - X\<langle>k\<rangle>\<bar> < r"
  by (tactic {* auto2s_tac @{context}
    (CHOOSE "k, \<forall>m\<ge>k. \<forall>n\<ge>k. \<bar>X\<langle>m\<rangle> - X\<langle>n\<rangle>\<bar> < r" THEN
     OBTAIN "\<forall>n\<ge>k. \<bar>X\<langle>n\<rangle> - X\<langle>k\<rangle>\<bar> < r") *})

lemma cauchy_intro2 [resolve]: "\<forall>r>0. \<exists>k. \<forall>n\<ge>k. \<bar>X\<langle>n\<rangle> - X\<langle>k\<rangle>\<bar> < r \<Longrightarrow> cauchy X"
  by (tactic {* auto2s_tac @{context}
    (CHOOSE "r, r > 0, \<not>(\<exists>k. \<forall>m\<ge>k. \<forall>n\<ge>k. \<bar>X\<langle>m\<rangle> - X\<langle>n\<rangle>\<bar> < r)" THEN
     CHOOSE "k, \<forall>n\<ge>k. \<bar>X\<langle>n\<rangle> - X\<langle>k\<rangle>\<bar> < r/2" THEN
     OBTAIN_FORALL "m, m \<ge> k, n, n \<ge> k, \<bar>X\<langle>m\<rangle> - X\<langle>n\<rangle>\<bar> < r/2 + r/2") *})

lemma cauchy_elim_le [backward2]: "cauchy X \<Longrightarrow> r > 0 \<Longrightarrow> \<exists>k. \<forall>m\<ge>k. \<forall>n\<ge>k. \<bar>X\<langle>m\<rangle> - X\<langle>n\<rangle>\<bar> \<le> r"
  by (tactic {* auto2s_tac @{context}
    (CHOOSE "k, \<forall>m\<ge>k. \<forall>n\<ge>k. \<bar>X\<langle>m\<rangle> - X\<langle>n\<rangle>\<bar> < r" THEN
     OBTAIN "\<forall>m\<ge>k. \<forall>n\<ge>k. \<bar>X\<langle>m\<rangle> - X\<langle>n\<rangle>\<bar> \<le> r") *})

lemma cauchy_const: "cauchy {c}\<^sub>S"
  by (tactic {* auto2s_tac @{context}
    (CHOOSE "r, r > 0, \<not>(\<exists>k. \<forall>m\<ge>k. \<forall>n\<ge>k. \<bar>{c}\<^sub>S\<langle>m\<rangle> - {c}\<^sub>S\<langle>n\<rangle>\<bar> < r)" THEN
     OBTAIN "\<forall>m\<ge>0. \<forall>n\<ge>0. \<bar>{c}\<^sub>S\<langle>m\<rangle> - {c}\<^sub>S\<langle>n\<rangle>\<bar> < r") *})
setup {* add_forward_prfstep_cond @{thm cauchy_const} [with_term "{?c}\<^sub>S"] *}

lemma cauchy_vanishes [forward]: "vanishes X \<Longrightarrow> cauchy X"
  by (tactic {* auto2s_tac @{context}
    (CHOOSE "r, r > 0, \<not>(\<exists>k. \<forall>m\<ge>k. \<forall>n\<ge>k. \<bar>X\<langle>m\<rangle> - X\<langle>n\<rangle>\<bar> < r)" THEN
     CHOOSE "i, \<forall>n\<ge>i. \<bar>X\<langle>n\<rangle>\<bar> < r/2" THEN
     OBTAIN_FORALL "m, m\<ge>i, n, n\<ge>i, \<bar>X\<langle>m\<rangle> - X\<langle>n\<rangle>\<bar> < r/2 + r/2") *})

lemma cauchy_add [backward2]: "cauchy X \<Longrightarrow> cauchy Y \<Longrightarrow> cauchy (X + Y)"
  by (tactic {* auto2s_tac @{context}
    (CHOOSE "r, r > 0, \<not>(\<exists>k. \<forall>m\<ge>k. \<forall>n\<ge>k. \<bar>(X + Y)\<langle>m\<rangle> - (X + Y)\<langle>n\<rangle>\<bar> < r)" THEN
     CHOOSE "s, t, s > 0, t > 0, r = s + t" THEN
     CHOOSE "k1, \<forall>m\<ge>k1. \<forall>n\<ge>k1. \<bar>X\<langle>m\<rangle> - X\<langle>n\<rangle>\<bar> < s" THEN
     CHOOSE "k2, \<forall>m\<ge>k2. \<forall>n\<ge>k2. \<bar>Y\<langle>m\<rangle> - Y\<langle>n\<rangle>\<bar> < t" THEN
     OBTAIN_FORALL "m, m\<ge>max k1 k2, n, n\<ge>max k1 k2, \<bar>(X + Y)\<langle>m\<rangle> - (X + Y)\<langle>n\<rangle>\<bar> < r") *})

lemma cauchy_minus [backward]: "cauchy X \<Longrightarrow> cauchy (-X)"
  by (tactic {* auto2s_tac @{context}
    (CHOOSE "r, r > 0, \<not>(\<exists>k. \<forall>m\<ge>k. \<forall>n\<ge>k. \<bar>(-X)\<langle>m\<rangle> - (-X)\<langle>n\<rangle>\<bar> < r)" THEN
     CHOOSE "k, \<forall>m\<ge>k. \<forall>n\<ge>k. \<bar>X\<langle>m\<rangle> - X\<langle>n\<rangle>\<bar> < r" THEN
     OBTAIN "\<forall>m\<ge>k. \<forall>n\<ge>k. \<bar>(-X)\<langle>m\<rangle> - (-X)\<langle>n\<rangle>\<bar> < r") *})

theorem cauchy_minus' [forward]: "cauchy (-X) \<Longrightarrow> cauchy X" using cauchy_minus by fastforce

lemma cauchy_diff [backward1]: "cauchy X \<Longrightarrow> cauchy Y \<Longrightarrow> cauchy (X - Y)" by auto2

lemma cauchy_imp_bounded [forward]: "cauchy X \<Longrightarrow> bounded X"
  by (tactic {* auto2s_tac @{context}
    (CHOOSE "k, \<forall>n\<ge>k. \<bar>X\<langle>n\<rangle> - X\<langle>k\<rangle>\<bar> < 1" THEN OBTAIN "\<forall>n\<ge>k. \<bar>X\<langle>n\<rangle>\<bar> < \<bar>X\<langle>k\<rangle>\<bar> + 1") *})

lemma cauchy_mult [backward2]: "cauchy X \<Longrightarrow> cauchy Y \<Longrightarrow> cauchy (X * Y)"
  by (tactic {* auto2s_tac @{context}
    (CHOOSES ["r, r > 0, \<not>(\<exists>k. \<forall>m\<ge>k. \<forall>n\<ge>k. \<bar>(X * Y)\<langle>m\<rangle> - (X * Y)\<langle>n\<rangle>\<bar> < r)",
              "a, a > 0, (\<forall>n. \<bar>X\<langle>n\<rangle>\<bar> < a)",
              "b, b > 0, (\<forall>n. \<bar>Y\<langle>n\<rangle>\<bar> < b)",
              "s, t, s > 0, t > 0, r = a * t + b * s",
              "i, \<forall>m\<ge>i. \<forall>n\<ge>i. \<bar>X\<langle>m\<rangle> - X\<langle>n\<rangle>\<bar> < s",
              "j, \<forall>m\<ge>j. \<forall>n\<ge>j. \<bar>Y\<langle>m\<rangle> - Y\<langle>n\<rangle>\<bar> < t"] THEN
     OBTAIN_FORALL "m, m\<ge>max i j, n, n\<ge>max i j, \<bar>(X * Y)\<langle>m\<rangle> - (X * Y)\<langle>n\<rangle>\<bar> < r" WITH
      (OBTAIN "(X * Y)\<langle>m\<rangle> - (X * Y)\<langle>n\<rangle> = X\<langle>m\<rangle> * (Y\<langle>m\<rangle> - Y\<langle>n\<rangle>) + (X\<langle>m\<rangle> - X\<langle>n\<rangle>) * Y\<langle>n\<rangle>" THEN
       OBTAIN "\<bar>X\<langle>m\<rangle> * (Y\<langle>m\<rangle> - Y\<langle>n\<rangle>)\<bar> < a * t")) *})

lemma cauchy_not_vanishes_cases [backward2]:
  "cauchy X \<Longrightarrow> \<not> vanishes X \<Longrightarrow> \<exists>b>0. \<exists>k. (\<forall>n\<ge>k. b < - X\<langle>n\<rangle>) \<or> (\<forall>n\<ge>k. b < X\<langle>n\<rangle>)"
  by (tactic {* auto2s_tac @{context}
    (CHOOSES ["r, r > 0, (\<forall>k. \<exists>n\<ge>k. r \<le> \<bar>X\<langle>n\<rangle>\<bar>)",
              "s, t, s > 0, t > 0, r = s + t",
              "i, \<forall>m\<ge>i. \<forall>n\<ge>i. \<bar>X\<langle>m\<rangle> - X\<langle>n\<rangle>\<bar> < s",
              "k, k \<ge> i, r \<le> \<bar>X\<langle>k\<rangle>\<bar>"] THEN
     OBTAIN "\<forall>n\<ge>k. \<bar>X\<langle>n\<rangle> - X\<langle>k\<rangle>\<bar> < s" THEN
     CASE "X\<langle>k\<rangle> \<le> -r" WITH OBTAIN "\<forall>n\<ge>k. t < - X\<langle>n\<rangle>" THEN
     CASE "X\<langle>k\<rangle> \<ge> r" WITH OBTAIN "\<forall>n\<ge>k. t < X\<langle>n\<rangle>") *})

lemma cauchy_not_vanishes [backward2]:
  "cauchy X \<Longrightarrow> \<not> vanishes X \<Longrightarrow> \<exists>b>0. \<exists>k. \<forall>n\<ge>k. b < \<bar>X\<langle>n\<rangle>\<bar>"
  by (tactic {* auto2s_tac @{context}
    (CHOOSE "b, b > 0, k, (\<forall>n\<ge>k. b < - X\<langle>n\<rangle>) \<or> (\<forall>n\<ge>k. b < X\<langle>n\<rangle>)" THEN OBTAIN "\<forall>n\<ge>k. b < \<bar>X\<langle>n\<rangle>\<bar>") *})

lemma cauchy_inverse [backward2]: "cauchy X \<Longrightarrow> \<not> vanishes X \<Longrightarrow> cauchy (seq_inverse X)"
  by (tactic {* auto2s_tac @{context}
    (CHOOSE "r, r > 0, \<not>(\<exists>k. \<forall>m\<ge>k. \<forall>n\<ge>k. \<bar>(seq_inverse X) \<langle>m\<rangle> - (seq_inverse X) \<langle>n\<rangle>\<bar> < r)" THEN
     CHOOSE "b, b > 0, i, \<forall>n\<ge>i. b < \<bar>X\<langle>n\<rangle>\<bar>" THEN
     CHOOSE "j, \<forall>m\<ge>j. \<forall>n\<ge>j. \<bar>X\<langle>m\<rangle> - X\<langle>n\<rangle>\<bar> < r*b*b" THEN
     OBTAIN_FORALL "m, m\<ge>max i j, n, n\<ge>max i j, \<bar>(seq_inverse X) \<langle>m\<rangle> - (seq_inverse X) \<langle>n\<rangle>\<bar> < r" WITH
      (OBTAIN "\<bar>1 / X\<langle>m\<rangle> - 1 / X\<langle>n\<rangle>\<bar> = \<bar>X\<langle>m\<rangle> - X\<langle>n\<rangle>\<bar> / \<bar>X\<langle>m\<rangle> * X\<langle>n\<rangle>\<bar>")) *})

lemma vanishes_diff_inverse [backward1]: "cauchy X \<and> \<not> vanishes X \<and> cauchy Y \<and> \<not> vanishes Y \<Longrightarrow>
  vanishes (X - Y) \<Longrightarrow> vanishes (seq_inverse X - seq_inverse Y)"
  by (tactic {* auto2s_tac @{context}
    (CHOOSE "r, r > 0, \<not>(\<exists>k. \<forall>n\<ge>k. \<bar>(seq_inverse X - seq_inverse Y) \<langle>n\<rangle>\<bar> < r)" THEN
     CHOOSE "a, a > 0, i, \<forall>n\<ge>i. a < \<bar>X\<langle>n\<rangle>\<bar>" THEN
     CHOOSE "b, b > 0, j, \<forall>n\<ge>j. b < \<bar>Y\<langle>n\<rangle>\<bar>" THEN
     CHOOSE "k, \<forall>n\<ge>k. \<bar>(X - Y)\<langle>n\<rangle>\<bar> < r*a*b" THEN
     OBTAIN_FORALL "n, n \<ge> max (max i j) k, \<bar>(seq_inverse X - seq_inverse Y) \<langle>n\<rangle>\<bar> < r" WITH
      (OBTAIN "\<bar>1 / X\<langle>n\<rangle> - 1 / Y\<langle>n\<rangle>\<bar> = \<bar>X\<langle>n\<rangle> - Y\<langle>n\<rangle>\<bar> / \<bar>X\<langle>n\<rangle> * Y\<langle>n\<rangle>\<bar>")) *})

lemma seq_inverse_is_inverse [backward2]:
  "cauchy X \<Longrightarrow> \<not> vanishes X \<Longrightarrow> vanishes ((seq_inverse X) * X - 1)"
  by (tactic {* auto2s_tac @{context}
    (CHOOSE "r, r > 0, \<not>(\<exists>k. \<forall>n\<ge>k. \<bar>((seq_inverse X) * X - 1) \<langle>n\<rangle>\<bar> < r)" THEN
     CHOOSE "b, b > 0, k, \<forall>n\<ge>k. b < \<bar>X\<langle>n\<rangle>\<bar>" THEN
     OBTAIN "\<forall>n\<ge>k. \<bar>((seq_inverse X) * X - 1) \<langle>n\<rangle>\<bar> < r") *})

subsection {* Equivalence relation on Cauchy sequences *}

definition realrel :: "rat seq \<Rightarrow> rat seq \<Rightarrow> bool" where
  "realrel X Y \<longleftrightarrow> cauchy X \<and> cauchy Y \<and> vanishes (X - Y)"
setup {* add_rewrite_rule @{thm realrel_def} *}

lemma realrel_refl [rewrite_back]: "cauchy X \<longleftrightarrow> realrel X X" by auto2
setup {* del_prfstep_thm @{thm realrel_def} #> add_rewrite_rule_cond @{thm realrel_def} [with_cond "?X \<noteq> ?Y"] *}

lemma symp_realrel [known_fact]: "symp realrel" by auto2

lemma transp_realrel: "transp realrel"
  by (tactic {* auto2s_tac @{context} (
    CHOOSE "X, Y, Z, realrel X Y, realrel Y Z, \<not> realrel X Z" THEN
    OBTAIN "(X - Y) + (Y - Z) = X - Z") *})

lemma part_equivp_realrel: "part_equivp realrel"
  by (meson cauchy_const part_equivpI realrel_refl symp_realrel transp_realrel)

subsection {* The field of real numbers *}

quotient_type real = "rat seq" / partial: realrel morphisms rep_real Real
  by (rule part_equivp_realrel)

theorem exists_lift_real [resolve]: "\<exists>S. cauchy S \<and> r = Real S"
  by (metis Quotient_alt_def2 Quotient_real cr_real_def realrel_def)

instantiation real :: field
begin

lift_definition zero_real :: "real" is "0" by auto2
lift_definition one_real :: "real" is "1" by auto2
lift_definition plus_real :: "real \<Rightarrow> real \<Rightarrow> real" is "\<lambda>X Y. X + Y" by auto2
lift_definition uminus_real :: "real \<Rightarrow> real" is "\<lambda>X. -X" by auto2

lift_definition times_real :: "real \<Rightarrow> real \<Rightarrow> real" is "\<lambda>X Y. X * Y"
proof -
  fix X1 Y1 X2 Y2
  show "realrel X1 Y1 \<Longrightarrow> realrel X2 Y2 \<Longrightarrow> realrel (X1 * X2) (Y1 * Y2)"
    by (tactic {* auto2s_tac @{context}
      (OBTAIN "(X1 * X2) - (Y1 * Y2) = X1 * (X2 - Y2) + Y2 * (X1 - Y1)" THEN
       OBTAIN "vanishes (X1 * (X2 - Y2))") *})
qed

lift_definition inverse_real :: "real \<Rightarrow> real" is
  "\<lambda>X. if vanishes X then {0}\<^sub>S else (seq_inverse X)" by auto2

definition "x - y = (x::real) + (-y)"
definition "x div y = (x::real) * inverse y"

lemma add_Real [rewrite_back]: "cauchy X \<Longrightarrow> cauchy Y \<Longrightarrow> Real X + Real Y = Real (X + Y)"
  by (simp add: realrel_refl plus_real.abs_eq)

lemma minus_Real [rewrite_back]: "cauchy X \<Longrightarrow> - Real X = Real (-X)"
  by (simp add: realrel_refl uminus_real.abs_eq)

lemma diff_Real [rewrite_back]: "cauchy X \<Longrightarrow> cauchy Y \<Longrightarrow> Real X - Real Y = Real (X - Y)"
  by (simp add: add_Real cauchy_minus minus_Real minus_real_def)

lemma mult_Real [rewrite_back]: "cauchy X \<Longrightarrow> cauchy Y \<Longrightarrow> Real X * Real Y = Real (X * Y)"
  by (simp add: realrel_refl times_real.abs_eq)

lemma inverse_Real [rewrite]:
  "cauchy X \<Longrightarrow> inverse (Real X) = (if vanishes X then Real {0}\<^sub>S else Real (seq_inverse X))"
  by (simp add: realrel_refl inverse_real.abs_eq zero_real.abs_eq)

instance proof
  fix a b c :: real
  show "a - b = a + (-b)" by (rule minus_real_def)
  show "a div b = a * inverse b" by (rule divide_real_def)
  show "a + b = b + a" by transfer auto2
  show "a * b = b * a" by transfer auto2
  show "0 + a = a" by transfer auto2
  show "1 * a = a" by transfer auto2
  show "a * b * c = a * (b * c)" by transfer auto2
  show "a + b + c = a + (b + c)" by transfer auto2
  show "-a + a = 0" by transfer auto2
  show "(0::real) \<noteq> 1" by transfer auto2
  show "inverse (0::real) = 0" by transfer auto2
  show "(a + b) * c = a * c + b * c" by transfer auto2
  show "a \<noteq> 0 \<Longrightarrow> inverse a * a = 1" by transfer auto2
qed

end

setup {* fold add_rewrite_rule_back [@{thm zero_real.abs_eq}, @{thm one_real.abs_eq}] *}

theorem inverse_Real1 [rewrite]: "vanishes X \<Longrightarrow> inverse (Real X) = 0" by auto2
theorem inverse_Real2 [rewrite_bidir]:
  "cauchy X \<Longrightarrow> \<not> vanishes X \<Longrightarrow> inverse (Real X) = Real (seq_inverse X)" by auto2
setup {* del_prfstep_thm @{thm inverse_Real}*}
theorem inverse_Real_const [rewrite_bidir]:
  "b > 0 \<Longrightarrow> Real {inverse b}\<^sub>S = inverse (Real {b}\<^sub>S)" by auto2

subsection {* Positive reals *}

definition positive_seq :: "('a::linordered_field) seq \<Rightarrow> bool" where
  "positive_seq X \<longleftrightarrow> (\<exists>r>0. \<exists>k. \<forall>n\<ge>k. r < X\<langle>n\<rangle>)"
setup {* add_rewrite_rule @{thm positive_seq_def} *}

theorem positive_seq_rel [backward1]: "realrel X Y \<Longrightarrow> positive_seq X \<Longrightarrow> positive_seq Y"
  by (tactic {* auto2s_tac @{context}
    (CHOOSES ["r, r > 0, i, \<forall>n\<ge>i. r < X\<langle>n\<rangle>",
              "s, t, s > 0, t > 0, r = s + t",
              "j, \<forall>n\<ge>j. \<bar>(X - Y)\<langle>n\<rangle>\<bar> < s"] THEN
     OBTAIN "\<forall>n\<ge>max i j. t < Y\<langle>n\<rangle>") *})

lift_definition positive :: "real \<Rightarrow> bool" is "\<lambda>X. positive_seq X" by auto2

lemma positive_Real [rewrite]: "cauchy X \<Longrightarrow> positive (Real X) \<longleftrightarrow> positive_seq X"
  by (simp add: positive.abs_eq realrel_refl)

lemma positive_zero: "\<not> positive 0"
  by transfer (metis le_square less_imp_not_less seq_evals(1) positive_seq_def)

lemma positive_seq_add [backward2]: "positive_seq X \<Longrightarrow> positive_seq Y \<Longrightarrow> positive_seq (X + Y)"
  by (tactic {* auto2s_tac @{context}
    (CHOOSE "s, s > 0, i, \<forall>n\<ge>i. s < X\<langle>n\<rangle>" THEN
     CHOOSE "t, t > 0, j, \<forall>n\<ge>j. t < Y\<langle>n\<rangle>" THEN
     OBTAIN_FORALL "n, n \<ge> max i j, s + t < (X + Y)\<langle>n\<rangle>" THEN OBTAIN "s + t > 0") *})

lemma positive_add: "positive x \<Longrightarrow> positive y \<Longrightarrow> positive (x + y)" by transfer auto2

lemma positive_seq_mult [backward2]: "positive_seq X \<Longrightarrow> positive_seq Y \<Longrightarrow> positive_seq (X * Y)"
  by (tactic {* auto2s_tac @{context}
    (CHOOSE "s, s > 0, i, \<forall>n\<ge>i. s < X\<langle>n\<rangle>" THEN
     CHOOSE "t, t > 0, j, \<forall>n\<ge>j. t < Y\<langle>n\<rangle>" THEN
     OBTAIN_FORALL "n, n \<ge> max i j, s * t < (X * Y)\<langle>n\<rangle>" THEN OBTAIN "s * t > 0") *})

lemma positive_mult: "positive x \<Longrightarrow> positive y \<Longrightarrow> positive (x * y)" by transfer auto2

lemma positive_seq_minus: "cauchy X \<Longrightarrow> \<not> vanishes X \<Longrightarrow> positive_seq X \<or> positive_seq (-X)"
  by (tactic {* auto2s_tac @{context}
    (CHOOSE "b, b > 0, k, (\<forall>n\<ge>k. b < - X\<langle>n\<rangle>) \<or> (\<forall>n\<ge>k. b < X\<langle>n\<rangle>)" THEN
     OBTAIN "\<exists>n\<ge>k. X\<langle>n\<rangle> \<le> b" THEN OBTAIN "\<exists>n\<ge>k. (-X)\<langle>n\<rangle> \<le> b") *})

lemma positive_minus: "\<not> positive x \<Longrightarrow> x \<noteq> 0 \<Longrightarrow> positive (-x)"
  apply transfer using positive_seq_minus realrel_def zero_real.rsp by auto

instantiation real :: linordered_field
(* This instantiation directly copies from HOL/Real.thy *)
begin

definition "x < y \<longleftrightarrow> positive (y - x)"
definition "x \<le> (y::real) \<longleftrightarrow> x < y \<or> x = y"
definition "abs (a::real) = (if a < 0 then - a else a)"
definition "sgn (a::real) = (if a = 0 then 0 else if 0 < a then 1 else - 1)"

instance proof
  fix a b c :: real
  show "\<bar>a\<bar> = (if a < 0 then - a else a)"
    by (rule abs_real_def)
  show "a < b \<longleftrightarrow> a \<le> b \<and> \<not> b \<le> a"
    unfolding less_eq_real_def less_real_def
    by (auto, drule (1) positive_add, simp_all add: positive_zero)
  show "a \<le> a"
    unfolding less_eq_real_def by simp
  show "a \<le> b \<Longrightarrow> b \<le> c \<Longrightarrow> a \<le> c"
    unfolding less_eq_real_def less_real_def
    by (auto, drule (1) positive_add, simp add: algebra_simps)
  show "a \<le> b \<Longrightarrow> b \<le> a \<Longrightarrow> a = b"
    unfolding less_eq_real_def less_real_def
    by (auto, drule (1) positive_add, simp add: positive_zero)
  show "a \<le> b \<Longrightarrow> c + a \<le> c + b"
    unfolding less_eq_real_def less_real_def by auto
  show "sgn a = (if a = 0 then 0 else if 0 < a then 1 else - 1)"
    by (rule sgn_real_def)
  show "a \<le> b \<or> b \<le> a"
    unfolding less_eq_real_def less_real_def
    by (auto dest!: positive_minus)
  show "a < b \<Longrightarrow> 0 < c \<Longrightarrow> c * a < c * b"
    unfolding less_real_def
    by (drule (1) positive_mult, simp add: algebra_simps)
qed

end

instantiation real :: distrib_lattice
(* This instantiation directly copies from HOL/Real.thy *)
begin

definition "(inf :: real \<Rightarrow> real \<Rightarrow> real) = min"
definition "(sup :: real \<Rightarrow> real \<Rightarrow> real) = max"

instance proof
  qed (auto simp add: inf_real_def sup_real_def max_min_distrib2)

end

lemma of_nat_Real [rewrite_back]: "of_nat x = Real {rat_of_nat x}\<^sub>S"
  by (tactic {* auto2s_tac @{context} (CASE "x = 0") *})

lemma of_int_Real [rewrite_back]: "of_int x = Real {rat_of_int x}\<^sub>S"
  by (tactic {* auto2s_tac @{context} (CHOOSE "m, n, x = int m - int n") *})

lemma of_rat_Real [rewrite_back]: "of_rat x = Real {x}\<^sub>S"
  by (tactic {* auto2s_tac @{context} (CHOOSE "a, b, b > 0, x = Fract a b") *})

theorem le_real_def [rewrite]: "x \<le> y \<longleftrightarrow> \<not> positive (x - y)"
  using less_real_def not_le by blast

subsection {* Further properties on positivity and ordering *}

lemma not_positive_Real [rewrite]:
  "cauchy X \<Longrightarrow> \<not> positive (Real X) \<longleftrightarrow> (\<forall>r>0. \<exists>k. \<forall>n\<ge>k. X\<langle>n\<rangle> \<le> r)"
  by (tactic {* auto2s_tac @{context}
    (CASE "\<not>positive (Real X)" WITH (
       CHOOSE "r, r > 0, \<not>(\<exists>k. \<forall>n\<ge>k. X\<langle>n\<rangle> \<le> r)" THEN
       CHOOSE "s, t, s > 0, t > 0, r = s + t" THEN
       CHOOSE "i, \<forall>m\<ge>i. \<forall>n\<ge>i. \<bar>X\<langle>m\<rangle> - X\<langle>n\<rangle>\<bar> < s" THEN
       CHOOSE "k, k \<ge> i, t \<ge> X\<langle>k\<rangle>" THEN
       OBTAIN "\<forall>n\<ge>k. X\<langle>n\<rangle> \<le> r") THEN
     CASE "positive (Real X)" WITH (
       CHOOSE "r, r > 0, k, \<forall>n\<ge>k. r < X\<langle>n\<rangle>" THEN
       CHOOSE "k', \<forall>n\<ge>k'. X\<langle>n\<rangle> \<le> r" THEN
       OBTAIN "X \<langle>max k k'\<rangle> \<le> r" THEN OBTAIN "X \<langle>max k k'\<rangle> > r")) *})

lemma le_Real [rewrite]:
  "cauchy X \<Longrightarrow> cauchy Y \<Longrightarrow> Real X \<le> Real Y \<longleftrightarrow> (\<forall>r>0. \<exists>k. \<forall>n\<ge>k. (X - Y)\<langle>n\<rangle> \<le> r)"
  by (tactic {* auto2s_tac @{context}
    (OBTAIN "Real (X - Y) = Real X - Real Y" THEN OBTAIN "cauchy (X - Y)") *})
setup {* del_prfstep_thm @{thm le_real_def} *}

lemma le_Real_all_n [backward1]: "cauchy X \<and> cauchy Y \<Longrightarrow> \<forall>n. X\<langle>n\<rangle> \<le> Y\<langle>n\<rangle> \<Longrightarrow> Real X \<le> Real Y"
  by (tactic {* auto2s_tac @{context}
    (CHOOSE "r, r > 0, \<not>(\<exists>k. \<forall>n\<ge>k. (X - Y)\<langle>n\<rangle> \<le> r)" THEN
     OBTAIN "\<forall>n\<ge>0. (X - Y)\<langle>n\<rangle> \<le> r") *})

theorem archimedean_Real [backward]: "cauchy X \<Longrightarrow> \<exists>z. Real X \<le> of_int z"
  by (tactic {* auto2s_tac @{context}
    (CHOOSE "b, b > 0, \<forall>n. \<bar>X\<langle>n\<rangle>\<bar> \<le> b" THEN
     OBTAIN "rat_of_int \<lceil>b\<rceil> \<ge> b" THEN
     OBTAIN "of_int \<lceil>b\<rceil> = Real {rat_of_int \<lceil>b\<rceil>}\<^sub>S" THEN
     OBTAIN "\<forall>n. X\<langle>n\<rangle> \<le> {rat_of_int \<lceil>b\<rceil>}\<^sub>S \<langle>n\<rangle>" THEN
     OBTAIN "Real X \<le> Real {rat_of_int \<lceil>b\<rceil>}\<^sub>S") *})

instance real :: archimedean_field
proof
  fix x :: real show "\<exists>z. x \<le> of_int z"
    by (tactic {* auto2s_tac @{context} (CHOOSE "S, cauchy S \<and> x = Real S") *})
qed

instantiation real :: floor_ceiling
(* This instantiation directly copies from HOL/Real.thy *)
begin

definition [code del]:
  "floor (x::real) = (THE z. of_int z \<le> x \<and> x < of_int (z + 1))"

instance proof
  fix x :: real
  show "of_int (floor x) \<le> x \<and> x < of_int (floor x + 1)"
    unfolding floor_real_def using floor_exists1 by (rule theI')
qed

end

subsection {* Ordering on and distance between real numbers *}

theorem le_rat_Real [backward1]:
  "cauchy X \<and> r > 0 \<Longrightarrow> Real X \<le> of_rat c \<Longrightarrow> \<exists>k. \<forall>n\<ge>k. X\<langle>n\<rangle> \<le> c + r"
  by (tactic {* auto2s_tac @{context}
    (OBTAIN "of_rat c = Real {c}\<^sub>S" THEN
     CHOOSE "k, \<forall>n\<ge>k. (X - {c}\<^sub>S) \<langle>n\<rangle> \<le> r" THEN
     OBTAIN "\<forall>n\<ge>k. X\<langle>n\<rangle> \<le> c + r") *})

theorem diff_le_rat_Real [backward1]:
  "cauchy X \<and> cauchy Y \<and> r > 0 \<Longrightarrow> Real X - Real Y \<le> of_rat c \<Longrightarrow> \<exists>k. \<forall>n\<ge>k. (X - Y)\<langle>n\<rangle> \<le> c + r"
  by (tactic {* auto2s_tac @{context}
    (OBTAIN "Real (X - Y) = Real X - Real Y" THEN OBTAIN "cauchy (X - Y)") *})

theorem diff_le_rat_Real2 [backward1]:
  "cauchy X \<and> cauchy Y \<and> r > 0 \<Longrightarrow> Real X - Real Y \<le> of_rat c \<Longrightarrow> \<exists>k. \<forall>m\<ge>k. \<forall>n\<ge>k. X\<langle>m\<rangle> - Y\<langle>n\<rangle> \<le> c + r"
  by (tactic {* auto2s_tac @{context}
    (CHOOSE "s, t, s > 0, t > 0, r = s + t" THEN
     CHOOSE "i, \<forall>n\<ge>i. (X - Y)\<langle>n\<rangle> \<le> c + s" THEN
     CHOOSE "j, \<forall>m\<ge>j. \<forall>n\<ge>j. \<bar>X\<langle>m\<rangle> - X\<langle>n\<rangle>\<bar> < t" THEN
     OBTAIN_FORALL "m, m\<ge>max i j, n, n\<ge>max i j, X\<langle>m\<rangle> - Y\<langle>n\<rangle> \<le> c + r" WITH
      (OBTAIN "X\<langle>m\<rangle> - Y\<langle>n\<rangle> = X\<langle>m\<rangle> - X\<langle>n\<rangle> + X\<langle>n\<rangle> - Y\<langle>n\<rangle>")) *})

theorem abs_diff_le_rat_Real2D [backward1]:
  "cauchy X \<and> cauchy Y \<and> r > 0 \<Longrightarrow> \<bar>Real X - Real Y\<bar> \<le> of_rat c \<Longrightarrow> \<exists>k. \<forall>m\<ge>k. \<forall>n\<ge>k. \<bar>X\<langle>m\<rangle> - Y\<langle>n\<rangle>\<bar> \<le> c + r"
  by (tactic {* auto2s_tac @{context}
    (OBTAIN "Real X - Real Y \<le> of_rat c" THEN OBTAIN "Real Y - Real X \<le> of_rat c" THEN
     CHOOSE "i, \<forall>m\<ge>i. \<forall>n\<ge>i. X\<langle>m\<rangle> - Y\<langle>n\<rangle> \<le> c + r" THEN
     CHOOSE "j, \<forall>m\<ge>j. \<forall>n\<ge>j. Y\<langle>m\<rangle> - X\<langle>n\<rangle> \<le> c + r" THEN
     OBTAIN_FORALL "m, m\<ge>max i j, n, n\<ge>max i j, \<bar>X\<langle>m\<rangle> - Y\<langle>n\<rangle>\<bar> \<le> c + r") *})

theorem le_rat_RealI [backward2]:
  "cauchy X \<Longrightarrow> \<forall>r>0. \<exists>k. \<forall>n\<ge>k. X\<langle>n\<rangle> \<le> c + r \<Longrightarrow> Real X \<le> of_rat c"
  by (tactic {* auto2s_tac @{context}
    (OBTAIN "of_rat c = Real {c}\<^sub>S" THEN
     OBTAIN_FORALL "r, r > 0, \<exists>k. \<forall>n\<ge>k. (X - {c}\<^sub>S) \<langle>n\<rangle> \<le> r" WITH
      (CHOOSE "k, \<forall>n\<ge>k. X\<langle>n\<rangle> \<le> c + r" THEN
       OBTAIN "\<forall>n\<ge>k. (X - {c}\<^sub>S) \<langle>n\<rangle> \<le> r")) *})

theorem diff_le_rat_RealI [backward2]:
  "cauchy X \<Longrightarrow> cauchy Y \<and> (\<forall>r>0. \<exists>k. \<forall>n\<ge>k. (X - Y)\<langle>n\<rangle> \<le> c + r) \<Longrightarrow> Real X - Real Y \<le> of_rat c"
  by (tactic {* auto2s_tac @{context}
    (OBTAIN "Real (X - Y) = Real X - Real Y" THEN OBTAIN "cauchy (X - Y)") *})

theorem abs_diff_le_rat_RealI [backward2]:
  "cauchy X \<Longrightarrow> cauchy Y \<and> (\<forall>r>0. \<exists>k. \<forall>n\<ge>k. \<bar>X\<langle>n\<rangle> - Y\<langle>n\<rangle>\<bar> \<le> c + r) \<Longrightarrow> \<bar>Real X - Real Y\<bar> \<le> of_rat c"
  by (tactic {* auto2s_tac @{context}
    (OBTAIN "Real X - Real Y \<le> of_rat c" WITH
      (CHOOSE "r, r > 0, \<not>(\<exists>k. \<forall>n\<ge>k. (X - Y)\<langle>n\<rangle> \<le> c + r)" THEN
       CHOOSE "k, \<forall>n\<ge>k. \<bar>X\<langle>n\<rangle> - Y\<langle>n\<rangle>\<bar> \<le> c + r" THEN
       OBTAIN "\<forall>n\<ge>k. (X - Y)\<langle>n\<rangle> \<le> c + r") THEN
     OBTAIN "Real Y - Real X \<le> of_rat c" WITH
      (CHOOSE "r, r > 0, \<not>(\<exists>k. \<forall>n\<ge>k. (Y - X)\<langle>n\<rangle> \<le> c + r)" THEN
       CHOOSE "k, \<forall>n\<ge>k. \<bar>X\<langle>n\<rangle> - Y\<langle>n\<rangle>\<bar> \<le> c + r" THEN
       OBTAIN "\<forall>n\<ge>k. (Y - X)\<langle>n\<rangle> \<le> c + r")) *})

theorem abs_diff_le_rat_RealI' [backward2]:
  "cauchy X \<Longrightarrow> cauchy Y \<and> (\<exists>k. \<forall>n\<ge>k. \<bar>X\<langle>n\<rangle> - Y\<langle>n\<rangle>\<bar> < c) \<Longrightarrow> \<bar>Real X - Real Y\<bar> \<le> of_rat c"
  by (tactic {* auto2s_tac @{context}
    (CHOOSE "r, r > 0, \<not>(\<exists>k. \<forall>n\<ge>k. \<bar>X\<langle>n\<rangle> - Y\<langle>n\<rangle>\<bar> \<le> c + r)" THEN
     CHOOSE "k, \<forall>n\<ge>k. \<bar>X\<langle>n\<rangle> - Y\<langle>n\<rangle>\<bar> < c" THEN
     OBTAIN "\<forall>n\<ge>k. \<bar>X\<langle>n\<rangle> - Y\<langle>n\<rangle>\<bar> \<le> c + r") *})

subsection {* Convergence of sequences, limits *}

definition converges_to :: "('a::linordered_field) seq \<Rightarrow> 'a \<Rightarrow> bool" where
  "converges_to X s = (\<forall>r>0. \<exists>k. \<forall>n\<ge>k. \<bar>X\<langle>n\<rangle> - s\<bar> < r)"
theorem converges_to_elim [backward2]: "converges_to X s \<Longrightarrow> r > 0 \<Longrightarrow> \<exists>k. \<forall>n\<ge>k. \<bar>X\<langle>n\<rangle> - s\<bar> < r"
  by (simp add: converges_to_def)
setup {* add_backward_prfstep (equiv_backward_th @{thm converges_to_def}) *}

(* In archimedean fields, suffice to check for rational numbers. *)

theorem ex_inverse_of_rat [backward]: "(c::('a::archimedean_field)) > 0 \<Longrightarrow> \<exists>r>0. of_rat r < c"
  by (tactic {* auto2s_tac @{context}
    (CHOOSE "n, n > 0, inverse (of_nat n) < c" THEN
     OBTAIN "of_rat (inverse (of_nat n)) < c") *})

theorem converges_to_in_rat [backward]:
  "\<forall>r>0. \<exists>k. \<forall>n\<ge>k. \<bar>X\<langle>n\<rangle> - s\<bar> \<le> of_rat r \<Longrightarrow> converges_to X (s::('a::archimedean_field))"
  by (tactic {* auto2s_tac @{context}
    (CHOOSE "r, r > 0, \<not>(\<exists>k. \<forall>n\<ge>k. \<bar>X\<langle>n\<rangle> - s\<bar> < r)" THEN
     CHOOSE "r', r' > 0, of_rat r' < r" THEN
     CHOOSE "k, \<forall>n\<ge>k. \<bar>X\<langle>n\<rangle> - s\<bar> \<le> of_rat r'" THEN
     OBTAIN "\<forall>n\<ge>k. \<bar>X\<langle>n\<rangle> - s\<bar> < r") *})

theorem lt_limit [backward2]: "converges_to X x \<Longrightarrow> y < x \<Longrightarrow> \<exists>n. y < X\<langle>n\<rangle>"
  by (tactic {* auto2s_tac @{context}
    (CHOOSE "k, \<forall>n\<ge>k. \<bar>X\<langle>n\<rangle> - x\<bar> < x - y" THEN  (* Can simplify one line *)
     OBTAIN "\<bar>X\<langle>k\<rangle> - x\<bar> < x - y" THEN OBTAIN "y < X\<langle>k\<rangle>") *})

theorem gt_limit [backward2]: "converges_to X x \<Longrightarrow> y > x \<Longrightarrow> \<exists>n. y > X\<langle>n\<rangle>"
  by (tactic {* auto2s_tac @{context}
    (CHOOSE "k, \<forall>n\<ge>k. \<bar>X\<langle>n\<rangle> - x\<bar> < y - x" THEN
     OBTAIN "\<bar>X\<langle>k\<rangle> - x\<bar> < y - x" THEN OBTAIN "y > X\<langle>k\<rangle>") *})

theorem limit_equal [forward]: "vanishes (X - Y) \<Longrightarrow> converges_to X x \<Longrightarrow> converges_to Y x"
  by (tactic {* auto2s_tac @{context}
    (CHOOSE "r, r > 0, \<not>(\<exists>k. \<forall>n\<ge>k. \<bar>Y\<langle>n\<rangle> - x\<bar> < r)" THEN
     CHOOSE "s, t, s > 0, t > 0, r = s + t" THEN
     CHOOSE "i, \<forall>n\<ge>i. \<bar>(X - Y)\<langle>n\<rangle>\<bar> < s" THEN
     CHOOSE "j, \<forall>n\<ge>j. \<bar>X\<langle>n\<rangle> - x\<bar> < t" THEN
     OBTAIN_FORALL "n, n \<ge> max i j, \<bar>Y\<langle>n\<rangle> - x\<bar> < r") *})

theorem limit_unique [forward]: "converges_to X x \<Longrightarrow> converges_to X y \<Longrightarrow> x = y"
  by (tactic {* auto2s_tac @{context}
    (CHOOSE "s, t, s > 0, t > 0, \<bar>x - y\<bar> = s + t" THEN
     CHOOSE "i, \<forall>n\<ge>i. \<bar>X\<langle>n\<rangle> - x\<bar> < s" THEN
     CHOOSE "j, \<forall>n\<ge>j. \<bar>X\<langle>n\<rangle> - y\<bar> < t" THEN
     CHOOSE "k, k = max i j" THEN OBTAIN "\<bar>X\<langle>k\<rangle> - x\<bar> < s \<and> \<bar>X\<langle>k\<rangle> - y\<bar> < t" THEN
     OBTAIN "\<bar>x - y\<bar> < s + t") *})

subsection {* Cauchy completeness *}

(* First step: define a positive rational sequence converging to zero. *)

definition err :: "nat \<Rightarrow> rat" where "err n = inverse (of_nat (n + 1))"
setup {* add_rewrite_rule @{thm err_def} *}

theorem err_gt_zero: "err n > 0" by (simp add: err_def)
setup {* add_forward_prfstep_cond @{thm err_gt_zero} [with_term "err ?n"] *}

theorem err_less_than_r [backward]:
  "r > 0 \<Longrightarrow> \<exists>n. err n < r" using ex_inverse_of_nat_Suc_less err_def by simp

theorem err_decreasing [backward]: "m > n \<Longrightarrow> err m < err n"
  by (tactic {* auto2s_tac @{context} (OBTAIN "rat_of_nat (m + 1) > rat_of_nat (n + 1)") *})

theorem err_converge_to_zero [backward]: "r > 0 \<Longrightarrow> \<exists>k. \<forall>n\<ge>k. err n < r"
  by (tactic {* auto2s_tac @{context}
    (CHOOSE "k, err k < r" THEN OBTAIN_FORALL "n, n\<ge>k, err n < r" WITH OBTAIN "err n < err k") *})
setup {* del_prfstep_thm @{thm err_def} *}

(* Now the main proof. *)

theorem obtain_pos_sum3 [backward]:
  "(r::('a::linordered_field)) > 0 \<Longrightarrow> \<exists>r1 r2 r3. r1 > 0 \<and> r2 > 0 \<and> r3 > 0 \<and> r = r1 + r1 + r2 + r3"
  by (tactic {* auto2s_tac @{context} (OBTAIN "r = r/4 + r/4 + r/4 + r/4") *})

theorem real_complete [resolve]: "cauchy (R::real seq) \<Longrightarrow> \<exists>x. converges_to R x"
  by (tactic {* auto2s_tac @{context} (
    CHOOSE "S, \<forall>n. cauchy (S\<langle>n\<rangle>) \<and> R\<langle>n\<rangle> = Real (S\<langle>n\<rangle>)" THEN
    OBTAIN_FORALL "n, \<exists>k. (\<forall>i\<ge>k. \<bar>S\<langle>n\<rangle>\<langle>i\<rangle> - S\<langle>n\<rangle>\<langle>k\<rangle>\<bar> < err n)" WITH OBTAIN "cauchy (S\<langle>n\<rangle>)" THEN
    CHOOSE "S', \<forall>n. \<exists>k. (\<forall>i\<ge>k. \<bar>S\<langle>n\<rangle>\<langle>i\<rangle> - S\<langle>n\<rangle>\<langle>k\<rangle>\<bar> < err n) \<and> S'\<langle>n\<rangle> = S\<langle>n\<rangle>\<langle>k\<rangle>" THEN
    OBTAIN "cauchy S'" WITH
      (CHOOSE "r, r > 0, \<not>(\<exists>k. \<forall>m\<ge>k. \<forall>n\<ge>k. \<bar>S'\<langle>m\<rangle> - S'\<langle>n\<rangle>\<bar> < r)" THEN
       CHOOSE "r1, r2, r3, r1 > 0, r2 > 0, r3 > 0, r = r1 + r1 + r2 + r3" THEN
       CHOOSE "i, \<forall>n\<ge>i. err n < r1" THEN
       CHOOSE "j, \<forall>m\<ge>j. \<forall>n\<ge>j. \<bar>R\<langle>m\<rangle> - R\<langle>n\<rangle>\<bar> \<le> of_rat r2" THEN
       OBTAIN_FORALL "m, m\<ge>max i j, n, n\<ge>max i j, \<bar>S'\<langle>m\<rangle> - S'\<langle>n\<rangle>\<bar> < r" WITH
        (CHOOSE "k1, (\<forall>k'\<ge>k1. \<bar>S\<langle>m\<rangle>\<langle>k'\<rangle> - S\<langle>m\<rangle>\<langle>k1\<rangle>\<bar> < err m) \<and> S'\<langle>m\<rangle> = S\<langle>m\<rangle>\<langle>k1\<rangle>" THEN
         CHOOSE "k2, (\<forall>k'\<ge>k2. \<bar>S\<langle>n\<rangle>\<langle>k'\<rangle> - S\<langle>n\<rangle>\<langle>k2\<rangle>\<bar> < err n) \<and> S'\<langle>n\<rangle> = S\<langle>n\<rangle>\<langle>k2\<rangle>" THEN
         CHOOSE "k3, \<forall>k'\<ge>k3. \<forall>k''\<ge>k3. \<bar>S\<langle>m\<rangle>\<langle>k'\<rangle> - S\<langle>n\<rangle>\<langle>k''\<rangle>\<bar> \<le> r2 + r3" THEN
         CHOOSE "k4, k4 \<ge> k1 \<and> k4 \<ge> k2 \<and> k4 \<ge> k3" THEN
         OBTAIN "\<bar>S\<langle>n\<rangle>\<langle>k4\<rangle> - S'\<langle>m\<rangle>\<bar> < err m + r2 + r3" THEN
         OBTAIN "\<bar>S'\<langle>m\<rangle> - S'\<langle>n\<rangle>\<bar> < err m + err n + r2 + r3")) THEN
    OBTAIN "converges_to R (Real S')" WITH
     (CHOOSE "r, r > 0, \<not>(\<exists>k. \<forall>n\<ge>k. \<bar>R\<langle>n\<rangle> - Real S'\<bar> \<le> of_rat r)" THEN
      CHOOSE "r1, r2, r1 > 0, r2 > 0, r = r1 + r2" THEN
      CHOOSE "i, \<forall>n\<ge>i. err n < r1" THEN
      CHOOSE "j, \<forall>m\<ge>j. \<forall>n\<ge>j. \<bar>S'\<langle>m\<rangle> - S'\<langle>n\<rangle>\<bar> < r2" THEN
      OBTAIN_FORALL "n, n\<ge>max i j, \<bar>R\<langle>n\<rangle> - Real S'\<bar> \<le> of_rat r" WITH
       (CHOOSE "k1, (\<forall>k'\<ge>k1. \<bar>S\<langle>n\<rangle>\<langle>k'\<rangle> - S\<langle>n\<rangle>\<langle>k1\<rangle>\<bar> < err n) \<and> S'\<langle>n\<rangle> = S\<langle>n\<rangle>\<langle>k1\<rangle>" THEN
        OBTAIN_FORALL "p, p\<ge>max k1 j, \<bar>S\<langle>n\<rangle>\<langle>p\<rangle> - S'\<langle>p\<rangle>\<bar> < r"))) *})

subsection {* Monotone convergence theorem *}

lemma induct_diff [backward1]: "(a::('a::linordered_idom)) > 0 \<Longrightarrow> \<forall>k. \<exists>n\<ge>k. X\<langle>n\<rangle> - X\<langle>k\<rangle> \<ge> a \<Longrightarrow>
  \<exists>n\<ge>k. X\<langle>n\<rangle> - X\<langle>k\<rangle> \<ge> (of_nat N) * a"
  by (tactic {* auto2s_tac @{context}
    (CASE "N = 0" WITH CHOOSE "n, n \<ge> k, X\<langle>n\<rangle> - X\<langle>k\<rangle> \<ge> a" THEN
     INDUCT ("N", [OnFact "N \<noteq> 0"]) THEN
     CHOOSE "n1, n1 \<ge> k, X\<langle>n1\<rangle> - X\<langle>k\<rangle> \<ge> of_nat (N - 1) * a" THEN
     CHOOSE "n2, n2 \<ge> n1, X\<langle>n2\<rangle> - X\<langle>n1\<rangle> \<ge> a") *})

theorem monotone_cauchy [backward2]:
  "monotone_incr (X::('a::archimedean_field) seq) \<Longrightarrow> upper_bounded X \<Longrightarrow> cauchy X"
  by (tactic {* auto2s_tac @{context}
    (CHOOSE "a, a > 0, \<forall>k. \<exists>n\<ge>k. \<bar>X\<langle>n\<rangle> - X\<langle>k\<rangle>\<bar> \<ge> a" THEN
     OBTAIN_FORALL "k, \<exists>n\<ge>k. X\<langle>n\<rangle> - X\<langle>k\<rangle> \<ge> a" WITH
      (CHOOSE "n, n \<ge> k, \<bar>X\<langle>n\<rangle> - X\<langle>k\<rangle>\<bar> \<ge> a" THEN OBTAIN "X\<langle>n\<rangle> \<ge> X\<langle>k\<rangle>") THEN
     CHOOSE "M, \<forall>n. X\<langle>n\<rangle> \<le> M" THEN
     CHOOSE "N, (of_nat N) * a > (M - X\<langle>0\<rangle>)" THEN
     CHOOSE "n, n \<ge> 0, X\<langle>n\<rangle> - X\<langle>0\<rangle> \<ge> (of_nat N) * a" THEN OBTAIN "X\<langle>n\<rangle> \<le> M") *})

theorem monotone_convergence [backward2]:
  "monotone_incr (X::real seq) \<Longrightarrow> upper_bounded X \<Longrightarrow> \<exists>x. converges_to X x"
  by (tactic {* auto2s_tac @{context} (OBTAIN "cauchy X") *})

theorem monotone_decr_cauchy [backward2]:
  "monotone_decr (X::('a::archimedean_field) seq) \<Longrightarrow> lower_bounded X \<Longrightarrow> cauchy X"
  by (tactic {* auto2s_tac @{context} (OBTAIN "monotone_incr (-X)" THEN OBTAIN "cauchy (-X)") *})

theorem monotone_decr_convergence [backward2]:
  "monotone_decr (X::real seq) \<Longrightarrow> lower_bounded X \<Longrightarrow> \<exists>x. converges_to X x"
  by (tactic {* auto2s_tac @{context} (OBTAIN "cauchy X") *})

subsection {* Dedekind cut completeness *}

theorem half_seq_induct [resolve]:
  "\<forall>n. \<bar>(X::('a::linordered_field) seq)\<langle>n+1\<rangle>\<bar> \<le> \<bar>X\<langle>n\<rangle>\<bar> / 2 \<Longrightarrow> \<bar>X\<langle>n\<rangle>\<bar> \<le> \<bar>X\<langle>0\<rangle>\<bar> / (2 ^ n)"
  by (tactic {* auto2s_tac @{context}
    (CASE "n = 0" THEN OBTAIN "n = (n-1) + 1" THEN OBTAIN "\<bar>X\<langle>n\<rangle>\<bar> \<le> \<bar>X\<langle>n-1\<rangle>\<bar> / 2") *})

theorem half_seq_abs_decr [backward2]:
  "\<forall>n. \<bar>(X::('a::linordered_field) seq)\<langle>n+1\<rangle>\<bar> \<le> \<bar>X\<langle>n\<rangle>\<bar> / 2 \<Longrightarrow> n' \<ge> n \<Longrightarrow> \<bar>X\<langle>n'\<rangle>\<bar> \<le> \<bar>X\<langle>n\<rangle>\<bar>"
  by (tactic {* auto2s_tac @{context}
    (OBTAIN_FORALL "k, \<bar>X\<langle>k+1\<rangle>\<bar> \<le> \<bar>X\<langle>k\<rangle>\<bar>" WITH OBTAIN "\<bar>X\<langle>k+1\<rangle>\<bar> \<le> \<bar>X\<langle>k\<rangle>\<bar> / 2") *})

theorem nat_less_two_power [resolve]: "n < (2::nat) ^ n"
  by (tactic {* auto2s_tac @{context}
    (CASE "n = 0" THEN OBTAIN "(n - 1) + 1 < (2::nat) ^ (n-1) + 2 ^ (n-1)") *})

theorem two_power_no_bound [resolve]: "\<exists>n. 2 ^ n > (M::('a::archimedean_field))"
  by (tactic {* auto2s_tac @{context}
    (CHOOSE "n, of_nat n > M" THEN OBTAIN "of_nat (2 ^ n) > M") *})

theorem half_seq_vanishes [resolve]:
  "\<forall>n. \<bar>(X::('a::archimedean_field) seq)\<langle>n+1\<rangle>\<bar> \<le> \<bar>X\<langle>n\<rangle>\<bar> / 2 \<Longrightarrow> vanishes X"
  by (tactic {* auto2s_tac @{context}
    (CHOOSE "r, r > 0, \<not>(\<exists>k. \<forall>n\<ge>k. \<bar>X\<langle>n\<rangle>\<bar> < r)" THEN
     CHOOSE "k, 2 ^ k > \<bar>X\<langle>0\<rangle>\<bar> / r" THEN
     OBTAIN_FORALL "n, n \<ge> k, \<bar>X\<langle>n\<rangle>\<bar> < r" WITH OBTAIN "\<bar>X\<langle>k\<rangle>\<bar> \<le> \<bar>X\<langle>0\<rangle>\<bar> / (2 ^ k)") *})

(* Definition of Dedekind cut: third part is closed downwards condition,
   fourth part is no greatest element condition. *)
definition dedekind_cut :: "('a::linorder) set \<Rightarrow> bool" where
  "dedekind_cut U \<longleftrightarrow> (U \<noteq> {}) \<and> (U \<noteq> UNIV) \<and> (\<forall>a\<in>U. \<forall>b\<le>a. b \<in> U) \<and> (\<forall>a\<in>U. \<exists>b>a. b \<in> U)"
setup {* add_rewrite_rule @{thm dedekind_cut_def} *}

theorem dedekind_cutI1 [forward]:
  "dedekind_cut U \<Longrightarrow> U \<noteq> {} \<and> U \<noteq> UNIV \<and> (\<forall>a\<in>U. \<forall>b\<le>a. b \<in> U)" by auto2
theorem dedekind_cutI2 [backward2]:
  "dedekind_cut U \<Longrightarrow> a \<in> U \<Longrightarrow> \<exists>b>a. b \<in> U" by auto2
setup {* del_prfstep_thm @{thm dedekind_cut_def} #> add_backward_prfstep (equiv_backward_th @{thm dedekind_cut_def}) *}

theorem dedekind_cut_compl_closed_upward [forward]: "dedekind_cut U \<Longrightarrow> a \<notin> U \<Longrightarrow> \<forall>b>a. b \<notin> U" by auto2

theorem dedekind_complete [resolve]: "dedekind_cut (U::real set) \<Longrightarrow> \<exists>x. \<forall>y. y < x \<longleftrightarrow> y \<in> U"
  by (tactic {* auto2s_tac @{context}
    (CHOOSE "a0, a0 \<in> U" THEN CHOOSE "b0, b0 \<notin> U" THEN OBTAIN "a0 \<le> b0" THEN
     CHOOSE ("A, B, A\<langle>0\<rangle> = a0, B\<langle>0\<rangle> = b0," ^
                   "\<forall>n. A\<langle>n+1\<rangle> = (if (A\<langle>n\<rangle>+B\<langle>n\<rangle>)/2 \<notin> U then A\<langle>n\<rangle> else (A\<langle>n\<rangle>+B\<langle>n\<rangle>)/2)," ^
                   "\<forall>n. B\<langle>n+1\<rangle> = (if (A\<langle>n\<rangle>+B\<langle>n\<rangle>)/2 \<notin> U then (A\<langle>n\<rangle>+B\<langle>n\<rangle>)/2 else B\<langle>n\<rangle>)") THEN
     OBTAIN_FORALL "n, A\<langle>n\<rangle> \<in> U" WITH CASE "n = 0" THEN
     OBTAIN_FORALL "n, B\<langle>n\<rangle> \<notin> U" WITH CASE "n = 0" THEN
     OBTAIN_FORALL "n, A\<langle>n\<rangle> \<le> B\<langle>n\<rangle>" WITH CASE "n = 0" THEN
     OBTAIN "monotone_incr A" THEN OBTAIN "monotone_decr B" THEN
     OBTAIN_FORALL "n, A\<langle>n\<rangle> \<le> B\<langle>0\<rangle>" THEN OBTAIN_FORALL "n, B\<langle>n\<rangle> \<ge> A\<langle>0\<rangle>" THEN
     OBTAIN_FORALL "n, \<bar>(B - A)\<langle>n+1\<rangle>\<bar> \<le> \<bar>(B - A)\<langle>n\<rangle>\<bar> / 2" THEN
     OBTAIN "vanishes (A - B)" THEN
     CHOOSE "x, converges_to A x" THEN OBTAIN "converges_to B x" THEN
     OBTAIN_FORALL "y, y < x \<longleftrightarrow> y \<in> U" WITH
      (CASE "y < x" WITH CHOOSE "n, y < A\<langle>n\<rangle>" THEN
       OBTAIN "x \<in> U" THEN CHOOSE "x', x' > x, x' \<in> U" THEN
       CHOOSE "n, x' > B\<langle>n\<rangle>" THEN OBTAIN "B\<langle>n\<rangle> \<notin> U")) *})

subsection {* Least upper bound property *}

setup {* add_resolve_prfstep (equiv_forward_th @{thm bdd_above_def}) *}
definition upper_bound :: "('a::linorder) set \<Rightarrow> 'a \<Rightarrow> bool" where
  "upper_bound S x \<longleftrightarrow> (\<forall>y\<in>S. x \<ge> y)"
setup {* add_rewrite_rule @{thm upper_bound_def} *}

theorem complete_real [backward1]: "(S::real set) \<noteq> {} \<Longrightarrow> upper_bound S z \<Longrightarrow>
  \<exists>y. upper_bound S y \<and> (\<forall>z. upper_bound S z \<longrightarrow> y \<le> z)"
  by (tactic {* auto2s_tac @{context}
    (CHOOSE "U, U = {x. \<not> upper_bound S x}" THEN
     OBTAIN "dedekind_cut U" WITH
      (OBTAIN "U \<noteq> {}" WITH (CHOOSE "x, x \<in> S" THEN CHOOSE "y, y < x" THEN OBTAIN "y \<in> U") THEN
       OBTAIN "U \<noteq> UNIV" WITH OBTAIN "z \<notin> U" THEN
       OBTAIN "\<forall>u\<in>U. \<forall>v\<le>u. v \<in> U" THEN
       OBTAIN_FORALL "a, a \<in> U, \<exists>b>a. b \<in> U" WITH
        (CHOOSE "c, c \<in> S, a < c" THEN CHOOSE "b, a < b \<and> b < c" THEN OBTAIN "b \<in> U")) THEN
     CHOOSE "y, \<forall>z. z < y \<longleftrightarrow> z \<in> U" THEN
     OBTAIN "y \<notin> U" THEN OBTAIN "upper_bound S y") *})

theorem Sup_real_prop: "x \<in> (S::real set) \<Longrightarrow> bdd_above S \<Longrightarrow>
  x \<le> (LEAST y. upper_bound S y) \<and> (\<forall>z. upper_bound S z \<longrightarrow> (LEAST y. upper_bound S y) \<le> z)"
  by (tactic {* auto2s_tac @{context}
    (OBTAIN "S \<noteq> {}" THEN CHOOSE "z, \<forall>x\<in>S. x \<le> z" THEN OBTAIN "upper_bound S z" THEN
     CHOOSE "y, upper_bound S y, \<forall>z. upper_bound S z \<longrightarrow> y \<le> z" THEN
     OBTAIN "(LEAST y. upper_bound S y) = y") *})

instantiation real :: linear_continuum
(* Part of the proof copies from HOL/Real.thy *)
begin

definition "Sup X = (LEAST z::real. upper_bound X z)"
definition "Inf (X::real set) = - Sup (uminus ` X)"

instance proof
  { fix x :: real and X :: "real set"
    assume "x \<in> X" "bdd_above X"
    then show "x \<le> Sup X" by (simp add: Sup_real_def Sup_real_prop) }
  note Sup_upper = this

  { fix z :: real and X :: "real set"
    assume "X \<noteq> {}" and "\<And>x. x \<in> X \<Longrightarrow> x \<le> z"
    then show "Sup X \<le> z"
    by (smt non_empty_exist_elt upper_bound_def bdd_above_def Sup_real_def Sup_real_prop) }
  note Sup_least = this

  { fix x :: real and X :: "real set" assume x: "x \<in> X" "bdd_below X" then show "Inf X \<le> x"
      using Sup_upper[of "-x" "uminus ` X"] by (auto simp: Inf_real_def) }
  { fix z :: real and X :: "real set" assume "X \<noteq> {}" "\<And>x. x \<in> X \<Longrightarrow> z \<le> x" then show "z \<le> Inf X"
      using Sup_least[of "uminus ` X" "- z"] by (force simp: Inf_real_def) }
  show "\<exists>a b::real. a \<noteq> b"
    using zero_neq_one by blast
qed

end

end
