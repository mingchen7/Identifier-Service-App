#!/usr/bin/perl -w

my $ASPERA_HEAD = "~/.aspera";
my $ASPERA = "$ASPERA_HEAD/connect";


# Example: ftp://ftp-trace.ncbi.nlm.nih.gov/sra/sra-instant/reads/ByExp/litesra/SRX/SRX026/SRX026940
# ftp://ftp-private.ncbi.nlm.nih.gov/1GB

my $FTP_ADDRESS = $ARGV[0];
my $DESTINATION_DIR = $ARGV[1] || "SRA-import";

# ascp -QT -l 500M -k2 -i $WORK/home/bin/.aspera/connect/etc/asperaweb_id_dsa.putty anonftp@ftp-private.ncbi.nlm.nih.gov:/sra/sra-instant/reads/ByExp/litesra/SRX/SRX002/SRX002495/SRR013307/ .

#my $ASCP_ADDRESS = $FTP_ADDRESS;
#if ($ASCP_ADDRESS =~ /trace/) {
#        $ASCP_ADDRESS =~ s/ftp\:\/\/ftp\-trace\.ncbi\.nlm\.nih\.gov//i;
#} elsif ($ASCP_ADDRESS =~ /private/) {
#        $ASCP_ADDRESS =~ s/ftp\:\/\/ftp\-private\.ncbi\.nlm\.nih\.gov//i;
#} els
        if ( $FTP_ADDRESS =~ m{SRR\d+} ) {
                my $new_address = $FTP_ADDRESS;
                my $chunk = substr($new_address, 0, 6);
                my $wholething = join "", $new_address, ".sra";
                $ASCP_ADDRESS = join "", 'anonftp@ftp-trace.ncbi.nlm.nih.gov:/sra/sra-instant/reads/ByRun/sra/SRR/', "$chunk", '/', "$new_address", '/', "$wholething";
                }
                
# Example: /sra/sra-instant/reads/ByExp/litesra/SRX/SRX026/SRX026940

unless (-d $DESTINATION_DIR) {
        system("mkdir $DESTINATION_DIR");
}

my $ASCP_COMMAND = "$ASPERA/bin/ascp -L /tmp --ignore-host-key -QT -l650M -i $ASPERA/etc/asperaweb_id_dsa.openssh $ASCP_ADDRESS $DESTINATION_DIR";

print STDERR "Aspera command:\n$ASCP_COMMAND\n";

my $res = system($ASCP_COMMAND);
die "Aborted download\n" if $res != 0;

my $sra_name = join '', "$FTP_ADDRESS", ".sra";

my $dump_cmd = join "", "fastq-dump ", "$DESTINATION_DIR/", "$sra_name";

print STDERR $dump_cmd, "\n";

system($dump_cmd);
