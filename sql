
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
DROP VIEW v_product_c_blurb;
DROP TABLE IF EXISTS r_product_c_blurb CASCADE;
DROP TABLE IF EXISTS copyright CASCADE;
DROP TABLE IF EXISTS binding_display CASCADE;
DROP TABLE IF EXISTS binding CASCADE;
DROP TABLE IF EXISTS data_source_type CASCADE;
DROP VIEW v_currency_currency_display;
DROP TABLE IF EXISTS r_currency_currency_display CASCADE;
DROP VIEW v_product_copyright;
DROP TABLE IF EXISTS r_product_copyright CASCADE;
DROP TABLE IF EXISTS blurb_text CASCADE;
DROP TABLE IF EXISTS data_source CASCADE;
DROP TABLE IF EXISTS meta_data CASCADE;
DROP VIEW v_c_blurb_meta_date;
DROP TABLE IF EXISTS r_c_blurb_meta_date CASCADE;
DROP VIEW v_product_binding;
DROP TABLE IF EXISTS r_product_binding CASCADE;
DROP TABLE IF EXISTS blurb_type_display CASCADE;
DROP VIEW v_product_meta_data;
DROP TABLE IF EXISTS r_product_meta_data CASCADE;
DROP TABLE IF EXISTS meta_type CASCADE;
DROP VIEW v_blurb_type_blurb_type_display;
DROP TABLE IF EXISTS r_blurb_type_blurb_type_display CASCADE;
DROP TABLE IF EXISTS title CASCADE;
DROP VIEW v_c_blurb_meta_data;
DROP TABLE IF EXISTS r_c_blurb_meta_data CASCADE;
DROP TABLE IF EXISTS _eta_date CASCADE;
DROP VIEW v_binding_binding_display;
DROP TABLE IF EXISTS r_binding_binding_display CASCADE;
DROP VIEW v_product_language;
DROP TABLE IF EXISTS r_product_language CASCADE;
DROP TABLE IF EXISTS currency CASCADE;
DROP VIEW v_product_list_price;
DROP TABLE IF EXISTS r_product_list_price CASCADE;
DROP TABLE IF EXISTS person CASCADE;
DROP VIEW v_blurb;
DROP TABLE IF EXISTS c_blurb CASCADE;
DROP TABLE IF EXISTS list_price CASCADE;
DROP TABLE IF EXISTS blurb_type CASCADE;
DROP TABLE IF EXISTS currency_display CASCADE;
DROP TABLE IF EXISTS language CASCADE;
DROP VIEW v_product_title;
DROP TABLE IF EXISTS r_product_title CASCADE;
DROP VIEW v_language_language_display;
DROP TABLE IF EXISTS r_language_language_display CASCADE;
DROP VIEW v_product_meta_date;
DROP TABLE IF EXISTS r_product_meta_date CASCADE;
DROP TABLE IF EXISTS language_display CASCADE;
DROP TABLE IF EXISTS data_source_instance CASCADE;
DROP TABLE IF EXISTS product CASCADE;
CREATE TABLE meta_type( id bigserial not null,meta_type varchar(255) not null, PRIMARY KEY (id));
CREATE TABLE copyright( id bigserial not null,copyright date not null UNIQUE, PRIMARY KEY (id));
CREATE TABLE binding_display( id bigserial not null,binding_display varchar(255) not null UNIQUE, PRIMARY KEY (id));
CREATE TABLE binding( id bigserial not null,binding varchar(255) NOT NULL UNIQUE, PRIMARY KEY (id));
CREATE TABLE data_source_type( id bigserial not null,data_source_type varchar(50) not null UNIQUE,trust smallint CHECK( 100 >= trust AND trust >= 0 )  DEFAULT 10, PRIMARY KEY (id));
CREATE TABLE blurb_text( id bigserial not null,blurb_text text not null,blurb_key VARCHAR(50) UNIQUE, PRIMARY KEY (id));
CREATE TABLE data_source( id bigserial not null,data_source varchar(100) not null,trust smallint CHECK( 100 >= trust AND trust >= 0 )  DEFAULT 10,data_source_type_id bigint REFERENCES data_source_type (id) ON DELETE RESTRICT ON UPDATE CASCADE ,UNIQUE (data_source, data_source_type_id), PRIMARY KEY (id));
CREATE TABLE meta_data( id bigserial not null,meta_data text not null,meta_type_id bigint REFERENCES meta_type (id) ON DELETE RESTRICT ON UPDATE CASCADE ,UNIQUE (meta_data, meta_type_id), PRIMARY KEY (id));
CREATE TABLE blurb_type_display( id bigserial not null,blurb_type_display varchar(255) not null UNIQUE, PRIMARY KEY (id));
CREATE TABLE title( id bigserial not null,title text not null,subtitle text DEFAULT null,title_key VARCHAR(100) not null UNIQUE, PRIMARY KEY (id));
CREATE TABLE _eta_date( id bigserial not null,meta_date date not null,meta_type_id bigint REFERENCES meta_type (id) ON DELETE RESTRICT ON UPDATE CASCADE ,UNIQUE (meta_date, meta_type_id), PRIMARY KEY (id));
CREATE TABLE currency( id bigserial not null,currency varchar(20) NOT NULL UNIQUE, PRIMARY KEY (id));
CREATE TABLE person( id bigserial not null, PRIMARY KEY (id));
CREATE TABLE list_price( id bigserial not null,list_price money not null UNIQUE,currency_id bigint REFERENCES currency (id) ON DELETE RESTRICT ON UPDATE CASCADE , PRIMARY KEY (id));
CREATE TABLE blurb_type( id bigserial not null,blurb_type varchar(255) NOT NULL UNIQUE, PRIMARY KEY (id));
CREATE TABLE currency_display( id bigserial not null,currency_display varchar(20) NOT NULL UNIQUE, PRIMARY KEY (id));
CREATE TABLE language( id bigserial not null,language varchar(255) NOT NULL UNIQUE, PRIMARY KEY (id));
CREATE TABLE language_display( id bigserial not null,language_display VARCHAR(255) NOT NULL UNIQUE, PRIMARY KEY (id));
CREATE TABLE data_source_instance( id bigserial not null,data_source_instance varchar(255) NOT NULL,data_source_id bigint REFERENCES data_source (id) ON DELETE RESTRICT ON UPDATE CASCADE ,trust smallint CHECK( 100 >= trust AND trust >= 0 )  DEFAULT 10,timestamp timestamp with time zone not null DEFAULT current_timestamp,UNIQUE (data_source_instance, data_source_id), PRIMARY KEY (id));
CREATE TABLE product( id bigserial not null,pid varchar(30) not null UNIQUE, PRIMARY KEY (id));
CREATE TABLE c_blurb( id bigserial not null,blurb_text_id bigint REFERENCES blurb_text (id) ON DELETE RESTRICT ON UPDATE CASCADE ,blurb_type_id bigint REFERENCES blurb_type (id) ON DELETE RESTRICT ON UPDATE CASCADE ,data_source_id bigint REFERENCES data_source (id) ON DELETE RESTRICT ON UPDATE CASCADE ,person_id bigint REFERENCES person (id) ON DELETE RESTRICT ON UPDATE CASCADE , PRIMARY KEY (id));
CREATE TABLE r_product_c_blurb( id bigserial not null,product_id bigint REFERENCES product (id) ON DELETE RESTRICT ON UPDATE CASCADE ,c_blurb_id bigint REFERENCES c_blurb (id) ON DELETE RESTRICT ON UPDATE CASCADE ,data_source_instance_id bigint REFERENCES data_source_instance (id) ON DELETE RESTRICT ON UPDATE CASCADE ,timestamp timestamp with time zone not null DEFAULT current_timestamp,trust smallint CHECK( 100 >= trust AND trust >= 0 )  DEFAULT 1, PRIMARY KEY (id));
CREATE TABLE r_currency_currency_display( id bigserial not null,currency_id bigint REFERENCES currency (id) ON DELETE RESTRICT ON UPDATE CASCADE ,currency_display_id bigint REFERENCES currency_display (id) ON DELETE RESTRICT ON UPDATE CASCADE ,data_source_instance_id bigint REFERENCES data_source_instance (id) ON DELETE RESTRICT ON UPDATE CASCADE ,timestamp timestamp with time zone not null DEFAULT current_timestamp,trust smallint CHECK( 100 >= trust AND trust >= 0 )  DEFAULT 1, PRIMARY KEY (id));
CREATE TABLE r_product_copyright( id bigserial not null,product_id bigint REFERENCES product (id) ON DELETE RESTRICT ON UPDATE CASCADE ,copyright_id bigint REFERENCES copyright (id) ON DELETE RESTRICT ON UPDATE CASCADE ,data_source_instance_id bigint REFERENCES data_source_instance (id) ON DELETE RESTRICT ON UPDATE CASCADE ,timestamp timestamp with time zone not null DEFAULT current_timestamp,trust smallint CHECK( 100 >= trust AND trust >= 0 )  DEFAULT 1, PRIMARY KEY (id));
CREATE TABLE r_c_blurb_meta_date( id bigserial not null,c_blurb_id bigint REFERENCES c_blurb (id) ON DELETE RESTRICT ON UPDATE CASCADE ,meta_date_id bigint REFERENCES meta_date (id) ON DELETE RESTRICT ON UPDATE CASCADE ,data_source_instance_id bigint REFERENCES data_source_instance (id) ON DELETE RESTRICT ON UPDATE CASCADE ,timestamp timestamp with time zone not null DEFAULT current_timestamp,trust smallint CHECK( 100 >= trust AND trust >= 0 )  DEFAULT 1, PRIMARY KEY (id));
CREATE TABLE r_product_binding( id bigserial not null,product_id bigint REFERENCES product (id) ON DELETE RESTRICT ON UPDATE CASCADE ,binding_id bigint REFERENCES binding (id) ON DELETE RESTRICT ON UPDATE CASCADE ,data_source_instance_id bigint REFERENCES data_source_instance (id) ON DELETE RESTRICT ON UPDATE CASCADE ,timestamp timestamp with time zone not null DEFAULT current_timestamp,trust smallint CHECK( 100 >= trust AND trust >= 0 )  DEFAULT 1, PRIMARY KEY (id));
CREATE TABLE r_product_meta_data( id bigserial not null,product_id bigint REFERENCES product (id) ON DELETE RESTRICT ON UPDATE CASCADE ,meta_data_id bigint REFERENCES meta_data (id) ON DELETE RESTRICT ON UPDATE CASCADE ,data_source_instance_id bigint REFERENCES data_source_instance (id) ON DELETE RESTRICT ON UPDATE CASCADE ,timestamp timestamp with time zone not null DEFAULT current_timestamp,trust smallint CHECK( 100 >= trust AND trust >= 0 )  DEFAULT 1, PRIMARY KEY (id));
CREATE TABLE r_blurb_type_blurb_type_display( id bigserial not null,blurb_type_id bigint REFERENCES blurb_type (id) ON DELETE RESTRICT ON UPDATE CASCADE ,blurb_type_display_id bigint REFERENCES blurb_type_display (id) ON DELETE RESTRICT ON UPDATE CASCADE ,data_source_instance_id bigint REFERENCES data_source_instance (id) ON DELETE RESTRICT ON UPDATE CASCADE ,timestamp timestamp with time zone not null DEFAULT current_timestamp,trust smallint CHECK( 100 >= trust AND trust >= 0 )  DEFAULT 1, PRIMARY KEY (id));
CREATE TABLE r_c_blurb_meta_data( id bigserial not null,c_blurb_id bigint REFERENCES c_blurb (id) ON DELETE RESTRICT ON UPDATE CASCADE ,meta_data_id bigint REFERENCES meta_data (id) ON DELETE RESTRICT ON UPDATE CASCADE ,data_source_instance_id bigint REFERENCES data_source_instance (id) ON DELETE RESTRICT ON UPDATE CASCADE ,timestamp timestamp with time zone not null DEFAULT current_timestamp,trust smallint CHECK( 100 >= trust AND trust >= 0 )  DEFAULT 1, PRIMARY KEY (id));
CREATE TABLE r_binding_binding_display( id bigserial not null,binding_id bigint REFERENCES binding (id) ON DELETE RESTRICT ON UPDATE CASCADE ,binding_display_id bigint REFERENCES binding_display (id) ON DELETE RESTRICT ON UPDATE CASCADE ,data_source_instance_id bigint REFERENCES data_source_instance (id) ON DELETE RESTRICT ON UPDATE CASCADE ,timestamp timestamp with time zone not null DEFAULT current_timestamp,trust smallint CHECK( 100 >= trust AND trust >= 0 )  DEFAULT 1, PRIMARY KEY (id));
CREATE TABLE r_product_language( id bigserial not null,product_id bigint REFERENCES product (id) ON DELETE RESTRICT ON UPDATE CASCADE ,language_id bigint REFERENCES language (id) ON DELETE RESTRICT ON UPDATE CASCADE ,data_source_instance_id bigint REFERENCES data_source_instance (id) ON DELETE RESTRICT ON UPDATE CASCADE ,timestamp timestamp with time zone not null DEFAULT current_timestamp,trust smallint CHECK( 100 >= trust AND trust >= 0 )  DEFAULT 1, PRIMARY KEY (id));
CREATE TABLE r_product_list_price( id bigserial not null,product_id bigint REFERENCES product (id) ON DELETE RESTRICT ON UPDATE CASCADE ,list_price_id bigint REFERENCES list_price (id) ON DELETE RESTRICT ON UPDATE CASCADE ,data_source_instance_id bigint REFERENCES data_source_instance (id) ON DELETE RESTRICT ON UPDATE CASCADE ,timestamp timestamp with time zone not null DEFAULT current_timestamp,trust smallint CHECK( 100 >= trust AND trust >= 0 )  DEFAULT 1, PRIMARY KEY (id));
CREATE TABLE r_product_title( id bigserial not null,product_id bigint REFERENCES product (id) ON DELETE RESTRICT ON UPDATE CASCADE ,title_id bigint REFERENCES title (id) ON DELETE RESTRICT ON UPDATE CASCADE ,data_source_instance_id bigint REFERENCES data_source_instance (id) ON DELETE RESTRICT ON UPDATE CASCADE ,timestamp timestamp with time zone not null DEFAULT current_timestamp,trust smallint CHECK( 100 >= trust AND trust >= 0 )  DEFAULT 1, PRIMARY KEY (id));
CREATE TABLE r_language_language_display( id bigserial not null,language_id bigint REFERENCES language (id) ON DELETE RESTRICT ON UPDATE CASCADE ,language_display_id bigint REFERENCES language_display (id) ON DELETE RESTRICT ON UPDATE CASCADE ,data_source_instance_id bigint REFERENCES data_source_instance (id) ON DELETE RESTRICT ON UPDATE CASCADE ,timestamp timestamp with time zone not null DEFAULT current_timestamp,trust smallint CHECK( 100 >= trust AND trust >= 0 )  DEFAULT 1, PRIMARY KEY (id));
CREATE TABLE r_product_meta_date( id bigserial not null,product_id bigint REFERENCES product (id) ON DELETE RESTRICT ON UPDATE CASCADE ,meta_date_id bigint REFERENCES meta_date (id) ON DELETE RESTRICT ON UPDATE CASCADE ,data_source_instance_id bigint REFERENCES data_source_instance (id) ON DELETE RESTRICT ON UPDATE CASCADE ,timestamp timestamp with time zone not null DEFAULT current_timestamp,trust smallint CHECK( 100 >= trust AND trust >= 0 )  DEFAULT 1, PRIMARY KEY (id));
CREATE VIEW v_product_c_blurb AS
                             SELECT r_product_c_blurb.id, product.pid, c_blurb.id AS blurb, r_product_c_blurb.timestamp, calc_trust(r_product_c_blurb.data_source_instance_id)
                             FROM r_product_c_blurb
                             JOIN product ON (r_product_c_blurb.product_id = product.id)
                             JOIN c_blurb ON (r_product_c_blurb.c_blurb_id = c_blurb.id)
;
                            
CREATE VIEW v_currency_currency_display AS
                             SELECT r_currency_currency_display.id, currency.currency, currency_display.currency_display, r_currency_currency_display.timestamp, calc_trust(r_currency_currency_display.data_source_instance_id)
                             FROM r_currency_currency_display
                             JOIN currency ON (r_currency_currency_display.currency_id = currency.id)
                             JOIN currency_display ON (r_currency_currency_display.currency_display_id = currency_display.id)
;
                            
CREATE VIEW v_product_copyright AS
                             SELECT r_product_copyright.id, product.pid, copyright.copyright, r_product_copyright.timestamp, calc_trust(r_product_copyright.data_source_instance_id)
                             FROM r_product_copyright
                             JOIN product ON (r_product_copyright.product_id = product.id)
                             JOIN copyright ON (r_product_copyright.copyright_id = copyright.id)
;
                            
CREATE VIEW v_c_blurb_meta_date AS
                             SELECT r_c_blurb_meta_date.id, c_blurb.id AS blurb, meta_date.meta_date, r_c_blurb_meta_date.timestamp, calc_trust(r_c_blurb_meta_date.data_source_instance_id)
                             FROM r_c_blurb_meta_date
                             JOIN c_blurb ON (r_c_blurb_meta_date.c_blurb_id = c_blurb.id)
                             JOIN meta_date ON (r_c_blurb_meta_date.meta_date_id = meta_date.id)
;
                            
CREATE VIEW v_product_binding AS
                             SELECT r_product_binding.id, product.pid, binding.binding, r_product_binding.timestamp, calc_trust(r_product_binding.data_source_instance_id)
                             FROM r_product_binding
                             JOIN product ON (r_product_binding.product_id = product.id)
                             JOIN binding ON (r_product_binding.binding_id = binding.id)
;
                            
CREATE VIEW v_product_meta_data AS
                             SELECT r_product_meta_data.id, product.pid, meta_data.meta_data, r_product_meta_data.timestamp, calc_trust(r_product_meta_data.data_source_instance_id)
                             FROM r_product_meta_data
                             JOIN product ON (r_product_meta_data.product_id = product.id)
                             JOIN meta_data ON (r_product_meta_data.meta_data_id = meta_data.id)
;
                            
CREATE VIEW v_blurb_type_blurb_type_display AS
                             SELECT r_blurb_type_blurb_type_display.id, blurb_type.blurb_type, blurb_type_display.blurb_type_display, r_blurb_type_blurb_type_display.timestamp, calc_trust(r_blurb_type_blurb_type_display.data_source_instance_id)
                             FROM r_blurb_type_blurb_type_display
                             JOIN blurb_type ON (r_blurb_type_blurb_type_display.blurb_type_id = blurb_type.id)
                             JOIN blurb_type_display ON (r_blurb_type_blurb_type_display.blurb_type_display_id = blurb_type_display.id)
;
                            
CREATE VIEW v_c_blurb_meta_data AS
                             SELECT r_c_blurb_meta_data.id, c_blurb.id AS blurb, meta_data.meta_data, r_c_blurb_meta_data.timestamp, calc_trust(r_c_blurb_meta_data.data_source_instance_id)
                             FROM r_c_blurb_meta_data
                             JOIN c_blurb ON (r_c_blurb_meta_data.c_blurb_id = c_blurb.id)
                             JOIN meta_data ON (r_c_blurb_meta_data.meta_data_id = meta_data.id)
;
                            
CREATE VIEW v_binding_binding_display AS
                             SELECT r_binding_binding_display.id, binding.binding, binding_display.binding_display, r_binding_binding_display.timestamp, calc_trust(r_binding_binding_display.data_source_instance_id)
                             FROM r_binding_binding_display
                             JOIN binding ON (r_binding_binding_display.binding_id = binding.id)
                             JOIN binding_display ON (r_binding_binding_display.binding_display_id = binding_display.id)
;
                            
CREATE VIEW v_product_language AS
                             SELECT r_product_language.id, product.pid, language.language, r_product_language.timestamp, calc_trust(r_product_language.data_source_instance_id)
                             FROM r_product_language
                             JOIN product ON (r_product_language.product_id = product.id)
                             JOIN language ON (r_product_language.language_id = language.id)
;
                            
CREATE VIEW v_product_list_price AS
                             SELECT r_product_list_price.id, product.pid, list_price.list_price, r_product_list_price.timestamp, calc_trust(r_product_list_price.data_source_instance_id)
                             FROM r_product_list_price
                             JOIN product ON (r_product_list_price.product_id = product.id)
                             JOIN list_price ON (r_product_list_price.list_price_id = list_price.id)
;
                            
CREATE VIEW v_blurb AS
                             SELECT c_blurb.id, blurb_text.blurb_text, blurb_type.blurb_type, data_source.data_source, person.id AS person
                             FROM c_blurb
                             JOIN blurb_text ON (c_blurb.blurb_text_id = blurb_text.id)
                             JOIN blurb_type ON (c_blurb.blurb_type_id = blurb_type.id)
                             JOIN data_source ON (c_blurb.data_source_id = data_source.id)
                             JOIN person ON (c_blurb.person_id = person.id)
;
                            
CREATE VIEW v_product_title AS
                             SELECT r_product_title.id, product.pid, title.title, r_product_title.timestamp, calc_trust(r_product_title.data_source_instance_id)
                             FROM r_product_title
                             JOIN product ON (r_product_title.product_id = product.id)
                             JOIN title ON (r_product_title.title_id = title.id)
;
                            
CREATE VIEW v_language_language_display AS
                             SELECT r_language_language_display.id, language.language, language_display.language_display, r_language_language_display.timestamp, calc_trust(r_language_language_display.data_source_instance_id)
                             FROM r_language_language_display
                             JOIN language ON (r_language_language_display.language_id = language.id)
                             JOIN language_display ON (r_language_language_display.language_display_id = language_display.id)
;
                            
CREATE VIEW v_product_meta_date AS
                             SELECT r_product_meta_date.id, product.pid, meta_date.meta_date, r_product_meta_date.timestamp, calc_trust(r_product_meta_date.data_source_instance_id)
                             FROM r_product_meta_date
                             JOIN product ON (r_product_meta_date.product_id = product.id)
                             JOIN meta_date ON (r_product_meta_date.meta_date_id = meta_date.id)
;
                            
insert into binding (binding) VALUES ('PB'); 
insert into binding_display (binding_display) VALUES ('PaperBack');
insert into data_source_type (data_source_type,trust) VALUES ('TEST',2);
insert into data_source (data_source,data_source_type_id) VALUES ('benh TEST',1);
insert into data_source_instance (data_source_instance, data_source_id) VALUES ('mksql TEST',1);
insert into r_binding_binding_display (binding_id,binding_display_id,data_source_instance_id) VALUES (1,1,1);
INSERT INTO data_source_type (data_source_type) VALUES ('TEST');
INSERT INTO data_source (data_source, data_source_type_id) VALUES ('this test', (SELECT id FROM data_source_type WHERE data_source_type = 'TEST'));
INSERT INTO data_source_instance (data_source_id, data_source_instance) VALUES ((SELECT id FROM data_source WHERE data_source = 'this test'), 'inserter');
INSERT INTO product (pid) VALUES ('9780803735330');
INSERT INTO binding (binding) VALUES ('Hardcover');
INSERT INTO r_product_binding (binding_id, product_id, data_source_instance_id) VALUES ((SELECT id FROM binding WHERE binding = 'Hardcover'), (SELECT id FROM product WHERE pid = '9780803735330'), (SELECT id FROM data_source_instance WHERE data_source_instance = 'inserter'));
INSERT INTO currency (currency) VALUES ('$');
INSERT INTO list_price (currency_id, list_price) VALUES ((SELECT id FROM currency WHERE currency = '$'), '16.99');
INSERT INTO r_product_list_price (product_id, list_price_id, data_source_instance_id) VALUES ((SELECT id FROM product WHERE pid = '9780803735330'), (SELECT id FROM list_price WHERE currency_id = (SELECT id FROM currency WHERE currency = '$') AND list_price = '16.99'), (SELECT id FROM data_source_instance WHERE data_source_instance = 'inserter'));
INSERT INTO meta_type (meta_type) VALUES ('author');
INSERT INTO meta_data (meta_type_id, meta_data) VALUES ((SELECT id FROM meta_type WHERE meta_type = 'author'), 'Jerry Pinkney');
INSERT INTO r_product_meta_data (product_id, data_source_instance_id, meta_data_id) VALUES ((SELECT id FROM product WHERE pid = '9780803735330'), (SELECT id FROM data_source_instance WHERE data_source_instance = 'inserter'), (SELECT id FROM meta_data WHERE meta_type_id = (SELECT id FROM meta_type WHERE meta_type = 'author') AND meta_data = 'Jerry Pinkney'));
INSERT INTO title (subtitle, title, title_key) VALUES ('', 'Three Little Kittens', 'threelittlekittens');
INSERT INTO r_product_title (product_id, data_source_instance_id, title_id) VALUES ((SELECT id FROM product WHERE pid = '9780803735330'), (SELECT id FROM data_source_instance WHERE data_source_instance = 'inserter'), (SELECT id FROM title WHERE title_key = 'threelittlekittens'));INSERT INTO data_source_type (data_source_type) VALUES ('TEST');
INSERT INTO data_source (data_source, data_source_type_id) VALUES ('this test', (SELECT id FROM data_source_type WHERE data_source_type = 'TEST'));
INSERT INTO data_source_instance (data_source_id, data_source_instance) VALUES ((SELECT id FROM data_source WHERE data_source = 'this test'), 'inserter');
INSERT INTO product (pid) VALUES ('9780803735330');
INSERT INTO binding (binding) VALUES ('Hardcover');
INSERT INTO r_product_binding (binding_id, product_id, data_source_instance_id) VALUES ((SELECT id FROM binding WHERE binding = 'Hardcover'), (SELECT id FROM product WHERE pid = '9780803735330'), (SELECT id FROM data_source_instance WHERE data_source_instance = 'inserter'));
INSERT INTO currency (currency) VALUES ('$');
INSERT INTO list_price (currency_id, list_price) VALUES ((SELECT id FROM currency WHERE currency = '$'), '16.99');
INSERT INTO r_product_list_price (product_id, list_price_id, data_source_instance_id) VALUES ((SELECT id FROM product WHERE pid = '9780803735330'), (SELECT id FROM list_price WHERE currency_id = (SELECT id FROM currency WHERE currency = '$') AND list_price = '16.99'), (SELECT id FROM data_source_instance WHERE data_source_instance = 'inserter'));
INSERT INTO meta_type (meta_type) VALUES ('author');
INSERT INTO meta_data (meta_type_id, meta_data) VALUES ((SELECT id FROM meta_type WHERE meta_type = 'author'), 'Jerry Pinkney');
INSERT INTO r_product_meta_data (product_id, data_source_instance_id, meta_data_id) VALUES ((SELECT id FROM product WHERE pid = '9780803735330'), (SELECT id FROM data_source_instance WHERE data_source_instance = 'inserter'), (SELECT id FROM meta_data WHERE meta_type_id = (SELECT id FROM meta_type WHERE meta_type = 'author') AND meta_data = 'Jerry Pinkney'));
INSERT INTO title (subtitle, title, title_key) VALUES ('', 'Three Little Kittens', 'threelittlekittens');
INSERT INTO r_product_title (product_id, data_source_instance_id, title_id) VALUES ((SELECT id FROM product WHERE pid = '9780803735330'), (SELECT id FROM data_source_instance WHERE data_source_instance = 'inserter'), (SELECT id FROM title WHERE title_key = 'threelittlekittens'));INSERT INTO data_source_type (data_source_type) VALUES ('TEST');
INSERT INTO data_source (data_source, data_source_type_id) VALUES ('this test', (SELECT id FROM data_source_type WHERE data_source_type = 'TEST'));
INSERT INTO data_source_instance (data_source_id, data_source_instance) VALUES ((SELECT id FROM data_source WHERE data_source = 'this test'), 'inserter');
INSERT INTO meta_type (meta_type) VALUES ('edition Description');
INSERT INTO meta_data (meta_type_id, meta_data) VALUES ((SELECT id FROM meta_type WHERE meta_type = 'edition Description'), 'AMERICAN Paperback');
INSERT INTO r_product_meta_data (product_id, data_source_instance_id, meta_data_id) VALUES ((SELECT id FROM product WHERE pid = '9780590353427'), (SELECT id FROM data_source_instance WHERE data_source_instance = 'inserter'), (SELECT id FROM meta_data WHERE meta_type_id = (SELECT id FROM meta_type WHERE meta_type = 'edition Description') AND meta_data = 'AMERICAN Paperback'));
INSERT INTO binding (binding) VALUES ('Paperback');
INSERT INTO r_product_binding (binding_id, product_id, data_source_instance_id) VALUES ((SELECT id FROM binding WHERE binding = 'Paperback'), (SELECT id FROM product WHERE pid = '9780590353427'), (SELECT id FROM data_source_instance WHERE data_source_instance = 'inserter'));
INSERT INTO meta_type (meta_type) VALUES ('publication Date');
INSERT INTO meta_data (meta_type_id, meta_data) VALUES ((SELECT id FROM meta_type WHERE meta_type = 'publication Date'), 'September 1999');
INSERT INTO r_product_meta_data (product_id, data_source_instance_id, meta_data_id) VALUES ((SELECT id FROM product WHERE pid = '9780590353427'), (SELECT id FROM data_source_instance WHERE data_source_instance = 'inserter'), (SELECT id FROM meta_data WHERE meta_type_id = (SELECT id FROM meta_type WHERE meta_type = 'publication Date') AND meta_data = 'September 1999'));
INSERT INTO copyright (copyright) VALUES ('1997');
INSERT INTO r_product_copyright (product_id, copyright_id, data_source_instance_id) VALUES ((SELECT id FROM product WHERE pid = '9780590353427'), (SELECT id FROM copyright WHERE copyright = '1997'), (SELECT id FROM data_source_instance WHERE data_source_instance = 'inserter'));
INSERT INTO meta_type (meta_type) VALUES ('dimensions');
INSERT INTO meta_data (meta_type_id, meta_data) VALUES ((SELECT id FROM meta_type WHERE meta_type = 'dimensions'), '7.64x5.25x.78 in. .53 lbs.');
INSERT INTO r_product_meta_data (product_id, data_source_instance_id, meta_data_id) VALUES ((SELECT id FROM product WHERE pid = '9780590353427'), (SELECT id FROM data_source_instance WHERE data_source_instance = 'inserter'), (SELECT id FROM meta_data WHERE meta_type_id = (SELECT id FROM meta_type WHERE meta_type = 'dimensions') AND meta_data = '7.64x5.25x.78 in. .53 lbs.'));
INSERT INTO meta_type (meta_type) VALUES ('author');
INSERT INTO meta_data (meta_type_id, meta_data) VALUES ((SELECT id FROM meta_type WHERE meta_type = 'author'), 'J. K. Rowling');
INSERT INTO r_product_meta_data (product_id, data_source_instance_id, meta_data_id) VALUES ((SELECT id FROM product WHERE pid = '9780590353427'), (SELECT id FROM data_source_instance WHERE data_source_instance = 'inserter'), (SELECT id FROM meta_data WHERE meta_type_id = (SELECT id FROM meta_type WHERE meta_type = 'author') AND meta_data = 'J. K. Rowling'));
INSERT INTO meta_type (meta_type) VALUES ('series');
INSERT INTO meta_data (meta_type_id, meta_data) VALUES ((SELECT id FROM meta_type WHERE meta_type = 'series'), 'Harry Potter (Paperback)');
INSERT INTO r_product_meta_data (product_id, data_source_instance_id, meta_data_id) VALUES ((SELECT id FROM product WHERE pid = '9780590353427'), (SELECT id FROM data_source_instance WHERE data_source_instance = 'inserter'), (SELECT id FROM meta_data WHERE meta_type_id = (SELECT id FROM meta_type WHERE meta_type = 'series') AND meta_data = 'Harry Potter (Paperback)'));
INSERT INTO product (pid) VALUES ('9780590353427');
INSERT INTO meta_type (meta_type) VALUES ('series Volume');
INSERT INTO meta_data (meta_type_id, meta_data) VALUES ((SELECT id FROM meta_type WHERE meta_type = 'series Volume'), '01');
INSERT INTO r_product_meta_data (product_id, data_source_instance_id, meta_data_id) VALUES ((SELECT id FROM product WHERE pid = '9780590353427'), (SELECT id FROM data_source_instance WHERE data_source_instance = 'inserter'), (SELECT id FROM meta_data WHERE meta_type_id = (SELECT id FROM meta_type WHERE meta_type = 'series Volume') AND meta_data = '01'));
INSERT INTO meta_type (meta_type) VALUES ('publisher');
INSERT INTO meta_data (meta_type_id, meta_data) VALUES ((SELECT id FROM meta_type WHERE meta_type = 'publisher'), 'Arthur A. Levine Books');
INSERT INTO r_product_meta_data (product_id, data_source_instance_id, meta_data_id) VALUES ((SELECT id FROM product WHERE pid = '9780590353427'), (SELECT id FROM data_source_instance WHERE data_source_instance = 'inserter'), (SELECT id FROM meta_data WHERE meta_type_id = (SELECT id FROM meta_type WHERE meta_type = 'publisher') AND meta_data = 'Arthur A. Levine Books'));
INSERT INTO meta_type (meta_type) VALUES ('edition Number');
INSERT INTO meta_data (meta_type_id, meta_data) VALUES ((SELECT id FROM meta_type WHERE meta_type = 'edition Number'), '1st American ed.');
INSERT INTO r_product_meta_data (product_id, data_source_instance_id, meta_data_id) VALUES ((SELECT id FROM product WHERE pid = '9780590353427'), (SELECT id FROM data_source_instance WHERE data_source_instance = 'inserter'), (SELECT id FROM meta_data WHERE meta_type_id = (SELECT id FROM meta_type WHERE meta_type = 'edition Number') AND meta_data = '1st American ed.'));
INSERT INTO language (language) VALUES ('English');
INSERT INTO r_product_language (language_id, product_id, data_source_instance_id) VALUES ((SELECT id FROM language WHERE language = 'English'), (SELECT id FROM product WHERE pid = '9780590353427'), (SELECT id FROM data_source_instance WHERE data_source_instance = 'inserter'));
INSERT INTO meta_type (meta_type) VALUES ('subject');
INSERT INTO meta_data (meta_type_id, meta_data) VALUES ((SELECT id FROM meta_type WHERE meta_type = 'subject'), 'Fiction');
INSERT INTO r_product_meta_data (product_id, data_source_instance_id, meta_data_id) VALUES ((SELECT id FROM product WHERE pid = '9780590353427'), (SELECT id FROM data_source_instance WHERE data_source_instance = 'inserter'), (SELECT id FROM meta_data WHERE meta_type_id = (SELECT id FROM meta_type WHERE meta_type = 'subject') AND meta_data = 'Fiction'));
INSERT INTO meta_type (meta_type) VALUES ('subject');
INSERT INTO meta_data (meta_type_id, meta_data) VALUES ((SELECT id FROM meta_type WHERE meta_type = 'subject'), 'Science Fiction, Fantasy, & Magic');
INSERT INTO r_product_meta_data (product_id, data_source_instance_id, meta_data_id) VALUES ((SELECT id FROM product WHERE pid = '9780590353427'), (SELECT id FROM data_source_instance WHERE data_source_instance = 'inserter'), (SELECT id FROM meta_data WHERE meta_type_id = (SELECT id FROM meta_type WHERE meta_type = 'subject') AND meta_data = 'Science Fiction, Fantasy, & Magic'));
INSERT INTO meta_type (meta_type) VALUES ('subject');
INSERT INTO meta_data (meta_type_id, meta_data) VALUES ((SELECT id FROM meta_type WHERE meta_type = 'subject'), 'Humorous Stories');
INSERT INTO r_product_meta_data (product_id, data_source_instance_id, meta_data_id) VALUES ((SELECT id FROM product WHERE pid = '9780590353427'), (SELECT id FROM data_source_instance WHERE data_source_instance = 'inserter'), (SELECT id FROM meta_data WHERE meta_type_id = (SELECT id FROM meta_type WHERE meta_type = 'subject') AND meta_data = 'Humorous Stories'));
INSERT INTO meta_type (meta_type) VALUES ('subject');
INSERT INTO meta_data (meta_type_id, meta_data) VALUES ((SELECT id FROM meta_type WHERE meta_type = 'subject'), 'Childrens 9-12 - Fiction - Fantasy');
INSERT INTO r_product_meta_data (product_id, data_source_instance_id, meta_data_id) VALUES ((SELECT id FROM product WHERE pid = '9780590353427'), (SELECT id FROM data_source_instance WHERE data_source_instance = 'inserter'), (SELECT id FROM meta_data WHERE meta_type_id = (SELECT id FROM meta_type WHERE meta_type = 'subject') AND meta_data = 'Childrens 9-12 - Fiction - Fantasy'));
INSERT INTO meta_type (meta_type) VALUES ('subject');
INSERT INTO meta_data (meta_type_id, meta_data) VALUES ((SELECT id FROM meta_type WHERE meta_type = 'subject'), 'Schools');
INSERT INTO r_product_meta_data (product_id, data_source_instance_id, meta_data_id) VALUES ((SELECT id FROM product WHERE pid = '9780590353427'), (SELECT id FROM data_source_instance WHERE data_source_instance = 'inserter'), (SELECT id FROM meta_data WHERE meta_type_id = (SELECT id FROM meta_type WHERE meta_type = 'subject') AND meta_data = 'Schools'));
INSERT INTO meta_type (meta_type) VALUES ('subject');
INSERT INTO meta_data (meta_type_id, meta_data) VALUES ((SELECT id FROM meta_type WHERE meta_type = 'subject'), 'School & Education');
INSERT INTO r_product_meta_data (product_id, data_source_instance_id, meta_data_id) VALUES ((SELECT id FROM product WHERE pid = '9780590353427'), (SELECT id FROM data_source_instance WHERE data_source_instance = 'inserter'), (SELECT id FROM meta_data WHERE meta_type_id = (SELECT id FROM meta_type WHERE meta_type = 'subject') AND meta_data = 'School & Education'));
INSERT INTO meta_type (meta_type) VALUES ('subject');
INSERT INTO meta_data (meta_type_id, meta_data) VALUES ((SELECT id FROM meta_type WHERE meta_type = 'subject'), 'England');
INSERT INTO r_product_meta_data (product_id, data_source_instance_id, meta_data_id) VALUES ((SELECT id FROM product WHERE pid = '9780590353427'), (SELECT id FROM data_source_instance WHERE data_source_instance = 'inserter'), (SELECT id FROM meta_data WHERE meta_type_id = (SELECT id FROM meta_type WHERE meta_type = 'subject') AND meta_data = 'England'));
INSERT INTO meta_type (meta_type) VALUES ('subject');
INSERT INTO meta_data (meta_type_id, meta_data) VALUES ((SELECT id FROM meta_type WHERE meta_type = 'subject'), 'Magic');
INSERT INTO r_product_meta_data (product_id, data_source_instance_id, meta_data_id) VALUES ((SELECT id FROM product WHERE pid = '9780590353427'), (SELECT id FROM data_source_instance WHERE data_source_instance = 'inserter'), (SELECT id FROM meta_data WHERE meta_type_id = (SELECT id FROM meta_type WHERE meta_type = 'subject') AND meta_data = 'Magic'));
INSERT INTO meta_type (meta_type) VALUES ('subject');
INSERT INTO meta_data (meta_type_id, meta_data) VALUES ((SELECT id FROM meta_type WHERE meta_type = 'subject'), 'Wizards');
INSERT INTO r_product_meta_data (product_id, data_source_instance_id, meta_data_id) VALUES ((SELECT id FROM product WHERE pid = '9780590353427'), (SELECT id FROM data_source_instance WHERE data_source_instance = 'inserter'), (SELECT id FROM meta_data WHERE meta_type_id = (SELECT id FROM meta_type WHERE meta_type = 'subject') AND meta_data = 'Wizards'));
INSERT INTO meta_type (meta_type) VALUES ('subject');
INSERT INTO meta_data (meta_type_id, meta_data) VALUES ((SELECT id FROM meta_type WHERE meta_type = 'subject'), 'Witches');
INSERT INTO r_product_meta_data (product_id, data_source_instance_id, meta_data_id) VALUES ((SELECT id FROM product WHERE pid = '9780590353427'), (SELECT id FROM data_source_instance WHERE data_source_instance = 'inserter'), (SELECT id FROM meta_data WHERE meta_type_id = (SELECT id FROM meta_type WHERE meta_type = 'subject') AND meta_data = 'Witches'));
INSERT INTO meta_type (meta_type) VALUES ('subject');
INSERT INTO meta_data (meta_type_id, meta_data) VALUES ((SELECT id FROM meta_type WHERE meta_type = 'subject'), 'England Fiction.');
INSERT INTO r_product_meta_data (product_id, data_source_instance_id, meta_data_id) VALUES ((SELECT id FROM product WHERE pid = '9780590353427'), (SELECT id FROM data_source_instance WHERE data_source_instance = 'inserter'), (SELECT id FROM meta_data WHERE meta_type_id = (SELECT id FROM meta_type WHERE meta_type = 'subject') AND meta_data = 'England Fiction.'));
INSERT INTO meta_type (meta_type) VALUES ('subject');
INSERT INTO meta_data (meta_type_id, meta_data) VALUES ((SELECT id FROM meta_type WHERE meta_type = 'subject'), 'Potter, Harry');
INSERT INTO r_product_meta_data (product_id, data_source_instance_id, meta_data_id) VALUES ((SELECT id FROM product WHERE pid = '9780590353427'), (SELECT id FROM data_source_instance WHERE data_source_instance = 'inserter'), (SELECT id FROM meta_data WHERE meta_type_id = (SELECT id FROM meta_type WHERE meta_type = 'subject') AND meta_data = 'Potter, Harry'));
INSERT INTO meta_type (meta_type) VALUES ('subject');
INSERT INTO meta_data (meta_type_id, meta_data) VALUES ((SELECT id FROM meta_type WHERE meta_type = 'subject'), 'Fantasy & Magic');
INSERT INTO r_product_meta_data (product_id, data_source_instance_id, meta_data_id) VALUES ((SELECT id FROM product WHERE pid = '9780590353427'), (SELECT id FROM data_source_instance WHERE data_source_instance = 'inserter'), (SELECT id FROM meta_data WHERE meta_type_id = (SELECT id FROM meta_type WHERE meta_type = 'subject') AND meta_data = 'Fantasy & Magic'));
INSERT INTO meta_type (meta_type) VALUES ('age Level');
INSERT INTO meta_data (meta_type_id, meta_data) VALUES ((SELECT id FROM meta_type WHERE meta_type = 'age Level'), '08-12');
INSERT INTO r_product_meta_data (product_id, data_source_instance_id, meta_data_id) VALUES ((SELECT id FROM product WHERE pid = '9780590353427'), (SELECT id FROM data_source_instance WHERE data_source_instance = 'inserter'), (SELECT id FROM meta_data WHERE meta_type_id = (SELECT id FROM meta_type WHERE meta_type = 'age Level') AND meta_data = '08-12'));
INSERT INTO meta_type (meta_type) VALUES ('illustrations');
INSERT INTO meta_data (meta_type_id, meta_data) VALUES ((SELECT id FROM meta_type WHERE meta_type = 'illustrations'), 'Y');
INSERT INTO r_product_meta_data (product_id, data_source_instance_id, meta_data_id) VALUES ((SELECT id FROM product WHERE pid = '9780590353427'), (SELECT id FROM data_source_instance WHERE data_source_instance = 'inserter'), (SELECT id FROM meta_data WHERE meta_type_id = (SELECT id FROM meta_type WHERE meta_type = 'illustrations') AND meta_data = 'Y'));
INSERT INTO meta_type (meta_type) VALUES ('grade Level');
INSERT INTO meta_data (meta_type_id, meta_data) VALUES ((SELECT id FROM meta_type WHERE meta_type = 'grade Level'), 'Elementary and junior high');
INSERT INTO r_product_meta_data (product_id, data_source_instance_id, meta_data_id) VALUES ((SELECT id FROM product WHERE pid = '9780590353427'), (SELECT id FROM data_source_instance WHERE data_source_instance = 'inserter'), (SELECT id FROM meta_data WHERE meta_type_id = (SELECT id FROM meta_type WHERE meta_type = 'grade Level') AND meta_data = 'Elementary and junior high'));
INSERT INTO meta_type (meta_type) VALUES ('illustrator');
INSERT INTO meta_data (meta_type_id, meta_data) VALUES ((SELECT id FROM meta_type WHERE meta_type = 'illustrator'), 'Grandpre, Mary');
INSERT INTO r_product_meta_data (product_id, data_source_instance_id, meta_data_id) VALUES ((SELECT id FROM product WHERE pid = '9780590353427'), (SELECT id FROM data_source_instance WHERE data_source_instance = 'inserter'), (SELECT id FROM meta_data WHERE meta_type_id = (SELECT id FROM meta_type WHERE meta_type = 'illustrator') AND meta_data = 'Grandpre, Mary'));
INSERT INTO title (subtitle, title, title_key) VALUES ('', 'Harry Potter and the Sorcerers Stone', 'harrypotterandthesorcerersstone');
INSERT INTO r_product_title (product_id, data_source_instance_id, title_id) VALUES ((SELECT id FROM product WHERE pid = '9780590353427'), (SELECT id FROM data_source_instance WHERE data_source_instance = 'inserter'), (SELECT id FROM title WHERE title_key = 'harrypotterandthesorcerersstone'));
INSERT INTO meta_type (meta_type) VALUES ('pages');
INSERT INTO meta_data (meta_type_id, meta_data) VALUES ((SELECT id FROM meta_type WHERE meta_type = 'pages'), '312');
INSERT INTO r_product_meta_data (product_id, data_source_instance_id, meta_data_id) VALUES ((SELECT id FROM product WHERE pid = '9780590353427'), (SELECT id FROM data_source_instance WHERE data_source_instance = 'inserter'), (SELECT id FROM meta_data WHERE meta_type_id = (SELECT id FROM meta_type WHERE meta_type = 'pages') AND meta_data = '312'));
