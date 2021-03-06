(*
  File: Cardinal.thy
  Author: Bohua Zhan

  Results about cardinals. Based on OrderType and Cardinal in Isabelle/ZF.
*)

theory Cardinal
  imports Finite WellOrder
begin

section \<open>Least ordinal satisfying a property\<close>

(* Least ordinal satisfying property P. *)
definition least_ord :: "(i \<Rightarrow> o) \<Rightarrow> i"  (binder "\<mu> " 10) where [rewrite]:
  "(\<mu> i. P(i)) = (THE i. ord(i) \<and> P(i) \<and> (\<forall>j\<in>i. \<not>P(j)))"

(* Show the definition of least_ord make sense. *)
lemma least_ord_eq [backward]:
  "P(i) \<Longrightarrow> ord(i) \<Longrightarrow> \<forall>x\<in>i. \<not>P(x) \<Longrightarrow> (\<mu> i. P(i)) = i"
@proof
  @have "\<forall>j. P(j) \<longrightarrow> ord(j) \<longrightarrow> (\<forall>y\<in>j. \<not>P(y)) \<longrightarrow> j = i" @with
    @have (@rule) "i \<in> j \<or> i = j \<or> j \<in> i"
  @end
@qed

definition le_ord :: "i \<Rightarrow> i \<Rightarrow> o"  (infix "\<le>\<^sub>O" 50) where [rewrite]:
  "i \<le>\<^sub>O j \<longleftrightarrow> (i \<in> j \<or> i = j)"

lemma least_ord_le [backward]:
  "P(i) \<Longrightarrow> ord(i) \<Longrightarrow> (\<mu> i. P(i)) \<le>\<^sub>O i"
@proof
  @induct "ord(i)" "P(i) \<longrightarrow> (\<mu> i. P(i)) \<le>\<^sub>O i"
@qed

lemma least_ord_prop:
  "ord(i) \<Longrightarrow> P(i) \<Longrightarrow> P(\<mu> i. P(i))"
@proof
  @induct "ord(i)" "\<not>P(i) \<or> P(\<mu> i. P(i))" @with
    @subgoal "\<not>P(x) \<or> P(\<mu> i. P(i))"
      @contradiction
      @have "(\<mu> i. P(i)) = x"
    @endgoal
  @end
@qed
setup {* add_forward_prfstep_cond @{thm least_ord_prop} [with_term "\<mu> i. ?P(i)"] *}

lemma ord_least_is_ord [backward]:
  "\<exists>i. ord(i) \<and> P(i) \<Longrightarrow> ord(\<mu> i. P(i))"
@proof
  @obtain i where "ord(i)" "P(i)"
  @have "(\<mu> i. P(i)) \<le>\<^sub>O i"
@qed

section \<open>Order type and order map\<close>

(* In this section, we construct an ordinal from any well-ordering on a set. *)

definition Tup_image :: "i \<Rightarrow> i \<Rightarrow> i" where [rewrite]:
  "Tup_image(f,S) = {f`x. x \<in> S}"

(* Order map: given a well-founded relation r, and an element x in source(r),
   construct the ordinal corresponding to x. This is simply the collection
   of ordermap(r,y), where y < x under r.
*)
definition ordermap :: "i \<Rightarrow> i \<Rightarrow> i" where [rewrite]:
  "ordermap(r,x) = wfrec(r, \<lambda>x f. Tup_image(f,ord_pred(r,x)), x)"

lemma ordermap_eq [rewrite]:
  "wf(r) \<Longrightarrow> x \<in>. r \<Longrightarrow> ordermap(r,x) = {ordermap(r,y). y \<in> ord_pred(r,x)}" by auto2
setup {* del_prfstep_thm @{thm ordermap_def} *}

lemma ord_ordermap:
  "wf(r) \<Longrightarrow> trans(r) \<Longrightarrow> x \<in>. r \<Longrightarrow> ord(ordermap(r,x))" by auto2
setup {* add_forward_prfstep_cond @{thm ord_ordermap} [with_term "ordermap(?r,?x)"] *}

(* The image of ordermap. *)
definition ordertype :: "i \<Rightarrow> i" where [rewrite]:
  "ordertype(r) = {ordermap(r,x). x \<in>. r}"

lemma ord_ordertype [forward]:
  "wf(r) \<Longrightarrow> trans(r) \<Longrightarrow> ord(ordertype(r))" by auto2

definition ordermap_fun :: "i \<Rightarrow> i" where [rewrite]:
  "ordermap_fun(r) = Fun(carrier(r),ordertype(r), \<lambda>x. ordermap(r,x))"

lemma ordermap_fun_type [typing]:
  "ordermap_fun(r) \<in> carrier(r) \<rightarrow> ordertype(r)" by auto2

lemma ordermap_fun_eval [rewrite]:
  "x \<in> source(ordermap_fun(r)) \<Longrightarrow> ordermap_fun(r)`x = ordermap(r,x)" by auto2
setup {* del_prfstep_thm @{thm ordermap_fun_def} *}

lemma ordermap_inj [forward]:
  "well_order(r) \<Longrightarrow> injective(ordermap_fun(r))"
@proof
  @let "f = ordermap_fun(r)"
  @have "\<forall>x\<in>.r. \<forall>y\<in>.r. x \<noteq> y \<longrightarrow> f`x \<noteq> f`y" @with
    @case "x \<le>\<^sub>r y" @with
      @have "ordermap(r,x) \<in> ordermap(r,y)"
    @end
    @case "y \<le>\<^sub>r x" @with
      @have "ordermap(r,y) \<in> ordermap(r,x)"
    @end
  @end
@qed

lemma ordermap_bij [forward]:
  "well_order(r) \<Longrightarrow> bijective(ordermap_fun(r))"
  by auto2

section \<open>Cardinals\<close>

definition cardinal :: "i \<Rightarrow> i" where [rewrite]:
  "cardinal(A) = (\<mu> i. i \<approx>\<^sub>S A)"

definition card :: "i \<Rightarrow> o" where [rewrite]:
  "card(i) \<longleftrightarrow> (i = cardinal(i))"

section \<open>Basic properties of cardinals\<close>

(* Without assuming axiom of choice *)
lemma cardinal_equipotent_gen [resolve]:
  "well_order(r) \<Longrightarrow> A = carrier(r) \<Longrightarrow> A \<approx>\<^sub>S cardinal(A)"
@proof
  @let "i = ordertype(r)"
  @have "A \<approx>\<^sub>S i" @with
    @have "ordermap_fun(r) \<in> A \<cong> ordertype(r)"
  @end
@qed

lemma card_is_ordinal_gen:
  "well_order(r) \<Longrightarrow> A = carrier(r) \<Longrightarrow> ord(cardinal(A))"
@proof
  @let "i = ordertype(r)"
  @have "A \<approx>\<^sub>S i" @with
    @have "ordermap_fun(r) \<in> A \<cong> ordertype(r)"
  @end
@qed
setup {* add_forward_prfstep_cond @{thm card_is_ordinal_gen} [with_term "cardinal(?A)"] *}

lemma cardinal_cong_gen [resolve]:
  "well_order(r) \<Longrightarrow> well_order(s) \<Longrightarrow> A = carrier(r) \<Longrightarrow> B = carrier(s) \<Longrightarrow>
   A \<approx>\<^sub>S B \<Longrightarrow> cardinal(A) = cardinal(B)"
@proof
  @have "A \<approx>\<^sub>S cardinal(A)"
  @have "B \<approx>\<^sub>S cardinal(B)"
  @have "cardinal(A) \<le>\<^sub>O cardinal(B)"
  @have "cardinal(B) \<le>\<^sub>O cardinal(A)"
@qed

(* With axiom of choice. Will make this assumption from now on. *)
lemma cardinal_equipotent [resolve]:
  "A \<approx>\<^sub>S cardinal(A)"
@proof
  @obtain "R\<in>raworder_space(A)" where "well_order(R)"
@qed

lemma card_is_ordinal [forward]:
  "ord(cardinal(A))"
@proof
  @obtain "R\<in>raworder_space(A)" where "well_order(R)"
@qed

lemma cardinal_from_cong [resolve]:
  "A \<approx>\<^sub>S B \<Longrightarrow> cardinal(A) = cardinal(B)"
@proof
  @obtain "R\<in>raworder_space(A)" where "well_order(R)"
  @obtain "S\<in>raworder_space(B)" where "well_order(S)"
@qed

lemma card_is_cardinal [forward]:
  "card(cardinal(A))"
@proof @have "A \<approx>\<^sub>S cardinal(A)" @qed

lemma cardinal_to_cong [resolve]:
  "cardinal(A) = cardinal(B) \<Longrightarrow> A \<approx>\<^sub>S B"
@proof
  @have "A \<approx>\<^sub>S cardinal(A)"
  @have "B \<approx>\<^sub>S cardinal(B)"
@qed

section \<open>Two successor function for cardinals\<close>

definition pow_cardinal :: "i \<Rightarrow> i" where [rewrite]:
  "pow_cardinal(K) = cardinal(Pow(K))"

lemma pow_cardinal_is_cardinal [forward]:
  "card(pow_cardinal(K))" by auto2

lemma pow_cardinal_equipotent [resolve]:
  "Pow(K) \<approx>\<^sub>S pow_cardinal(K)" by auto2

lemma cantor_non_equipotent [resolve]:
  "\<not> K \<approx>\<^sub>S Pow(K)"
@proof
  @contradiction
  @obtain f where "f \<in> K \<cong> Pow(K)"
  @let "S = {x \<in> K. x \<notin> f`x}"
  @have "\<forall>x\<in>K. f`x \<noteq> S" @with @case "x \<in> f`x" @end
@qed

lemma cantor_non_lepotent [resolve]:
  "\<not> Pow(K) \<lesssim>\<^sub>S K"
@proof @have "K \<lesssim>\<^sub>S Pow(K)" @qed

lemma pow_cardinal_less [resolve]:
  "card(K) \<Longrightarrow> K \<in> pow_cardinal(K)"
@proof
  @let "L = pow_cardinal(K)"
  @have "Pow(K) \<approx>\<^sub>S L"
  @have (@rule) "K \<in> L \<or> K = L \<or> L \<in> K"
  @case "L \<in> K" @with @have "L \<lesssim>\<^sub>S K" @end
@qed

(* Assume K is a cardinal in this definition *)
definition succ_cardinal :: "i \<Rightarrow> i" where [rewrite]:
  "succ_cardinal(K) = (\<mu> L. card(L) \<and> K \<in> L)"

lemma succ_cardinal_is_cardinal:
  "card(K) \<Longrightarrow> card(succ_cardinal(K)) \<and> K \<in> succ_cardinal(K)"
@proof
  @let "P = pow_cardinal(K)"
  @have "card(P) \<and> K \<in> P"
@qed
setup {* add_forward_prfstep (conj_left_th @{thm succ_cardinal_is_cardinal}) *}
setup {* add_resolve_prfstep (conj_right_th @{thm succ_cardinal_is_cardinal}) *}

lemma succ_cardinal_ineq [backward]:
  "card(K) \<Longrightarrow> succ_cardinal(K) \<le>\<^sub>O pow_cardinal(K)"
@proof
  @let "P = pow_cardinal(K)"
  @have "card(P) \<and> K \<in> P"
@qed

section \<open>Transfinite induction on ordinals\<close>

(* Given G a meta-function taking the family of values less than an ordinal i
   to the value at i, return the value at i. *)
definition trans_seq :: "(i \<Rightarrow> i) \<Rightarrow> i \<Rightarrow> i" where [rewrite]:
  "trans_seq(G,a) = wfrec(mem_rel(succ(a)), \<lambda>_ f. G(f), a)"

lemma trans_seq_eq1 [backward]:
  "ord(b) \<Longrightarrow> a \<in> b \<Longrightarrow> i \<in> a \<Longrightarrow> wfrec(mem_rel(b),H,i) = wfrec(mem_rel(a),H,i)"
@proof
  @let "r = mem_rel(a)" "s = mem_rel(b)"
  @induct "ord(i)" "i \<in> a \<longrightarrow> wfrec(s,H,i) = wfrec(r,H,i)" @with
    @subgoal "wfrec(s, H, x) = wfrec(r, H, x)"
      @have (@rule) "\<forall>p1 p2. p1 = p2 \<longrightarrow> H(x,p1) = H(x,p2)"
      @have "wfrec(s,H,x) = H(x, Tup(x, \<lambda>x. wfrec(s,H,x)))"
      @have "wfrec(r,H,x) = H(x, Tup(x, \<lambda>x. wfrec(r,H,x)))"
      @have "Tup(x, \<lambda>x. wfrec(s,H,x)) = Tup(x, \<lambda>x. wfrec(r,H,x))"
    @endgoal
  @end
@qed

lemma not_limit_ordinal_eq [backward1]:
  "ord(a) \<Longrightarrow> \<emptyset> \<in> a \<Longrightarrow> \<not>limit_ord(a) \<Longrightarrow> \<exists>b. a = succ(b)"
@proof
  @obtain b where "b \<in> a" "succ(b) \<notin> a"
  @have (@rule) "a \<in> succ(b) \<or> a = succ(b) \<or> succ(b) \<in> a"
@qed

lemma empty_ord [resolve]: "ord(\<emptyset>)" by auto2

lemma nonzero_ordinal [resolve]: "ord(a) \<Longrightarrow> x \<in> a \<Longrightarrow> \<emptyset> \<in> a"
@proof @have "ord(\<emptyset>)" @have (@rule) "\<emptyset> \<in> x \<or> \<emptyset> = x \<or> x \<in> \<emptyset>" @qed

lemma ord_mem_succ [backward]: "ord(a) \<Longrightarrow> i \<in> a \<Longrightarrow> succ(i) \<in> succ(a)"
@proof
  @case "limit_ord(a)"
  @obtain b where "a = succ(b)"
  @induct "ord(a)" "(\<forall>x. x \<in> a \<longrightarrow> succ(x) \<in> succ(a))" @with
    @subgoal "succ(x) \<in> succ(xa)"  (* Direction is just wrong *)
      @case "limit_ord(x)"
      @obtain y where "x = succ(y)"
      @have "xa \<in> succ(y)"
      @have (@rule) "xa = y \<or> xa \<in> y"
      @case "xa = y"
    @endgoal
  @end
@qed

lemma trans_seq_unfold [rewrite]:
  "ord(a) \<Longrightarrow> trans_seq(G,a) = G(Tup(a, \<lambda>x. trans_seq(G,x)))"
@proof
  @let "r = mem_rel(succ(a))"
  @have (@rule) "\<forall>p1 p2. p1 = p2 \<longrightarrow> G(p1) = G(p2)"
  @have "trans_seq(G,a) = G(Tup(a, \<lambda>x. wfrec(r, \<lambda>_ f. G(f), x)))"
  @have "\<forall>x\<in>a. trans_seq(G,x) = wfrec(r, \<lambda>_ f. G(f), x)" @with
    @have "trans_seq(G,x) = wfrec(mem_rel(succ(x)), \<lambda>_ f. G(f), x)"
    @have "wfrec(r, \<lambda>_ f. G(f), x) = wfrec(mem_rel(succ(x)), \<lambda>_ f. G(f), x)"
  @end
@qed

setup {* del_prfstep_thm @{thm trans_seq_def} *}

definition pred :: "i \<Rightarrow> i" where [rewrite]:
  "pred(x) = (THE y. x = succ(y))"
setup {* register_wellform_data ("pred(x)", ["\<not>limit_ord(x)", "\<emptyset> \<in> x"]) *}

lemma pred_eq [rewrite]:
  "ord(x) \<Longrightarrow> \<not>limit_ord(x) \<Longrightarrow> \<emptyset> \<in> x \<Longrightarrow> succ(pred(x)) = x" by auto2

lemma pred_eq2 [rewrite]:
  "ord(x) \<Longrightarrow> pred(succ(x)) = x" by auto2
setup {* del_prfstep_thm @{thm pred_def} *}

(* Another definition of transfinite induction *)
definition trans_seq2 :: "i \<Rightarrow> (i \<Rightarrow> i) \<Rightarrow> (i \<Rightarrow> i) \<Rightarrow> i \<Rightarrow> i" where [rewrite]:
  "trans_seq2(g1,G2,G3,a) =
     trans_seq(\<lambda>f. if source(f) = \<emptyset> then g1
                   else if limit_ord(source(f)) then G3(f)
                   else G2(f`pred(source(f))), a)"

lemma trans_seq2_unfold1 [rewrite]:
  "trans_seq2(g1,G2,G3,\<emptyset>) = g1"
@proof @have "ord(\<emptyset>)" @qed

lemma trans_seq2_unfold2 [rewrite]:
  "ord(a) \<Longrightarrow> trans_seq2(g1,G2,G3,succ(a)) = G2(trans_seq2(g1,G2,G3,a))"
@proof
  @have "\<not>limit_ord(succ(a))"
  @have "\<emptyset> \<in> succ(a)"
  @have "pred(succ(a)) = a"
@qed

lemma trans_seq2_unfold3 [rewrite]:
  "limit_ord(a) \<Longrightarrow> trans_seq2(g1,G2,G3,a) = G3(Tup(a, \<lambda>x. trans_seq2(g1,G2,G3,x)))"
@proof @have (@rule) "\<forall>p1 p2. p1 = p2 \<longrightarrow> G3(p1) = G3(p2)" @qed

setup {* del_prfstep_thm @{thm trans_seq2_def} *}

section \<open>Union of cardinals is a cardinal\<close>

lemma card_less [resolve]:
  "card(c) \<Longrightarrow> i \<in> c \<Longrightarrow> \<not>i \<approx>\<^sub>S c"
@proof
  @contradiction
  @have "c \<le>\<^sub>O i"
@qed

lemma union_card [backward]:
  "\<forall>x\<in>S. card(x) \<Longrightarrow> card(\<Union>S)"
@proof
  @have "(\<mu> i. i \<approx>\<^sub>S \<Union>S) = \<Union>S" @with
    @have "\<forall>i\<in>\<Union>S. \<not>i \<approx>\<^sub>S \<Union>S" @with
      @obtain c where "i \<in> c" "c \<in> S"
      @have "\<not>c \<lesssim>\<^sub>S i" @with
        @have "i \<lesssim>\<^sub>S c"
      @end
      @have "c \<lesssim>\<^sub>S \<Union>S" @with
        @have "c \<subseteq> \<Union>S"
      @end
    @end
  @end
@qed
  
section \<open>Aleph numbers\<close>

definition aleph :: "i \<Rightarrow> i" where [rewrite]:
  "aleph(i) = trans_seq2(\<omega>,succ_cardinal,\<lambda>f. \<Union>(Tup_image(f,source(f))),i)"

lemma aleph_unfold1 [rewrite]:
  "aleph(\<emptyset>) = \<omega>" by auto2

lemma aleph_unfold2 [rewrite]:
  "ord(a) \<Longrightarrow> aleph(succ(a)) = succ_cardinal(aleph(a))" by auto2

lemma aleph_unfold3 [rewrite]:
  "limit_ord(a) \<Longrightarrow> aleph(a) = \<Union>{aleph(c). c \<in> a}" by auto2
setup {* del_prfstep_thm @{thm aleph_def} *}

section \<open>Beth numbers\<close>

definition beth :: "i \<Rightarrow> i" where [rewrite]:
  "beth(i) = trans_seq2(\<omega>,pow_cardinal,\<lambda>f. \<Union>(Tup_image(f,source(f))),i)"

lemma beth_unfold1 [rewrite]:
  "beth(\<emptyset>) = \<omega>" by auto2

lemma beth_unfold2 [rewrite]:
  "ord(a) \<Longrightarrow> beth(succ(a)) = pow_cardinal(beth(a))" by auto2

lemma beth_unfold3 [rewrite]:
  "limit_ord(a) \<Longrightarrow> beth(a) = \<Union>{beth(c). c \<in> a}" by auto2
setup {* del_prfstep_thm @{thm beth_def} *}

section \<open>Natural numbers as cardinals\<close>

lemma nat_cardinal [forward]:
  "card(\<omega>)"
@proof
  @have "(\<mu> i. i \<approx>\<^sub>S \<omega>) = \<omega>"
@qed

section \<open>Aleph and Beth numbers are cardinals\<close>

lemma aleph_cardinal [forward]:
  "ord(a) \<Longrightarrow> card(aleph(a))"
@proof
  @induct "ord(a)" "card(aleph(a))" @with
    @subgoal "card(aleph(x))"
      @case "x = \<emptyset>"
      @case "limit_ord(x)"
      @obtain y where "x = succ(y)"
    @endgoal
  @end
@qed

lemma beth_cardinal [forward]:
  "ord(a) \<Longrightarrow> card(beth(a))"
@proof
  @induct "ord(a)" "card(beth(a))" @with
    @subgoal "card(beth(x))"
      @case "x = \<emptyset>"
      @case "limit_ord(x)"
      @obtain y where "x = succ(y)"
    @endgoal
  @end
@qed

setup {* fold del_prfstep_thm [@{thm trans_set_def}, @{thm cardinal_def}, @{thm card_def}] *}

end
