#!/usr/bin/perl 
use strict;
use warnings;
use YAML qw{LoadFile};
use Data::Manip qw{:all};
use Util::Log;

my $data = LoadFile( shift @ARGV || './pi.yaml') or die;

my $drop = shift @ARGV || 0;
my $schema = 'pi';

print q|
DROP FUNCTION IF EXISTS pi.calc_trust (bigint);
CREATE OR REPLACE FUNCTION pi.calc_trust (bigint) RETURNS integer AS $$
   my $query = sprintf q{SELECT * FROM data_source_instance WHERE id = %d}, $_[0] ;
   my $ins = spi_exec_query( $query, 1 );
   return 0 unless $ins->{rows}->[0]->{trust};

   $query = sprintf q{SELECT * FROM data_source WHERE id = %d}, $ins->{rows}->[0]->{data_source_id} ;
   my $src = spi_exec_query( $query, 1 );
   return 0 unless $src->{rows}->[0]->{trust};

   $query = sprintf q{SELECT * FROM data_source_type WHERE id = %d}, $src->{rows}->[0]->{data_source_type_id} ;
   my $typ = spi_exec_query( $query, 1);
   return $ins->{rows}->[0]->{trust} * $src->{rows}->[0]->{trust} * $typ->{rows}->[0]->{trust};
$$ LANGUAGE plperl;


DROP FUNCTION IF EXISTS pi.best (text,text,text);
CREATE OR REPLACE FUNCTION pi.best (text,text,text) RETURNS text AS $$
   my ($table,$col,$val) = @_;
   my $query = sprintf q{SELECT * FROM v_%s_%s WHERE %s = '%s' ORDER BY trust DESC}
                     , ($col eq 'pid') ? 'product' : $col
                     , $table
                     , $col
                     , $val ;
   my $rv = spi_exec_query( $query, 1 );
   return $rv->{rows}->[0]->{$table};
$$ LANGUAGE plperlu;


DROP FUNCTION IF EXISTS pi.best (text);
CREATE OR REPLACE FUNCTION pi.best (text) RETURNS text AS $$
   use Data::Dumper;
   my ($pid) = @_;
   #my $views = spi_exec_query(q{select table_name from information_schema.tables where table_schema = 'pi' AND table_type = 'VIEW' AND table_name LIKE '%product%'});
   my $views = spi_exec_query(q{SELECT view FROM config_best WHERE type = 'single'});
   foreach my $view (map{$_->{table_name}} @{ $views->{rows} }) {
      my ($type) = $view =~ m/v_product_(.*)/;
      my $col    = spi_exec_query( qq{SELECT column_name 
                                      FROM information_schema.columns 
                                      WHERE table_name = '$view'
                                        AND column_name NOT IN('id','pid','timestamp','trust')
                                     } );
      my $what   = join ', ', map{ $_->{column_name} } @{ $col->{rows} };
      my $rv     = spi_exec_query( qq{SELECT $what FROM $view WHERE pid = '$pid' AND trust > 0 ORDER BY trust,timestamp} );
#warn Dumper($view => $col);
warn Dumper($type => $rv);
   }
$$ LANGUAGE plperlu;
|;

my @drop;
my @first;
my @table;
my @collect;
my @relate;
my @view;
my @config;

for my $table (keys %$data ) {
   my $rows = $data->{$table};
   my $collect = $table =~ m/^c_/;
   my $relate  = $table =~ m/^r_/;

   #---------------------------------------------------------------------------
   #  EXTRA RELATIONSHIP JUJU
   #---------------------------------------------------------------------------
   if ($relate || $collect) { 
      my $view = $table;
      $view =~ s/^[rc]_/v_/;

      #---------------------------------------------------------------------------
      #  CONFIG
      #---------------------------------------------------------------------------
      my $config = ref($rows) ? { type => split /::/, lc(ref($rows)) } : {};
      $config->{custom_limit} = 1 if ($config->{type} =~ m/^(single|display)$/i)
                                  && ! defined $config->{custom_limit};
      $config->{type}         = undef unless $config->{type} =~ m/^(single|multi|display|collection)$/;
      push @config, sprintf q{INSERT INTO pi.config_best (view,type,custom_group,custom_order,custom_limit) VALUES (%s);}
                          , join ',', map{defined $_ ? qq{'$_'} : 'NULL'} $view, map{$config->{$_}} qw{type custom_group custom_order custom_limit};
      
      #---------------------------------------------------------------------------
      #  VIEW
      #---------------------------------------------------------------------------
      my (@select, @join);
      my $indent = join( '', map{' '} 1..29);
      
      for (grep{ref($_) eq 'HASH'} @$rows) {
         my ($rr ) = join '_', %$_;
         my ($tbl) = keys %$_;
         push @select, ($tbl eq 'product') ? 'product.pid'
                     : ($tbl eq 'person' ) ? 'person.id AS person'
                     : ($tbl eq 'c_blurb') ? 'c_blurb.id AS blurb'
                     :                       join '.', $tbl, $tbl;
         push @join, sprintf qq{JOIN $schema.%s ON ($schema.%s.%s = $schema.%s.id)\n}
                           , $tbl
                           , $table
                           , $rr
                           , $tbl ;
      }

      push @view, sprintf qq{CREATE VIEW $schema.$view AS
                             SELECT %s
                             FROM $schema.$table
                             %s;
                            },
                          join( ', ', qq{$schema.$table.id}, @select, ( $relate ) ? (qq{$table.timestamp}, qq{trust * $schema.calc_trust($table.data_source_instance_id) as trust}) : () ),
                          join( $indent, @join);
      ;

      #---------------------------------------------------------------------------
      #  DROP VIEW
      #---------------------------------------------------------------------------
      push @drop, sprintf q{DROP VIEW %s.%s;}, $schema,$view if $drop;

      #---------------------------------------------------------------------------
      #  BEST VIEW
      #---------------------------------------------------------------------------
      my $best_view = $view;
      $best_view =~ s/^v_/v_best_/;

      push @view, sprintf qq{CREATE VIEW $schema.$best_view AS
                             SELECT %s
                             FROM $schema.$view
                             WHERE trust > 0
                             %s
                             ORDER BY %s
                             %s
                             ;
                            },
                            '*',
                            '', # extra where juju
                            $config->{custom_order} || 'trust,timestamp'
      ;

      #---------------------------------------------------------------------------
      #  DROP BEST VIEW
      #---------------------------------------------------------------------------
      push @drop, sprintf q{DROP VIEW %s.%s;}, $schema,$best_view if $drop;

                            
      #---------------------------------------------------------------------------
      #  Add relationship rows 
      #---------------------------------------------------------------------------
      push @$rows, #{ data_source => 'id'}, # an instance already has a relationship to data_souce
                   { data_source_instance => 'id'},
                   'timestamp timestamp with time zone not null DEFAULT current_timestamp',
                   'trust smallint CHECK( 100 >= trust AND trust >= 0 )  DEFAULT 1'
         if $relate;
   }

   #---------------------------------------------------------------------------
   #  DROP TABLE
   #---------------------------------------------------------------------------
   push @drop, sprintf qq{DROP TABLE IF EXISTS %s.%s CASCADE;}, $schema, $table
      if $drop;

   #---------------------------------------------------------------------------
   #  CREATE TABLE
   #---------------------------------------------------------------------------
   my $create = sprintf qq{CREATE TABLE %s.%s( %s, PRIMARY KEY (id));},
                   $schema,
                   $table,
                   join ',',map{ ( ref($_) eq 'HASH' ) 
                                 ? sprintf( q{%s bigint REFERENCES %s.%s (%s) ON DELETE RESTRICT ON UPDATE CASCADE }, 
                                            join('_',flat($_)), 
                                            $schema,
                                            flat($_),
                                          )
                                 : $_;
                               } grep{defined} q{id bigserial not null}, @$rows ;
   
   #---------------------------------------------------------------------------
   #  Put query in to the right bucket
   #---------------------------------------------------------------------------
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

#---------------------------------------------------------------------------
#  print out sql
#---------------------------------------------------------------------------
{ no warnings; # would warn about undef in join, but we want that
  print join qq{\n}, @drop, @first, @table, @collect, @relate, @view, @config, undef;
}

# extra inserts just to have some play data at first
print <<END;
insert into $schema.binding (binding) VALUES ('PB'); 
insert into $schema.binding_display (binding_display) VALUES ('PaperBack');
insert into $schema.data_source_type (data_source_type,trust) VALUES ('TEST',2);
insert into $schema.data_source (data_source,data_source_type_id) VALUES ('benh TEST',1);
insert into $schema.data_source_instance (data_source_instance, data_source_id) VALUES ('mksql TEST',1);
insert into $schema.r_binding_binding_display (binding_id,binding_display_id,data_source_instance_id) VALUES (1,1,1);
END
