#!/usr/bin/perl 
use strict;
use warnings;
use YAML qw{LoadFile};

my $m = Manager->new;

for my $file (@ARGV) {
   for my $book (LoadFile($file) ) { # allow multiple books per YAML
      print join qq{\n}, $m->inserts_from_product($book) ;
   }
}
print qq{\n};


BEGIN {

package Manager;
use Mouse;
use YAML qw{LoadFile};

has struct => 
   is => 'rw',
   isa => 'HashRef',
   default => sub{ LoadFile('pi.yaml') },
;

has key_alias =>
   is => 'ro', 
   isa => 'HashRef', 
   default => sub{{
      pid => product => 
      price => list_price => 
   }},
;

has data_source => 
   is => 'rw',
   isa => 'Str',
   default => 'this test',
;

has data_source_type => 
   is => 'rw',
   isa => 'Str',
   default => 'TEST',
;

has data_source_instance => 
   is => 'rw',
   isa => 'Str',
   default => 'inserter',
;

has pids => 
   is => 'rw',
   isa => 'ArrayRef',
   lazy => 1,
   auto_deref => 1,
   default => sub{[]},
   clearer => 'clear_pids',
;

sub find_product_alias {
   my $self = shift;
   my $prod = shift;
   my @keys = ( 'product', grep{ $self->key_alias->{$_} eq 'product' } keys %{ $self->key_alias} );
   $self->pids([ grep{ defined } map { $prod->{$_}} @keys]);
}

sub inserts_from_product {
   my $self = shift;
   my $prod = (scalar(@_) == 1) ? $_[0] : {@_};
   $self->clear_pids;
   $self->find_product_alias($prod);
   ( INS( data_source_type => data_source_type => $self->data_source_type),
     INS( data_source => data_source => $self->data_source
                      => data_source_type_id => SEL( data_source_type => id => data_source_type => $self->data_source_type )
        ),
     INS( data_source_instance => data_source_instance => $self->data_source_instance
                               => data_source_id => SEL( data_source => id => data_source => $self->data_source )
        ),
     map{ my @val = ref($prod->{$_}) eq 'ARRAY' ? @{ $prod->{$_} } : $prod->{$_} ; 
          my $key = $self->key_alias->{$_} || $_;
          map{ $self->can($key)      ? $self->$key($_)
             : $self->struct->{$key} ? $self->generic( $key => $_ )
             :                         $self->meta_value($key => $_);
             } @val;
        } keys %$prod
   );
}

sub generic {
   my $self  = shift;
   my $table = shift;
   my $value = shift;
   ( INS( $table => $table => $value ) ,
     $self->RINS( q{r_product_}.$table => 
                  $table.q{_id} => SEL( $table => id => $table => $value )
                )
   );
}

sub INS {
   my $table = shift;
   my %rows  = @_;
   sprintf q{INSERT INTO %s (%s) VALUES (%s);}
         , $table
         , join( ', ', keys %rows)
         , join( ', ', map { ref($_) eq 'HASH' ? sprintf( q{(%s)}, SEL(%$_)) 
                           : is_SEL($_)        ? qq{($_)}
                           :                     qq{'$_'}
                           } map{ defined $_ ? $_ : '' } values %rows)
   ;
}

sub is_SEL { shift =~ m/SELECT.*FROM/ } 
sub SEL {
   my $table = shift;
   my $what  = shift;
   my %where = @_;
   sprintf q{SELECT %s FROM %s WHERE %s}
         , $what
         , $table
         , join ' AND ', map{ sprintf is_SEL($where{$_}) ? q{%s = (%s)} : q{%s = '%s'}, $_ => $where{$_} } keys %where
   ;
}
sub RINS {
   my $self  = shift;
   my $table = shift;
   my %rows  = @_;
   map { INS( $table => product_id => SEL(product => id => pid => $_)
                     => data_source_instance_id => SEL( data_source_instance => id => data_source_instance => $self->data_source_instance)
                     => %rows
                     
            );
       } $self->pids;
}

sub list_price {
   my $self = shift;
   map{ my $curr = join '', $_ =~ m/[^0-9.]/g;
        my $price= join '', $_ =~ m/[0-9.]/g;
        ( INS(currency   => currency    => $curr),
          INS(list_price => list_price  => $price
                         => currency_id => SEL(currency => id => currency => $curr),
             ),
          $self->RINS( r_product_list_price => 
                        list_price_id => SEL(list_price => id => list_price => $price
                                                        => currency_id => SEL(currency => id => currency => $curr),
                                            ),
                     ),
        );
      } @_ ;
}
sub product {
   my $self = shift;
   map{ INS( product => pid => $_ ) } @_;
}

sub title {
   my $self = shift;
   my ($title,$subtitle) = split /:/, shift, 2;
   my $t_key = key_me($title,$subtitle);
   ( INS( title => title => $title
                => subtitle => $subtitle
                => title_key => $t_key,
        ),
     $self->RINS( r_product_title => 
                  title_id => SEL( title => id => title_key => $t_key)
                ),
   );
}

sub meta_value {
   my ( $self, $type, $value ) = @_;
   ( INS(meta_type => meta_type => $type),
     # INSPECT FOR DATE
     INS(meta_data => meta_data => $value
                   => meta_type_id => SEL(meta_type => id => meta_type => $type)
        ),
     $self->RINS( r_product_meta_data => 
                  meta_type_id => SEL( meta_type => id => meta_type => $type),
                  meta_data_id => SEL( meta_data => id => meta_data => $value
                                                       => meta_type_id => SEL(meta_type => id => meta_type => $type)
                                     )
                ),
   );
}


sub key_me {
   my $key = lc( join '', grep{ defined } @_ );
   $key =~ s/\s*//g;
   $key =~ s/[^a-z0-9]//i;
   $key;
}


}; #END BEGIN

__END__
TODO:
- need to sql quote the values (deal with single quotes)

