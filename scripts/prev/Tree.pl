system "standard-RAxML-master/raxmlHPC-PTHREADS -m GTRCAT -T 12 -p 12345 -# 20 -s /home/jws48/TB_Tree/FilterPhyloSNPs/snpSuperset.fasta -w /home/jws48/TB_Tree/FilterPhyloSNPs/ML/1 -n T1";

system "standard-RAxML-master/raxmlHPC-PTHREADS -m GTRCAT -T 12 -p 12345 -b 12345 -# 1000 -s /home/jws48/TB_Tree/FilterPhyloSNPs/snpSuperset.fasta -w /home/jws48/TB_Tree/FilterPhyloSNPs/ML/2 -n T2";

system "standard-RAxML-master/raxmlHPC-PTHREADS -m GTRCAT -T 12 -p 12345 -f b -t /home/jws48/TB_Tree/FilterPhyloSNPs/ML/1/RAxML_bestTree.T1 -z /home/jws48/TB_Tree/FilterPhyloSNPs/ML/2/RAxML_bootstrap.T2 -n T3 -w /home/jws48/TB_Tree/FilterPhyloSNPs/ML/3";
