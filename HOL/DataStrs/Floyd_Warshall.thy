(* Ported from AFP/Floyd_Warshall or Timed_Automata. *)

theory Floyd_Warshall
imports "../Auto2_Main"
begin

section {* Auxiliary *}

lemma distinct_list_single_elem_decomp:
  "{xs. set xs \<subseteq> {0} \<and> distinct xs} = {[], [0::'a::zero]}"
@proof
  @have "\<forall>x\<in>{xs. set xs \<subseteq> {0} \<and> distinct xs}. x\<in>{[], [0::'a]}" @with
    @case "x = []" @then @have "x = hd x # tl x"
    @case "tl x = []" @then @have "tl x = hd (tl x) # tl (tl x)"
  @end
@qed

section {* Cycles in Lists *}

definition cnt :: "'a \<Rightarrow> 'a list \<Rightarrow> nat" where [rewrite]:
  "cnt x xs = length (filter (\<lambda>y. x = y) xs)"

lemma cnt_rev [rewrite]: "cnt x (rev xs) = cnt x xs" by auto2
lemma cnt_append [rewrite]: "cnt x (xs @ ys) = cnt x xs + cnt x ys" by auto2

(* remove_cycles xs x ys:
   If x does not appear in xs, return rev ys @ xs.
   Otherwise, write xs as x1 @ [x] @ x2, where x \<notin> set x2, then return x2. *)
fun remove_cycles :: "'a list \<Rightarrow> 'a \<Rightarrow> 'a list \<Rightarrow> 'a list" where
  "remove_cycles [] _ acc = rev acc" |
  "remove_cycles (x#xs) y acc =
    (if x = y then remove_cycles xs y [x] else remove_cycles xs y (x#acc))"
setup {* fold add_rewrite_rule @{thms remove_cycles.simps} *}

lemma remove_cycle_removes [forward_arg1]:
  "cnt x (remove_cycles xs x ys) \<le> max 1 (cnt x ys)"
@proof @induct xs arbitrary ys @qed

lemma remove_cycles_id [rewrite, backward]:
  "x \<notin> set xs \<Longrightarrow> remove_cycles xs x ys = rev ys @ xs"
@proof @induct xs arbitrary ys @qed

lemma remove_cycles_cnt_id [forward_arg1]:
  "cnt y (remove_cycles xs x ys) \<le> cnt y ys + cnt y xs"
@proof @induct xs arbitrary ys x @qed

lemma remove_cycles_begins_with [backward]:
  "x \<in> set xs \<Longrightarrow> \<exists>zs. remove_cycles xs x ys = x # zs \<and> x \<notin> set zs"
@proof @induct xs arbitrary ys @qed

lemma remove_cycles_self [rewrite]:
  "x \<in> set xs \<Longrightarrow> remove_cycles (remove_cycles xs x ys) x zs = remove_cycles xs x ys"
@proof
  @obtain ws where "remove_cycles xs x ys = x # ws" "x \<notin> set ws"
@qed

lemma remove_cycles_one [rewrite]:
  "remove_cycles (as @ x # xs) x ys = remove_cycles (x # xs) x ys"
@proof @induct as arbitrary ys @qed

lemma remove_cycles_same [backward]:
  "x \<in> set xs \<Longrightarrow> remove_cycles xs x ys1 = remove_cycles xs x ys2"
@proof @induct xs arbitrary ys1 @qed

lemma remove_cycles_tl [rewrite]:
  "x \<in> set x2 \<Longrightarrow> remove_cycles (x1 # x2) x ys = remove_cycles x2 x ys" by auto2

lemma remove_cycles_cycles [backward]:
  "x \<in> set xs \<Longrightarrow> \<exists>xxs as. as @ concat (map (\<lambda>xs. x # xs) xxs) @ remove_cycles xs x ys = xs \<and> x \<notin> set as"
@proof @induct xs arbitrary ys @with
  @subgoal "xs = y # xs"
    @case "y = x" @with
      @case "x \<in> set xs" @with
        @obtain xxs as where "as @ concat (map (\<lambda>xs. x # xs) xxs) @ remove_cycles xs x ys = xs" "x \<notin> set as"
        @have "[] @ concat (map (\<lambda>xs. x#xs) (as#xxs)) @ remove_cycles (y # xs) x ys = y # xs"
      @end
      @case "x \<notin> set xs" @with
        @have "[] @ concat (map (\<lambda>xs. x # xs) []) @ remove_cycles (y#xs) x ys = y # xs"
      @end
    @end
    @case "y \<noteq> x" @with
      @obtain xxs as where "as @ concat (map (\<lambda>xs. x # xs) xxs) @ remove_cycles xs x ys = xs" "x \<notin> set as"
      @have "(y # as) @ concat (map (\<lambda>xs. x#xs) xxs) @ remove_cycles (y#xs) x ys = y # xs"
    @end
  @endgoal @end
@qed

(* *)
fun start_remove :: "'a list \<Rightarrow> 'a \<Rightarrow> 'a list \<Rightarrow> 'a list" where
  "start_remove [] _ acc = rev acc"
| "start_remove (x # xs) y acc =
    (if x = y then rev acc @ remove_cycles xs y [y] else start_remove xs y (x # acc))"
setup {* fold add_rewrite_rule @{thms start_remove.simps} *}

lemma start_remove_decomp [backward]:
  "x \<in> set xs \<Longrightarrow> \<exists>as bs. xs = as @ x # bs \<and> start_remove xs x ys = rev ys @ as @ remove_cycles bs x [x]"
@proof @induct xs arbitrary ys @with
  @subgoal "xs = y # xs"
    @case "x = y" @with
      @have "start_remove (y # xs) x ys = rev ys @ [] @ remove_cycles xs x [x]"
    @end
    @case "x \<noteq> y" @with
      @obtain as bs where "xs = as @ x # bs"
                          "start_remove xs x (y # ys) = rev (y # ys) @ as @ remove_cycles bs x [x]"
      @have "start_remove xs x (y # ys) = rev ys @ ([y] @ as) @ remove_cycles bs x [x]"
    @end
  @endgoal @end
@qed

lemma start_remove_removes [forward_arg1]:
  "cnt x (start_remove xs x ys) \<le> cnt x ys + 1"
@proof @induct xs arbitrary ys @qed

lemma start_remove_id [rewrite]:
  "x \<notin> set xs \<Longrightarrow> start_remove xs x ys = rev ys @ xs"
@proof @induct xs arbitrary ys @qed

lemma start_remove_cnt_id [forward_arg1]:
  "cnt y (start_remove xs x ys) \<le> cnt y ys + cnt y xs"
@proof @induct xs arbitrary ys @qed

(* *)
fun remove_all_cycles :: "'a list \<Rightarrow> 'a list \<Rightarrow> 'a list" where
  "remove_all_cycles [] xs = xs"
| "remove_all_cycles (x # xs) ys = remove_all_cycles xs (start_remove ys x [])"
setup {* fold add_rewrite_rule @{thms remove_all_cycles.simps} *}

lemma cnt_remove_all_mono [forward_arg1]:
  "cnt y (remove_all_cycles xs ys) \<le> max 1 (cnt y ys)"
@proof @induct xs arbitrary ys @qed

lemma cnt_remove_all_cycles [forward_arg1]:
  "x \<in> set xs \<Longrightarrow> cnt x (remove_all_cycles xs ys) \<le> 1"
@proof @induct xs arbitrary ys @qed

lemma cnt_zero [forward]:
  "cnt x xs = 0 \<Longrightarrow> x \<notin> set xs"
@proof @induct xs @qed

lemma cnt_distinct_intro [forward]:
  "\<forall>x\<in>set xs. cnt x xs \<le> 1 \<Longrightarrow> distinct xs"
@proof @induct xs @with
  @subgoal "xs = x # xs"
    @have "\<forall>x'\<in>set xs. cnt x' xs \<le> 1"
    @have "cnt x xs = 0"
  @endgoal @end
@qed

lemma remove_cycles_subs [forward_arg1]:
  "set (remove_cycles xs x ys) \<subseteq> set xs \<union> set ys"
@proof @induct xs arbitrary ys @qed

lemma start_remove_subs [forward_arg1]:
  "set (start_remove xs x ys) \<subseteq> set xs \<union> set ys"
@proof @induct xs arbitrary ys @qed

lemma remove_all_cycles_subs [forward_arg1]:
  "set (remove_all_cycles xs ys) \<subseteq> set ys"
@proof @induct xs arbitrary ys @qed

lemma remove_all_cycles_distinct [forward_arg]:
  "set ys \<subseteq> set xs \<Longrightarrow> zs = remove_all_cycles xs ys \<Longrightarrow> distinct zs"
@proof @have "\<forall>x\<in>set zs. cnt x zs \<le> 1" @qed

lemma distinct_remove_cycles_inv [backward]:
  "distinct (xs @ ys) \<Longrightarrow> distinct (remove_cycles xs x ys)"
@proof @induct xs arbitrary ys @qed

(* *)
definition remove_all :: "'a \<Rightarrow> 'a list \<Rightarrow> 'a list" where [rewrite]:
  "remove_all x xs = (if x \<in> set xs then tl (remove_cycles xs x []) else xs)"

lemma remove_all_distinct [backward]:
  "distinct xs \<Longrightarrow> distinct (x # remove_all x xs)"
@proof
  @case "x \<in> set xs" @with
    @obtain zs where "remove_cycles xs x [] = x # zs" "x \<notin> set zs"
  @end
@qed

lemma remove_all_removes [resolve]:
  "x \<notin> set (remove_all x xs)"
@proof @contradiction
  @obtain zs where "remove_cycles xs x [] = x # zs" "x \<notin> set zs"
@qed

lemma remove_all_subs [forward_arg1]:
  "set (remove_all x xs) \<subseteq> set xs" by auto2

definition remove_all_rev :: "'a \<Rightarrow> 'a list \<Rightarrow> 'a list" where [rewrite]:
  "remove_all_rev x xs = (if x \<in> set xs then rev (tl (remove_cycles (rev xs) x [])) else xs)"

lemma remove_all_rev_distinct [backward]:
  "distinct xs \<Longrightarrow> distinct (x # remove_all_rev x xs)"
@proof
  @case "x \<in> set xs" @with
    @obtain zs where "remove_cycles (rev xs) x [] = x # zs" "x \<notin> set zs"  
    @have "distinct (remove_cycles (rev xs) x [])"
  @end
@qed

lemma remove_all_rev_removes [resolve]:
  "x \<notin> set (remove_all_rev x xs)"
@proof @contradiction
  @obtain zs where "remove_cycles (rev xs) x [] = x # zs" "x \<notin> set zs"
@qed

lemma remove_all_rev_subs [forward_arg1]:
  "set (remove_all_rev x xs) \<subseteq> set xs" by auto2

definition rem_cycles :: "'a \<Rightarrow> 'a \<Rightarrow> 'a list \<Rightarrow> 'a list" where [rewrite]:
  "rem_cycles i j xs = remove_all i (remove_all_rev j (remove_all_cycles xs xs))"

lemma rem_cycles_distinct' [backward]:
  "i \<noteq> j \<Longrightarrow> distinct (i # j # rem_cycles i j xs)"
@proof
  @have "distinct (remove_all_cycles xs xs)" @with
    @have "set xs \<subseteq> set xs" @end
  @have "distinct (j # remove_all_rev j (remove_all_cycles xs xs))"
  @have "distinct (i # rem_cycles i j xs)"
@qed

lemma rem_cycles_removes_last [resolve]:
  "j \<notin> set (rem_cycles i j xs)" by auto2

lemma rem_cycles_distinct [forward]:
  "distinct (rem_cycles i j xs)"
@proof
  @case "i \<noteq> j" @with
    @have "distinct (i # j # rem_cycles i j xs)" @end
  @have "distinct (remove_all_cycles xs xs)" @with
    @have "set xs \<subseteq> set xs" @end
  @have "distinct (i # rem_cycles i j xs)"
@qed

lemma rem_cycles_subs [forward_arg1]:
  "set (rem_cycles i j xs) \<subseteq> set xs" by auto2

section {* Matrices *}

datatype 'c mat = Mat (eval_fun: "nat \<Rightarrow> nat \<Rightarrow> 'c")
setup {* add_rewrite_rule_back @{thm mat.collapse} *}

fun mat_eval :: "'c mat \<Rightarrow> nat \<Rightarrow> nat \<Rightarrow> 'c" ("_\<langle>_,_\<rangle>" [90,91]) where
  "(Mat f)\<langle>a,b\<rangle> = f a b"
setup {* add_rewrite_rule @{thm mat_eval.simps} *}

lemma mat_eval_ext: "\<forall>x y. M\<langle>x,y\<rangle> = N\<langle>x,y\<rangle> \<Longrightarrow> M = N"
  apply (cases M) apply (cases N) by auto
setup {* add_backward_prfstep_cond @{thm mat_eval_ext} [with_filt (order_filter "M" "N")] *}

fun mat_update :: "'c mat \<Rightarrow> nat \<Rightarrow> nat \<Rightarrow> 'c \<Rightarrow> 'c mat" ("_ { _,_ \<rightarrow> _}" [89,90,90,90] 90) where
  "(Mat f) {x,y \<rightarrow> v} = Mat (\<lambda>x' y'. if x = x' then if y = y' then v else f x' y' else f x' y')"
setup {* add_rewrite_rule @{thm mat_update.simps} *}

lemma mat_update_eval [rewrite]:
  "M {x,y \<rightarrow> v} \<langle>x',y'\<rangle> = (if x = x' then if y = y' then v else M\<langle>x',y'\<rangle> else M\<langle>x',y'\<rangle>)" by auto2

lemma mat_update_eval' [rewrite]:
  "M {x,y \<rightarrow> v} \<langle>x,y\<rangle> = v"
  "x \<noteq> x' \<Longrightarrow> M {x,y \<rightarrow> v} \<langle>x',y'\<rangle> = M\<langle>x',y'\<rangle>"
  "y \<noteq> y' \<Longrightarrow> M {x,y \<rightarrow> v} \<langle>x',y'\<rangle> = M\<langle>x',y'\<rangle>" by auto2+
setup {* fold del_prfstep_thm [@{thm mat.collapse}, @{thm mat_eval.simps}, @{thm mat_update.simps}] *}

section {* Definition of the Algorithm *}

definition fw_upd :: "('a::linordered_ring) mat \<Rightarrow> nat \<Rightarrow> nat \<Rightarrow> nat \<Rightarrow> 'a mat" where [rewrite]:
  "fw_upd M k i j = M {i,j \<rightarrow> min (M\<langle>i,j\<rangle>) (M\<langle>i,k\<rangle> + M\<langle>k,j\<rangle>)}"

lemma fw_upd_mono [forward_arg1]:
  "(fw_upd M k i j)\<langle>i',j'\<rangle> \<le> M\<langle>i',j'\<rangle>" by auto2

fun fw :: "('a::linordered_ring) mat \<Rightarrow> nat \<Rightarrow> nat \<Rightarrow> nat \<Rightarrow> nat \<Rightarrow> 'a mat" where
  "fw M n 0       0       0        = fw_upd M 0 0 0" |
  "fw M n (Suc k) 0       0        = fw_upd (fw M n k n n) (Suc k) 0 0" |
  "fw M n k       (Suc i) 0        = fw_upd (fw M n k i n) k (Suc i) 0" |
  "fw M n k       i       (Suc j)  = fw_upd (fw M n k i j) k i (Suc j)"
setup {* fold add_rewrite_rule @{thms fw.simps} *}
setup {* register_wellform_data ("fw M n k i j", ["i \<le> n", "j \<le> n", "k \<le> n"]) *}

lemma fw_invariant_aux_1 [backward]:
  "j'' \<le> j \<Longrightarrow> (fw M n k i j)\<langle>i',j'\<rangle> \<le> (fw M n k i j'')\<langle>i',j'\<rangle>"
@proof @induct j @with
  @subgoal "j = Suc j"
    @case "j'' = Suc j"
  @endgoal @end
@qed

lemma fw_invariant_aux_2 [backward]:
  "j \<le> n \<Longrightarrow> i'' \<le> i \<Longrightarrow> j'' \<le> j \<Longrightarrow> (fw M n k i j)\<langle>i',j'\<rangle> \<le> (fw M n k i'' j'')\<langle>i',j'\<rangle>"
@proof @induct i @with
  @subgoal "i = Suc i"
    @case "i'' = Suc i" @then
    @have "(fw M n k (Suc i) j) \<langle>i',j'\<rangle> \<le> (fw M n k (Suc i) 0) \<langle>i',j'\<rangle>"
    @have "(fw M n k (Suc i) 0) \<langle>i',j'\<rangle> \<le> (fw M n k i n) \<langle>i',j'\<rangle>"
    @have "(fw M n k i n) \<langle>i',j'\<rangle> \<le> (fw M n k i j) \<langle>i',j'\<rangle>"
  @endgoal @end
@qed

lemma fw_invariant [backward]:
  "i \<le> n \<Longrightarrow> j \<le> n \<Longrightarrow> k' \<le> k \<Longrightarrow> j'' \<le> j \<Longrightarrow> i'' \<le> i \<Longrightarrow>
   (fw M n k i j)\<langle>i', j'\<rangle> \<le> (fw M n k' i'' j'')\<langle>i',j'\<rangle>"
@proof @induct k @with
  @subgoal "k = Suc k"
    @case "k' = Suc k" @then
    @have "(fw M n (Suc k) i j)\<langle>i',j'\<rangle> \<le> (fw M n (Suc k) 0 0)\<langle>i',j'\<rangle>"
    @have "(fw M n (Suc k) 0 0)\<langle>i',j'\<rangle> \<le> (fw M n k n n)\<langle>i',j'\<rangle>"
    @have "(fw M n k n n)\<langle>i',j'\<rangle> \<le> (fw M n k i j)\<langle>i',j'\<rangle>"
  @endgoal @end
@qed

lemma single_row_inv [backward]:
  "j' < j \<Longrightarrow> (fw M n k i' j) \<langle>i',j'\<rangle> = (fw M n k i' j') \<langle>i',j'\<rangle>"
@proof @induct j @qed

lemma single_iteration_inv' [backward]:
  "j' \<le> n \<Longrightarrow> i' < i \<Longrightarrow> (fw M n k i j)\<langle>i',j'\<rangle> = (fw M n k i' j')\<langle>i',j'\<rangle>"
@proof @induct i arbitrary j @with
  @subgoal "i = Suc i" @induct j @endgoal @end
@qed

lemma single_iteration_inv [backward]:
  "j \<le> n \<Longrightarrow> i' \<le> i \<Longrightarrow> j' \<le> j \<Longrightarrow> (fw M n k i j)\<langle>i',j'\<rangle> = (fw M n k i' j')\<langle>i',j'\<rangle>"
@proof @induct i arbitrary j @qed

lemma fw_innermost_id [rewrite]:
  "j' \<le> n \<Longrightarrow> i' < i \<Longrightarrow> (fw M n 0 i' j')\<langle>i,j\<rangle> = M\<langle>i,j\<rangle>"
@proof
  @induct i' arbitrary j' @with
  @subgoal "i' = 0" @induct j' @endgoal
  @subgoal "i' = Suc i'" @induct j' @endgoal @end
@qed

lemma fw_middle_id [backward]:
  "j' < j \<Longrightarrow> i' \<le> i \<Longrightarrow> (fw M n 0 i' j')\<langle>i,j\<rangle> = M\<langle>i,j\<rangle>"
@proof
  @induct i' arbitrary j' @with
  @subgoal "i' = 0" @induct j' @endgoal
  @subgoal "i' = Suc i'" @induct j' @endgoal @end
@qed

lemma fw_outermost_mono [resolve]:
  "(fw M n 0 i j)\<langle>i,j\<rangle> \<le> M\<langle>i,j\<rangle>"
@proof
  @case "j = 0" @with @cases i @end
  @have "(fw M n 0 i (j-1))\<langle>i,j\<rangle> = M\<langle>i,j\<rangle>"
@qed

lemma Suc_innermost_id1 [backward]:
  "i \<le> n \<Longrightarrow> j \<le> n \<Longrightarrow> i' < i \<Longrightarrow> (fw M n (Suc k) i' j')\<langle>i,j\<rangle> = (fw M n k i j)\<langle>i,j\<rangle>"
@proof @induct i' arbitrary j' @with
  @subgoal "i' = 0" @induct j' @endgoal
  @subgoal "i' = Suc i'" @induct j' @endgoal @end
@qed

lemma Suc_innermost_id2 [backward]:
  "i \<le> n \<Longrightarrow> j \<le> n \<Longrightarrow> j' < j \<Longrightarrow> i' \<le> i \<Longrightarrow> (fw M n (Suc k) i' j')\<langle>i,j\<rangle> = (fw M n k i j)\<langle>i,j\<rangle>"
@proof @induct i' arbitrary j' @with
  @subgoal "i' = 0" @induct j' @endgoal
  @subgoal "i' = Suc i'" @induct j' @endgoal @end
@qed

lemma Suc_innermost_id1' [backward]:
  "i \<le> n \<Longrightarrow> j \<le> n \<Longrightarrow> i' < i \<Longrightarrow> (fw M n (Suc k) i' j')\<langle>i,j\<rangle> = (fw M n k n n)\<langle>i,j\<rangle>"
@proof
  @have "(fw M n (Suc k) i' j')\<langle>i,j\<rangle> = (fw M n k i j)\<langle>i,j\<rangle>"
@qed

lemma Suc_innermost_id2' [backward]:
  "i \<le> n \<Longrightarrow> j \<le> n \<Longrightarrow> j' < j \<Longrightarrow> i' \<le> i \<Longrightarrow> (fw M n (Suc k) i' j')\<langle>i,j\<rangle> = (fw M n k n n)\<langle>i,j\<rangle>"
@proof
  @have "(fw M n (Suc k) i' j')\<langle>i,j\<rangle> = (fw M n k i j)\<langle>i,j\<rangle>"
@qed

lemma fw_mono' [forward_arg1]:
  "i \<le> n \<Longrightarrow> j \<le> n \<Longrightarrow> (fw M n k i j)\<langle>i,j\<rangle> \<le> M\<langle>i,j\<rangle>"
@proof @induct k @with
  @subgoal "k = Suc k"
    @have "(fw M n (Suc k) i j)\<langle>i,j\<rangle> \<le> (fw M n k i j)\<langle>i,j\<rangle>"
  @endgoal @end
@qed

lemma fw_mono [backward]:
  "i \<le> n \<Longrightarrow> j \<le> n \<Longrightarrow> i' \<le> n \<Longrightarrow> j' \<le> n \<Longrightarrow> (fw M n k i j)\<langle>i',j'\<rangle> \<le> M\<langle>i',j'\<rangle>"
@proof @cases k @with
  @subgoal "k = 0"
    @case "i < i'" @then
    @case "j' \<le> j" @with
      @have "(fw M n 0 i j)\<langle>i',j'\<rangle> \<le> (fw M n 0 i' j')\<langle>i',j'\<rangle>"
    @end
    @case "i = i'" @with
      @have "(fw M n 0 i' j)\<langle>i',j'\<rangle> = M\<langle>i',j'\<rangle>"
    @end
    @have "(fw M n 0 i j)\<langle>i',j'\<rangle> = (fw M n 0 i' j')\<langle>i',j'\<rangle>"
  @endgoal
  @subgoal "k = Suc k"
    @case "i' \<le> i \<and> j' \<le> j" @with
      @have "(fw M n (Suc k) i j)\<langle>i',j'\<rangle> = (fw M n (Suc k) i' j')\<langle>i',j'\<rangle>"
    @end
    @case "\<not>i' \<le> i" @with
      @have "(fw M n (Suc k) i j)\<langle>i',j'\<rangle> = (fw M n k i' j')\<langle>i',j'\<rangle>"
    @end
    @case "\<not>j' \<le> j" @with
      @case "i = i'" @with
        @have "(fw M n (Suc k) i j)\<langle>i',j'\<rangle> = (fw M n k i' j')\<langle>i',j'\<rangle>"
      @end
      @have "(fw M n (Suc k) i j)\<langle>i',j'\<rangle> = (fw M n (Suc k) i' j')\<langle>i',j'\<rangle>"
    @end
  @endgoal @end
@qed

lemma min_plus1 [rewrite]: "(b::'a::linordered_ring) \<ge> 0 \<Longrightarrow> min a (b + a) = a"
@proof @have "b + a \<ge> a" @qed

lemma min_plus2 [rewrite]: "(b::'a::linordered_ring) \<ge> 0 \<Longrightarrow> min a (a + b) = a"
@proof @have "a + b \<ge> a" @qed

lemma fw_step_0:
  "i \<le> n \<Longrightarrow> j \<le> n \<Longrightarrow> M\<langle>0,0\<rangle> \<ge> 0 \<Longrightarrow> (fw M n 0 i j)\<langle>i,j\<rangle> = min (M\<langle>i,j\<rangle>) (M\<langle>i,0\<rangle> + M\<langle>0,j\<rangle>)"
@proof @induct i @with
  @subgoal "i = 0"
    @have "(fw M n 0 0 0)\<langle>0,0\<rangle> = M\<langle>0,0\<rangle>"
    @cases j @with
      @subgoal "j = Suc j"
        @let "M' = fw M n 0 0 j"
        @have "M'\<langle>0,Suc j\<rangle> = M\<langle>0,Suc j\<rangle>"
        @have "M'\<langle>0,0\<rangle> = M\<langle>0,0\<rangle>"
      @endgoal
    @end
  @endgoal
  @subgoal "i = Suc i"
    @have "(fw M n 0 0 0)\<langle>0,0\<rangle> = M\<langle>0,0\<rangle>"
    @cases j @with
      @subgoal "j = 0"
        @let "M' = fw M n 0 i n"
        @have "M'\<langle>Suc i,0\<rangle> = M\<langle>Suc i,0\<rangle>"
        @have "M'\<langle>0,0\<rangle> = M\<langle>0,0\<rangle>"
      @endgoal
      @subgoal "j = Suc j"
        @have "(fw M n 0 0 (Suc j))\<langle>0,Suc j\<rangle> = M\<langle>0,Suc j\<rangle>" @with
          @have "(fw M n 0 0 j)\<langle>0,0\<rangle> = M\<langle>0,0\<rangle>"
        @end
        @have "(fw M n 0 (Suc i) (Suc j))\<langle>0,Suc j\<rangle> = M\<langle>0,Suc j\<rangle>"
        @have "(fw M n 0 (Suc i) 0)\<langle>Suc i,0\<rangle> = M\<langle>Suc i,0\<rangle>" @with
          @have "(fw M n 0 i n)\<langle>0,0\<rangle> = M\<langle>0,0\<rangle>"
        @end
        @have "(fw M n 0 (Suc i) j)\<langle>Suc i,0\<rangle> = M\<langle>Suc i,0\<rangle>"
        @have "(fw M n 0 (Suc i) j)\<langle>Suc i,Suc j\<rangle> = M\<langle>Suc i,Suc j\<rangle>"
      @endgoal
    @end
  @endgoal @end
@qed

lemma fw_step_Suc:
  "i \<le> n \<Longrightarrow> j \<le> n \<Longrightarrow> M' = fw M n k n n \<Longrightarrow> \<forall>k'\<le>n. M'\<langle>k',k'\<rangle> \<ge> 0 \<Longrightarrow> Suc k \<le> n \<Longrightarrow>
   (fw M n (Suc k) i j)\<langle>i,j\<rangle> = min (M'\<langle>i,j\<rangle>) (M'\<langle>i,Suc k\<rangle> + M'\<langle>Suc k,j\<rangle>)"
@proof @induct i @with
  @subgoal "i = 0"
    @cases j @with
      @subgoal "j = Suc j"
        @have "(fw M n (Suc k) 0 j)\<langle>0,Suc j\<rangle> = M'\<langle>0,Suc j\<rangle>"
        @have "(fw M n (Suc k) 0 j)\<langle>0,Suc k\<rangle> = M'\<langle>0,Suc k\<rangle>" @with
          @case "j < Suc k" @then
          @have "(fw M n (Suc k) 0 k)\<langle>Suc k,Suc k\<rangle> = M'\<langle>Suc k,Suc k\<rangle>"
          @have "(fw M n (Suc k) 0 j)\<langle>0,Suc k\<rangle> = (fw M n (Suc k) 0 (Suc k))\<langle>0,Suc k\<rangle>"
        @end
        @have "(fw M n (Suc k) 0 j)\<langle>Suc k,Suc j\<rangle> = M'\<langle>Suc k,Suc j\<rangle>"
      @endgoal
    @end
  @endgoal
  @subgoal "i = Suc i"
    @cases j @with
      @subgoal "j = 0"
        @have "(fw M n (Suc k) i n)\<langle>Suc i,0\<rangle> = M'\<langle>Suc i,0\<rangle>"
        @have "(fw M n (Suc k) i n)\<langle>Suc i,Suc k\<rangle> = M'\<langle>Suc i,Suc k\<rangle>"
        @have "(fw M n (Suc k) i n)\<langle>Suc k,0\<rangle> = M'\<langle>Suc k,0\<rangle>" @with
          @case "i < Suc k" @then
          @have "(fw M n (Suc k) k n)\<langle>Suc k,Suc k\<rangle> = M'\<langle>Suc k,Suc k\<rangle>"
          @have "(fw M n (Suc k) i n)\<langle>Suc k,0\<rangle> = (fw M n (Suc k) (Suc k) 0)\<langle>Suc k,0\<rangle>"
        @end
      @endgoal
      @subgoal "j = Suc j"
        @have "(fw M n (Suc k) (Suc i) j)\<langle>Suc i,Suc j\<rangle> = M'\<langle>Suc i,Suc j\<rangle>"
        @have "(fw M n (Suc k) (Suc i) j)\<langle>Suc i,Suc k\<rangle> = M'\<langle>Suc i,Suc k\<rangle>" @with
          @case "j < Suc k" @then
          @have "(fw M n (Suc k) (Suc i) k)\<langle>Suc i,Suc k\<rangle> = M'\<langle>Suc i,Suc k\<rangle>"
          @have "(fw M n (Suc k) (Suc i) k)\<langle>Suc k,Suc k\<rangle> = M'\<langle>Suc k,Suc k\<rangle>" @with
            @case "Suc i \<le> Suc k" @then
            @have "(fw M n (Suc k) (Suc i) k)\<langle>Suc k,Suc k\<rangle> = (fw M n (Suc k) (Suc k) (Suc k))\<langle>Suc k,Suc k\<rangle>"
            @have "(fw M n (Suc k) (Suc k) k)\<langle>Suc k,Suc k\<rangle> = M'\<langle>Suc k,Suc k\<rangle>"
          @end
          @have "(fw M n (Suc k) (Suc i) j)\<langle>Suc i,Suc k\<rangle> = (fw M n (Suc k) (Suc i) (Suc k))\<langle>Suc i,Suc k\<rangle>"
        @end
        @have "(fw M n (Suc k) (Suc i) j)\<langle>Suc k,Suc j\<rangle> = M'\<langle>Suc k,Suc j\<rangle>" @with
          @case "Suc i \<le> Suc k" @then
          @have "(fw M n (Suc k) (Suc k) j)\<langle>Suc k,Suc k\<rangle> = M'\<langle>Suc k,Suc k\<rangle>" @with
            @case "j < Suc k" @then
            @have "(fw M n (Suc k) (Suc k) j)\<langle>Suc k,Suc k\<rangle> = (fw M n (Suc k) (Suc k) (Suc k))\<langle>Suc k,Suc k\<rangle>"
            @have "(fw M n (Suc k) (Suc k) k)\<langle>Suc k,Suc k\<rangle> = M'\<langle>Suc k,Suc k\<rangle>"
          @end
          @have "(fw M n (Suc k) (Suc k) (Suc j))\<langle>Suc k,Suc j\<rangle> = M'\<langle>Suc k,Suc j\<rangle>"
        @end
      @endgoal
    @end
  @endgoal @end
@qed

subsection {* Length of paths *}

fun len :: "('a::linordered_ring) mat \<Rightarrow> nat \<Rightarrow> nat \<Rightarrow> nat list \<Rightarrow> 'a" where
  "len M u v [] = M\<langle>u,v\<rangle>" |
  "len M u v (w # ws) = M\<langle>u,w\<rangle> + len M w v ws"
setup {* fold add_rewrite_rule @{thms len.simps}*}

lemma len_decomp [rewrite]:
  "len M x z (ys @ y # zs) = len M x y ys + len M y z zs"
@proof @induct ys arbitrary x @qed

subsection {* Shortening Negative Cycles *}

lemma remove_cycles_neg_cycles_aux [backward1]:
  "xs' = i # ys \<Longrightarrow> i \<notin> set ys \<Longrightarrow>
   xs = as @ concat (map (\<lambda>xs. i # xs) xss) @ xs' \<Longrightarrow> i \<in> set xs \<Longrightarrow>
   len M i j ys > len M i j xs \<Longrightarrow>
   \<exists>ys. set ys \<subseteq> set xs \<and> len M i i ys < 0"
@proof @induct xss arbitrary xs as @with
  @subgoal "xss = []"
    @case "len M i i as \<ge> 0" @with
      @have "len M i j ys \<le> len M i j xs"
    @end
  @endgoal
  @subgoal "xss = zs # xss"
    @let "xs'' = zs @ concat (map (\<lambda>xs. i # xs) xss) @ xs'"
    @case "len M i i as \<ge> 0" @with
      @have "len M i j xs'' \<le> len M i j xs"
    @end
  @endgoal @end
@qed

lemma remove_cycles_neg_cycles_aux' [backward1]:
  "j \<notin> set ys \<Longrightarrow>
   xs = ys @ j # concat (map (\<lambda>xs. xs @ [j]) xss) @ as \<Longrightarrow> j \<in> set xs \<Longrightarrow>
   len M i j ys > len M i j xs \<Longrightarrow> 
   \<exists>ys. set ys \<subseteq> set xs \<and> len M j j ys < 0"
@proof @induct xss arbitrary xs as @with
  @subgoal "xss = []"
    @case "len M j j as \<ge> 0" @with
      @have "len M i j ys \<le> len M i j xs"
    @end
  @endgoal
  @subgoal "xss = zs # xss"
    @let "xs'' = ys @ j # concat (map (\<lambda>xs. xs @ [j]) xss) @ as"
    @let "t = concat (map (\<lambda>xs. xs @ [j]) xss) @ as"
    @case "len M i j xs'' \<le> len M i j xs" @then
    @have "len M j j (concat (map (\<lambda>xs. xs @ [j]) (zs # xss)) @ as) < len M j j t"
    @have "len M j j (zs @ j # t) < len M j j t"
  @endgoal @end
@qed

lemma start_remove_neg_cycles [resolve]:
  "len M i j (start_remove xs k []) > len M i j xs \<Longrightarrow>
   \<exists>ys. set ys \<subseteq> set xs \<and> len M k k ys < 0"
@proof
  @let "xs' = start_remove xs k []"
  @case "len M i j xs' > len M i j xs" @with
    @have "k \<in> set xs"
    @obtain as bs where "xs = as @ k # bs" "xs' = rev [] @ as @ remove_cycles bs k [k]"
    @have "xs' = as @ remove_cycles bs k [k]"
    @let "xs'' = remove_cycles bs k [k]"
    @have "k \<in> set bs"
    @obtain ys where "xs'' = k # ys" "k \<notin> set ys"
    @have "len M k j bs < len M k j ys"
    @obtain xss as' where "as' @ concat (map (\<lambda>xs. k # xs) xss) @ xs'' = bs \<and> k \<notin> set as'"
    @have "as' @ concat (map (\<lambda>xs. k # xs) xss) @ k # ys = bs"
    @obtain ys' where "set ys' \<subseteq> set bs \<and> len M k k ys' < 0"
  @end
@qed

lemma remove_all_cycles_neg_cycles [resolve]:
  "len M i j (remove_all_cycles ys xs) > len M i j xs \<Longrightarrow>
   \<exists>ys k. set ys \<subseteq> set xs \<and> k \<in> set xs \<and> len M k k ys < 0"
@proof @induct ys arbitrary xs @with
  @subgoal "ys = y # ys"
    @let "xs' = start_remove xs y []"
    @case "len M i j xs < len M i j xs'" @with
      @have "y \<in> set xs"
      @obtain ys' where "set ys' \<subseteq> set xs \<and> len M y y ys' < 0"
    @end
  @endgoal @end
@qed

lemma concat_map_cons_rev [rewrite]:
  "rev (concat (map (\<lambda>xs. j # xs) xss)) = concat (map (\<lambda>xs. xs @ [j]) (rev (map rev xss)))"
  by (induction xss) auto

lemma negative_cycle_dest [resolve]:
  "len M i j (rem_cycles i j xs) > len M i j xs \<Longrightarrow>
   \<exists>i' ys. len M i' i' ys < 0 \<and> set ys \<subseteq> set xs \<and> i' \<in> set (i # j # xs)"
@proof
  @let "xsij = rem_cycles i j xs"
  @let "xs' = remove_all_cycles xs xs"
  @let "xsj = remove_all_rev j xs'"
  @case "len M i j xsij > len M i j xs" @with
    @case "len M i j xsij \<le> len M i j xsj" @with
      @have "len M i j xsj > len M i j xs"
      @case "len M i j xsj \<le> len M i j xs'" @with
        @obtain ys k where "set ys \<subseteq> set xs \<and> k \<in> set xs \<and> len M k k ys < 0"
      @end
      @have "len M i j xsj > len M i j xs'"
      @case "j \<notin> set xs'"
      @have "j \<notin> set xsj"
      @have "j \<in> set (rev xs')"
      @obtain xss as where "as @ concat (map (\<lambda>xs. j # xs) xss) @ remove_cycles (rev xs') j [] = rev xs'" "j \<notin> set as"
      @have "xsj = rev (tl (remove_cycles (rev xs') j []))"
      @obtain zs where "remove_cycles (rev xs') j [] = j # zs \<and> j \<notin> set zs"
      @have "xsj @ j # concat (map (\<lambda>xs. xs @ [j]) (rev (map rev xss))) @ rev as = xs'" @with
        @have "remove_cycles (rev xs') j [] = j # rev xsj"
        @have "rev (as @ concat (map (\<lambda>xs. j # xs) xss) @ j # rev xsj) = xs'"
        @have "xsj @ j # rev (concat (map (\<lambda>xs. j # xs) xss)) @ rev as = xs'"
      @end
      @obtain ys where "set ys \<subseteq> set xs' \<and> len M j j ys < 0"
    @end
    @case "i \<notin> set xsj"
    @have "i \<notin> set xsij"
    @obtain xss as where "as @ concat (map (\<lambda>xs. i # xs) xss) @ remove_cycles xsj i [] = xsj" "i \<notin> set as"
    @have "xsij = tl (remove_cycles xsj i [])"
    @obtain zs where "remove_cycles xsj i [] = i # zs \<and> i \<notin> set zs"
    @have "remove_cycles xsj i [] = i # xsij"
    @have "as @ concat (map (\<lambda>xs. i # xs) xss) @ i # xsij = xsj"
    @obtain ys where "set ys \<subseteq> set xsj \<and> len M i i ys < 0"
  @end
@qed

end
