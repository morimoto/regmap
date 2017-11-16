#! /usr/bin/perl
#==============================
#
# remap
#
# 2016/02/19 Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
#==============================
die "regmap connfig reg val" if( 3 != @ARGV );

$CONFIG	= @ARGV[0];
$REG	= @ARGV[1];
$VAL	= @ARGV[2];

die "config file not exist" if (! -e $CONFIG );

$REG = hex( $REG ) if ( $REG =~ "0x.*" );
$VAL = hex( $VAL );

die "reg not defined" if (system( "grep -v \"#\" $CONFIG | grep \"\\\[.*$REG.*\\\]\" >> /dev/null" ));

sub PrintRegVal {
	my( $i );

	printf "%s    0x%08x\n\n", $REG, $VAL;

	for ( $i = 31; $i >=0; $i-- ) {
		printf "%d", !!($VAL & (1 << $i));
		printf " "  if (!($i % 4));
		printf "\n" if (!($i % 16));
	}
	printf "\n";
}

sub PrintItem {

	open( F, $CONFIG ) || die "can't open config file";
	my ( $on ) = 0;

	printf "  %-7s  %-8s  %s\n", "bit", "val(hex)", "name";
	while ( <F> ) {
		my $line = $_;
		my @list;
		chomp( $line );

		next if ( $line eq "" );
		next if ( $line =~ "#" );

		if ( $on ) {
			if ( "$line" =~ "\\[.*\\]" ) {
				last;
			}
		} else {
			if ( "$line" =~ "\\\[.*$REG.*\\\]" ) {
				$on = 1;
				next;
			}
		}

		if ( $on ) {
			my ($pos, $name) = split( /	/, $line );
			my ($posr, $posl) = split(/,/, $pos);
			my ($i, $mask);

			$posl = $posr if ($pos !~ ",");

			$mask = 0;
			for ( $i = $posl; $i <= $posr; $i++) {
				$mask |= 1 << $i;
			}

			printf "  %-7s  %-8x  %s\n", $pos, (($VAL & $mask) >> $posl, $name);
		}
	}
}

PrintRegVal(  );
PrintItem (  );
