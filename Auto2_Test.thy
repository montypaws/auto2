(* Unit tests for auto2. *)

theory Auto2_Test
imports Auto2
begin

ML_file "logic_steps_test.ML"
ML_file "order_test.ML"

setup {* ACUtil.clear_ac_data *}

ML_file "util_test.ML"
ML_file "acdata_test.ML"
ML_file "subterms_test.ML"
ML_file "normalize_test.ML"
ML_file "rewrite_test.ML"
ML_file "matcher_test.ML"

end
