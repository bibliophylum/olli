#!/usr/bin/perl

# NOTES
# The csv file from Counting Opinions is not in utf-8.  You need to open the file
# in emacs, change the encoding, and replace \212 with è and \202 with é
# (find a \212 character, copy it, do a replace-string, paste the \202,
# hit enter, copy a è from a real utf-8 file, paste in the command buffer, hit enter.
# Repeat for the \202.)
# Then change the encoding of the file (C-x C-m f, 'utf-8-unix'), and save the file.

use Getopt::Long;
use Text::CSV;
use DBI;
use Carp;
use Data::Dumper;

binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");

my $infname;
my $verbose;
my $help;
my $delete;
my $restart;
my $delyear;
GetOptions ("inf=s" => \$infname, "verbose"  => \$verbose, "help" => \$help,
	    "delete" => \$delete, "restart" => \$restart, "year=s" => \$delyear
    );

if ($delete) {
    my $dbh = DBI->connect("dbi:Pg:database=olli;host=localhost;port=5432",
			   "olli",
			   "olli",
			   {AutoCommit => 1, 
			    RaiseError => 1, 
			    PrintError => 1,
			   }
	);
    my $rv;
	
    if ($restart) {
	my @tables = qw( technology social_media personnel ill hours_of_operation ebook_circ contact collections circulations activities branches financial libmun libraries municipalities );
	foreach my $table (@tables) {
	    my $sql = "delete from $table";
	    print $sql;
	    $rv = $dbh->do($sql) or warn $dbh->errstr;
	    print " ... $rv\n";
	}
	
	my @seqs = qw( technology social_media personnel ill hours_of_operation ebook_circ contact collections circulations activities branches financial libraries municipalities );
	foreach my $seq (@seqs) {
	    $dbh->do("alter sequence " . $seq . "_id_seq restart with 1");
	}
	
    } elsif ($delyear) {
	if ($delyear =~ /\d\d\d\d/) {
	    my @linkedToBranch = qw( technology social_media personnel ill hours_of_operation ebook_circ contact collections circulations activities );
	    foreach my $table (@linkedToBranch) {
		my $sql = "delete from $table where branch_id in (select id from branches where year='" . $delyear . "')";
		print $sql;
		$rv = $dbh->do($sql) or warn $dbh->errstr;
		print " ... $rv\n";
	    }
	    my @linkedToLibrary = qw( branches financial libmun );
	    foreach my $table (@linkedToLibrary) {
		my $sql = "delete from $table where library_id in (select id from libraries where year='" . $delyear . "')";
		print $sql;
		$rv = $dbh->do($sql) or warn $dbh->errstr;
		print " ... $rv\n";
	    }
	    my @tables = qw( libraries municipalities );
	    foreach my $table (@tables) {
		my $sql = "delete from $table where year='" . $delyear . "'";
		print $sql;
		$rv = $dbh->do($sql) or warn $dbh->errstr;
		print " ... $rv\n";
	    }
	} else {
	    print STDERR "$0: --delete with --year requires four-digit year (YYYY)\n\tYou gave [$delyear]\n\tNo action taken.\n";
	}

    } else {
	print STDERR "$0: --delete requires either --restart or --year YYYY\n\tNo action taken.\n";
    }
    
    $dbh->disconnect or warn $dbh->errstr;
    exit;
}

if ($help || (!defined $infname)) {
    print "usage: $0 --inf filename [--verbose] [--delete [--restart || --year YYYY]]\n";
    exit;
}

# NEED TO ADD SYMBOLS TO WPL BRANCHES!!!

use constant {
	LS_ID => 0,
	SP_ID => 1,
	Collection_ID => 2,
	Period_ID => 3,
	Subperiod_ID => 4,
	LIB_NAME => 5,
	LIB_TITLE => 6,
	WEB => 7,
	EMAIL => 8,
	STREET_ADDRESS => 9,
	ADDRESS => 10,
	CITY => 11,
	PROV => 12,
	POSTAL_CODE => 13,
	PHONE_NUMBER => 14,
	FAX_NUMBER => 15,
	CHAIR_NAME => 16,
	CHAIR_EMAIL => 17,
	LIBRARIAN_NAME => 18,
	EMAIL_ADMIN => 19,
	NUC => 20,
	EMAIL_ILL => 21,
	LIB_SERVER => 22,
	LIB_DATE => 23,
	FAC_OWN => 24,
	FAC_TERM => 25,
	RENT => 26,
	SQFT => 27,
	CONTACT_EMAIL => 28,
	COPYRIGHT => 29,
	COPYRIGHT_D => 30,
	HRS_OPERATION => 31,
	PLAN => 32,
	PLAN_END => 33,
	TECH_PLAN => 34,
	MONDAY => 35,
	TUESDAY => 36,
	WEDNESDAY => 37,
	THURSDAY => 38,
	FRIDAY => 39,
	SATURDAY => 40,
	SUNDAY => 41,
	REGULAR_HRS => 42,
	SUMMER_HRS => 43,
	HOLD_BKS_EN => 44,
	COLLECTIONBK_TOT => 45,
	COLLECTIONOTH_TOT => 46,
	COLLECTIONTOT => 47,
	HOLD_OTH_EN => 48,
	HOLD_BKS_FR => 49,
	HOLD_SERIAL => 50,
	COLL_TOT => 51,
	COLLECTIONOTH_FR => 52,
	NUMBER_LIB_MEMBERSHIPS => 53,
	NONRES_SINGLE_MEMBER => 54,
	NONRES_FAM_MEMBER => 55,
	NUM_NONRES_LIB_MEMBER => 56,
	FEE_NONRES_MEMBER => 57,
	FEE_NONRES_FAMILY => 58,
	TOT_NUMBER_COMPUTERS_IN_LIB => 59,
	TOT_PACS => 60,
	TOT_NUMBER_COMPUTER_BKINGS => 61,
	E_VISITS => 62,
	BK_BARCODE => 63,
	BK_BRCD_LNGTH => 64,
	PTRN_BARCODE => 65,
	PTRN_BRCD_LNGTH => 66,
	LIB_SYSTEM => 67,
	INFO_TRANS => 68,
	GATE_COUNT => 69,
	PROGRAM => 70,
	CIRC_A => 71,
	CIRC_C => 72,
	AUD_VISUAL_GENERAL => 73,
	CIRC_TOT_BOOKS => 74,
	NEW_CIRC_EBOOKS => 75,
	CIRC_TOT => 76,
	CIRC_EBOOKS => 77,
	MAPLIN_REQ_MADE => 78,
	MAPLIN_REQ_REC => 79,
	ILL_IN => 80,
	ILLS_OUT => 81,
	ADOBE_EPUB => 82,
	ADOBE_PDF => 83,
	DISNEY => 84,
	OPEN_EPUB => 85,
	OPEN_PDF => 86,
	MOBIPOCKET => 87,
	READ => 88,
	LISTEN => 89,
	MP3 => 90,
	WMA => 91,
	EBSCO_SEARCH => 92,
	FB_YN => 93,
	FB_HNDL => 94,
	FB_FLWR => 95,
	FB_PST => 96,
	TW_YN => 97,
	TW_HNDL => 98,
	TW_FLWR => 99,
	TW_PST => 100,
	FL_YN => 101,
	FL_HNDL => 102,
	FL_FLWR => 103,
	FL_PST => 104,
	BG_YN => 105,
	BG_HNDL => 106,
	BG_FLWR => 107,
	BG_PST => 108,
	GG_YN => 109,
	GG_HNDL => 110,
	GG_FLWR => 111,
	GG_PST => 112,
	YT_YN => 113,
	YT_HNDL => 114,
	YT_FLWR => 115,
	YT_PST => 116,
	PN_YN => 117,
	PN_HNDL => 118,
	PN_FLWR => 119,
	PN_PST => 120,
	IN_YN => 121,
	IN_HNDL => 122,
	IN_FLWR => 123,
	IN_PST => 124,
	OTH1_YN => 125,
	OTH1_HNDL => 126,
	OTH1_FLWR => 127,
	OTH1_PST => 128,
	OTH2_YN => 129,
	OTH2_HNDL => 130,
	OTH2_FLWR => 131,
	OTH2_PST => 132,
	OTH3_YN => 133,
	OTH3_HNDL => 134,
	OTH3_FLWR => 135,
	OTH3_PST => 136,
	NUMBER_FT_STAFF => 137,
	NUMBER_PT_STAFF => 138,
	TOT_HRS_WORKED_PROFESSIONAL => 139,
	TOT_HRS_WORKED_PARAPRO => 140,
	TOT_HRS_WORKED_OTHER => 141,
	EXTRA_HOURS => 142,
	REP_TOT_HRS_ALL_STAFF => 143,
	TOT_HRS_WORKED_ALL_STAFF => 144,
	CHAIR_TITLE => 145,
	CHAIR_PHONE => 146,
	CHAIR_APP => 147,
	CHAIR_TERM => 148,
	CNCL_MEM => 149,
	VCHAIR_NAME => 150,
	VCHAIR_TITLE => 151,
	VCHAIR_PHONE => 152,
	VCHAIR_EMAIL => 153,
	VCHAIR_APP => 154,
	VCHAIR_TERM => 155,
	VCHAIR_CNCL_MEM => 156,
	TREAS_NAME => 157,
	TREAS_TITLE => 158,
	TREAS_PHONE => 159,
	TREAS_EMAIL => 160,
	TREAS_APP => 161,
	TREAS_TERM => 162,
	TREAS_CNCL_MEM => 163,
	SEC_NAME => 164,
	SEC_TITLE => 165,
	SEC_PHONE => 166,
	SEC_EMAIL => 167,
	SEC_APP => 168,
	SEC_TERM => 169,
	SEC_CNCL_MEM => 170,
	MEM4_NAME => 171,
	MEM4_TITLE => 172,
	MEM4_PHONE => 173,
	MEM4_EMAIL => 174,
	MEM4_APP => 175,
	MEM4_TERM => 176,
	MEM4_MEM => 177,
	MEM5_NAME => 178,
	MEM5_TITLE => 179,
	MEM5_PHONE => 180,
	MEM5_EMAIL => 181,
	MEM5_APP => 182,
	MEM5_TERM => 183,
	MEM5_MEM => 184,
	MEM6_NAME => 185,
	MEM6_TITLE => 186,
	MEM6_PHONE => 187,
	MEM6_EMAIL => 188,
	MEM6_APP => 189,
	MEM6_TERM => 190,
	MEM6_MEM => 191,
	MEM7_NAME => 192,
	MEM7_TITLE => 193,
	MEM7_PHONE => 194,
	MEM7_EMAIL => 195,
	MEM7_APP => 196,
	MEM7_TERM => 197,
	MEM7_MEM => 198,
	MEM8_NAME => 199,
	MEM8_TITLE => 200,
	MEM8_PHONE => 201,
	MEM8_EMAIL => 202,
	MEM8_APP => 203,
	MEM8_TERM => 204,
	MEM8_MEM => 205,
	MEM9_NAME => 206,
	MEM9_TITLE => 207,
	MEM9_PHONE => 208,
	MEM9_EMAIL => 209,
	MEM9_APP => 210,
	MEM9_TERM => 211,
	MEM9_MEM => 212,
	MEM10_NAME => 213,
	MEM10_TITLE => 214,
	MEM10_PHONE => 215,
	MEM10_EMAIL => 216,
	MEM10_APP => 217,
	MEM10_TERM => 218,
	MEM10_MEM => 219,
	MEM11_NAME => 220,
	MEM11_TITLE => 221,
	MEM11_PHONE => 222,
	MEM11_EMAIL => 223,
	MEM11_APP => 224,
	MEM11_TERM => 225,
	MEM11_MEM => 226,
	MEM12_NAME => 227,
	MEM12_TITLE => 228,
	MEM12_PHONE => 229,
	MEM12_EMAIL => 230,
	MEM12_APP => 231,
	MEM12_TERM => 232,
	MEM12_MEM => 233,
	MEM13_NAME => 234,
	MEM13_TITLE => 235,
	MEM13_PHONE => 236,
	MEM13_EMAIL => 237,
	MEM13_APP => 238,
	MEM13_TERM => 239,
	MEM13_MEM => 240,
	MEM14_NAME => 241,
	MEM14_TITLE => 242,
	MEM14_PHONE => 243,
	MEM14_EMAIL => 244,
	MEM14_APP => 245,
	MEM14_TERM => 246,
	MEM14_MEM => 247,
	MUNICIPAL_CONTRIBUTION_NEW => 248,
	PROVINCIAL_GRANT => 249,
	COLLECTION_DEVELOPMENT => 250,
	ESTABLISHMENT => 251,
	TOT_REV_PROVINCIAL => 252,
	OTH_CONTRIBUTION_MISC => 253,
	OTH_CONTRIBUTION_MUNICIPA => 254,
	OTH_CONTRIBUTION_PROVINCIAL => 255,
	OTH_CONTRIBUTION_FED => 256,
	OTH_CONTRIBUTION_PRIV => 257,
	NEW_TOT_OTHER_CONTRIBUTION => 258,
	TOT_REV => 259,
	PER_CAP_NEW => 260,
	POP_NEW => 261,
	BOOKMOBILE => 262,
	TOT_OTH_CONTRIBUTION => 263,
	PROVINCIAL_GRANT_NEW => 264,
	COLLECTION_DEVELOPMENT_NEW => 265,
	ESTABLISHMENT_NEW => 266,
	MUNICIPAL_CONTRIBUTION => 267,
	POP => 268,
	PERCAP => 269,
	PERSONNEL => 270,
	MATS => 271,
	CAPITAL => 272,
	BUILDING => 273,
	Technology => 274,
	OTH_EXPS => 275,
	TOT_EXPS => 276,
	MUN_1 => 277,
	MUN_1_POP => 278,
	MUN_1_CONTR => 279,
	MUN_1_PER_CAP => 280,
	MUN_1_ESTAB => 281,
	MUN_1_OPERATE => 282,
	MUN_1_COLL => 283,
	MUN_2 => 284,
	MUN_2_POP => 285,
	MUN_2_CONTR => 286,
	MUN_2_PER_CAP => 287,
	MUN_2_ESTAB => 288,
	MUN_2_OPERATE => 289,
	MUN_2_COLL => 290,
	MUN_3 => 291,
	MUN_3_POP => 292,
	MUN_3_CONTR => 293,
	MUN_3_PER_CAP => 294,
	MUN_3_ESTAB => 295,
	MUN_3_OPERATE => 296,
	MUN_3_COLL => 297,
	MUN_4 => 298,
	MUN_4_POP => 299,
	MUN_4_CONTR => 300,
	MUN_4_PER_CAP => 301,
	MUN_4_ESTAB => 302,
	MUN_4_OPERATE => 303,
	MUN_4_COLL => 304,
	MUN_5 => 305,
	MUN_5_POP => 306,
	MUN_5_CONTR => 307,
	MUN_5_PER_CAP => 308,
	MUN_5_ESTAB => 309,
	MUN_5_OPERATE => 310,
	MUN_5_COLL => 311,
	MUN_6 => 312,
	MUN_6_POP => 313,
	MUN_6_CONTR => 314,
	MUN_6_PER_CAP => 315,
	MUN_6_ESTAB => 316,
	MUN_6_OPERATE => 317,
	MUN_6_COLL => 318,
	MUN_7 => 319,
	MUN_7_POP => 320,
	MUN_7_CONTR => 321,
	MUN_7_PER_CAP => 322,
	MUN_7_ESTAB => 323,
	MUN_7_OPERATE => 324,
	MUN_7_COLL => 325,
	MUN_8 => 326,
	MUN_8_POP => 327,
	MUN_8_CONTR => 328,
	MUN_8_PER_CAP => 329,
	MUN_8_ESTAB => 330,
	MUN_8_OPERATE => 331,
	MUN_8_COLL => 332,
	MUN_9 => 333,
	MUN_9_POP => 334,
	MUN_9_CONTR => 335,
	MUN_9_PER_CAP => 336,
	MUN_9_ESTAB => 337,
	MUN_9_OPERATE => 338,
	MUN_9_COLL => 339,
	MUN_10 => 340,
	MUN_10_POP => 341,
	MUN_10_CONTR => 342,
	MUN_10_PER_CAP => 343,
	MUN_10_ESTAB => 344,
	MUN_10_OPERATE => 345,
	MUN_10_COLL => 346,
	MUN_11 => 347,
	MUN_11_POP => 348,
	MUN_11_CONTR => 349,
	MUN_11_PER_CAP => 350,
	MUN_11_ESTAB => 351,
	MUN_11_OPERATE => 352,
	MUN_11_COLL => 353,
	MUN_12 => 354,
	MUN_12_POP => 355,
	MUN_12_CONTR => 356,
	MUN_12_PER_CAP => 357,
	MUN_12_ESTAB => 358,
	MUN_12_OPERATE => 359,
	MUN_12_COLL => 360,
	MUN_13 => 361,
	MUN_13_POP => 362,
	MUN_13_CONTR => 363,
	MUN_13_PER_CAP => 364,
	MUN_13_ESTAB => 365,
	MUN_13_OPERATE => 366,
	MUN_13_COLL => 367,
	MUN_14 => 368,
	MUN_14_POP => 369,
	MUN_14_CONTR => 370,
	MUN_14_PER_CAP => 371,
	MUN_14_ESTAB => 372,
	MUN_14_OPERATE => 373,
	MUN_14_COLL => 374,
	MUN_15 => 375,
	MUN_15_POP => 376,
	MUN_15_CONTR => 377,
	MUN_15_PER_CAP => 378,
	MUN_15_ESTAB => 379,
	MUN_15_OPERATE => 380,
	MUN_15_COLL => 381,
	MUN_16 => 382,
	MUN_16_POP => 383,
	MUN_16_CONTR => 384,
	MUN_16_PER_CAP => 385,
	MUN_16_ESTAB => 386,
	MUN_16_OPERATE => 387,
	MUN_16_COLL => 388,
	MUN_17 => 389,
	MUN_17_POP => 390,
	MUN_17_CONTR => 391,
	MUN_17_PER_CAP => 392,
	MUN_17_ESTAB => 393,
	MUN_17_OPERATE => 394,
	MUN_17_COLL => 395,
	MUN_18 => 396,
	MUN_18_POP => 397,
	MUN_18_CONTR => 398,
	MUN_18_PER_CAP => 399,
	MUN_18_ESTAB => 400,
	MUN_18_OPERATE => 401,
	MUN_18_COLL => 402,
	MUN_19 => 403,
	MUN_19_POP => 404,
	MUN_19_CONTR => 405,
	MUN_19_PER_CAP => 406,
	MUN_19_ESTAB => 407,
	MUN_19_OPERATE => 408,
	MUN_19_COLL => 409,
	MUN_20 => 410,
	MUN_20_POP => 411,
	MUN_20_CONTR => 412,
	MUN_20_PER_CAP => 413,
	MUN_20_ESTAB => 414,
	MUN_20_OPERATE => 415,
	MUN_20_COLL => 416,
	MUN_21 => 417,
	MUN_21_POP => 418,
	MUN_21_CONTR => 419,
	MUN_21_PER_CAP => 420,
	MUN_21_ESTAB => 421,
	MUN_21_OPERATE => 422,
	MUN_21_COLL => 423,
	MUN_22 => 424,
	MUN_22_POP => 425,
	MUN_22_CONTR => 426,
	MUN_22_PER_CAP => 427,
	MUN_22_ESTAB => 428,
	MUN_22_OPERATE => 429,
	MUN_22_COLL => 430,
	MUN_23 => 431,
	MUN_23_POP => 432,
	MUN_23_CONTR => 433,
	MUN_23_PER_CAP => 434,
	MUN_23_ESTAB => 435,
	MUN_23_OPERATE => 436,
	MUN_23_COLL => 437,
	PERC_PERS_EXPEND => 438,
	CIRC_PER_STAFF_FTE => 439,
	PERC_INC_PROV => 440,
	PERC_MAT_EXPEND => 441,
	PERC_CAPITAL_EXPEND => 442,
	PERC_BUILD_EXPEND => 443,
	PERC_OTHER_EXPEND => 444,
	EXPEND_PER_CAP => 445,
	BOOKING_PAC => 446,
	EXPEND_CAP_HOUR => 447,
	COMP_FTE => 448,
	BOOKINGS_HOUR => 449,
	BOOKING_WEEK => 450,
	INFO_HOUR => 451,
	INFO_WEEK => 452,
	VISIT_HOUR => 453,
	CIRC_HOUR => 454,
	EBOOK_PER_CAP => 455,
	PERC_TECH_EXPEND => 456,
	REV_PER_CAP => 457,
	PERCAP_PROV => 458,
	CIRC_GATE_POP => 459,
	ACTIVITY_REV => 460,
	PERC_INC_MUN => 461,
	PERC_COLL_FRENCH => 462,
	REG_BORROWERS_PER_POP => 463,
	CIRC_PER_CAP => 464,
	SOCIAL => 465,
	COLL_PER_CAP => 466,
	GATE_PER_CAP => 467,
	PERC_MEMB_NONRES => 468,
	STAFFHRS_PER_CAP => 469,
	TURNOVER => 470,
	SQUARE_PER_ITEM => 471,
	SQUARE_PER_CAP => 472,
	BUILD_EXP_PER_SQUARE => 473,
	USERS_PER_COMPUTER => 474,
	CIRC_PER_VISIT => 475,
	CIRC_PER_STAFF_HOUR => 476,
	GATE_PER_WEEK => 477,
	ILLS_OUT_PER_WEEK => 478,
	ILLS_IN_PER_WEEK => 479,
	ILLS_OUT_PER_1K_HOLDINGS => 480,
	TOT_PAID_STAFF_FTE => 481,
	VISITS_PER_STAFF_FTE => 482,
	REF_TRANS_PER_STAFF_FTE => 483,
	MTLS_EXP_PER_CAPITA => 484,
	POP_PER_STAFF_FTE => 485,
	STAFF_EXPENSE_PER_STAFF => 486,
	PROG_PER_CAP => 487,
	EXPEND_HOUR => 488,
	FACE => 489,
	BOOKINGS_CAP => 490,
	WEB_PER_CAP => 491,
	PERCAP_MUNICIP => 492,
	PERC_INC_MUN_D => 493,
};

#use constant YEAR => '2014';  # now pulled from $row->[Period_ID]

my $dbh = DBI->connect("dbi:Pg:database=olli;host=localhost;port=5432",
                       "olli",
                       "olli",
                       {AutoCommit => 0, 
                        RaiseError => 1, 
                        PrintError => 0,
                       }
    );


my @rows;
my $csv = Text::CSV->new ( { binary => 1 } )  # should set binary attribute.
    or die "Cannot use CSV: ".Text::CSV->error_diag ();

open my $fh, "<:encoding(utf8)", $infname or die "$infname: $!";
while ( my $row = $csv->getline( $fh ) ) {
    #    $row->[2] =~ m/pattern/ or next; # 3rd field should match
    # my @fields = @$row;
    push @rows, $row;
}
$csv->eof or $csv->error_diag();
close $fh;

my %coLib2pgLib;   # hash to translate between CO LS_ID and postgres libraries id
my %coBr2pgBr;     # ditto  $branch_id{ LS_ID . "-" . SP_ID } gives pg branch id

my $s2lm;
my $s2lm_needs_building = 1;

#my $debugcnt = 6;

foreach my $row (@rows) {
    next if ($row->[0] =~ m/\#/);  # skip headers
    next unless ($row->[LIB_NAME]);  # skip "blanks" - rows with no library name

#    last if ($debugcnt-- == 0); 

    #print Dumper ($row);
    #print $row->[0] . "\n" if ($verbose);

    my %data = ();
    $data{year} = $row->[Period_ID];

    # symbol to library & municipality names
    if ($s2lm_needs_building) {
	$s2lm = generate_s2lm( $data{year} ); 
	#print Dumper($s2lm);
	$s2lm_needs_building = 0;
    }
    
    if ($row->[SP_ID] == 0) {  # library system
	$data{library} = extract_library($row);
	$data{municipalities} = extract_municipalities($row);
	$data{financial} = extract_financial($row);
    } else {                   # branch
	$data{branch} = extract_branch($row);
	# I hate special cases...
	if ( $s2lm->{ $data{branch}{symbol} }{ library } eq "Parkland Regional Library") {
	    print STDERR ">>>>" . $data{branch}{symbol} . ", " . $s2lm->{ $data{branch}{symbol} }{ library } . "<<<<\n";
	    $data{municipalities} = extract_municipalities($row,1); # force
	}
	$data{contact} = extract_contact($row);
	$data{circ} = extract_circulations($row);
	$data{collection} = extract_collections($row);
	$data{hours} = extract_hours($row);
	$data{tech} = extract_technology($row);
	$data{activities} = extract_activities($row);
	$data{ill} = extract_ill($row);
	$data{ebook_circ} = extract_ebook_circ($row);
	$data{social_media} = extract_social_media($row);
	$data{personnel} = extract_personnel($row);
    }
    #    print "Data\n----\n" . Dumper(\%data) . "\n";

    if ($row->[SP_ID] == 0) {
	load_library(\%data);
    } else {
	# I hate special cases...
	if ( $s2lm->{ $data{branch}{symbol} }{ library } eq "Parkland Regional Library") {
	    load_parkland_municipalities($data{municipalities});
	}

	load_branch(\%data);
    }
}

exit;

#-----------------------------------------------------------------------------------
sub to_num {
    my $n = shift;
    if (defined $n) {
	$n =~ s/[\$,]//g;  
	$n = 0+$n;
    } else {
	$n = 0;
    }
    return $n;
}

#-----------------------------------------------------------------------------------
sub extract_library {
    my $row = shift;
    return if ($row->[SP_ID] != 0);  # library branch-level, we want system level
    return unless ($row->[LIB_NAME]);  

    print "\nExtracting...\n" if ($verbose);
    
    my $is_charity = $row->[CONTACT_EMAIL];  # this CO ID does not match CO field name
    if ($is_charity) { $is_charity = uc($is_charity) eq 'YES' ? 1 : 0 } else { $is_charity = 0 }
    my $has_copyright = $row->[COPYRIGHT];
    if ($has_copyright) { $has_copyright = uc($has_copyright) eq 'YES' ? 1 : 0 } else { $has_copyright = 0 }
    my $has_boardweb = $row->[COPYRIGHT_D];  # this CO ID does not match CO field name
    if ($has_boardweb) { $has_boardweb = uc($has_boardweb) eq 'YES' ? 1 : 0 } else { $has_boardweb = 0 }

    my $established = $row->[LIB_DATE];
    if ($established == '') { $established = undef; }
    my $sp_start = $row->[PLAN];
    if ($sp_start == '') { $sp_start = undef; }
    my $sp_end = $row->[PLAN_END];
    if ($sp_end == '') { $sp_end = undef; }
    
    my $href = {
	co_lib_id => $row->[LS_ID],  # will be used to associate other data to library
	year => $row->[Period_ID],
	name => $row->[LIB_NAME],
	symbol => uc $row->[NUC],
	fee_nr_single => to_num($row->[FEE_NONRES_MEMBER]),
	fee_nr_family => to_num($row->[FEE_NONRES_FAMILY]),
	established => $established,
	is_registered_charity => $is_charity,
	has_access_copyright_license => $has_copyright,
	has_board_minutes_on_website => $has_boardweb,
	strategic_plan_start => $sp_start,
	strategic_plan_end => $sp_end,
	has_technology_plan => $has_tech_plan,
    };
    return $href;
}

#-----------------------------------------------------------------------------------
sub extract_municipalities {
    my $row = shift;
    my $force = shift;

    unless ($force) {
	return if ($row->[SP_ID] != 0);  # library branch-level, we want system level
    }

    my @mun;
    for (my $m=0; $m<23; $m++) {
	my $i = MUN_1 + ($m * 7);
	next unless ($row->[$i]); # skip empty municipalities
	my $name         = $row->[ $i + 0 ];
	my $pop          = to_num($row->[ $i + 1 ]);
	my $contrib      = to_num($row->[ $i + 2 ]);
	my $percap       = $row->[ $i + 3 ];
	my $is_bilingual = $row->[ $i + 4 ];  # CO id is ESTAB
	my $is_northern  = $row->[ $i + 5 ];  # CO id is OPERATE
	my $branches     = $row->[ $i + 6 ];  # CO id is COLL
	#print STDERR "mun: col [$i], $name,$pop,$contrib,$percap,$is_bilingual,$is_northern,$branches\n";

	if ($name =~ /R\.M\./) { $name =~ s/R\.M\./RM/g }
	if ($name =~ /R\. M\./) { $name =~ s/R\. M\./RM/g }
	if ($name =~ /T of/) { $name =~ s/T of/Town of/g }
	if ($name =~ /V of/) { $name =~ s/V of/Village of/g }
	if ($is_bilingual) { $is_bilingual = uc($is_bilingual) eq 'Y' ? 1 : 0 }
	else { $is_bilingual = 0 }
	if ($is_northern) { $is_northern = uc($is_northern) eq 'Y' ? 1 : 0 }
	else { $is_northern = 0 }

	print "extracted municipality [" . $name . "]\n" if ($verbose);
	
	push @mun, { year => $row->[Period_ID],
		     name => $name,
		     population => $pop,
		     is_bilingual => $is_bilingual,
		     is_northern => $is_northern,
		     contribution => $contrib,         # this will go into libmun
		     contribution_to => $row->[LS_ID], # associate with library
	};
    }
    return \@mun;
}

#-----------------------------------------------------------------------------------
sub extract_branch {
    my $row = shift;
    return if ($row->[SP_ID] == 0);  # library system level, we want branch-level
    
    my $href = {
	co_lib_id => $row->[LS_ID],  # will be used to associate other data to library
	co_br_id => $row->[LS_ID] . "-" . $row->[SP_ID],
	year => $row->[Period_ID],
	municipality => undef,  # can't tell from CO data... perhaps a symbol lookup table?
	name => $row->[LIB_NAME],
	symbol => uc $row->[NUC],
	facility_owner => $row->[FAC_OWN],
	facility_term_expires => $row->[FAC_TERM],
	annual_rent => to_num($row->[RENT]),
	floor_space => to_num($row->[SQFT]),
	active_memberships => to_num($row->[NUMBER_LIB_MEMBERSHIPS]),
	nonresident_single_memberships => to_num($row->[NONRES_SINGLE_MEMBER]),
	nonresident_family_memberships => to_num($row->[NONRES_FAMILY_MEMBER])
    };
    return $href;
}

#-----------------------------------------------------------------------------------
sub extract_contact {
    my $row = shift;
    return if ($row->[SP_ID] == 0);  # library system level, we want branch-level
    
    my $href = {
	co_lib_id => $row->[LS_ID],  # will be used to associate other data to library
	co_br_id => $row->[LS_ID] . "-" . $row->[SP_ID],
	librarian => $row->[LIBRARIAN_NAME],
	symbol => uc $row->[NUC],
	street => $row->[STREET_ADDRESS],
	box => $row->[ADDRESS],
	town => $row->[CITY],
	province => $row->[PROV] || "MB",
	postal_code => $row->[POSTAL_CODE],
	phone => $row->[PHONE_NUMBER],
	fax => $row->[FAX_NUMBER],
	email_general => $row->[EMAIL],
	email_admin => $row->[EMAIL_ADMIN],
	email_ill => $row->[EMAIL_ILL],
	website => $row->[WEB],
	catalogue => $row->[LIB_SERVER]
    };
    return $href;
}

#-----------------------------------------------------------------------------------
sub extract_circulations {
    my $row = shift;
    return if ($row->[SP_ID] == 0);  # library system level, we want branch-level
    
    my $href = {
	co_lib_id => $row->[LS_ID],  # will be used to associate other data to library
	co_br_id => $row->[LS_ID] . "-" . $row->[SP_ID],
	symbol => uc $row->[NUC],
	adult => to_num($row->[CIRC_A]),
	children => to_num($row->[CIRC_C]),
	audio_visual => to_num($row->[AUD_VISUAL_GENERAL]),
	ebooks => to_num($row->[CIRC_EBOOKS])
    };
    return $href;
}

#-----------------------------------------------------------------------------------
sub extract_collections {
    my $row = shift;
    return if ($row->[SP_ID] == 0);  # library system level, we want branch-level
    
    my $href = {
	co_lib_id => $row->[LS_ID],  # will be used to associate other data to library
	co_br_id => $row->[LS_ID] . "-" . $row->[SP_ID],
	symbol => uc $row->[NUC],
	english => to_num($row->[HOLD_BKS_EN]),
	french => to_num($row->[HOLD_BKS_FR]),
	other => to_num($row->[HOLD_OTHER_EN]),
	serial_subscriptions => to_num($row->[HOLD_SERIAL])
    };
    return $href;
}

#-----------------------------------------------------------------------------------
sub extract_financial {
    my $row = shift;
    return if ($row->[SP_ID] != 0);  # library branch-level, we want system level
    
    my $href = {
	co_lib_id => $row->[LS_ID],  # will be used to associate other data to library
	inc_mun => to_num($row->[MUNICIPAL_CONTRIBUTION_NEW]),
	inc_prov_operating => to_num($row->[PROVINCIAL_GRANT]),
	inc_prov_colldev => to_num($row->[COLLECTION_DEVELOPMENT]),
	inc_prov_establish => to_num($row->[ESTABLISHMENT]),
	inc_other_misc => to_num($row->[OTH_CONTRIBUTION_MISC]),
	inc_other_mun => to_num($row->[OTH_CONTRIBUTION_MUNICIPA]),
	inc_other_prov => to_num($row->[OTH_CONTRIBUTION_PROVINCIAL]),
	inc_other_fed => to_num($row->[OTH_CONTRIBUTION_FED]),
	inc_other_private => to_num($row->[OTH_CONTRIBUTION_PRIV]),
	exp_personnel => to_num($row->[PERSONNEL]),
	exp_materials => to_num($row->[MATS]),
	exp_capital => to_num($row->[CAPITAL]),
	exp_building => to_num($row->[BUILDING]),
	exp_technology => to_num($row->[Technology]),
	exp_other => to_num($row->[OTH_EXPS])
    };
    return $href;
}

#-----------------------------------------------------------------------------------
sub extract_hours {
    my $row = shift;
    return if ($row->[SP_ID] == 0);  # library system level, we want branch-level
    
    my $href = {
	co_lib_id => $row->[LS_ID],  # will be used to associate other data to library
	co_br_id => $row->[LS_ID] . "-" . $row->[SP_ID],
	symbol => uc $row->[NUC],
	seasonal => "Regular",
	season_begins => $row->[Period_ID] . "-01-01",
	season_ends => $row->[Period_ID] . "-12-31",
	sunday => $row->[SUNDAY],
	monday => $row->[MONDAY],
	tuesday => $row->[TUESDAY],
	wednesday => $row->[WEDNESDAY],
	thursday => $row->[THURSDAY],
	friday => $row->[FRIDAY],
	saturday => $row->[SATURDAY],
	per_week => to_num($row->[REGULAR_HRS])
    };
    return $href;
}

#-----------------------------------------------------------------------------------
sub extract_technology {
    my $row = shift;
    return if ($row->[SP_ID] == 0);  # library system level, we want branch-level
    
    my $href = {
	co_lib_id => $row->[LS_ID],  # will be used to associate other data to library
	co_br_id => $row->[LS_ID] . "-" . $row->[SP_ID],
	symbol => uc $row->[NUC],
	computers => to_num($row->[TOT_NUMBER_COMPUTERS_IN_LIB]),
	public_access_computers => to_num($row->[TOT_PACS]),
	computer_bookings => to_num($row->[TOT_NUMBER_COMPUTER_BKINGS]),
	website_visits => to_num($row->[E_VISITS]),
	barcode_items_prefix => $row->[BK_BARCODE],
	barcode_items_length => to_num($row->[BK_BRCD_LNGTH]),
	barcode_patron_prefix => $row->[PTRN_BARCODE],
	barcode_patron_length => to_num($row->[PTRN_BARCODE_LNGTH]),
	ils => $row->[LIB_SYSTEM]
    };
    return $href;
}

#-----------------------------------------------------------------------------------
sub extract_activities {
    my $row = shift;
    return if ($row->[SP_ID] == 0);  # library system level, we want branch-level
    
    my $href = {
	co_lib_id => $row->[LS_ID],  # will be used to associate other data to library
	co_br_id => $row->[LS_ID] . "-" . $row->[SP_ID],
	symbol => uc $row->[NUC],
	informational_transactions => to_num($row->[INFO_TRANS]),
	gate_count => to_num($row->[GATE_COUNT]),
	program_attendance => to_num($row->[PROGRAM]),
    };
    return $href;
}

#-----------------------------------------------------------------------------------
sub extract_ill {
    my $row = shift;
    return if ($row->[SP_ID] == 0);  # library system level, we want branch-level
    
    my $href = {
	co_lib_id => $row->[LS_ID],  # will be used to associate other data to library
	co_br_id => $row->[LS_ID] . "-" . $row->[SP_ID],
	symbol => uc $row->[NUC],
	requests_made => to_num($row->[MAPLIN_REQ_MADE]),
	items_received => to_num($row->[ILL_IN]),
	requests_received => to_num($row->[MAPLIN_REQ_REC]),
	items_sent => to_num($row->[ILL_OUT]),
    };
    return $href;
}

#-----------------------------------------------------------------------------------
sub extract_ebook_circ {
    my $row = shift;
    return if ($row->[SP_ID] == 0);  # library system level, we want branch-level
    
    my $href = {
	co_lib_id => $row->[LS_ID],  # will be used to associate other data to library
	co_br_id => $row->[LS_ID] . "-" . $row->[SP_ID],
	symbol => uc $row->[NUC],
	adobe_epub => to_num($row->[ADOBE_EPUB]),
	adobe_pdf => to_num($row->[ADOBE_PDF]),
	disney_online => to_num($row->[DISNEY]),
	open_epub => to_num($row->[OPEN_EPUB]),
	open_pdf => to_num($row->[OPEN_PDF]),
	mobipocket => to_num($row->[MOBIPOCKET]),
	overdrive_read => to_num($row->[READ]),
	overdrive_listen => to_num($row->[LISTEN]),
	mp3_audio => to_num($row->[MP3]),
	wma_audio => to_num($row->[WMA]),
	database_sessions => to_num($row->[EBSCO_SEARCH]),
    };
    return $href;
}

#-----------------------------------------------------------------------------------
sub extract_social_media {
    my $row = shift;
    return if ($row->[SP_ID] == 0);  # library system level, we want branch-level
    
    my $has_facebook = $row->[FB_YN];
    if ($has_facebook) { $has_facebook = uc($has_facebook) eq 'YES' ? 1 : 0 } else { $has_facebook = 0 }
    my $has_twitter = $row->[TW_YN];
    if ($has_twitter) { $has_twitter = uc($has_twitter) eq 'YES' ? 1 : 0 } else { $has_twitter = 0 }
    my $has_flickr = $row->[FL_YN];
    if ($has_flickr) { $has_flickr = uc($has_flickr) eq 'YES' ? 1 : 0 } else { $has_flickr = 0 }
    my $has_blog = $row->[BG_YN];
    if ($has_blog) { $has_blog = uc($has_blog) eq 'YES' ? 1 : 0 } else { $has_blog = 0 }
    my $has_gplus = $row->[GG_YN];
    if ($has_gplus) { $has_gplus = uc($has_gplus) eq 'YES' ? 1 : 0 } else { $has_gplus = 0 }
    my $has_youtube = $row->[YT_YN];
    if ($has_youtube) { $has_youtube = uc($has_youtube) eq 'YES' ? 1 : 0 } else { $has_youtube = 0 }
    my $has_pinterest = $row->[PN_YN];
    if ($has_pinterest) { $has_pinterest = uc($has_pinterest) eq 'YES' ? 1 : 0 } else { $has_pinterest = 0 }
    my $has_instagram = $row->[IN_YN];
    if ($has_instagram) { $has_instagram = uc($has_instagram) eq 'YES' ? 1 : 0 } else { $has_instagram = 0 }
    my $has_other_1 = $row->[OTH1_YN];
    if ($has_other_1) { $has_other_1 = uc($has_other_1) eq 'YES' ? 1 : 0 } else { $has_other_1 = 0 }
    my $has_other_2 = $row->[OTH2_YN];
    if ($has_other_2) { $has_other_2 = uc($has_other_2) eq 'YES' ? 1 : 0 } else { $has_other_2 = 0 }
    my $has_other_3 = $row->[OTH3_YN];
    if ($has_other_3) { $has_other_3 = uc($has_other_3) eq 'YES' ? 1 : 0 } else { $has_other_3 = 0 }

    my $href = {
	co_lib_id => $row->[LS_ID],  # will be used to associate other data to library
	co_br_id => $row->[LS_ID] . "-" . $row->[SP_ID],
	symbol => uc $row->[NUC],
	has_facebook => $has_facebook,
	facebook_handle => $row->[FB_HNDL],
	facebook_followers => to_num($row->[FB_FLWR]),
	facebook_posts => to_num($row->[FB_PST]),
	has_twitter => $has_twitter,
	twitter_handle => $row->[TW_HNDL],
	twitter_followers => to_num($row->[TW_FLWR]),
	twitter_posts => to_num($row->[TW_PST]),
	has_flickr => $has_flickr,
	flickr_handle => $row->[FL_HNDL],
	flickr_followers => to_num($row->[FL_FLWR]),
	flickr_posts => to_num($row->[FL_PST]),
	has_blog => $has_blog,
	blog_handle => $row->[BG_HNDL],
	blog_followers => to_num($row->[BG_FLWR]),
	blog_posts => to_num($row->[BG_PST]),
	has_google_plus => $has_gplus,
	google_plus_handle => $row->[GG_HNDL],
	google_plus_followers => to_num($row->[GG_FLWR]),
	google_plus_posts => to_num($row->[GG_PST]),
	has_youtube => $has_youtube,
	youtube_handle => $row->[YT_HNDL],
	youtube_followers => to_num($row->[YT_FLWR]),
	youtube_posts => to_num($row->[YT_PST]),
	has_pinterest => $has_pinterest,
	pinterest_handle => $row->[PN_HNDL],
	pinterest_followers => to_num($row->[PN_FLWR]),
	pinterest_posts => to_num($row->[PN_PST]),
	has_instagram => $has_instagram,
	instagram_handle => $row->[IN_HNDL],
	instagram_followers => to_num($row->[IN_FLWR]),
	instagram_posts => to_num($row->[IN_PST]),
	has_other_1 => $has_other_1,
	other_1_handle => $row->[OTH1_HNDL],
	other_1_followers => to_num($row->[OTH1_FLWR]),
	other_1_posts => to_num($row->[OTH1_PST]),
	has_other_2 => $has_other_2,
	other_2_handle => $row->[OTH2_HNDL],
	other_2_followers => to_num($row->[OTH2_FLWR]),
	other_2_posts => to_num($row->[OTH2_PST]),
	has_other_3 => $has_other_3,
	other_3_handle => $row->[OTH3_HNDL],
	other_3_followers => to_num($row->[OTH3_FLWR]),
	other_3_posts => to_num($row->[OTH3_PST]),
    };
    return $href;
}

#-----------------------------------------------------------------------------------
sub extract_personnel {
    my $row = shift;
    return if ($row->[SP_ID] == 0);  # library system level, we want branch-level
    
    my $href = {
	co_lib_id => $row->[LS_ID],  # will be used to associate other data to library
	co_br_id => $row->[LS_ID] . "-" . $row->[SP_ID],
	symbol => uc $row->[NUC],
	staff_count_full_time => to_num($row->[NUMBER_FT_STAFF]),
	staff_count_part_time => to_num($row->[NUMBER_PT_STAFF]),
	weekly_hours_professional => to_num($row->[TOT_HRS_WORKED_PROFESSIONAL]),
	weekly_hours_library_tech => to_num($row->[TOT_HRS_WORKED_PARAPRO]),
	weekly_hours_other => to_num($row->[TOT_HRS_WORKED_OTHER]),
	total_weekly_hours_reported_all_staff => to_num($row->[REP_TOT_HRS_ALL_STAFF]),
	weekly_hours_worked_when_closed => to_num($row->[EXTRA_HOURS])
    };
    return $href;
}




#-----------------------------------------------------------------------------------
sub load_library {
    my $data = shift;

    print "\n\n" if ($verbose);
    
    my $library_id = add_library($dbh, $data->{library});
    if ($library_id) {
	
	$coLib2pgLib{ $data->{library}->{co_lib_id} } = $library_id;
	print "symbol is [" . $data->{library}{symbol} . "]\n";
	$s2lm->{ $data->{library}->{symbol} }{ library_id } = $library_id;
#	print "s2lm:\n" . Dumper($s2lm->{ $data->{library}->{symbol} }) . "\n";

	foreach my $mun (@{ $data->{municipalities} }) {
	    my $mun_id = add_municipality($dbh, $mun);
	    if ($mun_id) {
		my $rv = add_libmun($dbh,$library_id,$mun_id,
				    $mun->{contribution});
		if (!defined $rv) {
		    carp "could not create library/municipality relation";
		}
	    } else {
		carp "could not add municipality";
	    }
	}
	my $fin_id = add_financials($dbh, $library_id, $data->{financial});
	if (!defined $fin_id) {
	    carp "could not add financial";
	}
    } else { 
	carp "could not add library"; 
    }
    
}

#-----------------------------------------------------------------------------------
sub load_branch {
    my $data = shift;

    my $branch_id = add_branch($dbh, $data->{branch});
    if ($branch_id) {

	$coBr2pgBr{ $data->{branch}->{co_br_id} } = $branch_id;

	add_contact( $dbh, $data->{contact} ) || croak "could not add contact";
	add_circ( $dbh, $data->{circ} ) || croak "could not add circ";
	add_collection( $dbh, $data->{collection} ) || croak "could not add collection";
	add_hours( $dbh, $data->{hours} ) || croak "could not add hours";
	add_tech( $dbh, $data->{tech} ) || croak "could not add tech";
	add_activities( $dbh, $data->{activities} ) || croak "could not add activities";
	add_ill( $dbh, $data->{ill} ) || croak "could not add ill";
	add_ebook_circ( $dbh, $data->{ebook_circ} ) || croak "could not add ebook_circ";
	add_social_media( $dbh, $data->{social_media} ) || croak "could not add social_media";
	add_personnel( $dbh, $data->{personnel} ) || croak "could not add personnel";

    } else {
	croak "could not add branch";
    }
}


#-----------------------------------------------------------------------------------
# I hate special cases!
#-----------------------------------------------------------------------------------
sub load_parkland_municipalities {
    my $data = shift;

    print "\n\tloading parkland municipalities\n" if ($verbose);
    print Dumper($data->[0]) . "\n";
    
    my $library_id = $coLib2pgLib{ $data->[0]->{contribution_to} };
    print "\tlib id: $library_id\n";
    if ($library_id) {
	foreach my $mun (@$data) {
	    my $mun_id = add_municipality($dbh, $mun);
	    if ($mun_id) {
		my $rv = add_libmun($dbh,$library_id,$mun_id,
				    $mun->{contribution});
		if (!defined $rv) {
		    carp "could not create library/municipality relation";
		}
	    } else {
		carp "could not add municipality";
	    }
	}
    }
}




#-----------------------------------------------------------------------------------
sub add_library {
    my ($dbh,$lib) = @_;
    print $lib->{name} . "\n------------------------------------------\n" if ($verbose);
    my $retval;
    my $ary_ref = $dbh->selectrow_arrayref("select id from libraries where name=? and year=?", undef, $lib->{name}, $lib->{year});
    if (defined $ary_ref) {
	# library exists
	$retval = $ary_ref->[0];
	print "exists, id $retval\n" if ($verbose);
    } else {
	# need to add library
	#print STDERR Dumper($lib) . "\n";
	eval {
	    $dbh->do("INSERT INTO libraries (year,name,fee_nonresident_single,fee_nonresident_family,established,is_registered_charity,has_access_copyright_license,has_board_minutes_on_website,strategic_plan_start,strategic_plan_end,has_technology_plan) VALUES (?,?,?,?,to_date(?,'YYYY-MM-DD'),?,?,?,to_date(?,'YYYY-MM-DD'),to_date(?,'YYYY-MM-DD'),?)",
		     undef,
		     $lib->{year},
		     $lib->{name},
		     $lib->{fee_nr_single},
		     $lib->{fee_nr_family},
		     $lib->{established},
		     $lib->{is_registered_charity},
		     $lib->{has_access_copyright_license},
		     $lib->{has_board_minutes_on_website},
		     $lib->{strategic_plan_start},
		     $lib->{strategic_plan_end},
		     $lib->{has_technology_plan}
		);
	    
	    $dbh->commit;
	};  # end of eval
	if ($@) {
	    warn "insert into libraries aborted because $@";
	    eval { $dbh->rollback };
	} else {
	    my $ary_ref = $dbh->selectrow_arrayref("select id from libraries where name=? and year=?", undef, $lib->{name},$lib->{year});
	    $retval = $ary_ref->[0];
	    print "added, id $retval\n" if ($verbose);
	}
    }
    return $retval;
}

#-----------------------------------------------------------------------------------
sub add_municipality {
    my ($dbh,$mun) = @_;
    print "\tadding municipality [" . $mun->{name} . "]:\n" if ($verbose);

    my $retval;

    if ($mun->{name} eq 'Winnipeg') { $mun->{name} = 'City of Winnipeg' };
    
    my $ary_ref = $dbh->selectrow_arrayref("select id from municipalities where name=? and year=?", undef, $mun->{name}, $mun->{year});
    if (defined $ary_ref) {
	# municipality exists
	$retval = $ary_ref->[0];
	print "\t\tmunicipality exists, id $retval\n" if ($verbose);
    } else {
	# need to add municipality
	eval {
	    $dbh->do("INSERT INTO municipalities (year,name,population,is_bilingual,is_northern) VALUES (?,?,?,?,?)", 
		     undef,
		     $mun->{year},
		     $mun->{name},
		     $mun->{population},
		     $mun->{is_bilingual},
		     $mun->{is_northern}
		);
	    
	    $dbh->commit;
	};  # end of eval
	if ($@) {
	    warn "\t\tinsert into municipalities aborted because $@";
	    eval { $dbh->rollback };
	} else {
	    my $ary_ref = $dbh->selectrow_arrayref("select id from municipalities where name=? and year=?", undef, $mun->{name}, $mun->{year});
	    $retval = $ary_ref->[0];
	    print "\t\tmunicipality added, id $retval\n" if ($verbose);
	}
    }
    return $retval;
}

#-----------------------------------------------------------------------------------
sub add_libmun {
    my ($dbh,$library_id,$mun_id,$contrib) = @_;
    print "\t\tcreating library/municipality relation\n" if ($verbose);
    my $retval;
    eval {
        $retval = $dbh->do("INSERT INTO libmun (library_id,municipality_id,contribution) VALUES (?,?,?)", 
			   undef,
			   $library_id,$mun_id,$contrib
	    );
        
        $dbh->commit;
    };  # end of eval
    if ($@) {
        warn "\t\tinsert into libmun aborted because $@";
        eval { $dbh->rollback };
    }
    return $retval;
}

#-----------------------------------------------------------------------------------
sub add_financials {
    my ($dbh,$library_id,$fin) = @_;
    my $retval;
    eval {
	$retval = $dbh->do("INSERT INTO financial (library_id,income_municipal_contribution,income_provincial_operating_grant,income_provincial_collection_development_grant,income_provincial_establishment_grant,income_other_miscellaneous,income_other_municipal,income_other_provincial,income_other_federal,income_other_private,expenditure_personnel,expenditure_materials,expenditure_capital,expenditure_building,expenditure_technology,expenditure_other) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", 
			   undef,
			   $library_id,
			   $fin->{inc_mun},
			   $fin->{inc_prov_operating},
			   $fin->{inc_prov_colldev},
			   $fin->{inc_prov_establish},
			   $fin->{inc_other_misc},
			   $fin->{inc_other_mun},
			   $fin->{inc_other_prov},
			   $fin->{inc_other_fed},
			   $fin->{inc_other_private},
			   $fin->{exp_personnel},
			   $fin->{exp_materials},
			   $fin->{exp_capital},
			   $fin->{exp_building},
			   $fin->{exp_technology},
			   $fin->{exp_other}
	    );
	
	$dbh->commit;
    };  # end of eval
    if ($@) {
	warn "\tinsert into financial aborted because $@";
	eval { $dbh->rollback };
    } else {
	if ($verbose) {
	    my $ary_ref = $dbh->selectrow_arrayref("select id from financial where library_id=?", undef, $library_id);
	    print "\tfinancials added, id " . $ary_ref->[0] . "\n" if ($verbose);
	}
    }
    return $retval;
}

#-----------------------------------------------------------------------------------
# Branch-level
#-----------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------
sub add_branch {
    my ($dbh,$branch) = @_;
    print "\n\tbranch: " . $branch->{name} . " [" . $branch->{symbol} . "]\n" if ($verbose);
    my $retval;

    # CO has no data on which municipality a branch is in... so there's this:
    my $library_id = $coLib2pgLib{ $branch->{co_lib_id} };
    my $municipality = $s2lm->{ $branch->{symbol} }{ municipality };
    print "\t\t...found in s2lm at [$municipality]\n";
    
    my $ary_ref = $dbh->selectrow_arrayref("select id from municipalities where name=?", undef, $municipality);
    my $mun_id;
    if (defined $ary_ref) {
	# symbol exists in lookup table
	print "\t\t...found municipality id: " . $ary_ref->[0] . "\n" if ($verbose);
	$mun_id = $ary_ref->[0];
    } else {
	print STDERR "\t\t*** invalid municipality: " . $branch->{name} . ", " . $branch->{symbol} . ", " . $s2lm->{ $branch->{symbol} }{ municipality } . "\n";
    }

    eval {
	$dbh->do("INSERT INTO branches (year,library_id,municipality_id,name,symbol,facility_owner,facility_term_expires,annual_rent,floor_space,active_memberships,nonresident_single_memberships,nonresident_family_memberships) VALUES (?,?,?,?,?,?,to_date(?,'YYYY-MM-DD'),?,?,?,?,?)",
		 undef,
		 $branch->{year},
		 $library_id,
		 $mun_id, # may be undef if not found in s2lm
		 $branch->{name},
		 $branch->{symbol},
		 $branch->{facility_owner},
		 $branch->{facility_term_expires},
		 $branch->{annual_rent},
		 $branch->{floor_space},
		 $branch->{active_memberships},
		 $branch->{nonresident_single_memberships},
		 $branch->{nonresident_family_memberships}
	    );
	    
	$dbh->commit;
    };  # end of eval
    if ($@) {
	warn "\t\tinsert into branches aborted because $@";
	eval { $dbh->rollback };
    } else {
	my $ary_ref = $dbh->selectrow_arrayref("select id from branches where symbol=? and year=?", undef, $branch->{symbol},$branch->{year});
	$retval = $ary_ref->[0];
    }
    print "\t\t...returning [$retval]\n" if ($verbose);
    return $retval;
}

#-----------------------------------------------------------------------------------
sub add_contact {
    my ($dbh,$data) = @_;
    my $branch_id = $coBr2pgBr{ $data->{co_br_id} };

    my $retval;
    eval {
	$retval = $dbh->do("INSERT INTO contact (branch_id,librarian,street,box,town,province,postal_code,phone,fax,email_general,email_admin,email_ill,website,catalogue) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)", 
		 undef,
		 $branch_id,
		 $data->{librarian},$data->{street},$data->{box},
		 $data->{town},$data->{province},$data->{postal_code},
		 $data->{phone},$data->{fax},$data->{email_general},
		 $data->{email_admin},$data->{email_ill},$data->{website},
		 $data->{catalogue}
	    );
	
	$dbh->commit;
    };  # end of eval
    if ($@) {
	warn "\tinsert into contact aborted because $@";
	eval { $dbh->rollback };
    } else {
	if ($verbose) {
	    my $ary_ref = $dbh->selectrow_arrayref("select id from contact where branch_id=?", undef, $branch_id);
	    print "\tcontact added, id " .$ary_ref->[0] . "\n";
	}
    }
    return $retval;
}

#-----------------------------------------------------------------------------------
sub add_circ {
    my ($dbh,$data) = @_;
    my $retval;

    my $branch_id = $coBr2pgBr{ $data->{co_br_id} };
    eval {
	$retval = $dbh->do("INSERT INTO circulations (branch_id,adult,children,audio_visual,ebooks) VALUES (?,?,?,?,?)", 
		 undef,
		 $branch_id,
		 $data->{adult},
		 $data->{children},
		 $data->{audio_visual},
		 $data->{ebooks}
	    );
	
	$dbh->commit;
    };  # end of eval
    if ($@) {
	warn "\tinsert into circulations aborted because $@";
	eval { $dbh->rollback };
    } else {
	if ($verbose) {
	    my $ary_ref = $dbh->selectrow_arrayref("select id from circulations where branch_id=?", undef, $branch_id);
	    print "\tcirculations added, id " . $ary_ref->[0] . "\n";
	}
    }
    return $retval;
}

#-----------------------------------------------------------------------------------
sub add_collection {
    my ($dbh,$data) = @_;
    my $branch_id = $coBr2pgBr{ $data->{co_br_id} };
    my $retval;
    eval {
	$retval = $dbh->do("INSERT INTO collections (branch_id,english,french,other,serial_subscriptions) VALUES (?,?,?,?,?)", 
			   undef,
			   $branch_id,
			   $data->{english},$data->{french},$data->{other},
			   $data->{serial_subscripstions}
	    );
	
	$dbh->commit;
    };  # end of eval
    if ($@) {
	warn "\tinsert into collections aborted because $@";
	eval { $dbh->rollback };
    } else {
	if ($verbose) {
	    my $ary_ref = $dbh->selectrow_arrayref("select id from collections where branch_id=?", undef, $branch_id);
	    print "\tcollection added, id " . $ary_ref->[0] . "\n";
	}
    }
    return $retval;
}

#-----------------------------------------------------------------------------------
sub add_hours {
    my ($dbh,$data) = @_;
    my $branch_id = $coBr2pgBr{ $data->{co_br_id} };

    my $retval;
    eval {
        $retval = $dbh->do("INSERT INTO hours_of_operation (branch_id,seasonal,season_begins,season_ends,sunday,monday,tuesday,wednesday,thursday,friday,saturday,per_week) VALUES (?,?,to_date(?,'YYYY-MM-DD'),to_date(?,'YYYY-MM-DD'),?,?,?,?,?,?,?,?)", 
			   undef,
			   $branch_id,
			   $data->{seasonal},$data->{season_begins},$data->{season_ends},
			   $data->{sunday},$data->{monday},$data->{tuesday},
			   $data->{wednesday},$data->{thursday},$data->{friday},
			   $data->{saturday},$data->{per_week}
	    );
        
        $dbh->commit;
    };  # end of eval
    if ($@) {
        warn "\tinsert into hours_of_operation aborted because $@";
        eval { $dbh->rollback };
    } else {
	if ($verbose) {
	    my $ary_ref = $dbh->selectrow_arrayref("select id from hours_of_operation where branch_id=? and seasonal=?", undef, $branch_id,$data->{seasonal});
	    print "\thours added, id " . $ary_ref->[0] . "\n";
	}
    }
    return $retval;
}

#-----------------------------------------------------------------------------------
sub add_tech {
    my ($dbh,$data) = @_;
    my $branch_id = $coBr2pgBr{ $data->{co_br_id} };
    my $retval;
    eval {
	$retval = $dbh->do("INSERT INTO technology (branch_id,computers,public_access_computers,computer_bookings,website_visits,barcode_items_prefix,barcode_items_length,barcode_patron_prefix,barcode_patron_length,ils) VALUES (?,?,?,?,?,?,?,?,?,?)", 
			   undef,
			   $branch_id,
			   $data->{computers},$data->{public_access_computers},
			   $data->{computer_bookings},$data->{website_visits},
			   $data->{barcode_items_prefix},$data->{barcode_items_length},
			   $data->{barcode_patron_prefix},$data->{barcode_patron_length},
			   $data->{ils}
	    );
	
	$dbh->commit;
    };  # end of eval
    if ($@) {
	warn "\tinsert into technology aborted because $@";
	eval { $dbh->rollback };
    } else {
	if ($verbose) {
	    my $ary_ref = $dbh->selectrow_arrayref("select id from technology where branch_id=?", undef, $branch_id);
	    print "\ttechnology added, id " . $ary_ref->[0] . "\n";
	}
    }
    return $retval;
}

#-----------------------------------------------------------------------------------
sub add_activities {
    my ($dbh,$data) = @_;
    my $branch_id = $coBr2pgBr{ $data->{co_br_id} };
    my $retval;
    eval {
	$retval = $dbh->do("INSERT INTO activities (branch_id,informational_transactions,gate_count,program_attendance) VALUES (?,?,?,?)", 
			   undef,
			   $branch_id,
			   $data->{informational_transactions},
			   $data->{gate_count},
			   $data->{program_attendance}
	    );
	
	$dbh->commit;
    };  # end of eval
    if ($@) {
	warn "\tinsert into activities aborted because $@";
	eval { $dbh->rollback };
    } else {
	if ($verbose) {
	    my $ary_ref = $dbh->selectrow_arrayref("select id from activities where branch_id=?", undef, $branch_id);
	    print "\tactivities added, id " . $ary_ref->[0] . "\n";
	}
    }
    return $retval;
}

#-----------------------------------------------------------------------------------
sub add_ill {
    my ($dbh,$data) = @_;
    my $branch_id = $coBr2pgBr{ $data->{co_br_id} };
    my $retval;
    eval {
	$retval = $dbh->do("INSERT INTO ill (branch_id,requests_made,items_received,requests_received,items_sent) VALUES (?,?,?,?,?)", 
			   undef,
			   $branch_id,
			   $data->{requests_made},$data->{items_received},
			   $data->{requests_received},$data->{items_sent}
	    );
	
	$dbh->commit;
    };  # end of eval
    if ($@) {
	warn "\tinsert into ill aborted because $@";
	eval { $dbh->rollback };
    } else {
	if ($verbose) {
	    my $ary_ref = $dbh->selectrow_arrayref("select id from ill where branch_id=?", undef, $branch_id);
	    print "\till added, id " . $ary_ref->[0] . "\n";
	}
    }
    return $retval;
}

#-----------------------------------------------------------------------------------
sub add_ebook_circ {
    my ($dbh,$data) = @_;
    my $branch_id = $coBr2pgBr{ $data->{co_br_id} };
    my $retval;
    eval {
	$retval = $dbh->do("INSERT INTO ebook_circ (branch_id,adobe_epub,adobe_pdf,disney_online,open_epub,open_pdf,mobipocket,overdrive_read,overdrive_listen,mp3_audio,wma_audio,database_sessions) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)", 
			   undef,
			   $branch_id,
			   $data->{adobe_epub},$data->{adobe_pdf},$data->{disney_online},
			   $data->{open_epub},$data->{open_pdf},$data->{mobipocket},
			   $data->{overdrive_read},$data->{overdrive_listen},
			   $data->{mp3_audio},$data->{wma_audio},
			   $data->{database_sessions}
	    );
	
	$dbh->commit;
    };  # end of eval
    if ($@) {
	warn "\tinsert into ebook_circ aborted because $@";
	eval { $dbh->rollback };
    } else {
	if ($verbose) {
	    my $ary_ref = $dbh->selectrow_arrayref("select id from ebook_circ where branch_id=?", undef, $branch_id);
	    print "\tebook_circ added, id " . $ary_ref->[0] . "\n";
	}
    }
    return $retval;
}

#-----------------------------------------------------------------------------------
sub add_social_media {
    my ($dbh,$data) = @_;
    my $branch_id = $coBr2pgBr{ $data->{co_br_id} };
    my $retval;
    eval {
	$retval = $dbh->do("INSERT INTO social_media (branch_id,has_facebook,facebook_handle,facebook_followers,facebook_posts,has_twitter,twitter_handle,twitter_followers,twitter_posts,has_flickr,flickr_handle,flickr_followers,flickr_posts,has_blog,blog_handle,blog_followers,blog_posts,has_google_plus,google_plus_handle,google_plus_followers,google_plus_posts,has_youtube,youtube_handle,youtube_followers,youtube_posts,has_pinterest,pinterest_handle,pinterest_followers,pinterest_posts,has_instagram,instagram_handle,instagram_followers,instagram_posts,has_other_1,other_1_handle,other_1_followers,other_1_posts,has_other_2,other_2_handle,other_2_followers,other_2_posts,has_other_3,other_3_handle,other_3_followers,other_3_posts) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", 
			   undef,
			   $branch_id,
			   $data->{has_facebook},$data->{facebook_handle},
			   $data->{facebook_followers},$data->{facebook_posts},
			   $data->{has_twitter},$data->{twitter_handle},
			   $data->{twitter_followers},$data->{twitter_posts},
			   $data->{has_flickr},$data->{flickr_handle},
			   $data->{flickr_followers},$data->{flickr_posts},
			   $data->{has_blog},$data->{blog_handle},
			   $data->{blog_followers},$data->{blog_posts},
			   $data->{has_google_plus},$data->{google_plus_handle},
			   $data->{google_plus_followers},$data->{google_plus_posts},
			   $data->{has_youtube},$data->{youtube_handle},
			   $data->{youtube_followers},$data->{youtube_posts},
			   $data->{has_pinterest},$data->{pinterest_handle},
			   $data->{pinterest_followers},$data->{pinterest_posts},
			   $data->{has_instagram},$data->{instagram_handle},
			   $data->{instagram_followers},$data->{instagram_posts},
			   $data->{has_other_1},$data->{other_1_handle},
			   $data->{other_1_followers},$data->{other_1_posts},
			   $data->{has_other_2},$data->{other_2_handle},
			   $data->{other_2_followers},$data->{other_2_posts},
			   $data->{has_other_3},$data->{other_3_handle},
			   $data->{other_3_followers},$data->{other_3_posts}
	    );
	
	$dbh->commit;
    };  # end of eval
    if ($@) {
	warn "\tinsert into social_media aborted because $@";
	eval { $dbh->rollback };
    } else {
	if ($verbose) {
	    my $ary_ref = $dbh->selectrow_arrayref("select id from social_media where branch_id=?", undef, $branch_id);
	    print "\tsocial_media added, id " . $ary_ref->[0] . "\n";
	}
    }
    return $retval;
}

#-----------------------------------------------------------------------------------
sub add_personnel {
    my ($dbh,$data) = @_;
    my $branch_id = $coBr2pgBr{ $data->{co_br_id} };
    my $retval;
    eval {
	$retval = $dbh->do("INSERT INTO personnel (branch_id,staff_count_full_time,staff_count_part_time,weekly_hours_professional,weekly_hours_library_tech,weekly_hours_other,total_weekly_hours_reported_all_staff,weekly_hours_worked_when_closed) VALUES (?,?,?,?,?,?,?,?)", 
			   undef,
			   $branch_id,
			   $data->{staff_count_full_time},
			   $data->{staff_count_part_time},
			   $data->{weekly_hours_professional},
			   $data->{weekly_hours_library_tech},
			   $data->{weekly_hours_other},
			   $data->{total_weekly_hours_reported},
			   $data->{weekly_hours_worked_when_closed}
	    );
	
	$dbh->commit;
    };  # end of eval
    if ($@) {
	warn "\tinsert into personnel aborted because $@, trying minimal";
	eval { $dbh->rollback };
	eval {
	    $retval = $dbh->do("INSERT INTO personnel (branch_id,is_confirmed) VALUES (?,?)", 
			       undef,
			       $branch_id,
			       0
		);
	    
	    $dbh->commit;
	};  # end of eval
	if ($@) {
	    warn "\tminimal insert into personnel aborted because $@";
	    eval { $dbh->rollback };
	}
    } else {
	if ($verbose) {
	    my $ary_ref = $dbh->selectrow_arrayref("select id from personnel where branch_id=?", undef, $branch_id);
	    print "\tpersonnel added, id " . $ary_ref->[0] . "\n";
	}
    }
    return $retval;
}


#-----------------------------------------------------------------------------------
sub generate_s2lm {
    my $year = shift;
    $year =~ to_num($year);
    my $s2lm;
    if ($year <= 2014) { $s2lm = generate_s2lm_pre2015(); }
    else { $s2lm = generate_s2lm_2015_plus(); }
    return $s2lm;
}


#-----------------------------------------------------------------------------------
# I'm leaving the "# 2016" comments as a record of what has changed due to amalgamation....
#-----------------------------------------------------------------------------------
sub generate_s2lm_pre2015 {
    my %s2lm = (
	'MGI' => { library => 'Bette Winner Public Library', municipality => 'Town of Gillam'},
	'MSTG' => { library => 'Bibliothèque Allard Regional Library', municipality => 'RM of Alexander'},
	'MBBB' => { library => 'Bibliothèque Allard Regional Library', municipality => 'Town of Powerview/Pine Falls'},
	'MVBB' => { library => 'Bibliothèque Allard Regional Library', municipality => 'RM of Victoria Beach'},
	'MSJB' => { library => 'Bibliothèque Montcalm Library', municipality => 'RM of Montcalm'},
# 2016	'MNDP' => { library => 'Lorne Library Services', municipality => 'Municipality of Lorne'},
	'MNDP' => { library => 'Bibliothèque Pere Champagne Library', municipality => 'Village of Notre-Dame-de-Lourdes'},
	'MIBR' => { library => 'Bibliothèque Ritchot Library', municipality => 'RM of Ritchot'},
	'MSAD' => { library => 'Bibliothèque Ritchot Library', municipality => 'RM of Ritchot'},
	'MSAG' => { library => 'Bibliothèque Ritchot Library', municipality => 'RM of Ritchot'},
	'MLB' => { library => 'Bibliothèque Saint-Joachim Library', municipality => 'RM of La Broquerie'},
# 2016	'MS' => { library => 'Lorne Library Services', municipality => 'Municipality of Lorne'},
	'MS' => { library => 'Bibliothèque Somerset', municipality => 'Village of Somerset'},
# 2016	'MSCL' => { library => 'Bibliothèque St. Claude Library', municipality => 'RM of Grey'},
	'MSCL' => { library => 'Bibliothèque St. Claude Library', municipality => 'Village of St. Claude'},
	'MSA' => { library => 'Bibliothèque Ste Anne Library', municipality => 'Town of Ste. Anne'},
	'MTPL' => { library => 'Bibliothèque Taché  Library', municipality => 'RM of Tache'},
# 2016	'MBOM' => { library => 'Boissevain & Morton Regional Library', municipality => 'Municipality of Boissevain-Morton'},
	'MBOM' => { library => 'Boissevain & Morton Regional Library', municipality => 'Town of Boissevain'},
	'MVE' => { library => 'Border Regional Library', municipality => 'Town of Virden'},
# 2016	'ME' => { library => 'Border Regional Library', municipality => 'RM of Wallace-Woodworth'},
	'ME' => { library => 'Border Regional Library', municipality => 'Village of Elkhorn'},
# 2016	'MMCA' => { library => 'Border Regional Library', municipality => 'Municipality of Ellice-Archie'},
	'MMCA' => { library => 'Border Regional Library', municipality => 'RM of Archie'},
	'MCB' => { library => 'Boyne Regional Library', municipality => 'Town of Carman'},
# 2016	'MDB' => { library => 'Bren Del Win Centennial Library', municipality => 'Municipality of Deloraine-Winchester'},
	'MDB' => { library => 'Bren Del Win Centennial Library', municipality => 'Town of Deloraine'},
# 2016	'TWAS' => { library => 'Bren Del Win Centennial Library', municipality => 'RM of Brenda-Waskada'},
	'TWAS' => { library => 'Bren Del Win Centennial Library', municipality => 'Village of Waskada'},
	'MBBR' => { library => 'Brokenhead River Regional Library', municipality => 'Town of Beausejour'},
	'MCH' => { library => 'Churchill Public Library', municipality => 'Town of Churchill'},
# 2016	'MEPL' => { library => 'Emerson Public Library', municipality => 'Municipality of Emerson-Franklin'},
	'MEPL' => { library => 'Emerson Public Library', municipality => 'Town of Emerson'},
# 2016	'MEL' => { library => 'Eriksdale Public Library', municipality => 'RM of West Interlake'},
	'MEL' => { library => 'Eriksdale Public Library', municipality => 'RM of Eriksdale'},
	'MGE' => { library => 'Evergreen Regional Library', municipality => 'RM of Gimli'},
	'MAB' => { library => 'Evergreen Regional Library', municipality => 'Town of Arborg'},
# 2016	'MRB' => { library => 'Evergreen Regional Library', municipality => 'RM of Bifrost-Riverton'},
	'MRB' => { library => 'Evergreen Regional Library', municipality => 'Village of Riverton'},
	'MFF' => { library => 'Flin Flon Public Library', municipality => 'City of Flin Flon'},
	'MSEL' => { library => 'Gaynor Family Regional Library', municipality => 'City of Selkirk'},
# 2016	'MSOG' => { library => 'Glenwood & Souris Regional Library', municipality => 'Municipality of Souris-Glenwood'},
	'MSOG' => { library => 'Glenwood & Souris Regional Library', municipality => 'Town of Souris'},
	'MHH' => { library => 'Headingley Municipal Library', municipality => 'RM of Headingley'},
	'MSTE' => { library => 'Jake Epp Library', municipality => 'City of Steinbach'},
	'MSTP' => { library => 'Jolys Regional Library', municipality => 'Village of St. Pierre-Jolys'},
	'MSSM' => { library => 'Jolys Regional Library', municipality => 'RM of DeSalaberry'},
	'MLDB' => { library => 'Lac Du Bonnet Regional Library', municipality => 'Town of Lac Du Bonnet'},
	'MKL' => { library => 'Lakeland Regional Library', municipality => 'RM of Killarney-Turtle Mountain'},
# 2016	'MCCB' => { library => 'Lakeland Regional Library', municipality => 'Cartwright-Roblin Municipality'},
	'MCCB' => { library => 'Lakeland Regional Library', municipality => 'Village of Cartwright'},
	'MLR' => { library => 'Leaf Rapids Public Library', municipality => 'Town of Leaf Rapids'},
# 2016	'MPM' => { library => 'Louise Public Library', municipality => 'Municipality of Louise'},
	'MPM' => { library => 'Pilot Mound Public', municipality => 'Town of Pilot Mound'},
	'MLLC' => { library => 'Lynn Lake Centennial Library', municipality => 'Town of Lynn Lake'},
	'MMA' => { library => 'Manitou Regional Library', municipality => 'RM of Pembina'},
	'MMR' => { library => 'Minnedosa Regional Library', municipality => 'Town of Minnedosa'},
# 2016	'MMNN' => { library => 'North Norfolk-MacGregor Regional Library', municipality => 'Municipality of North Norfolk'},
	'MMNN' => { library => 'North Norfolk-MacGregor Regional Library', municipality => 'Town of Macgregor'},
	'MSRN' => { library => 'North-West Regional Library', municipality => 'Town of Swan River'},
# 2016	'MBB' => { library => 'North-West Regional Library', municipality => 'Municipality of Swan Valley West'},
	'MBB' => { library => 'North-West Regional Library', municipality => 'Village of Benito'},
	'MDP' => { library => 'Parkland Regional Library', municipality => undef },
	'MDPBR' => { library => 'Parkland Regional Library', municipality => 'RM of Mountain'},
# 2016	'MDPBI' => { library => 'Parkland Regional Library', municipality => 'Prairie View Municipality'},
	'MDPBI' => { library => 'Parkland Regional Library', municipality => 'Town of Birtle'},
# 2016	'MDPBO' => { library => 'Parkland Regional Library', municipality => 'Municipality of Minitonas-Bowsman'},
	'MDPBO' => { library => 'Parkland Regional Library', municipality => 'Village of Bowsman'},
	'MDA' => { library => 'Parkland Regional Library', municipality => 'City of Dauphin'},
# 2016	'MDPER' => { library => 'Parkland Regional Library', municipality => 'Municipality of Clanwilliam-Erickson'},
	'MDPER' => { library => 'Parkland Regional Library', municipality => 'Town of Erickson'},
# 2016	'MDPFO' => { library => 'Parkland Regional Library', municipality => 'Prairie View Municipality'},
	'MDPFO' => { library => 'Parkland Regional Library', municipality => 'RM of Birtle'},
# 2016	'MDPGP' => { library => 'Parkland Regional Library', municipality => 'Gilbert Plains Municipality'},
	'MDPGP' => { library => 'Parkland Regional Library', municipality => 'Town of Gilbert Plains'},
# 2016	'MDPGL' => { library => 'Parkland Regional Library', municipality => 'RM of Westlake-Gladstone'},
	'MDPGL' => { library => 'Parkland Regional Library', municipality => 'Town of Gladstone'},
# 2016	'MDPGV' => { library => 'Parkland Regional Library', municipality => 'Grandview Municipality'},
	'MDPGV' => { library => 'Parkland Regional Library', municipality => 'Town of Grandview'},
# 2016	'MDPHA' => { library => 'Parkland Regional Library', municipality => 'Hamiota Municipality'},
	'MDPHA' => { library => 'Parkland Regional Library', municipality => 'Town of Hamiota'},
# 2016	'MDPLA' => { library => 'Parkland Regional Library', municipality => 'RM of Westlake-Gladstone'},
	'MDPLA' => { library => 'Parkland Regional Library', municipality => 'RM of Lakeview'},
# 2016	'MDPMC' => { library => 'Parkland Regional Library', municipality => 'Municipality of McCreary'},
	'MDPMC' => { library => 'Parkland Regional Library', municipality => 'Village of McCreary'},
# 2016	'MDPMI' => { library => 'Parkland Regional Library', municipality => 'Municipality of Minitonas-Bowsman'},
	'MDPMI' => { library => 'Parkland Regional Library', municipality => 'Town of Minitonas'},
# 2016	'MDPOR' => { library => 'Parkland Regional Library', municipality => 'RM of Lakeshore'},
	'MDPOR' => { library => 'Parkland Regional Library', municipality => 'RM of Ochre River'},
# 2016	'MDPRO' => { library => 'Parkland Regional Library', municipality => 'Hillsburg-Roblin-Shell River'},
	'MDPRO' => { library => 'Parkland Regional Library', municipality => 'Town of Roblin'},
# 2016	'MDPSLA' => { library => 'Parkland Regional Library', municipality => 'RM of Ellice-Archie'},
	'MDPSLA' => { library => 'Parkland Regional Library', municipality => 'Village of St. Lazare'},
# 2016	'MDPSL' => { library => 'Parkland Regional Library', municipality => 'RM of Yellowhead'},
	'MDPSL' => { library => 'Parkland Regional Library', municipality => 'RM of Shoal Lake'},
# 2016	'MDPSI' => { library => 'Parkland Regional Library', municipality => 'RM of West Interlake'},
	'MDPSI' => { library => 'Parkland Regional Library', municipality => 'RM of Siglunes'},
# 2016	'MDPST' => { library => 'Parkland Regional Library', municipality => 'RM of Yellowhead'},
	'MDPST' => { library => 'Parkland Regional Library', municipality => 'RM of Strathclair'},
# 2016	'MDPWP' => { library => 'Parkland Regional Library', municipality => 'RM of Mossey River'},
	'MDPWP' => { library => 'Parkland Regional Library', municipality => 'Village of Winnipegosis'},
# 2016	'MRO' => { library => 'Parkland Regional Library', municipality => 'Rossburn Municipality'},
	'MRO' => { library => 'Rossburn Regional Library', municipality => 'Town of Rossburn'},
# 2016	'MSTR' => { library => 'Parkland Regional Library', municipality => 'Municipality of Ste. Rose'},
	'MSTR' => { library => 'Ste. Rose Regional Library', municipality => 'Town of Ste. Rose du Lac'},
	'MLPJ' => { library => 'Pauline Johnson Library', municipality => 'RM of Coldwell'},
	'MPFN' => { library => 'Peguis First Nation Public Library', municipality => 'Peguis First Nation'},
	'MP' => { library => 'Pinawa Public Library', municipality => 'LGD of Pinawa'},
	'MPLP' => { library => 'Portage la Prairie Regional Library', municipality => 'City of Portage La Prairie'},
# 2016	'MRIP' => { library => 'Prairie Crocus Regional Library', municipality => 'Riverdale Municipality'},
	'MRIP' => { library => 'Prairie Crocus Regional Library', municipality => 'Town of Rivers'},
	'MBA' => { library => 'RM of Argyle Public Library', municipality => 'RM of Argyle'},
# 2016	'MRA' => { library => 'Rapid City Regional Library', municipality => 'RM of Oakview'},
	'MRA' => { library => 'Rapid City Regional Library', municipality => 'Town of Rapid City'},
	'MRP' => { library => 'Reston District Library', municipality => 'RM of Pipestone'},
# 2016	'MRD' => { library => 'Russell & District Regional Library', municipality => 'Municipality of Russell-Binscarth'},
	'MRD' => { library => 'Russell & District Regional Library', municipality => 'Town of Russell'},
# 2016	'MBI' => { library => 'Russell & District Regional Library', municipality => 'Municipality of Russell-Binscarth'},
	'MBI' => { library => 'Russell & District Regional Library', municipality => 'Village of Binscarth'},
	'MSL' => { library => 'Snow Lake Community Library', municipality => 'Town of Snow Lake'},
	'MWOWH' => { library => 'South Central Regional Library', municipality => undef },   # South Central, HQ
	'MAOW' => { library => 'South Central Regional Library', municipality => 'Town of Altona'},
	'MMIOW' => { library => 'South Central Regional Library', municipality => 'RM of Thompson'},
	'MMOW' => { library => 'South Central Regional Library', municipality => 'City of Morden'},
	'MWOW' => { library => 'South Central Regional Library', municipality => 'City of Winkler'},
	'MSTOS' => { library => 'South Interlake Regional Library', municipality => 'Town of Stonewall'},
	'MTSIR' => { library => 'South Interlake Regional Library', municipality => 'Town of Teulon'},
	'MESM' => { library => 'Southwestern Manitoba Regional Library', municipality => 'Town of Melita'},
# 2016!	'MESMN' => { library => 'Southwestern Manitoba Regional Library', municipality => 'RM of Brenda-Waskada'},
	'MESMN' => { library => 'Southwestern Manitoba Regional Library', municipality => 'RM of Brenda'},
# 2016	'MESP' => { library => 'Southwestern Manitoba Regional Library', municipality => 'Municipality of Two Borders'},
	'MESP' => { library => 'Southwestern Manitoba Regional Library', municipality => 'RM of Edward'},
	'MDS' => { library => 'Springfield Public Library', municipality => 'RM of Springfield'},
	'MTP' => { library => 'The Pas Regional Library', municipality => 'Town of The Pas'},
	'MTH' => { library => 'Thompson Public Library', municipality => 'City of Thompson'},
	'MEC' => { library => 'UCN Chemawawin Public Library', municipality => 'Chemawawin'},
	'MNH' => { library => 'UCN Norway House Public Library', municipality => 'Norway House'},
	'MMVR' => { library => 'Valley Regional Library', municipality => 'Town of Morris'},
	'MHP' => { library => 'Victoria Municipal Library', municipality => 'RM of Victoria'},
	'MBW' => { library => 'Western Manitoba Regional Library', municipality => 'City of Brandon'},
	'MCNC' => { library => 'Western Manitoba Regional Library', municipality => 'Town of Carberry'},
# 2016	'MGW' => { library => 'Western Manitoba Regional Library', municipality => 'Municipality of Glenboro-South Cypress'},
	'MGW' => { library => 'Western Manitoba Regional Library', municipality => 'Village of Glenboro'},
# 2016	'MHW' => { library => 'Western Manitoba Regional Library', municipality => 'Municipality of Grassland'},
	'MHW' => { library => 'Western Manitoba Regional Library', municipality => 'Town of Hartney'},
	'MNW' => { library => 'Western Manitoba Regional Library', municipality => 'Town of Neepawa'},
	'MW' => { library => 'Winnipeg Public Library', municipality => undef },      # Winnipeg (with made-up branch symbols)
	'MWCH' => { library => 'Winnipeg Public Library', municipality => 'City of Winnipeg'},  #  Charlsewood
	'MWCO' => { library => 'Winnipeg Public Library', municipality => 'City of Winnipeg'},  #  Cornish
	'MWFG' => { library => 'Winnipeg Public Library', municipality => 'City of Winnipeg'},  #  Fort Garry
	'MWHE' => { library => 'Winnipeg Public Library', municipality => 'City of Winnipeg'},  #  Henderson
	'MWLR' => { library => 'Winnipeg Public Library', municipality => 'City of Winnipeg'},  #  Louis Riel
	'MWMU' => { library => 'Winnipeg Public Library', municipality => 'City of Winnipeg'},  #  Munroe
	'MWPT' => { library => 'Winnipeg Public Library', municipality => 'City of Winnipeg'},  #  Pembina Trail
	'MWOS' => { library => 'Winnipeg Public Library', municipality => 'City of Winnipeg'},  #  Osborne
	'MWMI' => { library => 'Winnipeg Public Library', municipality => 'City of Winnipeg'},  #  Millennium
	'MWRH' => { library => 'Winnipeg Public Library', municipality => 'City of Winnipeg'},  #  River Heights
	'MWWS' => { library => 'Winnipeg Public Library', municipality => 'City of Winnipeg'},  #  Sir William Stephenson
	'MWSB' => { library => 'Winnipeg Public Library', municipality => 'City of Winnipeg'},  #  St. Boniface
	'MWSJA' => { library => 'Winnipeg Public Library', municipality => 'City of Winnipeg'},  #  St. James-Assiniboia
	'MWSJ' => { library => 'Winnipeg Public Library', municipality => 'City of Winnipeg'},  #  St. John's
	'MWSV' => { library => 'Winnipeg Public Library', municipality => 'City of Winnipeg'},  #  St. Vital
	'MWTR' => { library => 'Winnipeg Public Library', municipality => 'City of Winnipeg'},  #  Transcona
	'MWWE' => { library => 'Winnipeg Public Library', municipality => 'City of Winnipeg'},  #  West End
	'MWWK' => { library => 'Winnipeg Public Library', municipality => 'City of Winnipeg'},  #  West Kildonan
	'MWWW' => { library => 'Winnipeg Public Library', municipality => 'City of Winnipeg'},  #  Westwood
	'MWWP' => { library => 'Winnipeg Public Library', municipality => 'City of Winnipeg'}   #  Windsor Park
    );
    
    return \%s2lm;
}


#-----------------------------------------------------------------------------------
sub generate_s2lm_2015_plus {
    my %s2lm = (
	'MGI' => { library => 'Bette Winner Public Library', municipality => 'Town of Gillam'},
	'MSTG' => { library => 'Bibliothèque Allard Regional Library', municipality => 'RM of Alexander'},
	'MBBB' => { library => 'Bibliothèque Allard Regional Library', municipality => 'Town of Powerview/Pine Falls'},
	'MVBB' => { library => 'Bibliothèque Allard Regional Library', municipality => 'RM of Victoria Beach'},
	'MSJB' => { library => 'Bibliothèque Montcalm Library', municipality => 'RM of Montcalm'},
	'MNDP' => { library => 'Lorne Library Services', municipality => 'Municipality of Lorne'},
	'MIBR' => { library => 'Bibliothèque Ritchot Library', municipality => 'RM of Ritchot'},
	'MSAD' => { library => 'Bibliothèque Ritchot Library', municipality => 'RM of Ritchot'},
	'MSAG' => { library => 'Bibliothèque Ritchot Library', municipality => 'RM of Ritchot'},
	'MLB' => { library => 'Bibliothèque Saint-Joachim Library', municipality => 'RM of La Broquerie'},
	'MS' => { library => 'Lorne Library Services', municipality => 'Municipality of Lorne'},
	'MSCL' => { library => 'Bibliothèque St. Claude Library', municipality => 'RM of Grey'},
	'MSA' => { library => 'Bibliothèque Ste Anne Library', municipality => 'Town of Ste. Anne'},
	'MTPL' => { library => 'Bibliothèque Taché  Library', municipality => 'RM of Tache'},
	'MBOM' => { library => 'Boissevain & Morton Regional Library', municipality => 'Municipality of Boissevain-Morton'},
	'MVE' => { library => 'Border Regional Library', municipality => 'Town of Virden'},
	'ME' => { library => 'Border Regional Library', municipality => 'RM of Wallace-Woodworth'},
	'MMCA' => { library => 'Border Regional Library', municipality => 'Municipality of Ellice-Archie'},
	'MCB' => { library => 'Boyne Regional Library', municipality => 'Town of Carman'},
	'MDB' => { library => 'Bren Del Win Centennial Library', municipality => 'Municipality of Deloraine-Winchester'},
	'TWAS' => { library => 'Bren Del Win Centennial Library', municipality => 'RM of Brenda-Waskada'},
	'MBBR' => { library => 'Brokenhead River Regional Library', municipality => 'Town of Beausejour'},
	'MCH' => { library => 'Churchill Public Library', municipality => 'Town of Churchill'},
	'MEPL' => { library => 'Emerson Public Library', municipality => 'Municipality of Emerson-Franklin'},
	'MEL' => { library => 'Eriksdale Public Library', municipality => 'RM of West Interlake'},
	'MGE' => { library => 'Evergreen Regional Library', municipality => 'RM of Gimli'},
	'MAB' => { library => 'Evergreen Regional Library', municipality => 'Town of Arborg'},
	'MRB' => { library => 'Evergreen Regional Library', municipality => 'RM of Bifrost-Riverton'},
	'MFF' => { library => 'Flin Flon Public Library', municipality => 'City of Flin Flon'},
	'MSEL' => { library => 'Gaynor Family Regional Library', municipality => 'City of Selkirk'},
	'MSOG' => { library => 'Glenwood & Souris Regional Library', municipality => 'Municipality of Souris-Glenwood'},
	'MHH' => { library => 'Headingley Municipal Library', municipality => 'RM of Headingley'},
	'MSTE' => { library => 'Jake Epp Library', municipality => 'City of Steinbach'},
	'MSTP' => { library => 'Jolys Regional Library', municipality => 'Village of St. Pierre-Jolys'},
	'MSSM' => { library => 'Jolys Regional Library', municipality => 'RM of DeSalaberry'},
	'MLDB' => { library => 'Lac Du Bonnet Regional Library', municipality => 'Town of Lac Du Bonnet'},
	'MKL' => { library => 'Lakeland Regional Library', municipality => 'RM of Killarney-Turtle Mountain'},
	'MCCB' => { library => 'Lakeland Regional Library', municipality => 'Cartwright-Roblin Municipality'},
	'MLR' => { library => 'Leaf Rapids Public Library', municipality => 'Town of Leaf Rapids'},
	'MPM' => { library => 'Louise Public Library', municipality => 'Municipality of Louise'},
	'MLLC' => { library => 'Lynn Lake Centennial Library', municipality => 'Town of Lynn Lake'},
	'MMA' => { library => 'Manitou Regional Library', municipality => 'RM of Pembina'},
	'MMR' => { library => 'Minnedosa Regional Library', municipality => 'Town of Minnedosa'},
	'MMNN' => { library => 'North Norfolk-MacGregor Regional Library', municipality => 'Municipality of North Norfolk'},
	'MSRN' => { library => 'North-West Regional Library', municipality => 'Town of Swan River'},
	'MBB' => { library => 'North-West Regional Library', municipality => 'Municipality of Swan Valley West'},
	'MDP' => { library => 'Parkland Regional Library', municipality => undef },
	'MDPBR' => { library => 'Parkland Regional Library', municipality => 'RM of Mountain'},
	'MDPBI' => { library => 'Parkland Regional Library', municipality => 'Prairie View Municipality'},
	'MDPBO' => { library => 'Parkland Regional Library', municipality => 'Municipality of Minitonas-Bowsman'},
	'MDA' => { library => 'Parkland Regional Library', municipality => 'City of Dauphin'},
	'MDPER' => { library => 'Parkland Regional Library', municipality => 'Municipality of Clanwilliam-Erickson'},
	'MDPFO' => { library => 'Parkland Regional Library', municipality => 'Prairie View Municipality'},
	'MDPGP' => { library => 'Parkland Regional Library', municipality => 'Gilbert Plains Municipality'},
	'MDPGL' => { library => 'Parkland Regional Library', municipality => 'RM of Westlake-Gladstone'},
	'MDPGV' => { library => 'Parkland Regional Library', municipality => 'Grandview Municipality'},
	'MDPHA' => { library => 'Parkland Regional Library', municipality => 'Hamiota Municipality'},
	'MDPLA' => { library => 'Parkland Regional Library', municipality => 'RM of Westlake-Gladstone'},
	'MDPMC' => { library => 'Parkland Regional Library', municipality => 'Municipality of McCreary'},
	'MDPMI' => { library => 'Parkland Regional Library', municipality => 'Municipality of Minitonas-Bowsman'},
	'MDPOR' => { library => 'Parkland Regional Library', municipality => 'RM of Lakeshore'},
	'MDPRO' => { library => 'Parkland Regional Library', municipality => 'Hillsburg-Roblin-Shell River'},
	'MDPSLA' => { library => 'Parkland Regional Library', municipality => 'RM of Ellice-Archie'},
	'MDPSL' => { library => 'Parkland Regional Library', municipality => 'RM of Yellowhead'},
	'MDPSI' => { library => 'Parkland Regional Library', municipality => 'RM of West Interlake'},
	'MDPST' => { library => 'Parkland Regional Library', municipality => 'RM of Yellowhead'},
	'MDPWP' => { library => 'Parkland Regional Library', municipality => 'RM of Mossey River'},
	'MRO' => { library => 'Parkland Regional Library', municipality => 'Rossburn Municipality'},
	'MSTR' => { library => 'Parkland Regional Library', municipality => 'Municipality of Ste. Rose'},
	'MLPJ' => { library => 'Pauline Johnson Library', municipality => 'RM of Coldwell'},
	'MPFN' => { library => 'Peguis First Nation Public Library', municipality => 'Peguis First Nation'},
	'MP' => { library => 'Pinawa Public Library', municipality => 'LGD of Pinawa'},
	'MPLP' => { library => 'Portage la Prairie Regional Library', municipality => 'City of Portage La Prairie'},
	'MRIP' => { library => 'Prairie Crocus Regional Library', municipality => 'Riverdale Municipality'},
	'MBA' => { library => 'RM of Argyle Public Library', municipality => 'RM of Argyle'},
	'MRA' => { library => 'Rapid City Regional Library', municipality => 'RM of Oakview'},
	'MRP' => { library => 'Reston District Library', municipality => 'RM of Pipestone'},
	'MRD' => { library => 'Russell & District Regional Library', municipality => 'Municipality of Russell-Binscarth'},
	'MBI' => { library => 'Russell & District Regional Library', municipality => 'Municipality of Russell-Binscarth'},
	'MSL' => { library => 'Snow Lake Community Library', municipality => 'Town of Snow Lake'},
	'MWOWH' => { library => 'South Central Regional Library', municipality => undef },   # South Central, HQ
	'MAOW' => { library => 'South Central Regional Library', municipality => 'Town of Altona'},
	'MMIOW' => { library => 'South Central Regional Library', municipality => 'RM of Thompson'},
	'MMOW' => { library => 'South Central Regional Library', municipality => 'City of Morden'},
	'MWOW' => { library => 'South Central Regional Library', municipality => 'City of Winkler'},
	'MSTOS' => { library => 'South Interlake Regional Library', municipality => 'Town of Stonewall'},
	'MTSIR' => { library => 'South Interlake Regional Library', municipality => 'Town of Teulon'},
	'MESM' => { library => 'Southwestern Manitoba Regional Library', municipality => 'Town of Melita'},
	'MESMN' => { library => 'Southwestern Manitoba Regional Library', municipality => 'RM of Brenda-Waskada'},
	'MESP' => { library => 'Southwestern Manitoba Regional Library', municipality => 'Municipality of Two Borders'},
	'MDS' => { library => 'Springfield Public Library', municipality => 'RM of Springfield'},
	'MTP' => { library => 'The Pas Regional Library', municipality => 'Town of The Pas'},
	'MTH' => { library => 'Thompson Public Library', municipality => 'City of Thompson'},
	'MEC' => { library => 'UCN Chemawawin Public Library', municipality => 'Chemawawin'},
	'MNH' => { library => 'UCN Norway House Public Library', municipality => 'Norway House'},
	'MMVR' => { library => 'Valley Regional Library', municipality => 'Town of Morris'},
	'MHP' => { library => 'Victoria Municipal Library', municipality => 'RM of Victoria'},
	'MBW' => { library => 'Western Manitoba Regional Library', municipality => 'City of Brandon'},
	'MCNC' => { library => 'Western Manitoba Regional Library', municipality => 'Town of Carberry'},
	'MGW' => { library => 'Western Manitoba Regional Library', municipality => 'Municipality of Glenboro-South Cypress'},
	'MHW' => { library => 'Western Manitoba Regional Library', municipality => 'Municipality of Grassland'},
	'MNW' => { library => 'Western Manitoba Regional Library', municipality => 'Town of Neepawa'},
	'MW' => { library => 'Winnipeg Public Library', municipality => undef },      # Winnipeg (with made-up branch symbols)
	'MWCH' => { library => 'Winnipeg Public Library', municipality => 'City of Winnipeg'},  #  Charlsewood
	'MWCO' => { library => 'Winnipeg Public Library', municipality => 'City of Winnipeg'},  #  Cornish
	'MWFG' => { library => 'Winnipeg Public Library', municipality => 'City of Winnipeg'},  #  Fort Garry
	'MWHE' => { library => 'Winnipeg Public Library', municipality => 'City of Winnipeg'},  #  Henderson
	'MWLR' => { library => 'Winnipeg Public Library', municipality => 'City of Winnipeg'},  #  Louis Riel
	'MWMU' => { library => 'Winnipeg Public Library', municipality => 'City of Winnipeg'},  #  Munroe
	'MWPT' => { library => 'Winnipeg Public Library', municipality => 'City of Winnipeg'},  #  Pembina Trail
	'MWOS' => { library => 'Winnipeg Public Library', municipality => 'City of Winnipeg'},  #  Osborne
	'MWMI' => { library => 'Winnipeg Public Library', municipality => 'City of Winnipeg'},  #  Millennium
	'MWRH' => { library => 'Winnipeg Public Library', municipality => 'City of Winnipeg'},  #  River Heights
	'MWWS' => { library => 'Winnipeg Public Library', municipality => 'City of Winnipeg'},  #  Sir William Stephenson
	'MWSB' => { library => 'Winnipeg Public Library', municipality => 'City of Winnipeg'},  #  St. Boniface
	'MWSJA' => { library => 'Winnipeg Public Library', municipality => 'City of Winnipeg'},  #  St. James-Assiniboia
	'MWSJ' => { library => 'Winnipeg Public Library', municipality => 'City of Winnipeg'},  #  St. John's
	'MWSV' => { library => 'Winnipeg Public Library', municipality => 'City of Winnipeg'},  #  St. Vital
	'MWTR' => { library => 'Winnipeg Public Library', municipality => 'City of Winnipeg'},  #  Transcona
	'MWWE' => { library => 'Winnipeg Public Library', municipality => 'City of Winnipeg'},  #  West End
	'MWWK' => { library => 'Winnipeg Public Library', municipality => 'City of Winnipeg'},  #  West Kildonan
	'MWWW' => { library => 'Winnipeg Public Library', municipality => 'City of Winnipeg'},  #  Westwood
	'MWWP' => { library => 'Winnipeg Public Library', municipality => 'City of Winnipeg'}   #  Windsor Park
    );
    
    return \%s2lm;
}
