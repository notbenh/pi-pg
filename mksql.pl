#!/usr/bin/perl 
use strict;
use warnings;
use YAML qw{LoadFile};
use Data::Manip qw{:all};

my $data = LoadFile( shift @ARGV || './pi.yaml') or die;

my $drop = shift @ARGV || 0;

print q|
CREATE OR REPLACE FUNCTION calc_trust (bigint) RETURNS integer AS $$
   use Data::Dumper;

   my $query = sprintf q{SELECT * FROM data_source_instance WHERE id = %d}, $_[0] ;
   my $ins = spi_exec_query( $query, 1 );
   #warn Dumper( $ins );
   return 0 unless $ins->{rows}->[0]->{trust};

   $query = sprintf q{SELECT * FROM data_source WHERE id = %d}, $ins->{rows}->[0]->{data_source_id} ;
   my $src = spi_exec_query( $query, 1 );
   #warn Dumper( $src );
   return 0 unless $src->{rows}->[0]->{trust};

   $query = sprintf q{SELECT * FROM data_source_type WHERE id = %d}, $src->{rows}->[0]->{data_source_type_id} ;
   my $typ = spi_exec_query( $query, 1);
   #warn Dumper( $typ );
   return $ins->{rows}->[0]->{trust} * $src->{rows}->[0]->{trust} * $typ->{rows}->[0]->{trust};
$$ LANGUAGE plperlu;
|;

my @drop;
my @first;
my @table;
my @collect;
my @relate;
my @view;

for my $table (keys %$data ) {
   my $rows = $data->{$table};
   my $collect = $table =~ m/^c_/;
   my $relate  = $table =~ m/^r_/;
   if ($relate || $collect) { 
      my $view = $table;
      $view =~ s/^[rc]_/v_/;

      my (@select, @join);
      my $indent = join( '', map{' '} 1..29);
      
      for (grep{ref($_) eq 'HASH'} @$rows) {
         my ($rr ) = join '_', %$_;
         my ($tbl) = keys %$_;
         push @select, ($tbl eq 'product') ? 'product.pid'
                     : ($tbl eq 'person' ) ? 'person.id AS person'
                     : ($tbl eq 'c_blurb') ? 'c_blurb.id AS blurb'
                     :                       join '.', $tbl, $tbl;
         push @join, sprintf qq{JOIN %s ON (%s.%s = %s.id)\n}
                           , $tbl
                           , $table
                           , $rr
                           , $tbl ;
      }

      push @view, sprintf qq{CREATE VIEW $view AS
                             SELECT %s
                             FROM $table
                             %s;
                            },
                          join( ', ', qq{$table.id}, @select, ( $relate ) ? (qq{$table.timestamp}, qq{trust * calc_trust($table.data_source_instance_id) as trust}) : () ),
                          join( $indent, @join);
      ;

      push @drop, sprintf q{DROP VIEW %s;}, $view if $drop;
                            
      push @$rows, #{ data_source => 'id'}, # an instance already has a relationship to data_souce
                   { data_source_instance => 'id'},
                   'timestamp timestamp with time zone not null DEFAULT current_timestamp',
                   'trust smallint CHECK( 100 >= trust AND trust >= 0 )  DEFAULT 1'
         if $relate;
   }

   push @drop, sprintf qq{DROP TABLE IF EXISTS %s CASCADE;}, $table
      if $drop;
   my $create = sprintf qq{CREATE TABLE %s( %s, PRIMARY KEY (id));},
                   $table,
                   join ',',map{ ( ref($_) eq 'HASH' ) 
                                 ? sprintf( q{%s bigint REFERENCES %s (%s) ON DELETE RESTRICT ON UPDATE CASCADE }, join('_',flat($_)), flat($_) )
                                 : $_;
                               } grep{defined} q{id bigserial not null}, @$rows ;
   if ( $relate ) {
      push @relate, $create;
   } elsif ($collect) {
      push @collect, $create;
   } elsif ($table =~ m/^(meta_type)$/) {
      push @first, $create;
   } else {
      push @table, $create  
   }
}

{ no warnings; # would warn about undef in join, but we want that
  print join qq{\n}, @drop, @first, @table, @collect, @relate, @view, undef;
}


print <<END;
insert into binding (binding) VALUES ('PB'); 
insert into binding_display (binding_display) VALUES ('PaperBack');
insert into data_source_type (data_source_type,trust) VALUES ('TEST',2);
insert into data_source (data_source,data_source_type_id) VALUES ('benh TEST',1);
insert into data_source_instance (data_source_instance, data_source_id) VALUES ('mksql TEST',1);
insert into r_binding_binding_display (binding_id,binding_display_id,data_source_instance_id) VALUES (1,1,1);
END

