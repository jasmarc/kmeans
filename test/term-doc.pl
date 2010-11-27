#!/usr/bin/perl
#create term_document matrix from corpus (PG, 20 Nov 09)
#Usage: cat test/file*.txt | term-doc.pl >  term-doc-matrix.txt

chomp(@stoplist = `cat test/stoplist.txt`);

while (<>) { #read in document files, assumed one line apiece
    chomp;
    tr/[A-Z]/[a-z]/;
    foreach my $word (split) {
        next if grep(/^$word$/,@stoplist) || $word !~ /^[a-z]/;
        ++$term_doc{$word}{$.};  #accumulate term_doc matrix
    }
}

foreach my $word (sort keys %term_doc) {  #print term_doc matrix
    print ++$m,' ',$word;
    foreach my $doc (sort {$a <=> $b} keys %{$term_doc{$word}}) {
	print " $doc:$term_doc{$word}{$doc}";
    }
    print ' [',scalar(keys %{$term_doc{$word}}),"]\n";  #doc frequency
}
