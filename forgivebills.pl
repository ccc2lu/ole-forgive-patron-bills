#!/usr/bin/perl

use DBI;
use DBD::mysql;
use POSIX qw(strftime);

# Author: Chris Creswell
# e-mail: ccc2@lehigh.edu

# As input this script takes as a parameter the name of an 
# input file that should contain bill IDs.
# The input file can contain whatever else, as long as the bill ID is
# the first thing before a comma on each line.  The bill IDs can 
# optionally be enclosed by double quotation marks.

# The script will go through each bill in the input file and mark
# it as forgiven in ole_dlvr_ptrn_bill_t, with a pay_amt equal to 
# the tot_amt_due and a note saying that the bill has been forgiven.  
# The ver_nbr is also incremented to '2'.  The 'operator' forgiving 
# the bills is configurable via the $operator variable below.

# Each fee in ole_dlvr_ptrn_bill_fee_typ_t associated with each bill 
# is then set to pay_status_id '5' (which means forgiven), given
# a balance_amt of 0, and a payment in the amount of the fee
# is inserted into ole_dlvr_ptrn_bill_pay_t.

$inputfile=$ARGV[0];
open(INPUT, "<$inputfile") or die "Unable to open input file $inputfile";

$username = "OLEuser";
$host = "dbhost";
$dbname = "oledb";
$pw = "OLEDBPassword";
$datestring = strftime("%Y-%m-%d", localtime);
$operator="123456";  # operator ID for a valid operator
$connectionInfo = "dbi:mysql:database=$dbname";
$connection = DBI->connect($connectionInfo, $username, $pw);
$debug = 1;

while($line=<INPUT>) {
    @parts = split(',', $line);
    $billid = $parts[0];
    print "Bill ID: $billid\n";
    $billid =~ s/\"//g;
    $query = "select tot_amt_due from ole_dlvr_ptrn_bill_t where ptrn_bill_id='$billid'";
    @data = run_query($query);
    $amt = $data[0];
    $query = "update ole_dlvr_ptrn_bill_t set unpaid_bal=0.00, pay_method_id='Forgive', pay_amt=$amt, pay_dt='$datestring', pay_optr_id='$operator', pay_note='\$$amt has been forgiven', ver_nbr=2 where ptrn_bill_id='$billid' and ver_nbr=1";
    run_query($query, 1);
    $query = "select * from ole_dlvr_ptrn_bill_fee_typ_t where ptrn_bill_id='$billid'";
    @data = run_query($query);
    print "Looping over all bill fees for bill $billid\n";
    foreach $row (@data) {
	# $data[0] is the "ID" field and $data[5] is the "FEE_TYP_AMT" field
	# This will obviously have to be updated if the database schema changes.
	$feetypid = $data[0];
	$feeamt = $data[5];
	$query = "update ole_dlvr_ptrn_bill_fee_typ_t set pay_status_id='5', balance_amt=0 where id='$feetypid'";
	@data = run_query($query, 1);
	$query = "insert into ole_dlvr_ptrn_bill_fee_typ_s values(NULL)";
	@data = run_query($query, 1);
	$query = "select MAX(id) from ole_dlvr_ptrn_bill_fee_typ_s";
	@data = run_query($query);
	$billpayid = $data[0];
	$query = "INSERT INTO ole_dlvr_ptrn_bill_pay_t (ID,ITM_LINE_ID,BILL_PAY_AMT,CRTE_DT_TIME,OPTR_CRTE_ID,TRNS_NUMBER,TRNS_NOTE,TRNS_MODE) VALUES ('$billpayid','$feetypid',$feeamt,'$datestring','$operator','','','Forgive')";
	run_query($query, 1);
    }
    print "\n\n\n";
}

sub run_query
{
    my $query = shift;
    my $mod = shift;
    if ( $debug ) {
	print "Query: $query\n";
    }
    $statement = $connection->prepare($query);
    $statement->execute();
    if (!$mod) {
	my @data = $statement->fetchrow_array();
	return @data;
    }
}
