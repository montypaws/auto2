theory Reverse_Func
imports "../Auto2_Main"
begin

section {* Results about nth *}

setup {* add_rewrite_rule @{thm List.nth_append} *}
setup {* add_rewrite_rule @{thm List.nth_Cons'} *}

section {* Basic definitions *}

setup {* fold add_rewrite_rule @{thms List.rev.simps} *}

lemma rev_one [rewrite]: "rev [x] = [x]" by simp

lemma rev_append [rewrite]: "rev (xs @ ys) = rev ys @ rev xs"
@proof @induct xs @qed

lemma rev_length: "length (rev xs) = length xs"
@proof @induct xs @qed
setup {* add_forward_prfstep_cond @{thm rev_length} [with_term "rev ?xs"] *}

lemma nat_sub1 [rewrite]: "(a::nat) - n - 1 = a - 1 - n" by simp

lemma rev_nth [rewrite]:
  "n < length xs \<Longrightarrow> rev xs ! n = xs ! (length xs - 1 - n)"
@proof @induct xs @qed

section {* Linear time version of rev *}

fun itrev :: "'a list \<Rightarrow> 'a list \<Rightarrow> 'a list" where
  "itrev []       ys = ys" |
  "itrev (x # xs) ys = itrev xs (x # ys)"
setup {* fold add_rewrite_rule @{thms itrev.simps} *}

lemma itrev_eq_rev: "itrev x [] = rev x"
@proof
  @have (@rule) "\<forall>y. itrev x y = rev x @ y" @with
    @induct x arbitrary y @with
      @subgoal "x = a # b" @have "a # y = [a] @ y" @endgoal
    @end
  @end
@qed

section {* List update *}

setup {* register_wellform_data ("xs[i := x]", ["i < length xs"]) *}
setup {* add_rewrite_rule @{thm List.nth_list_update} *}
setup {* add_forward_prfstep_cond @{thm List.length_list_update} [with_term "?xs[?i := ?x]"] *}

definition list_swap :: "'a list \<Rightarrow> nat \<Rightarrow> nat \<Rightarrow> 'a list" where
  "list_swap xs i j = xs[i := xs ! j, j := xs ! i]"
setup {* add_rewrite_rule @{thm list_swap_def} *}
setup {* register_wellform_data ("list_swap xs i j", ["i < length xs", "j < length xs"]) *}
setup {* add_prfstep_check_req ("list_swap xs i j", "i < length xs \<and> j < length xs") *}

lemma list_swap_eval:
  "i < length xs \<Longrightarrow> j < length xs \<Longrightarrow>
   (list_swap xs i j) ! k = (if k = i then xs ! j else if k = j then xs ! i else xs ! k)" by auto2
setup {* add_rewrite_rule_cond @{thm list_swap_eval} [with_cond "?k \<noteq> ?i", with_cond "?k \<noteq> ?j"] *}

lemma list_swap_eval_triv [rewrite]:
  "i < length xs \<Longrightarrow> (list_swap xs i j) ! i = xs ! j"
  "j < length xs \<Longrightarrow> (list_swap xs i j) ! j = xs ! i" by auto2+

lemma length_list_swap:
  "length (list_swap xs i j) = length xs" by auto2
setup {* add_forward_prfstep_cond @{thm length_list_swap} [with_term "list_swap ?xs ?i ?j"] *}

lemma mset_list_swap [rewrite]:
  "i < length xs \<Longrightarrow> j < length xs \<Longrightarrow> mset (list_swap xs i j) = mset xs" by auto2
setup {* del_prfstep_thm @{thm list_swap_def} *}

section {* Definition of rev in terms of swaps *}
  
fun rev_swap :: "'a list \<Rightarrow> nat \<Rightarrow> nat \<Rightarrow> 'a list" where
  "rev_swap xs i j = (if i < j then rev_swap (list_swap xs i j) (i + 1) (j - 1) else xs)"
setup {* add_rewrite_rule_cond @{thm rev_swap.simps} [with_filt (size1_filter "i"), with_filt (size1_filter "j")] *}
setup {* register_wellform_data ("rev_swap xs i j", ["j < length xs"]) *}

lemma rev_swap_length:
  "j < length xs \<Longrightarrow> length (rev_swap xs i j) = length xs"
@proof
  @strong_induct j arbitrary i xs
  @case "i < j" @with
    @apply_induct_hyp "j - 1" "i + 1" "list_swap xs i j"
  @end
@qed
setup {* add_forward_prfstep_cond @{thm rev_swap_length} [with_term "rev_swap ?xs ?i ?j"] *}

lemma nat_sub2 [rewrite]: "(k::nat) \<ge> i + 1 \<Longrightarrow> j - 1 - (k - (i + 1)) = j - (k - i)" by simp

lemma rev_swap_eval [rewrite]:
  "j < length xs \<Longrightarrow> (rev_swap xs i j) ! k =
    (if k < i then xs ! k else if k > j then xs ! k else xs ! (j - (k - i)))"
@proof @strong_induct j arbitrary i xs
  @case "i < j" @with
    @let "xs' = list_swap xs i j"
    @apply_induct_hyp "j - 1" "i + 1" xs'
    @case "k < i + 1" @then @case "j - 1 < k" @then
    @have "i \<noteq> j - (k - i)"
  @end
@qed

lemma rev_swap_is_rev [rewrite]:
  "length xs \<ge> 1 \<Longrightarrow> rev_swap xs 0 (length xs - 1) = rev xs"
@proof @have "length xs - 1 < length xs" @qed

end
