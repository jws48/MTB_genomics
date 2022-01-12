#!/usr/bin/perl
#
##  Genome_Assembly.pl
##  
##
##  Created by Joe Saelens on 4/16/14.
##

use warnings;

$PE_1 = "/home/reads/1";
opendir (PE1, "$PE_1");
@PE_Reads1 = readdir PE1;
closedir PE1;
splice (@PE_Reads1, 0, 2);

$PE_2 = "home/reads/2";
opendir (PE2, "$PE_2");
@PE_Reads2 = readdir PE2;
closedir PE2;
splice (@PE_Reads2, 0, 2);

$Single = "/home/reads/single";
opendir (SE, "$Single");
@SE_Reads = readdir SE;
closedir SE;
splice (@SE_Reads, 0, 2);

$PE_size = @PE_Reads1;
$SE_size = @SE_Reads;


$out_dir = "/home/Out";
$ref = "/home/Reference/H37Rv.fasta";
$path = "/home/reads";

system "bwa index -a bwtsw $ref";

for ($i = 0; $i < $PE_size; $i++)
{
    @Name = split('_', $PE_Reads1[$i]);
    $Strain[$i] = $Name[0];
    @Name = ();
    
    system "mkdir $out_dir/$Strain[$i]";
    
    system "bwa aln $ref $path/1/$PE_Reads1[$i] > $out_dir/$Strain[$i]/$Strain[$i]_1.sai";

    system "bwa aln $ref $path/2/$PE_Reads2[$i] > $out_dir/$Strain[$i]/$Strain[$i]_2.sai";
    
    system "bwa sampe $ref $out_dir/$Strain[$i]/$Strain[$i]_1.sai $out_dir/$Strain[$i]/$Strain[$i]_2.sai $path/1/$PE_Reads1[$i] $path/2/$PE_Reads2[$i] > $out_dir/$Strain[$i]/$Strain[$i].sam";
    
    system "samtools view -bS $out_dir/$Strain[$i]/$Strain[$i].sam > $out_dir/$Strain[$i]/$Strain[$i].bam";
    
    system "samtools sort $out_dir/$Strain[$i]/$Strain[$i].bam $out_dir/$Strain[$i]/$Strain[$i]_sort";
    
    system "samtools index $out_dir/$Strain[$i]/$Strain[$i]_sort.bam";
    
    system "samtools mpileup -f $ref $path/$Strain[$i]_sort.bam > $out_dir/$Strain[$j].mpileup";
    
    system "java -jar /home/jws48/Software/VarScan.v2.3.7.jar mpileup2cns $out_dir/$Strain[$j].mpileup --min-var-freq 0.75 --min-avg-qual 20 --min-coverage 20 --variants --output-vcf > $Var_out/$Strain[$i].vcf";
    
    system "java -jar Software/VarScan.v2.3.7.jar mpileup2indel $out_dir/$Strain[$j].mpileup --min-coverage 20 --min-avg-qual 20 --min-var-freq 0.75 --variants > $Var_out/$Strain[$i].indel";
    
    system "java -jar /home/jws48/Software/VarScan.v2.3.7.jar filter $Var_out/$Strain[$j].vcf --min-coverage 20 --min-avg-qual 20 --min-var-freq 0.75 --indel-file $Var_out/$Strain[$i].indel > $Var_out/$Strain[$i]_indel_filt.vcf";
    
    system "rm $out_dir/$Strain[$i].mpileup";
    
    system "convert2annovar.pl -format vcf4 $Var_out/$Strain[$i]_indel_filt.vcf > $Var_out/$Strain[$i].avinput";
    
    system "annotate_variation.pl -transcript_function -buildver H37Rv -outfile $Final_Output/$Strain[$i] $Var_out/$Strain[$j].avinput /home/jws48/Software/annovar/tbdb/";

}

for ($j = 0; $j < $SE_size; $j++)
{
    @Name = split('_', $SE_Reads[$j]);
    $Strain[$j] = $Name[0];

#    print "$SE_Reads[$j]\t$Strain[$j]\n";

    @Name = ();
    
    system "mkdir $out_dir/$Strain[$j]";

    system "bwa aln $ref $path/Single/$SE_Reads[$j] > $out_dir/$Strain[$j]/$Strain[$j].sai";
    
    system "bwa samse $ref $out_dir/$Strain[$j]/$Strain[$j].sai $path/Single/$SE_Reads[$j] > $out_dir/$Strain[$j]/$Strain[$j].sam";
    
    system "samtools view -bS $out_dir/$Strain[$j]/$Strain[$j].sam > $out_dir/$Strain[$j]/$Strain[$j].bam";
    
    system "samtools sort $out_dir/$Strain[$j]/$Strain[$j].bam $out_dir/$Strain[$j]/$Strain[$j]_sort";
    
    system "samtools index $out_dir/$Strain[$j]/$Strain[$j]_sort.bam";
    
    system "samtools mpileup -f $ref $path/$Strain[$j]_sort.bam > $out_dir/$Strain[$j].mpileup";
    
    system "java -jar /home/jws48/Software/VarScan.v2.3.7.jar mpileup2cns $out_dir/$Strain[$j].mpileup --min-var-freq 0.75 --min-avg-qual 20 --min-coverage 20 --variants --output-vcf > $Var_out/$Strain[$j].vcf";
    
    system "java -jar Software/VarScan.v2.3.7.jar mpileup2indel $out_dir/$Strain[$j].mpileup --min-coverage 20 --min-avg-qual 20 --min-var-freq 0.75 --variants > $Var_out/$Strain[$j].indel";
    
    system "java -jar /home/jws48/Software/VarScan.v2.3.7.jar filter $Var_out/$Strain[$j].vcf --min-coverage 20 --min-avg-qual 20 --min-var-freq 0.75 --indel-file $Var_out/$Strain[$j].indel > $Var_out/$Strain[$j]_indel_filt.vcf";
    
    system "rm $out_dir/$Strain[$j].mpileup";
    
    system "convert2annovar.pl -format vcf4 $Var_out/$Strain[$j]_indel_filt.vcf > $Var_out/$Strain[$j].avinput";
    
    system "annotate_variation.pl -transcript_function -buildver H37Rv -outfile $Final_Output/$Strain[$j] $Var_out/$Strain[$j].avinput /home/jws48/Software/annovar/tbdb/";

}


