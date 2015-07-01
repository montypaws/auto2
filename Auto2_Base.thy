theory Auto2_Base
imports Main Logic_Base
begin

ML_file "util.ML"
ML_file "box_id.ML"
ML_file "acdata.ML"
ML_file "subterms.ML"
ML_file "rewrite.ML"
ML_file "normalize.ML"
ML_file "status.ML"
ML_file "proofsteps.ML"
ML_file "script.ML"
ML_file "auto2.ML"
ML_file "induction.ML"

method_setup auto2 = {* Scan.succeed (SIMPLE_METHOD o auto2_tac) *} "auto2 prover"

end
