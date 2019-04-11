#!/bin/bash
. ./path.sh || exit 1
. ./cmd.sh || exit 1
nj=1      # number of parallel jobs - 1 is perfect for such a small dataset
lm_order=1 # language model order (n-gram quantity) - 1 is enough for our grammar
# Safety mechanism (possible running this script with modified arguments)
. utils/parse_options.sh || exit 1
[[ $# -ge 1 ]] && { echo "Wrong arguments!"; exit 1; }


echo "===== HMM TRIPHONE 2B TRAINING ====="
echo
steps/train_lda_mllt.sh --cmd "$train_cmd" 2000 11000 data/train data/lang exp/tri1_ali exp/tri2b || exit 1
echo
echo "===== HMM TRIPHONE 2B DECODING ====="
echo
utils/mkgraph.sh data/lang exp/tri2b exp/tri2b/graph || exit 1
steps/decode.sh --config conf/decode.config --nj $nj --cmd "$decode_cmd" exp/tri2b/graph data/test exp/tri2b/decode
echo
echo "===== HMM TRIPHONE 2B ALIGNMENT ====="
echo
steps/align_si.sh --nj $nj --cmd "$train_cmd" --use-graphs true data/train data/lang exp/tri2b exp/tri2b_ali || exit 1
echo
echo "===== HMM TRIPHONE 2B DENOMINATOR LATTICES ====="
echo
steps/make_denlats.sh --nj $nj --cmd "$train_cmd" data/train data/lang exp/tri2b exp/tri2b_denlats || exit 1;
echo
echo "===== run_tri2b.sh script is finished ====="
echo
