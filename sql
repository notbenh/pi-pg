
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
DROP VIEW pi.v_product_c_blurb;
DROP VIEW pi.v_best_product_c_blurb;
DROP TABLE IF EXISTS pi.r_product_c_blurb CASCADE;
DROP TABLE IF EXISTS pi.copyright CASCADE;
DROP TABLE IF EXISTS pi.binding_display CASCADE;
DROP TABLE IF EXISTS pi.binding CASCADE;
DROP TABLE IF EXISTS pi.data_source_type CASCADE;
DROP VIEW pi.v_product_publisher;
DROP VIEW pi.v_best_product_publisher;
DROP TABLE IF EXISTS pi.r_product_publisher CASCADE;
DROP VIEW pi.v_currency_currency_display;
DROP VIEW pi.v_best_currency_currency_display;
DROP TABLE IF EXISTS pi.r_currency_currency_display CASCADE;
DROP VIEW pi.v_product_copyright;
DROP VIEW pi.v_best_product_copyright;
DROP TABLE IF EXISTS pi.r_product_copyright CASCADE;
DROP TABLE IF EXISTS pi.blurb_text CASCADE;
DROP TABLE IF EXISTS pi.data_source CASCADE;
DROP TABLE IF EXISTS pi.meta_data CASCADE;
DROP VIEW pi.v_c_blurb_meta_date;
DROP VIEW pi.v_best_c_blurb_meta_date;
DROP TABLE IF EXISTS pi.r_c_blurb_meta_date CASCADE;
DROP VIEW pi.v_product_binding;
DROP VIEW pi.v_best_product_binding;
DROP TABLE IF EXISTS pi.r_product_binding CASCADE;
DROP TABLE IF EXISTS pi.publisher CASCADE;
DROP TABLE IF EXISTS pi.blurb_type_display CASCADE;
DROP VIEW pi.v_product_meta_data;
DROP VIEW pi.v_best_product_meta_data;
DROP TABLE IF EXISTS pi.r_product_meta_data CASCADE;
DROP TABLE IF EXISTS pi.subject CASCADE;
DROP TABLE IF EXISTS pi.meta_type CASCADE;
DROP VIEW pi.v_blurb_type_blurb_type_display;
DROP VIEW pi.v_best_blurb_type_blurb_type_display;
DROP TABLE IF EXISTS pi.r_blurb_type_blurb_type_display CASCADE;
DROP TABLE IF EXISTS pi.title CASCADE;
DROP VIEW pi.v_c_blurb_meta_data;
DROP VIEW pi.v_best_c_blurb_meta_data;
DROP TABLE IF EXISTS pi.r_c_blurb_meta_data CASCADE;
DROP TABLE IF EXISTS pi.pages CASCADE;
DROP TABLE IF EXISTS pi.config_best CASCADE;
DROP VIEW pi.v_binding_binding_display;
DROP VIEW pi.v_best_binding_binding_display;
DROP TABLE IF EXISTS pi.r_binding_binding_display CASCADE;
DROP VIEW pi.v_product_language;
DROP VIEW pi.v_best_product_language;
DROP TABLE IF EXISTS pi.r_product_language CASCADE;
DROP TABLE IF EXISTS pi.currency CASCADE;
DROP VIEW pi.v_product_list_price;
DROP VIEW pi.v_best_product_list_price;
DROP TABLE IF EXISTS pi.r_product_list_price CASCADE;
DROP TABLE IF EXISTS pi.person CASCADE;
DROP VIEW pi.v_blurb;
DROP VIEW pi.v_best_blurb;
DROP TABLE IF EXISTS pi.c_blurb CASCADE;
DROP TABLE IF EXISTS pi.list_price CASCADE;
DROP TABLE IF EXISTS pi.blurb_type CASCADE;
DROP TABLE IF EXISTS pi.currency_display CASCADE;
DROP TABLE IF EXISTS pi.language CASCADE;
DROP VIEW pi.v_product_subject;
DROP VIEW pi.v_best_product_subject;
DROP TABLE IF EXISTS pi.r_product_subject CASCADE;
DROP VIEW pi.v_product_title;
DROP VIEW pi.v_best_product_title;
DROP TABLE IF EXISTS pi.r_product_title CASCADE;
DROP VIEW pi.v_language_language_display;
DROP VIEW pi.v_best_language_language_display;
DROP TABLE IF EXISTS pi.r_language_language_display CASCADE;
DROP VIEW pi.v_product_meta_date;
DROP VIEW pi.v_best_product_meta_date;
DROP TABLE IF EXISTS pi.r_product_meta_date CASCADE;
DROP TABLE IF EXISTS pi.language_display CASCADE;
DROP TABLE IF EXISTS pi.meta_date CASCADE;
DROP VIEW pi.v_product_pages;
DROP VIEW pi.v_best_product_pages;
DROP TABLE IF EXISTS pi.r_product_pages CASCADE;
DROP TABLE IF EXISTS pi.data_source_instance CASCADE;
DROP TABLE IF EXISTS pi.product CASCADE;
CREATE TABLE pi.meta_type( id bigserial not null,meta_type varchar(255) not null UNIQUE, PRIMARY KEY (id));
CREATE TABLE pi.copyright( id bigserial not null,copyright date not null UNIQUE, PRIMARY KEY (id));
CREATE TABLE pi.binding_display( id bigserial not null,binding_display varchar(255) not null UNIQUE, PRIMARY KEY (id));
CREATE TABLE pi.binding( id bigserial not null,binding varchar(255) NOT NULL UNIQUE, PRIMARY KEY (id));
CREATE TABLE pi.data_source_type( id bigserial not null,data_source_type varchar(50) not null UNIQUE,trust smallint CHECK( 100 >= trust AND trust >= 0 )  DEFAULT 10, PRIMARY KEY (id));
CREATE TABLE pi.blurb_text( id bigserial not null,blurb_text text not null,blurb_key VARCHAR(50) UNIQUE, PRIMARY KEY (id));
CREATE TABLE pi.data_source( id bigserial not null,data_source varchar(100) not null,trust smallint CHECK( 100 >= trust AND trust >= 0 )  DEFAULT 10,data_source_type_id bigint REFERENCES pi.data_source_type (id) ON DELETE RESTRICT ON UPDATE CASCADE ,UNIQUE (data_source, data_source_type_id), PRIMARY KEY (id));
CREATE TABLE pi.meta_data( id bigserial not null,meta_data text not null,meta_type_id bigint REFERENCES pi.meta_type (id) ON DELETE RESTRICT ON UPDATE CASCADE ,UNIQUE (meta_data, meta_type_id), PRIMARY KEY (id));
CREATE TABLE pi.publisher( id bigserial not null,publisher varchar(255) not null UNIQUE, PRIMARY KEY (id));
CREATE TABLE pi.blurb_type_display( id bigserial not null,blurb_type_display varchar(255) not null UNIQUE, PRIMARY KEY (id));
CREATE TABLE pi.subject( id bigserial not null,subject varchar(255) not null UNIQUE, PRIMARY KEY (id));
CREATE TABLE pi.title( id bigserial not null,title text not null,subtitle text DEFAULT null,title_key VARCHAR(100) not null UNIQUE, PRIMARY KEY (id));
CREATE TABLE pi.pages( id bigserial not null,pages int not null UNIQUE, PRIMARY KEY (id));
CREATE TABLE pi.config_best( id bigserial not null,view VARCHAR(255) NOT NULL UNIQUE,type VARCHAR(255),custom_group text,custom_order text,custom_limit integer, PRIMARY KEY (id));
CREATE TABLE pi.currency( id bigserial not null,currency varchar(20) NOT NULL UNIQUE, PRIMARY KEY (id));
CREATE TABLE pi.person( id bigserial not null, PRIMARY KEY (id));
CREATE TABLE pi.list_price( id bigserial not null,list_price money not null UNIQUE,currency_id bigint REFERENCES pi.currency (id) ON DELETE RESTRICT ON UPDATE CASCADE , PRIMARY KEY (id));
CREATE TABLE pi.blurb_type( id bigserial not null,blurb_type varchar(255) NOT NULL UNIQUE, PRIMARY KEY (id));
CREATE TABLE pi.currency_display( id bigserial not null,currency_display varchar(20) NOT NULL UNIQUE, PRIMARY KEY (id));
CREATE TABLE pi.language( id bigserial not null,language varchar(255) NOT NULL UNIQUE, PRIMARY KEY (id));
CREATE TABLE pi.language_display( id bigserial not null,language_display VARCHAR(255) NOT NULL UNIQUE, PRIMARY KEY (id));
CREATE TABLE pi.meta_date( id bigserial not null,meta_date date not null,meta_type_id bigint REFERENCES pi.meta_type (id) ON DELETE RESTRICT ON UPDATE CASCADE ,UNIQUE (meta_date, meta_type_id), PRIMARY KEY (id));
CREATE TABLE pi.data_source_instance( id bigserial not null,data_source_instance varchar(255) NOT NULL,data_source_id bigint REFERENCES pi.data_source (id) ON DELETE RESTRICT ON UPDATE CASCADE ,trust smallint CHECK( 100 >= trust AND trust >= 0 )  DEFAULT 10,timestamp timestamp with time zone not null DEFAULT current_timestamp,UNIQUE (data_source_instance, data_source_id), PRIMARY KEY (id));
CREATE TABLE pi.product( id bigserial not null,pid varchar(30) not null UNIQUE, PRIMARY KEY (id));
CREATE TABLE pi.c_blurb( id bigserial not null,blurb_text_id bigint REFERENCES pi.blurb_text (id) ON DELETE RESTRICT ON UPDATE CASCADE ,blurb_type_id bigint REFERENCES pi.blurb_type (id) ON DELETE RESTRICT ON UPDATE CASCADE ,data_source_id bigint REFERENCES pi.data_source (id) ON DELETE RESTRICT ON UPDATE CASCADE ,person_id bigint REFERENCES pi.person (id) ON DELETE RESTRICT ON UPDATE CASCADE , PRIMARY KEY (id));
CREATE TABLE pi.r_product_c_blurb( id bigserial not null,product_id bigint REFERENCES pi.product (id) ON DELETE RESTRICT ON UPDATE CASCADE ,c_blurb_id bigint REFERENCES pi.c_blurb (id) ON DELETE RESTRICT ON UPDATE CASCADE ,data_source_instance_id bigint REFERENCES pi.data_source_instance (id) ON DELETE RESTRICT ON UPDATE CASCADE ,timestamp timestamp with time zone not null DEFAULT current_timestamp,trust smallint CHECK( 100 >= trust AND trust >= 0 )  DEFAULT 1, PRIMARY KEY (id));
CREATE TABLE pi.r_product_publisher( id bigserial not null,product_id bigint REFERENCES pi.product (id) ON DELETE RESTRICT ON UPDATE CASCADE ,publisher_id bigint REFERENCES pi.publisher (id) ON DELETE RESTRICT ON UPDATE CASCADE ,data_source_instance_id bigint REFERENCES pi.data_source_instance (id) ON DELETE RESTRICT ON UPDATE CASCADE ,timestamp timestamp with time zone not null DEFAULT current_timestamp,trust smallint CHECK( 100 >= trust AND trust >= 0 )  DEFAULT 1, PRIMARY KEY (id));
CREATE TABLE pi.r_currency_currency_display( id bigserial not null,currency_id bigint REFERENCES pi.currency (id) ON DELETE RESTRICT ON UPDATE CASCADE ,currency_display_id bigint REFERENCES pi.currency_display (id) ON DELETE RESTRICT ON UPDATE CASCADE ,data_source_instance_id bigint REFERENCES pi.data_source_instance (id) ON DELETE RESTRICT ON UPDATE CASCADE ,timestamp timestamp with time zone not null DEFAULT current_timestamp,trust smallint CHECK( 100 >= trust AND trust >= 0 )  DEFAULT 1, PRIMARY KEY (id));
CREATE TABLE pi.r_product_copyright( id bigserial not null,product_id bigint REFERENCES pi.product (id) ON DELETE RESTRICT ON UPDATE CASCADE ,copyright_id bigint REFERENCES pi.copyright (id) ON DELETE RESTRICT ON UPDATE CASCADE ,data_source_instance_id bigint REFERENCES pi.data_source_instance (id) ON DELETE RESTRICT ON UPDATE CASCADE ,timestamp timestamp with time zone not null DEFAULT current_timestamp,trust smallint CHECK( 100 >= trust AND trust >= 0 )  DEFAULT 1, PRIMARY KEY (id));
CREATE TABLE pi.r_c_blurb_meta_date( id bigserial not null,c_blurb_id bigint REFERENCES pi.c_blurb (id) ON DELETE RESTRICT ON UPDATE CASCADE ,meta_date_id bigint REFERENCES pi.meta_date (id) ON DELETE RESTRICT ON UPDATE CASCADE ,data_source_instance_id bigint REFERENCES pi.data_source_instance (id) ON DELETE RESTRICT ON UPDATE CASCADE ,timestamp timestamp with time zone not null DEFAULT current_timestamp,trust smallint CHECK( 100 >= trust AND trust >= 0 )  DEFAULT 1, PRIMARY KEY (id));
CREATE TABLE pi.r_product_binding( id bigserial not null,product_id bigint REFERENCES pi.product (id) ON DELETE RESTRICT ON UPDATE CASCADE ,binding_id bigint REFERENCES pi.binding (id) ON DELETE RESTRICT ON UPDATE CASCADE ,data_source_instance_id bigint REFERENCES pi.data_source_instance (id) ON DELETE RESTRICT ON UPDATE CASCADE ,timestamp timestamp with time zone not null DEFAULT current_timestamp,trust smallint CHECK( 100 >= trust AND trust >= 0 )  DEFAULT 1, PRIMARY KEY (id));
CREATE TABLE pi.r_product_meta_data( id bigserial not null,product_id bigint REFERENCES pi.product (id) ON DELETE RESTRICT ON UPDATE CASCADE ,meta_type_id bigint REFERENCES pi.meta_type (id) ON DELETE RESTRICT ON UPDATE CASCADE ,meta_data_id bigint REFERENCES pi.meta_data (id) ON DELETE RESTRICT ON UPDATE CASCADE ,UNIQUE (product_id, meta_data_id, meta_type_id, data_source_instance_id),data_source_instance_id bigint REFERENCES pi.data_source_instance (id) ON DELETE RESTRICT ON UPDATE CASCADE ,timestamp timestamp with time zone not null DEFAULT current_timestamp,trust smallint CHECK( 100 >= trust AND trust >= 0 )  DEFAULT 1, PRIMARY KEY (id));
CREATE TABLE pi.r_blurb_type_blurb_type_display( id bigserial not null,blurb_type_id bigint REFERENCES pi.blurb_type (id) ON DELETE RESTRICT ON UPDATE CASCADE ,blurb_type_display_id bigint REFERENCES pi.blurb_type_display (id) ON DELETE RESTRICT ON UPDATE CASCADE ,data_source_instance_id bigint REFERENCES pi.data_source_instance (id) ON DELETE RESTRICT ON UPDATE CASCADE ,timestamp timestamp with time zone not null DEFAULT current_timestamp,trust smallint CHECK( 100 >= trust AND trust >= 0 )  DEFAULT 1, PRIMARY KEY (id));
CREATE TABLE pi.r_c_blurb_meta_data( id bigserial not null,c_blurb_id bigint REFERENCES pi.c_blurb (id) ON DELETE RESTRICT ON UPDATE CASCADE ,meta_data_id bigint REFERENCES pi.meta_data (id) ON DELETE RESTRICT ON UPDATE CASCADE ,data_source_instance_id bigint REFERENCES pi.data_source_instance (id) ON DELETE RESTRICT ON UPDATE CASCADE ,timestamp timestamp with time zone not null DEFAULT current_timestamp,trust smallint CHECK( 100 >= trust AND trust >= 0 )  DEFAULT 1, PRIMARY KEY (id));
CREATE TABLE pi.r_binding_binding_display( id bigserial not null,binding_id bigint REFERENCES pi.binding (id) ON DELETE RESTRICT ON UPDATE CASCADE ,binding_display_id bigint REFERENCES pi.binding_display (id) ON DELETE RESTRICT ON UPDATE CASCADE ,data_source_instance_id bigint REFERENCES pi.data_source_instance (id) ON DELETE RESTRICT ON UPDATE CASCADE ,timestamp timestamp with time zone not null DEFAULT current_timestamp,trust smallint CHECK( 100 >= trust AND trust >= 0 )  DEFAULT 1, PRIMARY KEY (id));
CREATE TABLE pi.r_product_language( id bigserial not null,product_id bigint REFERENCES pi.product (id) ON DELETE RESTRICT ON UPDATE CASCADE ,language_id bigint REFERENCES pi.language (id) ON DELETE RESTRICT ON UPDATE CASCADE ,data_source_instance_id bigint REFERENCES pi.data_source_instance (id) ON DELETE RESTRICT ON UPDATE CASCADE ,timestamp timestamp with time zone not null DEFAULT current_timestamp,trust smallint CHECK( 100 >= trust AND trust >= 0 )  DEFAULT 1, PRIMARY KEY (id));
CREATE TABLE pi.r_product_list_price( id bigserial not null,product_id bigint REFERENCES pi.product (id) ON DELETE RESTRICT ON UPDATE CASCADE ,list_price_id bigint REFERENCES pi.list_price (id) ON DELETE RESTRICT ON UPDATE CASCADE ,data_source_instance_id bigint REFERENCES pi.data_source_instance (id) ON DELETE RESTRICT ON UPDATE CASCADE ,timestamp timestamp with time zone not null DEFAULT current_timestamp,trust smallint CHECK( 100 >= trust AND trust >= 0 )  DEFAULT 1, PRIMARY KEY (id));
CREATE TABLE pi.r_product_subject( id bigserial not null,product_id bigint REFERENCES pi.product (id) ON DELETE RESTRICT ON UPDATE CASCADE ,subject_id bigint REFERENCES pi.subject (id) ON DELETE RESTRICT ON UPDATE CASCADE ,data_source_instance_id bigint REFERENCES pi.data_source_instance (id) ON DELETE RESTRICT ON UPDATE CASCADE ,timestamp timestamp with time zone not null DEFAULT current_timestamp,trust smallint CHECK( 100 >= trust AND trust >= 0 )  DEFAULT 1, PRIMARY KEY (id));
CREATE TABLE pi.r_product_title( id bigserial not null,product_id bigint REFERENCES pi.product (id) ON DELETE RESTRICT ON UPDATE CASCADE ,title_id bigint REFERENCES pi.title (id) ON DELETE RESTRICT ON UPDATE CASCADE ,data_source_instance_id bigint REFERENCES pi.data_source_instance (id) ON DELETE RESTRICT ON UPDATE CASCADE ,timestamp timestamp with time zone not null DEFAULT current_timestamp,trust smallint CHECK( 100 >= trust AND trust >= 0 )  DEFAULT 1, PRIMARY KEY (id));
CREATE TABLE pi.r_language_language_display( id bigserial not null,language_id bigint REFERENCES pi.language (id) ON DELETE RESTRICT ON UPDATE CASCADE ,language_display_id bigint REFERENCES pi.language_display (id) ON DELETE RESTRICT ON UPDATE CASCADE ,data_source_instance_id bigint REFERENCES pi.data_source_instance (id) ON DELETE RESTRICT ON UPDATE CASCADE ,timestamp timestamp with time zone not null DEFAULT current_timestamp,trust smallint CHECK( 100 >= trust AND trust >= 0 )  DEFAULT 1, PRIMARY KEY (id));
CREATE TABLE pi.r_product_meta_date( id bigserial not null,product_id bigint REFERENCES pi.product (id) ON DELETE RESTRICT ON UPDATE CASCADE ,meta_type_id bigint REFERENCES pi.meta_type (id) ON DELETE RESTRICT ON UPDATE CASCADE ,meta_date_id bigint REFERENCES pi.meta_date (id) ON DELETE RESTRICT ON UPDATE CASCADE ,UNIQUE (product_id, meta_date_id, meta_type_id, data_source_instance_id),data_source_instance_id bigint REFERENCES pi.data_source_instance (id) ON DELETE RESTRICT ON UPDATE CASCADE ,timestamp timestamp with time zone not null DEFAULT current_timestamp,trust smallint CHECK( 100 >= trust AND trust >= 0 )  DEFAULT 1, PRIMARY KEY (id));
CREATE TABLE pi.r_product_pages( id bigserial not null,product_id bigint REFERENCES pi.product (id) ON DELETE RESTRICT ON UPDATE CASCADE ,pages_id bigint REFERENCES pi.pages (id) ON DELETE RESTRICT ON UPDATE CASCADE ,data_source_instance_id bigint REFERENCES pi.data_source_instance (id) ON DELETE RESTRICT ON UPDATE CASCADE ,timestamp timestamp with time zone not null DEFAULT current_timestamp,trust smallint CHECK( 100 >= trust AND trust >= 0 )  DEFAULT 1, PRIMARY KEY (id));
CREATE VIEW pi.v_product_c_blurb AS
                             SELECT pi.r_product_c_blurb.id, product.pid, c_blurb.id AS blurb, r_product_c_blurb.timestamp, trust * pi.calc_trust(r_product_c_blurb.data_source_instance_id) as trust
                             FROM pi.r_product_c_blurb
                             JOIN pi.product ON (pi.r_product_c_blurb.product_id = pi.product.id)
                             JOIN pi.c_blurb ON (pi.r_product_c_blurb.c_blurb_id = pi.c_blurb.id)
;
                            
CREATE VIEW pi.v_best_product_c_blurb AS
                             SELECT *
                             FROM pi.v_product_c_blurb
                             WHERE trust > 0
                             
                             ORDER BY trust,timestamp
                             ;
                            
CREATE VIEW pi.v_product_publisher AS
                             SELECT pi.r_product_publisher.id, product.pid, publisher.publisher, r_product_publisher.timestamp, trust * pi.calc_trust(r_product_publisher.data_source_instance_id) as trust
                             FROM pi.r_product_publisher
                             JOIN pi.product ON (pi.r_product_publisher.product_id = pi.product.id)
                             JOIN pi.publisher ON (pi.r_product_publisher.publisher_id = pi.publisher.id)
;
                            
CREATE VIEW pi.v_best_product_publisher AS
                             SELECT *
                             FROM pi.v_product_publisher
                             WHERE trust > 0
                             
                             ORDER BY trust,timestamp
                             ;
                            
CREATE VIEW pi.v_currency_currency_display AS
                             SELECT pi.r_currency_currency_display.id, currency.currency, currency_display.currency_display, r_currency_currency_display.timestamp, trust * pi.calc_trust(r_currency_currency_display.data_source_instance_id) as trust
                             FROM pi.r_currency_currency_display
                             JOIN pi.currency ON (pi.r_currency_currency_display.currency_id = pi.currency.id)
                             JOIN pi.currency_display ON (pi.r_currency_currency_display.currency_display_id = pi.currency_display.id)
;
                            
CREATE VIEW pi.v_best_currency_currency_display AS
                             SELECT *
                             FROM pi.v_currency_currency_display
                             WHERE trust > 0
                             
                             ORDER BY trust,timestamp
                             ;
                            
CREATE VIEW pi.v_product_copyright AS
                             SELECT pi.r_product_copyright.id, product.pid, copyright.copyright, r_product_copyright.timestamp, trust * pi.calc_trust(r_product_copyright.data_source_instance_id) as trust
                             FROM pi.r_product_copyright
                             JOIN pi.product ON (pi.r_product_copyright.product_id = pi.product.id)
                             JOIN pi.copyright ON (pi.r_product_copyright.copyright_id = pi.copyright.id)
;
                            
CREATE VIEW pi.v_best_product_copyright AS
                             SELECT *
                             FROM pi.v_product_copyright
                             WHERE trust > 0
                             
                             ORDER BY trust,timestamp
                             ;
                            
CREATE VIEW pi.v_c_blurb_meta_date AS
                             SELECT pi.r_c_blurb_meta_date.id, c_blurb.id AS blurb, meta_date.meta_date, r_c_blurb_meta_date.timestamp, trust * pi.calc_trust(r_c_blurb_meta_date.data_source_instance_id) as trust
                             FROM pi.r_c_blurb_meta_date
                             JOIN pi.c_blurb ON (pi.r_c_blurb_meta_date.c_blurb_id = pi.c_blurb.id)
                             JOIN pi.meta_date ON (pi.r_c_blurb_meta_date.meta_date_id = pi.meta_date.id)
;
                            
CREATE VIEW pi.v_best_c_blurb_meta_date AS
                             SELECT *
                             FROM pi.v_c_blurb_meta_date
                             WHERE trust > 0
                             
                             ORDER BY trust,timestamp
                             ;
                            
CREATE VIEW pi.v_product_binding AS
                             SELECT pi.r_product_binding.id, product.pid, binding.binding, r_product_binding.timestamp, trust * pi.calc_trust(r_product_binding.data_source_instance_id) as trust
                             FROM pi.r_product_binding
                             JOIN pi.product ON (pi.r_product_binding.product_id = pi.product.id)
                             JOIN pi.binding ON (pi.r_product_binding.binding_id = pi.binding.id)
;
                            
CREATE VIEW pi.v_best_product_binding AS
                             SELECT *
                             FROM pi.v_product_binding
                             WHERE trust > 0
                             
                             ORDER BY trust,timestamp
                             ;
                            
CREATE VIEW pi.v_product_meta_data AS
                             SELECT pi.r_product_meta_data.id, product.pid, meta_type.meta_type, meta_data.meta_data, r_product_meta_data.timestamp, trust * pi.calc_trust(r_product_meta_data.data_source_instance_id) as trust
                             FROM pi.r_product_meta_data
                             JOIN pi.product ON (pi.r_product_meta_data.product_id = pi.product.id)
                             JOIN pi.meta_type ON (pi.r_product_meta_data.meta_type_id = pi.meta_type.id)
                             JOIN pi.meta_data ON (pi.r_product_meta_data.meta_data_id = pi.meta_data.id)
;
                            
CREATE VIEW pi.v_best_product_meta_data AS
                             SELECT *
                             FROM pi.v_product_meta_data
                             WHERE trust > 0
                             
                             ORDER BY trust,timestamp
                             ;
                            
CREATE VIEW pi.v_blurb_type_blurb_type_display AS
                             SELECT pi.r_blurb_type_blurb_type_display.id, blurb_type.blurb_type, blurb_type_display.blurb_type_display, r_blurb_type_blurb_type_display.timestamp, trust * pi.calc_trust(r_blurb_type_blurb_type_display.data_source_instance_id) as trust
                             FROM pi.r_blurb_type_blurb_type_display
                             JOIN pi.blurb_type ON (pi.r_blurb_type_blurb_type_display.blurb_type_id = pi.blurb_type.id)
                             JOIN pi.blurb_type_display ON (pi.r_blurb_type_blurb_type_display.blurb_type_display_id = pi.blurb_type_display.id)
;
                            
CREATE VIEW pi.v_best_blurb_type_blurb_type_display AS
                             SELECT *
                             FROM pi.v_blurb_type_blurb_type_display
                             WHERE trust > 0
                             
                             ORDER BY trust,timestamp
                             ;
                            
CREATE VIEW pi.v_c_blurb_meta_data AS
                             SELECT pi.r_c_blurb_meta_data.id, c_blurb.id AS blurb, meta_data.meta_data, r_c_blurb_meta_data.timestamp, trust * pi.calc_trust(r_c_blurb_meta_data.data_source_instance_id) as trust
                             FROM pi.r_c_blurb_meta_data
                             JOIN pi.c_blurb ON (pi.r_c_blurb_meta_data.c_blurb_id = pi.c_blurb.id)
                             JOIN pi.meta_data ON (pi.r_c_blurb_meta_data.meta_data_id = pi.meta_data.id)
;
                            
CREATE VIEW pi.v_best_c_blurb_meta_data AS
                             SELECT *
                             FROM pi.v_c_blurb_meta_data
                             WHERE trust > 0
                             
                             ORDER BY trust,timestamp
                             ;
                            
CREATE VIEW pi.v_binding_binding_display AS
                             SELECT pi.r_binding_binding_display.id, binding.binding, binding_display.binding_display, r_binding_binding_display.timestamp, trust * pi.calc_trust(r_binding_binding_display.data_source_instance_id) as trust
                             FROM pi.r_binding_binding_display
                             JOIN pi.binding ON (pi.r_binding_binding_display.binding_id = pi.binding.id)
                             JOIN pi.binding_display ON (pi.r_binding_binding_display.binding_display_id = pi.binding_display.id)
;
                            
CREATE VIEW pi.v_best_binding_binding_display AS
                             SELECT *
                             FROM pi.v_binding_binding_display
                             WHERE trust > 0
                             
                             ORDER BY trust,timestamp
                             ;
                            
CREATE VIEW pi.v_product_language AS
                             SELECT pi.r_product_language.id, product.pid, language.language, r_product_language.timestamp, trust * pi.calc_trust(r_product_language.data_source_instance_id) as trust
                             FROM pi.r_product_language
                             JOIN pi.product ON (pi.r_product_language.product_id = pi.product.id)
                             JOIN pi.language ON (pi.r_product_language.language_id = pi.language.id)
;
                            
CREATE VIEW pi.v_best_product_language AS
                             SELECT *
                             FROM pi.v_product_language
                             WHERE trust > 0
                             
                             ORDER BY trust,timestamp
                             ;
                            
CREATE VIEW pi.v_product_list_price AS
                             SELECT pi.r_product_list_price.id, product.pid, list_price.list_price, r_product_list_price.timestamp, trust * pi.calc_trust(r_product_list_price.data_source_instance_id) as trust
                             FROM pi.r_product_list_price
                             JOIN pi.product ON (pi.r_product_list_price.product_id = pi.product.id)
                             JOIN pi.list_price ON (pi.r_product_list_price.list_price_id = pi.list_price.id)
;
                            
CREATE VIEW pi.v_best_product_list_price AS
                             SELECT *
                             FROM pi.v_product_list_price
                             WHERE trust > 0
                             
                             ORDER BY trust,timestamp
                             ;
                            
CREATE VIEW pi.v_blurb AS
                             SELECT pi.c_blurb.id, blurb_text.blurb_text, blurb_type.blurb_type, data_source.data_source, person.id AS person
                             FROM pi.c_blurb
                             JOIN pi.blurb_text ON (pi.c_blurb.blurb_text_id = pi.blurb_text.id)
                             JOIN pi.blurb_type ON (pi.c_blurb.blurb_type_id = pi.blurb_type.id)
                             JOIN pi.data_source ON (pi.c_blurb.data_source_id = pi.data_source.id)
                             JOIN pi.person ON (pi.c_blurb.person_id = pi.person.id)
;
                            
CREATE VIEW pi.v_best_blurb AS
                             SELECT *
                             FROM pi.v_blurb
                             WHERE trust > 0
                             
                             ORDER BY trust,timestamp
                             ;
                            
CREATE VIEW pi.v_product_subject AS
                             SELECT pi.r_product_subject.id, product.pid, subject.subject, r_product_subject.timestamp, trust * pi.calc_trust(r_product_subject.data_source_instance_id) as trust
                             FROM pi.r_product_subject
                             JOIN pi.product ON (pi.r_product_subject.product_id = pi.product.id)
                             JOIN pi.subject ON (pi.r_product_subject.subject_id = pi.subject.id)
;
                            
CREATE VIEW pi.v_best_product_subject AS
                             SELECT *
                             FROM pi.v_product_subject
                             WHERE trust > 0
                             
                             ORDER BY trust,timestamp
                             ;
                            
CREATE VIEW pi.v_product_title AS
                             SELECT pi.r_product_title.id, product.pid, title.title, r_product_title.timestamp, trust * pi.calc_trust(r_product_title.data_source_instance_id) as trust
                             FROM pi.r_product_title
                             JOIN pi.product ON (pi.r_product_title.product_id = pi.product.id)
                             JOIN pi.title ON (pi.r_product_title.title_id = pi.title.id)
;
                            
CREATE VIEW pi.v_best_product_title AS
                             SELECT *
                             FROM pi.v_product_title
                             WHERE trust > 0
                             
                             ORDER BY trust,timestamp
                             ;
                            
CREATE VIEW pi.v_language_language_display AS
                             SELECT pi.r_language_language_display.id, language.language, language_display.language_display, r_language_language_display.timestamp, trust * pi.calc_trust(r_language_language_display.data_source_instance_id) as trust
                             FROM pi.r_language_language_display
                             JOIN pi.language ON (pi.r_language_language_display.language_id = pi.language.id)
                             JOIN pi.language_display ON (pi.r_language_language_display.language_display_id = pi.language_display.id)
;
                            
CREATE VIEW pi.v_best_language_language_display AS
                             SELECT *
                             FROM pi.v_language_language_display
                             WHERE trust > 0
                             
                             ORDER BY trust,timestamp
                             ;
                            
CREATE VIEW pi.v_product_meta_date AS
                             SELECT pi.r_product_meta_date.id, product.pid, meta_type.meta_type, meta_date.meta_date, r_product_meta_date.timestamp, trust * pi.calc_trust(r_product_meta_date.data_source_instance_id) as trust
                             FROM pi.r_product_meta_date
                             JOIN pi.product ON (pi.r_product_meta_date.product_id = pi.product.id)
                             JOIN pi.meta_type ON (pi.r_product_meta_date.meta_type_id = pi.meta_type.id)
                             JOIN pi.meta_date ON (pi.r_product_meta_date.meta_date_id = pi.meta_date.id)
;
                            
CREATE VIEW pi.v_best_product_meta_date AS
                             SELECT *
                             FROM pi.v_product_meta_date
                             WHERE trust > 0
                             
                             ORDER BY trust,timestamp
                             ;
                            
CREATE VIEW pi.v_product_pages AS
                             SELECT pi.r_product_pages.id, product.pid, pages.pages, r_product_pages.timestamp, trust * pi.calc_trust(r_product_pages.data_source_instance_id) as trust
                             FROM pi.r_product_pages
                             JOIN pi.product ON (pi.r_product_pages.product_id = pi.product.id)
                             JOIN pi.pages ON (pi.r_product_pages.pages_id = pi.pages.id)
;
                            
CREATE VIEW pi.v_best_product_pages AS
                             SELECT *
                             FROM pi.v_product_pages
                             WHERE trust > 0
                             
                             ORDER BY trust,timestamp
                             ;
                            
INSERT INTO pi.config_best (view,type,custom_group,custom_order,custom_limit) VALUES ('v_product_c_blurb','multi',NULL,NULL,'10');
INSERT INTO pi.config_best (view,type,custom_group,custom_order,custom_limit) VALUES ('v_product_publisher','single',NULL,NULL,'1');
INSERT INTO pi.config_best (view,type,custom_group,custom_order,custom_limit) VALUES ('v_currency_currency_display','display',NULL,NULL,'1');
INSERT INTO pi.config_best (view,type,custom_group,custom_order,custom_limit) VALUES ('v_product_copyright','single',NULL,NULL,'1');
INSERT INTO pi.config_best (view,type,custom_group,custom_order,custom_limit) VALUES ('v_c_blurb_meta_date','multi',NULL,NULL,NULL);
INSERT INTO pi.config_best (view,type,custom_group,custom_order,custom_limit) VALUES ('v_product_binding','single',NULL,NULL,'1');
INSERT INTO pi.config_best (view,type,custom_group,custom_order,custom_limit) VALUES ('v_product_meta_data','multi',NULL,NULL,NULL);
INSERT INTO pi.config_best (view,type,custom_group,custom_order,custom_limit) VALUES ('v_blurb_type_blurb_type_display','display',NULL,NULL,'1');
INSERT INTO pi.config_best (view,type,custom_group,custom_order,custom_limit) VALUES ('v_c_blurb_meta_data','multi',NULL,NULL,NULL);
INSERT INTO pi.config_best (view,type,custom_group,custom_order,custom_limit) VALUES ('v_binding_binding_display','display',NULL,NULL,'1');
INSERT INTO pi.config_best (view,type,custom_group,custom_order,custom_limit) VALUES ('v_product_language','single',NULL,NULL,'1');
INSERT INTO pi.config_best (view,type,custom_group,custom_order,custom_limit) VALUES ('v_product_list_price','single',NULL,NULL,'1');
INSERT INTO pi.config_best (view,type,custom_group,custom_order,custom_limit) VALUES ('v_blurb','collection',NULL,NULL,NULL);
INSERT INTO pi.config_best (view,type,custom_group,custom_order,custom_limit) VALUES ('v_product_subject','multi',NULL,NULL,NULL);
INSERT INTO pi.config_best (view,type,custom_group,custom_order,custom_limit) VALUES ('v_product_title','single',NULL,NULL,'1');
INSERT INTO pi.config_best (view,type,custom_group,custom_order,custom_limit) VALUES ('v_language_language_display','single',NULL,NULL,'1');
INSERT INTO pi.config_best (view,type,custom_group,custom_order,custom_limit) VALUES ('v_product_meta_date','multi',NULL,NULL,NULL);
INSERT INTO pi.config_best (view,type,custom_group,custom_order,custom_limit) VALUES ('v_product_pages','single',NULL,NULL,'1');
insert into pi.binding (binding) VALUES ('PB'); 
insert into pi.binding_display (binding_display) VALUES ('PaperBack');
insert into pi.data_source_type (data_source_type,trust) VALUES ('TEST',2);
insert into pi.data_source (data_source,data_source_type_id) VALUES ('benh TEST',1);
insert into pi.data_source_instance (data_source_instance, data_source_id) VALUES ('mksql TEST',1);
insert into pi.r_binding_binding_display (binding_id,binding_display_id,data_source_instance_id) VALUES (1,1,1);
INSERT INTO pi.data_source_type (data_source_type) VALUES ('TEST');
INSERT INTO pi.data_source (data_source, data_source_type_id) VALUES ('this test', (SELECT id FROM pi.data_source_type WHERE data_source_type = 'TEST'));
INSERT INTO pi.data_source_instance (data_source_id, data_source_instance) VALUES ((SELECT id FROM pi.data_source WHERE data_source = 'this test'), 'inserter');
INSERT INTO pi.product (pid) VALUES ('9780803735330');
INSERT INTO pi.binding (binding) VALUES ('Hardcover');
INSERT INTO pi.r_product_binding (binding_id, product_id, data_source_instance_id) VALUES ((SELECT id FROM pi.binding WHERE binding = 'Hardcover'), (SELECT id FROM pi.product WHERE pid = '9780803735330'), (SELECT id FROM pi.data_source_instance WHERE data_source_instance = 'inserter'));
INSERT INTO pi.currency (currency) VALUES ('$');
INSERT INTO pi.list_price (currency_id, list_price) VALUES ((SELECT id FROM pi.currency WHERE currency = '$'), '16.99');
INSERT INTO pi.r_product_list_price (product_id, list_price_id, data_source_instance_id) VALUES ((SELECT id FROM pi.product WHERE pid = '9780803735330'), (SELECT id FROM pi.list_price WHERE currency_id = (SELECT id FROM pi.currency WHERE currency = '$') AND list_price = '16.99'), (SELECT id FROM pi.data_source_instance WHERE data_source_instance = 'inserter'));
INSERT INTO pi.meta_type (meta_type) VALUES ('author');
INSERT INTO pi.meta_data (meta_type_id, meta_data) VALUES ((SELECT id FROM pi.meta_type WHERE meta_type = 'author'), 'Jerry Pinkney');
INSERT INTO pi.r_product_meta_data (meta_type_id, product_id, data_source_instance_id, meta_data_id) VALUES ((SELECT id FROM pi.meta_type WHERE meta_type = 'author'), (SELECT id FROM pi.product WHERE pid = '9780803735330'), (SELECT id FROM pi.data_source_instance WHERE data_source_instance = 'inserter'), (SELECT id FROM pi.meta_data WHERE meta_type_id = (SELECT id FROM pi.meta_type WHERE meta_type = 'author') AND meta_data = 'Jerry Pinkney'));
INSERT INTO pi.title (subtitle, title, title_key) VALUES ('', 'Three Little Kittens', 'threelittlekittens');
INSERT INTO pi.r_product_title (product_id, data_source_instance_id, title_id) VALUES ((SELECT id FROM pi.product WHERE pid = '9780803735330'), (SELECT id FROM pi.data_source_instance WHERE data_source_instance = 'inserter'), (SELECT id FROM pi.title WHERE title_key = 'threelittlekittens'));INSERT INTO pi.data_source_type (data_source_type) VALUES ('TEST');
INSERT INTO pi.data_source (data_source, data_source_type_id) VALUES ('this test', (SELECT id FROM pi.data_source_type WHERE data_source_type = 'TEST'));
INSERT INTO pi.data_source_instance (data_source_id, data_source_instance) VALUES ((SELECT id FROM pi.data_source WHERE data_source = 'this test'), 'inserter');
INSERT INTO pi.product (pid) VALUES ('9780803735330');
INSERT INTO pi.binding (binding) VALUES ('Hardcover');
INSERT INTO pi.r_product_binding (binding_id, product_id, data_source_instance_id) VALUES ((SELECT id FROM pi.binding WHERE binding = 'Hardcover'), (SELECT id FROM pi.product WHERE pid = '9780803735330'), (SELECT id FROM pi.data_source_instance WHERE data_source_instance = 'inserter'));
INSERT INTO pi.currency (currency) VALUES ('$');
INSERT INTO pi.list_price (currency_id, list_price) VALUES ((SELECT id FROM pi.currency WHERE currency = '$'), '16.99');
INSERT INTO pi.r_product_list_price (product_id, list_price_id, data_source_instance_id) VALUES ((SELECT id FROM pi.product WHERE pid = '9780803735330'), (SELECT id FROM pi.list_price WHERE currency_id = (SELECT id FROM pi.currency WHERE currency = '$') AND list_price = '16.99'), (SELECT id FROM pi.data_source_instance WHERE data_source_instance = 'inserter'));
INSERT INTO pi.meta_type (meta_type) VALUES ('author');
INSERT INTO pi.meta_data (meta_type_id, meta_data) VALUES ((SELECT id FROM pi.meta_type WHERE meta_type = 'author'), 'Jerry Pinkney');
INSERT INTO pi.r_product_meta_data (meta_type_id, product_id, data_source_instance_id, meta_data_id) VALUES ((SELECT id FROM pi.meta_type WHERE meta_type = 'author'), (SELECT id FROM pi.product WHERE pid = '9780803735330'), (SELECT id FROM pi.data_source_instance WHERE data_source_instance = 'inserter'), (SELECT id FROM pi.meta_data WHERE meta_type_id = (SELECT id FROM pi.meta_type WHERE meta_type = 'author') AND meta_data = 'Jerry Pinkney'));
INSERT INTO pi.title (subtitle, title, title_key) VALUES ('', 'Three Little Kittens', 'threelittlekittens');
INSERT INTO pi.r_product_title (product_id, data_source_instance_id, title_id) VALUES ((SELECT id FROM pi.product WHERE pid = '9780803735330'), (SELECT id FROM pi.data_source_instance WHERE data_source_instance = 'inserter'), (SELECT id FROM pi.title WHERE title_key = 'threelittlekittens'));INSERT INTO pi.data_source_type (data_source_type) VALUES ('TEST');
INSERT INTO pi.data_source (data_source, data_source_type_id) VALUES ('this test', (SELECT id FROM pi.data_source_type WHERE data_source_type = 'TEST'));
INSERT INTO pi.data_source_instance (data_source_id, data_source_instance) VALUES ((SELECT id FROM pi.data_source WHERE data_source = 'this test'), 'inserter');
INSERT INTO pi.meta_type (meta_type) VALUES ('edition Description');
INSERT INTO pi.meta_data (meta_type_id, meta_data) VALUES ((SELECT id FROM pi.meta_type WHERE meta_type = 'edition Description'), 'AMERICAN Paperback');
INSERT INTO pi.r_product_meta_data (meta_type_id, product_id, data_source_instance_id, meta_data_id) VALUES ((SELECT id FROM pi.meta_type WHERE meta_type = 'edition Description'), (SELECT id FROM pi.product WHERE pid = '9780590353427'), (SELECT id FROM pi.data_source_instance WHERE data_source_instance = 'inserter'), (SELECT id FROM pi.meta_data WHERE meta_type_id = (SELECT id FROM pi.meta_type WHERE meta_type = 'edition Description') AND meta_data = 'AMERICAN Paperback'));
INSERT INTO pi.binding (binding) VALUES ('Paperback');
INSERT INTO pi.r_product_binding (binding_id, product_id, data_source_instance_id) VALUES ((SELECT id FROM pi.binding WHERE binding = 'Paperback'), (SELECT id FROM pi.product WHERE pid = '9780590353427'), (SELECT id FROM pi.data_source_instance WHERE data_source_instance = 'inserter'));
INSERT INTO pi.meta_type (meta_type) VALUES ('publication Date');
INSERT INTO pi.meta_data (meta_type_id, meta_data) VALUES ((SELECT id FROM pi.meta_type WHERE meta_type = 'publication Date'), 'September 1999');
INSERT INTO pi.r_product_meta_data (meta_type_id, product_id, data_source_instance_id, meta_data_id) VALUES ((SELECT id FROM pi.meta_type WHERE meta_type = 'publication Date'), (SELECT id FROM pi.product WHERE pid = '9780590353427'), (SELECT id FROM pi.data_source_instance WHERE data_source_instance = 'inserter'), (SELECT id FROM pi.meta_data WHERE meta_type_id = (SELECT id FROM pi.meta_type WHERE meta_type = 'publication Date') AND meta_data = 'September 1999'));
INSERT INTO pi.copyright (copyright) VALUES ('1997');
INSERT INTO pi.r_product_copyright (product_id, copyright_id, data_source_instance_id) VALUES ((SELECT id FROM pi.product WHERE pid = '9780590353427'), (SELECT id FROM pi.copyright WHERE copyright = '1997'), (SELECT id FROM pi.data_source_instance WHERE data_source_instance = 'inserter'));
INSERT INTO pi.meta_type (meta_type) VALUES ('dimensions');
INSERT INTO pi.meta_data (meta_type_id, meta_data) VALUES ((SELECT id FROM pi.meta_type WHERE meta_type = 'dimensions'), '7.64x5.25x.78 in. .53 lbs.');
INSERT INTO pi.r_product_meta_data (meta_type_id, product_id, data_source_instance_id, meta_data_id) VALUES ((SELECT id FROM pi.meta_type WHERE meta_type = 'dimensions'), (SELECT id FROM pi.product WHERE pid = '9780590353427'), (SELECT id FROM pi.data_source_instance WHERE data_source_instance = 'inserter'), (SELECT id FROM pi.meta_data WHERE meta_type_id = (SELECT id FROM pi.meta_type WHERE meta_type = 'dimensions') AND meta_data = '7.64x5.25x.78 in. .53 lbs.'));
INSERT INTO pi.meta_type (meta_type) VALUES ('author');
INSERT INTO pi.meta_data (meta_type_id, meta_data) VALUES ((SELECT id FROM pi.meta_type WHERE meta_type = 'author'), 'J. K. Rowling');
INSERT INTO pi.r_product_meta_data (meta_type_id, product_id, data_source_instance_id, meta_data_id) VALUES ((SELECT id FROM pi.meta_type WHERE meta_type = 'author'), (SELECT id FROM pi.product WHERE pid = '9780590353427'), (SELECT id FROM pi.data_source_instance WHERE data_source_instance = 'inserter'), (SELECT id FROM pi.meta_data WHERE meta_type_id = (SELECT id FROM pi.meta_type WHERE meta_type = 'author') AND meta_data = 'J. K. Rowling'));
INSERT INTO pi.meta_type (meta_type) VALUES ('series');
INSERT INTO pi.meta_data (meta_type_id, meta_data) VALUES ((SELECT id FROM pi.meta_type WHERE meta_type = 'series'), 'Harry Potter (Paperback)');
INSERT INTO pi.r_product_meta_data (meta_type_id, product_id, data_source_instance_id, meta_data_id) VALUES ((SELECT id FROM pi.meta_type WHERE meta_type = 'series'), (SELECT id FROM pi.product WHERE pid = '9780590353427'), (SELECT id FROM pi.data_source_instance WHERE data_source_instance = 'inserter'), (SELECT id FROM pi.meta_data WHERE meta_type_id = (SELECT id FROM pi.meta_type WHERE meta_type = 'series') AND meta_data = 'Harry Potter (Paperback)'));
INSERT INTO pi.product (pid) VALUES ('9780590353427');
INSERT INTO pi.meta_type (meta_type) VALUES ('series Volume');
INSERT INTO pi.meta_data (meta_type_id, meta_data) VALUES ((SELECT id FROM pi.meta_type WHERE meta_type = 'series Volume'), '01');
INSERT INTO pi.r_product_meta_data (meta_type_id, product_id, data_source_instance_id, meta_data_id) VALUES ((SELECT id FROM pi.meta_type WHERE meta_type = 'series Volume'), (SELECT id FROM pi.product WHERE pid = '9780590353427'), (SELECT id FROM pi.data_source_instance WHERE data_source_instance = 'inserter'), (SELECT id FROM pi.meta_data WHERE meta_type_id = (SELECT id FROM pi.meta_type WHERE meta_type = 'series Volume') AND meta_data = '01'));
INSERT INTO pi.publisher (publisher) VALUES ('Arthur A. Levine Books');
INSERT INTO pi.r_product_publisher (product_id, data_source_instance_id, publisher_id) VALUES ((SELECT id FROM pi.product WHERE pid = '9780590353427'), (SELECT id FROM pi.data_source_instance WHERE data_source_instance = 'inserter'), (SELECT id FROM pi.publisher WHERE publisher = 'Arthur A. Levine Books'));
INSERT INTO pi.meta_type (meta_type) VALUES ('edition Number');
INSERT INTO pi.meta_data (meta_type_id, meta_data) VALUES ((SELECT id FROM pi.meta_type WHERE meta_type = 'edition Number'), '1st American ed.');
INSERT INTO pi.r_product_meta_data (meta_type_id, product_id, data_source_instance_id, meta_data_id) VALUES ((SELECT id FROM pi.meta_type WHERE meta_type = 'edition Number'), (SELECT id FROM pi.product WHERE pid = '9780590353427'), (SELECT id FROM pi.data_source_instance WHERE data_source_instance = 'inserter'), (SELECT id FROM pi.meta_data WHERE meta_type_id = (SELECT id FROM pi.meta_type WHERE meta_type = 'edition Number') AND meta_data = '1st American ed.'));
INSERT INTO pi.language (language) VALUES ('English');
INSERT INTO pi.r_product_language (language_id, product_id, data_source_instance_id) VALUES ((SELECT id FROM pi.language WHERE language = 'English'), (SELECT id FROM pi.product WHERE pid = '9780590353427'), (SELECT id FROM pi.data_source_instance WHERE data_source_instance = 'inserter'));
INSERT INTO pi.subject (subject) VALUES ('Fiction');
INSERT INTO pi.r_product_subject (subject_id, product_id, data_source_instance_id) VALUES ((SELECT id FROM pi.subject WHERE subject = 'Fiction'), (SELECT id FROM pi.product WHERE pid = '9780590353427'), (SELECT id FROM pi.data_source_instance WHERE data_source_instance = 'inserter'));
INSERT INTO pi.subject (subject) VALUES ('Science Fiction, Fantasy, & Magic');
INSERT INTO pi.r_product_subject (subject_id, product_id, data_source_instance_id) VALUES ((SELECT id FROM pi.subject WHERE subject = 'Science Fiction, Fantasy, & Magic'), (SELECT id FROM pi.product WHERE pid = '9780590353427'), (SELECT id FROM pi.data_source_instance WHERE data_source_instance = 'inserter'));
INSERT INTO pi.subject (subject) VALUES ('Humorous Stories');
INSERT INTO pi.r_product_subject (subject_id, product_id, data_source_instance_id) VALUES ((SELECT id FROM pi.subject WHERE subject = 'Humorous Stories'), (SELECT id FROM pi.product WHERE pid = '9780590353427'), (SELECT id FROM pi.data_source_instance WHERE data_source_instance = 'inserter'));
INSERT INTO pi.subject (subject) VALUES ('Childrens 9-12 - Fiction - Fantasy');
INSERT INTO pi.r_product_subject (subject_id, product_id, data_source_instance_id) VALUES ((SELECT id FROM pi.subject WHERE subject = 'Childrens 9-12 - Fiction - Fantasy'), (SELECT id FROM pi.product WHERE pid = '9780590353427'), (SELECT id FROM pi.data_source_instance WHERE data_source_instance = 'inserter'));
INSERT INTO pi.subject (subject) VALUES ('Schools');
INSERT INTO pi.r_product_subject (subject_id, product_id, data_source_instance_id) VALUES ((SELECT id FROM pi.subject WHERE subject = 'Schools'), (SELECT id FROM pi.product WHERE pid = '9780590353427'), (SELECT id FROM pi.data_source_instance WHERE data_source_instance = 'inserter'));
INSERT INTO pi.subject (subject) VALUES ('School & Education');
INSERT INTO pi.r_product_subject (subject_id, product_id, data_source_instance_id) VALUES ((SELECT id FROM pi.subject WHERE subject = 'School & Education'), (SELECT id FROM pi.product WHERE pid = '9780590353427'), (SELECT id FROM pi.data_source_instance WHERE data_source_instance = 'inserter'));
INSERT INTO pi.subject (subject) VALUES ('England');
INSERT INTO pi.r_product_subject (subject_id, product_id, data_source_instance_id) VALUES ((SELECT id FROM pi.subject WHERE subject = 'England'), (SELECT id FROM pi.product WHERE pid = '9780590353427'), (SELECT id FROM pi.data_source_instance WHERE data_source_instance = 'inserter'));
INSERT INTO pi.subject (subject) VALUES ('Magic');
INSERT INTO pi.r_product_subject (subject_id, product_id, data_source_instance_id) VALUES ((SELECT id FROM pi.subject WHERE subject = 'Magic'), (SELECT id FROM pi.product WHERE pid = '9780590353427'), (SELECT id FROM pi.data_source_instance WHERE data_source_instance = 'inserter'));
INSERT INTO pi.subject (subject) VALUES ('Wizards');
INSERT INTO pi.r_product_subject (subject_id, product_id, data_source_instance_id) VALUES ((SELECT id FROM pi.subject WHERE subject = 'Wizards'), (SELECT id FROM pi.product WHERE pid = '9780590353427'), (SELECT id FROM pi.data_source_instance WHERE data_source_instance = 'inserter'));
INSERT INTO pi.subject (subject) VALUES ('Witches');
INSERT INTO pi.r_product_subject (subject_id, product_id, data_source_instance_id) VALUES ((SELECT id FROM pi.subject WHERE subject = 'Witches'), (SELECT id FROM pi.product WHERE pid = '9780590353427'), (SELECT id FROM pi.data_source_instance WHERE data_source_instance = 'inserter'));
INSERT INTO pi.subject (subject) VALUES ('England Fiction.');
INSERT INTO pi.r_product_subject (subject_id, product_id, data_source_instance_id) VALUES ((SELECT id FROM pi.subject WHERE subject = 'England Fiction.'), (SELECT id FROM pi.product WHERE pid = '9780590353427'), (SELECT id FROM pi.data_source_instance WHERE data_source_instance = 'inserter'));
INSERT INTO pi.subject (subject) VALUES ('Potter, Harry');
INSERT INTO pi.r_product_subject (subject_id, product_id, data_source_instance_id) VALUES ((SELECT id FROM pi.subject WHERE subject = 'Potter, Harry'), (SELECT id FROM pi.product WHERE pid = '9780590353427'), (SELECT id FROM pi.data_source_instance WHERE data_source_instance = 'inserter'));
INSERT INTO pi.subject (subject) VALUES ('Fantasy & Magic');
INSERT INTO pi.r_product_subject (subject_id, product_id, data_source_instance_id) VALUES ((SELECT id FROM pi.subject WHERE subject = 'Fantasy & Magic'), (SELECT id FROM pi.product WHERE pid = '9780590353427'), (SELECT id FROM pi.data_source_instance WHERE data_source_instance = 'inserter'));
INSERT INTO pi.meta_type (meta_type) VALUES ('age Level');
INSERT INTO pi.meta_data (meta_type_id, meta_data) VALUES ((SELECT id FROM pi.meta_type WHERE meta_type = 'age Level'), '08-12');
INSERT INTO pi.r_product_meta_data (meta_type_id, product_id, data_source_instance_id, meta_data_id) VALUES ((SELECT id FROM pi.meta_type WHERE meta_type = 'age Level'), (SELECT id FROM pi.product WHERE pid = '9780590353427'), (SELECT id FROM pi.data_source_instance WHERE data_source_instance = 'inserter'), (SELECT id FROM pi.meta_data WHERE meta_type_id = (SELECT id FROM pi.meta_type WHERE meta_type = 'age Level') AND meta_data = '08-12'));
INSERT INTO pi.meta_type (meta_type) VALUES ('illustrations');
INSERT INTO pi.meta_data (meta_type_id, meta_data) VALUES ((SELECT id FROM pi.meta_type WHERE meta_type = 'illustrations'), 'Y');
INSERT INTO pi.r_product_meta_data (meta_type_id, product_id, data_source_instance_id, meta_data_id) VALUES ((SELECT id FROM pi.meta_type WHERE meta_type = 'illustrations'), (SELECT id FROM pi.product WHERE pid = '9780590353427'), (SELECT id FROM pi.data_source_instance WHERE data_source_instance = 'inserter'), (SELECT id FROM pi.meta_data WHERE meta_type_id = (SELECT id FROM pi.meta_type WHERE meta_type = 'illustrations') AND meta_data = 'Y'));
INSERT INTO pi.meta_type (meta_type) VALUES ('grade Level');
INSERT INTO pi.meta_data (meta_type_id, meta_data) VALUES ((SELECT id FROM pi.meta_type WHERE meta_type = 'grade Level'), 'Elementary and junior high');
INSERT INTO pi.r_product_meta_data (meta_type_id, product_id, data_source_instance_id, meta_data_id) VALUES ((SELECT id FROM pi.meta_type WHERE meta_type = 'grade Level'), (SELECT id FROM pi.product WHERE pid = '9780590353427'), (SELECT id FROM pi.data_source_instance WHERE data_source_instance = 'inserter'), (SELECT id FROM pi.meta_data WHERE meta_type_id = (SELECT id FROM pi.meta_type WHERE meta_type = 'grade Level') AND meta_data = 'Elementary and junior high'));
INSERT INTO pi.meta_type (meta_type) VALUES ('illustrator');
INSERT INTO pi.meta_data (meta_type_id, meta_data) VALUES ((SELECT id FROM pi.meta_type WHERE meta_type = 'illustrator'), 'Grandpre, Mary');
INSERT INTO pi.r_product_meta_data (meta_type_id, product_id, data_source_instance_id, meta_data_id) VALUES ((SELECT id FROM pi.meta_type WHERE meta_type = 'illustrator'), (SELECT id FROM pi.product WHERE pid = '9780590353427'), (SELECT id FROM pi.data_source_instance WHERE data_source_instance = 'inserter'), (SELECT id FROM pi.meta_data WHERE meta_type_id = (SELECT id FROM pi.meta_type WHERE meta_type = 'illustrator') AND meta_data = 'Grandpre, Mary'));
INSERT INTO pi.title (subtitle, title, title_key) VALUES ('', 'Harry Potter and the Sorcerers Stone', 'harrypotterandthesorcerersstone');
INSERT INTO pi.r_product_title (product_id, data_source_instance_id, title_id) VALUES ((SELECT id FROM pi.product WHERE pid = '9780590353427'), (SELECT id FROM pi.data_source_instance WHERE data_source_instance = 'inserter'), (SELECT id FROM pi.title WHERE title_key = 'harrypotterandthesorcerersstone'));
INSERT INTO pi.pages (pages) VALUES ('312');
INSERT INTO pi.r_product_pages (product_id, data_source_instance_id, pages_id) VALUES ((SELECT id FROM pi.product WHERE pid = '9780590353427'), (SELECT id FROM pi.data_source_instance WHERE data_source_instance = 'inserter'), (SELECT id FROM pi.pages WHERE pages = '312'));
