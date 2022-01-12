use warnings;
use strict;

our @Rv = ();
our $RepeatSize;
our @Shared = ();
open (REPEAT, "/home/jws48/Repetitive_DR_genes.txt");
#Fill with Rv numbers of drug-resistance targets and repetitive genes
@Rv = getRepeats (*REPEAT);
$RepeatSize = $#Rv+1;

#Enter Directory with Lineage SNPs
print "Enter variant directory: ";
my $Var_Dir = <STDIN>;
chomp $Var_Dir;

opendir (IO_DIR, "$Var_Dir");
my @IO_Vars = readdir IO_DIR;
closedir IO_DIR;
splice (@IO_Vars, 0, 2);
my $size = @IO_Vars;

my @IO = ();
our (@IO_Union, @IO_Intersect, @IO_Difference);
for (my $i = 0; $i < $size; $i++)
{	
	if ($i == 0)
	{
		open (IO, "$Var_Dir/$IO_Vars[$i]");
		@IO = filterReps (*IO);
		
		@Shared = @IO;
		print "These are the first strain\n @Shared\n";
		@IO = ();
	}
		
	else
	{
		open (IO, "$Var_Dir/$IO_Vars[$i]");
		@IO = filterReps (*IO);

		my %IO_Count = ();
		
		foreach my $element (@Shared, @IO) {$IO_Count{$element}++}
		foreach my $element (keys %IO_Count)
		{
			push @IO_Union, $element;
			push @{ $IO_Count{$element} > 1 ? \@IO_Intersect : \@IO_Difference }, $element;
		}
		
# 		print "@IO_Difference\n";
	}
	
	@Shared = sort {$a <=> $b} @IO_Intersect;
	@IO = ();
}

our @LineageSNPs = &getSuperset (@Shared);

print "@LineageSNPs\n";

sub getRepeats
{
	my $FH = shift();
	my $i = 0;
	my @array;
	
	while (<$FH>)
	{
		chomp;
		my $line = $_;
		if ($line =~ /(\w+)/)
		{
			$array[$i] = $1;
			$i++;
		}
	}
	return @array;
}

sub filterReps
{
	my $Transcript;
	my $found;
	my $start;
	my $Gene;
	my @array;
	my $count = 0;
	
	my $FH = shift();
	
	while (<$FH>)
	{
		chomp;
		my $line = $_;
		
		if ( $line =~ /(\S+)(\s+)(\S+)(\s+)(\S+)(\s+)(\S+)(\s+)(\S+)(\s+)(\S+)/)
		{
			$Transcript = $7;
			$start = $11;
		}
		$found = 0;
		my $i;
		
		for ($i = 0; $i < $RepeatSize; $i++)
		{
			$Gene = $Rv[$i];
			if ( ($Transcript =~ /$Gene/) )
			{
				$found = 1;
			}
		}
		
		if ( $found == 0 )
		{
			$array[$count] = $start;
# 			print "\n$array[$count]";
			$count++;
		}
	}
	
	return @array;
}

sub getSuperset
{
	my @GroupSNPs = @_;
	
	my @Unique = ();
	my %Seen = ();
	my @Sorted = ();
	my $elem;
	my $size;
	my $i;
	
	foreach $elem (@GroupSNPs)
	{
		next if $Seen{$elem}++;
		push @Unique, $elem;
	}

	@Sorted = sort {$a <=> $b} @Unique;
	$size = @Sorted;

	return @Sorted
}