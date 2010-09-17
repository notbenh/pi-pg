#!/usr/bin/perl 
use strict;
use warnings;
use Util::Log;
use YAML qw{LoadFile};

my $m = Manager->new;

for my $file (@ARGV) {
   for my $book (LoadFile($file) ) { # allow multiple books per YAML
      print join qq{\n}, $m->inserts_from_product($book) ;
   }
}


BEGIN {

package Manager;
use Mouse;
use YAML qw{LoadFile};
use Util::Log;

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

sub inserts_from_product {
   my $self = shift;
   my $prod = (scalar(@_) == 1) ? $_[0] : {@_};

   map{ my @val = ref($prod->{$_}) eq 'ARRAY' ? @{ $prod->{$_} } : $prod->{$_} ; 
        my $key = $self->key_alias->{$_} || $_;
# WORK OUT SOME MAGIC FOR THE RELATIONSHIPS
        map{ $self->can($key)      ? $self->$key($_)
           : $self->struct->{$key} ? INS( $key => $key => $_ )
           :                         $self->meta_value($key => $_);
           } @val;
      } keys %$prod;
}

sub INS {
   my $table = shift;
   my %rows  = @_;
   sprintf q{INSERT INTO %s (%s) VALUES (%s);}
         , $table
         , join( ', ', keys %rows)
         , join( ', ', map{ ref($_) eq 'HASH' ? sprintf( q{(%s)}, SEL(%$_)) 
                          : m/^SELECT.*FROM/  ? qq{($_)}
                          :                     qq{'$_'}
                          } values %rows)
   ;
}

sub SEL {
   my $table = shift;
   my $what  = shift;
   my %where = @_;
   sprintf q{SELECT %s FROM %s WHERE %s}
         , $what
         , $table
         , join ' AND ', map{ sprintf q{%s = '%s'}, $_ => $where{$_} } keys %where
   ;
}

sub list_price {
   my $self = shift;
   map{ my $curr = join '', $_ =~ m/[^0-9.]/g;
        my $price= join '', $_ =~ m/[0-9.]/g;
        ( INS(currency => currency => $curr),
          INS(list_price => list_price => $price
                         => currency_id => SEL(currency => id => currency => $curr),
             )
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
   INS( title => title => $title
              => subtitle => $subtitle
              => title_key => key_me($title,$subtitle)
      );
}

sub meta_value {
   my ( $self, $type, $value ) = @_;
   ( INS(meta_type => meta_type => $type),
     # INSPECT FOR DATE
     INS(meta_data => meta_data => $value
                   => meta_type_id => SEL(meta_type => id => meta_type => $type)
        )
   );
}


sub key_me {
   my $key = lc( join '', @_ );
   $key =~ s/\s*//g;
   $key =~ s/[^a-z0-9]//i;
   $key;
}


}; #END BEGIN


