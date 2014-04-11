CREATE TABLE jatkokysymys
  (
    jatkokysymysid    INTEGER NOT NULL ,
    kylla_teksti_fi   VARCHAR (500) ,
    kylla_teksti_sv   VARCHAR (500) ,
    ei_teksti_fi      VARCHAR (500) ,
    ei_teksti_sv      VARCHAR (500) ,
    max_vastaus       INTEGER ,
    luotu_kayttaja    VARCHAR (80) NOT NULL ,
    muutettu_kayttaja VARCHAR (80) NOT NULL ,
    luotuaika TIMESTAMPTZ NOT NULL ,
    muutettuaika TIMESTAMPTZ NOT NULL
  ) ;
COMMENT ON COLUMN jatkokysymys.kylla_teksti_fi
IS
  'Kyllä vastauksen jatkokysymys (asteikko)' ;
  COMMENT ON COLUMN jatkokysymys.ei_teksti_fi
IS
  'Ei vastauksen jatkokysymys (vapaateksti)' ;
  COMMENT ON COLUMN jatkokysymys.max_vastaus
IS
  'Ei vastauksen maksimipituus' ;
  ALTER TABLE jatkokysymys ADD CONSTRAINT jatkokysymys_PK PRIMARY KEY ( jatkokysymysid ) ;

CREATE TABLE jatkovastaus
  (
    jatkovastausid INTEGER NOT NULL ,
    jatkokysymysid INTEGER NOT NULL ,
    kylla_asteikko INTEGER ,
    ei_vastausteksti TEXT
  ) ;
COMMENT ON COLUMN jatkovastaus.kylla_asteikko
IS
  'Jatkokysymyksen kyllä-vastaus' ;
  COMMENT ON COLUMN jatkovastaus.ei_vastausteksti
IS
  'Jatkokysymyksen ei-vastaus' ;
  ALTER TABLE jatkovastaus ADD CONSTRAINT jatkovastaus_PK PRIMARY KEY ( jatkovastausid ) ;

CREATE TABLE kayttaja
  (
    oid               VARCHAR (80) NOT NULL ,
    "uid"             VARCHAR (80) ,
    etunimi           VARCHAR (100) ,
    sukunimi          VARCHAR (100) ,
    rooli             VARCHAR (16) NOT NULL ,
    organisaatio      VARCHAR (16) ,
    voimassa          BOOLEAN DEFAULT false NOT NULL ,
    luotu_kayttaja    VARCHAR (80) NOT NULL ,
    muutettu_kayttaja VARCHAR (80) NOT NULL ,
    luotuaika TIMESTAMPTZ NOT NULL ,
    muutettuaika TIMESTAMPTZ NOT NULL
  ) ;
ALTER TABLE kayttaja ADD CONSTRAINT kayttaja_PK PRIMARY KEY ( oid ) ;

CREATE TABLE kayttajarooli
  (
    roolitunnus VARCHAR (16) NOT NULL ,
    kuvaus      VARCHAR (200) ,
    luotuaika TIMESTAMPTZ NOT NULL ,
    muutettuaika TIMESTAMPTZ NOT NULL
  ) ;
ALTER TABLE kayttajarooli ADD CONSTRAINT kayttajarooli_PK PRIMARY KEY ( roolitunnus ) ;

CREATE TABLE kysely
  (
    kyselyid        INTEGER NOT NULL ,
    voimassa_alkaen DATE ,
    lakkautettu     DATE ,
    nimi_fi         VARCHAR (200) ,
    nimi_sv         VARCHAR (200) ,
    selite_fi TEXT ,
    selite_sv TEXT ,
    luotu_kayttaja    VARCHAR (80) NOT NULL ,
    muutettu_kayttaja VARCHAR (80) NOT NULL ,
    luotuaika TIMESTAMPTZ NOT NULL ,
    muutettuaika TIMESTAMPTZ NOT NULL
  ) ;
COMMENT ON COLUMN kysely.voimassa_alkaen
IS
  'Kyselyn voimaantulopäivä' ;
  COMMENT ON COLUMN kysely.lakkautettu
IS
  'Kyselyn lakkautuspäivä' ;
  ALTER TABLE kysely ADD CONSTRAINT kysely_PK PRIMARY KEY ( kyselyid ) ;

CREATE TABLE kysely_kysymys
  (
    kyselyid          INTEGER NOT NULL ,
    kysymysid         INTEGER NOT NULL ,
    luotu_kayttaja    VARCHAR (80) NOT NULL ,
    muutettu_kayttaja VARCHAR (80) NOT NULL ,
    luotuaika TIMESTAMPTZ NOT NULL ,
    muutettuaika TIMESTAMPTZ NOT NULL
  ) ;
ALTER TABLE kysely_kysymys ADD CONSTRAINT kysely_kysymys_PK PRIMARY KEY ( kysymysid, kyselyid ) ;

CREATE TABLE kysely_kysymysryhma
  (
    kyselyid          INTEGER NOT NULL ,
    kysymysryhmaid    INTEGER NOT NULL ,
    kyselypohjaid     INTEGER ,
    jarjestys         INTEGER ,
    luotu_kayttaja    VARCHAR (80) NOT NULL ,
    muutettu_kayttaja VARCHAR (80) NOT NULL ,
    luotuaika TIMESTAMPTZ NOT NULL ,
    muutettuaika TIMESTAMPTZ NOT NULL
  ) ;
COMMENT ON COLUMN kysely_kysymysryhma.jarjestys
IS
  'kysymysryhmän järjestys kyselyn sisällä' ;
  ALTER TABLE kysely_kysymysryhma ADD CONSTRAINT kysely_kysymysryhma_PK PRIMARY KEY ( kyselyid, kysymysryhmaid ) ;

CREATE TABLE kyselykerta
  (
    kyselykertaid       INTEGER NOT NULL ,
    kyselyid            INTEGER NOT NULL ,
    nimi_fi             VARCHAR (200) NOT NULL ,
    nimi_sv             VARCHAR (200) ,
    voimassa_alkaen     DATE NOT NULL ,
    voimassaolo_paattyy DATE ,
    selite_fi TEXT ,
    selite_sv TEXT ,
    luotu_kayttaja    VARCHAR (80) NOT NULL ,
    muutettu_kayttaja VARCHAR (80) NOT NULL ,
    luotuaika TIMESTAMPTZ NOT NULL ,
    muutettuaika TIMESTAMPTZ NOT NULL
  ) ;
COMMENT ON COLUMN kyselykerta.voimassa_alkaen
IS
  'Kyselykerran voimaantulopäivä' ;
  COMMENT ON COLUMN kyselykerta.voimassaolo_paattyy
IS
  'Kyselykerran voimassaolon päättyminen' ;
  ALTER TABLE kyselykerta ADD CONSTRAINT kyselykerta_PK PRIMARY KEY ( kyselykertaid ) ;

CREATE TABLE kyselypohja
  (
    kyselypohjaid    INTEGER NOT NULL ,
    valtakunnallinen BOOLEAN NOT NULL ,
    voimassa_alkaen  DATE ,
    poistettu        DATE ,
    lakkautettu      DATE ,
    nimi_fi          VARCHAR (200) ,
    nimi_sv          VARCHAR (200) ,
    selite_fi TEXT ,
    selite_sv TEXT ,
    luotu_kayttaja    VARCHAR (80) NOT NULL ,
    muutettu_kayttaja VARCHAR (80) NOT NULL ,
    luotuaika TIMESTAMPTZ NOT NULL ,
    muutettuaika TIMESTAMPTZ NOT NULL
  ) ;
COMMENT ON COLUMN kyselypohja.valtakunnallinen
IS
  'Onko kyselypohja valtakunnallinen' ;
  COMMENT ON COLUMN kyselypohja.voimassa_alkaen
IS
  'Kyselypohjan voimaantuloaika' ;
  COMMENT ON COLUMN kyselypohja.poistettu
IS
  'Kyselypohjan poistopäivä' ;
  COMMENT ON COLUMN kyselypohja.lakkautettu
IS
  'Kyselypohjan lakkautuspäivä' ;
  ALTER TABLE kyselypohja ADD CONSTRAINT kyselypohja_PK PRIMARY KEY ( kyselypohjaid ) ;

CREATE TABLE kysymys
  (
    kysymysid         INTEGER NOT NULL ,
    pakollinen        BOOLEAN NOT NULL ,
    poistettava       BOOLEAN NOT NULL ,
    vastaustyyppi     VARCHAR (20) NOT NULL ,
    kysymysryhmaid    INTEGER NOT NULL ,
    kysymys_fi        VARCHAR (500) NOT NULL ,
    kysymys_sv        VARCHAR (500) ,
    jarjestys         INTEGER ,
    jatkokysymysid    INTEGER ,
    luotu_kayttaja    VARCHAR (80) NOT NULL ,
    muutettu_kayttaja VARCHAR (80) NOT NULL ,
    luotuaika TIMESTAMPTZ NOT NULL ,
    muutettuaika TIMESTAMPTZ NOT NULL
  ) ;
COMMENT ON COLUMN kysymys.pakollinen
IS
  'onko kysymykseen pakko vastata' ;
  COMMENT ON COLUMN kysymys.poistettava
IS
  'Voidaanko kysymys poistaa kyselystä' ;
  COMMENT ON COLUMN kysymys.vastaustyyppi
IS
  'Vastauksen tyyppi (kylla_ei_valinta, asteikko, monivalinta, vapaateksti)' ;
  COMMENT ON COLUMN kysymys.jarjestys
IS
  'Kysymyksen järjestys kysymysryhmän sisällä' ;
  ALTER TABLE kysymys ADD CONSTRAINT kysymys_PK PRIMARY KEY ( kysymysid ) ;
  ALTER TABLE kysymys ADD CONSTRAINT kysymys_ryhma_jarjestys_UN UNIQUE ( kysymysryhmaid , jarjestys ) DEFERRABLE INITIALLY DEFERRED ;

CREATE TABLE kysymysryhma
  (
    kysymysryhmaid   INTEGER NOT NULL ,
    voimassa_alkaen  DATE ,
    lakkautettu      DATE ,
    taustakysymykset BOOLEAN DEFAULT false NOT NULL ,
    valtakunnallinen BOOLEAN DEFAULT false NOT NULL ,
    nimi_fi          VARCHAR (200) NOT NULL ,
    nimi_sv          VARCHAR (200) ,
    selite_fi TEXT ,
    selite_sv TEXT ,
    luotu_kayttaja    VARCHAR (80) NOT NULL ,
    muutettu_kayttaja VARCHAR (80) NOT NULL ,
    luotuaika TIMESTAMPTZ NOT NULL ,
    muutettuaika TIMESTAMPTZ NOT NULL
  ) ;
COMMENT ON COLUMN kysymysryhma.voimassa_alkaen
IS
  'Kysymysryhmän voimaantuloaika' ;
  COMMENT ON COLUMN kysymysryhma.lakkautettu
IS
  'Kysymysryhmän lakkautusaika' ;
  COMMENT ON COLUMN kysymysryhma.taustakysymykset
IS
  'Kuuluuko kysymysryhmä taustakysymyksiin' ;
  COMMENT ON COLUMN kysymysryhma.valtakunnallinen
IS
  'Onko kysymysryhmä valtakunnallinen' ;
  ALTER TABLE kysymysryhma ADD CONSTRAINT kysymysryhmä_PK PRIMARY KEY ( kysymysryhmaid ) ;

CREATE TABLE kysymysryhma_kyselypohja
  (
    kysymysryhmaid    INTEGER NOT NULL ,
    kyselypohjaid     INTEGER NOT NULL ,
    jarjestys         INTEGER NOT NULL ,
    luotu_kayttaja    VARCHAR (80) NOT NULL ,
    muutettu_kayttaja VARCHAR (80) NOT NULL ,
    luotuaika TIMESTAMPTZ NOT NULL ,
    muutettuaika TIMESTAMPTZ NOT NULL
  ) ;
COMMENT ON COLUMN kysymysryhma_kyselypohja.jarjestys
IS
  'Kysymysryhmän järjestys kyselypohjan sisällä' ;
  ALTER TABLE kysymysryhma_kyselypohja ADD CONSTRAINT kysymysryhma_kyselypohja_PK PRIMARY KEY ( kysymysryhmaid, kyselypohjaid ) ;

CREATE TABLE monivalintavaihtoehto
  (
    monivalintavaihtoehtoid INTEGER NOT NULL ,
    kysymysid               INTEGER NOT NULL ,
    jarjestys               INTEGER DEFAULT 0 NOT NULL ,
    teksti_fi               VARCHAR (200) NOT NULL ,
    teksti_sv               VARCHAR (200) NOT NULL ,
    luotu_kayttaja          VARCHAR (80) NOT NULL ,
    muutettu_kayttaja       VARCHAR (80) NOT NULL ,
    luotuaika TIMESTAMPTZ NOT NULL ,
    muutettuaika TIMESTAMPTZ NOT NULL
  ) ;
COMMENT ON COLUMN monivalintavaihtoehto.jarjestys
IS
  'Monivalintavaihtoehdon järjestys kysymyksessä' ;
  ALTER TABLE monivalintavaihtoehto ADD CONSTRAINT kysymys_lisatieto_PK PRIMARY KEY ( monivalintavaihtoehtoid ) ;
  ALTER TABLE monivalintavaihtoehto ADD CONSTRAINT mv_kysymys_UN UNIQUE ( kysymysid , jarjestys ) ;

CREATE TABLE vastaus
  (
    vastausid       INTEGER NOT NULL ,
    kysymysid       INTEGER NOT NULL ,
    vastaustunnusid INTEGER NOT NULL ,
    vastausaika     DATE ,
    vapaateksti TEXT ,
    numerovalinta  INTEGER ,
    vaihtoehto     VARCHAR (10) ,
    jatkovastausid INTEGER
  ) ;
ALTER TABLE vastaus ADD CHECK ( vaihtoehto IN ('ei', 'kylla')) ;
COMMENT ON COLUMN vastaus.vastausaika
IS
  'Vastausaika' ;
  COMMENT ON COLUMN vastaus.vapaateksti
IS
  'vapaatekstivastaus' ;
  COMMENT ON COLUMN vastaus.numerovalinta
IS
  'vastausvalinta (asteikko tai monivalinta)' ;
  COMMENT ON COLUMN vastaus.vaihtoehto
IS
  'kyllä/ei vastausvaihtoehto' ;
  ALTER TABLE vastaus ADD CONSTRAINT vastaus_PK PRIMARY KEY ( vastausid ) ;

CREATE TABLE vastaustunnus
  (
    vastaustunnusid   INTEGER NOT NULL ,
    kyselykertaid     INTEGER NOT NULL ,
    vastannut         BOOLEAN DEFAULT false NOT NULL ,
    luotu_kayttaja    VARCHAR (80) NOT NULL ,
    muutettu_kayttaja VARCHAR (80) NOT NULL ,
    luotuaika TIMESTAMPTZ NOT NULL ,
    muutettuaika TIMESTAMPTZ NOT NULL
  ) ;
COMMENT ON COLUMN vastaustunnus.vastannut
IS
  'Onko vastaustunnuksella vastattu kyselyyn' ;
  ALTER TABLE vastaustunnus ADD CONSTRAINT vastaustunnus_PK PRIMARY KEY ( vastaustunnusid ) ;

ALTER TABLE jatkokysymys ADD CONSTRAINT jatkokysymys_kayttaja_FK FOREIGN KEY ( luotu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;

ALTER TABLE jatkokysymys ADD CONSTRAINT jatkokysymys_kayttaja_FKv1 FOREIGN KEY ( muutettu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;

ALTER TABLE jatkovastaus ADD CONSTRAINT jatkovastaus_jatkokysymys_FK FOREIGN KEY ( jatkokysymysid ) REFERENCES jatkokysymys ( jatkokysymysid ) NOT DEFERRABLE ;

ALTER TABLE kayttaja ADD CONSTRAINT kayttaja_kayttaja_FK FOREIGN KEY ( luotu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;

ALTER TABLE kayttaja ADD CONSTRAINT kayttaja_kayttaja_FKv1 FOREIGN KEY ( muutettu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;

ALTER TABLE kayttaja ADD CONSTRAINT kayttaja_kayttajarooli_FK FOREIGN KEY ( rooli ) REFERENCES kayttajarooli ( roolitunnus ) NOT DEFERRABLE ;

ALTER TABLE kysymysryhma_kyselypohja ADD CONSTRAINT kr_kp_kayttaja_FK FOREIGN KEY ( luotu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;

ALTER TABLE kysymysryhma_kyselypohja ADD CONSTRAINT kr_kp_kayttaja_FKv1 FOREIGN KEY ( muutettu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;

ALTER TABLE kysymysryhma_kyselypohja ADD CONSTRAINT kr_kp_kyselypohja_FK FOREIGN KEY ( kyselypohjaid ) REFERENCES kyselypohja ( kyselypohjaid ) NOT DEFERRABLE ;

ALTER TABLE kysymysryhma_kyselypohja ADD CONSTRAINT kr_kp_kysymysryhma_FK FOREIGN KEY ( kysymysryhmaid ) REFERENCES kysymysryhma ( kysymysryhmaid ) NOT DEFERRABLE ;

ALTER TABLE kysely ADD CONSTRAINT kysely_kayttaja_FK FOREIGN KEY ( luotu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;

ALTER TABLE kysely ADD CONSTRAINT kysely_kayttaja_FKv1 FOREIGN KEY ( muutettu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;

ALTER TABLE kysely_kysymysryhma ADD CONSTRAINT kysely_kr_kayttaja_FK FOREIGN KEY ( luotu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;

ALTER TABLE kysely_kysymysryhma ADD CONSTRAINT kysely_kr_kayttaja_FKv1 FOREIGN KEY ( muutettu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;

ALTER TABLE kysely_kysymysryhma ADD CONSTRAINT kysely_kr_kysely_FK FOREIGN KEY ( kyselyid ) REFERENCES kysely ( kyselyid ) NOT DEFERRABLE ;

ALTER TABLE kysely_kysymysryhma ADD CONSTRAINT kysely_kr_kyselypohja_FK FOREIGN KEY ( kyselypohjaid ) REFERENCES kyselypohja ( kyselypohjaid ) NOT DEFERRABLE ;

ALTER TABLE kysely_kysymysryhma ADD CONSTRAINT kysely_kr_kysymysryhma_FK FOREIGN KEY ( kysymysryhmaid ) REFERENCES kysymysryhma ( kysymysryhmaid ) NOT DEFERRABLE ;

ALTER TABLE kysely_kysymys ADD CONSTRAINT kysely_kysymys_kayttaja_FK FOREIGN KEY ( luotu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;

ALTER TABLE kysely_kysymys ADD CONSTRAINT kysely_kysymys_kayttaja_FKv1 FOREIGN KEY ( muutettu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;

ALTER TABLE kysely_kysymys ADD CONSTRAINT kysely_kysymys_kysely_FK FOREIGN KEY ( kyselyid ) REFERENCES kysely ( kyselyid ) NOT DEFERRABLE ;

ALTER TABLE kysely_kysymys ADD CONSTRAINT kysely_kysymys_kysymys_FK FOREIGN KEY ( kysymysid ) REFERENCES kysymys ( kysymysid ) NOT DEFERRABLE ;

ALTER TABLE kyselykerta ADD CONSTRAINT kyselykerta_kayttaja_FK FOREIGN KEY ( luotu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;

ALTER TABLE kyselykerta ADD CONSTRAINT kyselykerta_kayttaja_FKv1 FOREIGN KEY ( muutettu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;

ALTER TABLE kyselykerta ADD CONSTRAINT kyselykerta_kysely_FK FOREIGN KEY ( kyselyid ) REFERENCES kysely ( kyselyid ) NOT DEFERRABLE ;

ALTER TABLE kyselypohja ADD CONSTRAINT kyselypohja_kayttaja_FK FOREIGN KEY ( luotu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;

ALTER TABLE kyselypohja ADD CONSTRAINT kyselypohja_kayttaja_FKv1 FOREIGN KEY ( muutettu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;

ALTER TABLE kysymys ADD CONSTRAINT kysymys_jatkokysymys_FK FOREIGN KEY ( jatkokysymysid ) REFERENCES jatkokysymys ( jatkokysymysid ) NOT DEFERRABLE ;

ALTER TABLE kysymys ADD CONSTRAINT kysymys_kayttaja_FK FOREIGN KEY ( luotu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;

ALTER TABLE kysymys ADD CONSTRAINT kysymys_kayttaja_FKv1 FOREIGN KEY ( muutettu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;

ALTER TABLE kysymys ADD CONSTRAINT kysymys_kysymysryhmä_FK FOREIGN KEY ( kysymysryhmaid ) REFERENCES kysymysryhma ( kysymysryhmaid ) NOT DEFERRABLE ;

ALTER TABLE kysymysryhma ADD CONSTRAINT kysymysryhma_kayttaja_FK FOREIGN KEY ( luotu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;

ALTER TABLE kysymysryhma ADD CONSTRAINT kysymysryhma_kayttaja_FKv1 FOREIGN KEY ( muutettu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;

ALTER TABLE monivalintavaihtoehto ADD CONSTRAINT mv_kayttaja_FK FOREIGN KEY ( luotu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;

ALTER TABLE monivalintavaihtoehto ADD CONSTRAINT mv_kayttaja_FKv1 FOREIGN KEY ( muutettu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;

ALTER TABLE monivalintavaihtoehto ADD CONSTRAINT mv_kysymys_FK FOREIGN KEY ( kysymysid ) REFERENCES kysymys ( kysymysid ) NOT DEFERRABLE ;

ALTER TABLE vastaus ADD CONSTRAINT vastaus_jatkovastaus_FK FOREIGN KEY ( jatkovastausid ) REFERENCES jatkovastaus ( jatkovastausid ) NOT DEFERRABLE ;

ALTER TABLE vastaus ADD CONSTRAINT vastaus_kysymys_FK FOREIGN KEY ( kysymysid ) REFERENCES kysymys ( kysymysid ) NOT DEFERRABLE ;

ALTER TABLE vastaus ADD CONSTRAINT vastaus_vastaustunnus_FK FOREIGN KEY ( vastaustunnusid ) REFERENCES vastaustunnus ( vastaustunnusid ) NOT DEFERRABLE ;

ALTER TABLE vastaustunnus ADD CONSTRAINT vastaustunnus_kayttaja_FK FOREIGN KEY ( luotu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;

ALTER TABLE vastaustunnus ADD CONSTRAINT vastaustunnus_kayttaja_FKv1 FOREIGN KEY ( muutettu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;

ALTER TABLE vastaustunnus ADD CONSTRAINT vastaustunnus_kyselykerta_FK FOREIGN KEY ( kyselykertaid ) REFERENCES kyselykerta ( kyselykertaid ) NOT DEFERRABLE ;

insert into kayttajarooli(roolitunnus, kuvaus, muutettuaika, luotuaika)
values ('YLLAPITAJA', 'Ylläpitäjäroolilla on kaikki oikeudet', current_timestamp, current_timestamp);

insert into kayttaja(oid, uid, etunimi, sukunimi, voimassa, rooli, muutettuaika, luotuaika, luotu_kayttaja, muutettu_kayttaja)
values ('JARJESTELMA', 'JARJESTELMA', 'Järjestelmä', '', true, 'YLLAPITAJA', current_timestamp, current_timestamp, 'JARJESTELMA', 'JARJESTELMA');
insert into kayttaja(oid, uid, etunimi, sukunimi, voimassa, rooli, muutettuaika, luotuaika, luotu_kayttaja, muutettu_kayttaja)
values ('KONVERSIO', 'KONVERSIO', 'Järjestelmä', '', true, 'YLLAPITAJA', current_timestamp, current_timestamp, 'JARJESTELMA', 'JARJESTELMA');

CREATE OR REPLACE function update_stamp() returns trigger as $$ begin new.muutettuaika := now(); return new; end; $$ language plpgsql;
CREATE OR REPLACE function update_created() returns trigger as $$ begin new.luotuaika := now(); return new; end; $$ language plpgsql;
CREATE OR REPLACE function update_creator() returns trigger as $$ begin new.luotu_kayttaja := current_setting('aipal.kayttaja'); return new; end; $$ language plpgsql;
CREATE OR REPLACE function update_modifier() returns trigger as $$ begin new.muutettu_kayttaja := current_setting('aipal.kayttaja'); return new; end; $$ language plpgsql;

-- jatkokysymys
create trigger jatkokysymys_update before update on jatkokysymys for each row execute procedure update_stamp() ;
create trigger jatkokysymysl_insert before insert on jatkokysymys for each row execute procedure update_created() ;
create trigger jatkokysymysm_insert before insert on jatkokysymys for each row execute procedure update_stamp() ;
create trigger jatkokysymys_mu_update before update on jatkokysymys for each row execute procedure update_modifier() ;
create trigger jatkokysymys_cu_insert before insert on jatkokysymys for each row execute procedure update_creator() ;
create trigger jatkokysymys_mu_insert before insert on jatkokysymys for each row execute procedure update_modifier() ;

-- kayttajarooli
create trigger kayttajarooli_update before update on kayttajarooli for each row execute procedure update_stamp() ;
create trigger kayttajaroolil_insert before insert on kayttajarooli for each row execute procedure update_created() ;
create trigger kayttajaroolim_insert before insert on kayttajarooli for each row execute procedure update_stamp() ;

-- kayttaja
create trigger kayttaja_update before update on kayttaja for each row execute procedure update_stamp() ;
create trigger kayttajal_insert before insert on kayttaja for each row execute procedure update_created() ;
create trigger kayttajam_insert before insert on kayttaja for each row execute procedure update_stamp() ;
create trigger kayttaja_mu_update before update on kayttaja for each row execute procedure update_modifier() ;
create trigger kayttaja_cu_insert before insert on kayttaja for each row execute procedure update_creator() ;
create trigger kayttaja_mu_insert before insert on kayttaja for each row execute procedure update_modifier() ;

-- kysely
create trigger kysely_update before update on kysely for each row execute procedure update_stamp() ;
create trigger kyselyl_insert before insert on kysely for each row execute procedure update_created() ;
create trigger kyselym_insert before insert on kysely for each row execute procedure update_stamp() ;
create trigger kysely_mu_update before update on kysely for each row execute procedure update_modifier() ;
create trigger kysely_cu_insert before insert on kysely for each row execute procedure update_creator() ;
create trigger kysely_mu_insert before insert on kysely for each row execute procedure update_modifier() ;

-- kysely_kysymys
create trigger kysely_kysymys_update before update on kysely_kysymys for each row execute procedure update_stamp() ;
create trigger kysely_kysymysl_insert before insert on kysely_kysymys for each row execute procedure update_created() ;
create trigger kysely_kysymysm_insert before insert on kysely_kysymys for each row execute procedure update_stamp() ;
create trigger kysely_kysymys_mu_update before update on kysely_kysymys for each row execute procedure update_modifier() ;
create trigger kysely_kysymys_cu_insert before insert on kysely_kysymys for each row execute procedure update_creator() ;
create trigger kysely_kysymys_mu_insert before insert on kysely_kysymys for each row execute procedure update_modifier() ;

-- kysely_kysymysryhma
create trigger kysely_kysymysryhma_update before update on kysely_kysymysryhma for each row execute procedure update_stamp() ;
create trigger kysely_kysymysryhmal_insert before insert on kysely_kysymysryhma for each row execute procedure update_created() ;
create trigger kysely_kysymysryhmam_insert before insert on kysely_kysymysryhma for each row execute procedure update_stamp() ;
create trigger kysely_kysymysryhma_mu_update before update on kysely_kysymysryhma for each row execute procedure update_modifier() ;
create trigger kysely_kysymysryhma_cu_insert before insert on kysely_kysymysryhma for each row execute procedure update_creator() ;
create trigger kysely_kysymysryhma_mu_insert before insert on kysely_kysymysryhma for each row execute procedure update_modifier() ;

-- kyselykerta
create trigger kyselykerta_update before update on kyselykerta for each row execute procedure update_stamp() ;
create trigger kyselykertal_insert before insert on kyselykerta for each row execute procedure update_created() ;
create trigger kyselykertam_insert before insert on kyselykerta for each row execute procedure update_stamp() ;
create trigger kyselykerta_mu_update before update on kyselykerta for each row execute procedure update_modifier() ;
create trigger kyselykerta_cu_insert before insert on kyselykerta for each row execute procedure update_creator() ;
create trigger kyselykerta_mu_insert before insert on kyselykerta for each row execute procedure update_modifier() ;

-- kyselypohja
create trigger kyselypohja_update before update on kyselypohja for each row execute procedure update_stamp() ;
create trigger kyselypohjal_insert before insert on kyselypohja for each row execute procedure update_created() ;
create trigger kyselypohjam_insert before insert on kyselypohja for each row execute procedure update_stamp() ;
create trigger kyselypohja_mu_update before update on kyselypohja for each row execute procedure update_modifier() ;
create trigger kyselypohja_cu_insert before insert on kyselypohja for each row execute procedure update_creator() ;
create trigger kyselypohja_mu_insert before insert on kyselypohja for each row execute procedure update_modifier() ;

-- kysymys
create trigger kysymys_update before update on kysymys for each row execute procedure update_stamp() ;
create trigger kysymysl_insert before insert on kysymys for each row execute procedure update_created() ;
create trigger kysymysm_insert before insert on kysymys for each row execute procedure update_stamp() ;
create trigger kysymys_mu_update before update on kysymys for each row execute procedure update_modifier() ;
create trigger kysymys_cu_insert before insert on kysymys for each row execute procedure update_creator() ;
create trigger kysymys_mu_insert before insert on kysymys for each row execute procedure update_modifier() ;

-- kysymysryhma
create trigger kysymysryhma_update before update on kysymysryhma for each row execute procedure update_stamp() ;
create trigger kysymysryhmal_insert before insert on kysymysryhma for each row execute procedure update_created() ;
create trigger kysymysryhmam_insert before insert on kysymysryhma for each row execute procedure update_stamp() ;
create trigger kysymysryhma_mu_update before update on kysymysryhma for each row execute procedure update_modifier() ;
create trigger kysymysryhma_cu_insert before insert on kysymysryhma for each row execute procedure update_creator() ;
create trigger kysymysryhma_mu_insert before insert on kysymysryhma for each row execute procedure update_modifier() ;

-- kysymysryhma_kyselypohja
create trigger kysymysryhma_kyselypohja_update before update on kysymysryhma_kyselypohja for each row execute procedure update_stamp() ;
create trigger kysymysryhma_kyselypohjal_insert before insert on kysymysryhma_kyselypohja for each row execute procedure update_created() ;
create trigger kysymysryhma_kyselypohjam_insert before insert on kysymysryhma_kyselypohja for each row execute procedure update_stamp() ;
create trigger kysymysryhma_kyselypohja_mu_update before update on kysymysryhma_kyselypohja for each row execute procedure update_modifier() ;
create trigger kysymysryhma_kyselypohja_cu_insert before insert on kysymysryhma_kyselypohja for each row execute procedure update_creator() ;
create trigger kysymysryhma_kyselypohja_mu_insert before insert on kysymysryhma_kyselypohja for each row execute procedure update_modifier() ;

-- monivalintavaihtoehto
create trigger monivalintavaihtoehto_update before update on monivalintavaihtoehto for each row execute procedure update_stamp() ;
create trigger monivalintavaihtoehtol_insert before insert on monivalintavaihtoehto for each row execute procedure update_created() ;
create trigger monivalintavaihtoehtom_insert before insert on monivalintavaihtoehto for each row execute procedure update_stamp() ;
create trigger monivalintavaihtoehto_mu_update before update on monivalintavaihtoehto for each row execute procedure update_modifier() ;
create trigger monivalintavaihtoehto_cu_insert before insert on monivalintavaihtoehto for each row execute procedure update_creator() ;
create trigger monivalintavaihtoehto_mu_insert before insert on monivalintavaihtoehto for each row execute procedure update_modifier() ;

-- vastaustunnus
create trigger vastaustunnus_update before update on vastaustunnus for each row execute procedure update_stamp() ;
create trigger vastaustunnusl_insert before insert on vastaustunnus for each row execute procedure update_created() ;
create trigger vastaustunnusm_insert before insert on vastaustunnus for each row execute procedure update_stamp() ;
create trigger vastaustunnus_mu_update before update on vastaustunnus for each row execute procedure update_modifier() ;
create trigger vastaustunnus_cu_insert before insert on vastaustunnus for each row execute procedure update_creator() ;
create trigger vastaustunnus_mu_insert before insert on vastaustunnus for each row execute procedure update_modifier() ;
