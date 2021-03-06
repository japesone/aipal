CREATE OR REPLACE function update_stamp() returns trigger as $$ begin new.muutettuaika := now(); return new; end; $$ language plpgsql;
CREATE OR REPLACE function update_created() returns trigger as $$ begin new.luotuaika := now(); return new; end; $$ language plpgsql;
CREATE OR REPLACE function update_creator() returns trigger as $$ begin new.luotu_kayttaja := current_setting('aipal.kayttaja'); return new; end; $$ language plpgsql;
CREATE OR REPLACE function update_modifier() returns trigger as $$ begin new.muutettu_kayttaja := current_setting('aipal.kayttaja'); return new; end; $$ language plpgsql;

CREATE TABLE kayttaja
  (
    oid               VARCHAR (80) NOT NULL ,
    "uid"             VARCHAR (80) ,
    etunimi           VARCHAR (100) ,
    sukunimi          VARCHAR (100) ,
    voimassa          BOOLEAN DEFAULT false NOT NULL ,
    luotu_kayttaja    VARCHAR (80) NOT NULL ,
    muutettu_kayttaja VARCHAR (80) NOT NULL ,
    luotuaika TIMESTAMPTZ NOT NULL ,
    muutettuaika TIMESTAMPTZ NOT NULL
  ) ;
ALTER TABLE kayttaja ADD CONSTRAINT kayttaja_PK PRIMARY KEY ( oid ) ;
ALTER TABLE kayttaja ADD CONSTRAINT kayttaja_uid_unique UNIQUE ( "uid" );

CREATE TABLE kayttajarooli
  (
    roolitunnus VARCHAR (32) NOT NULL ,
    kuvaus      VARCHAR (200) ,
    luotuaika TIMESTAMPTZ NOT NULL ,
    muutettuaika TIMESTAMPTZ NOT NULL
  ) ;
ALTER TABLE kayttajarooli ADD CONSTRAINT kayttajarooli_PK PRIMARY KEY ( roolitunnus ) ;

CREATE TABLE jatkokysymys
  (
    jatkokysymysid    SERIAL NOT NULL ,
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
    jatkovastausid SERIAL NOT NULL ,
    jatkokysymysid INTEGER NOT NULL ,
    kylla_asteikko INTEGER ,
    ei_vastausteksti TEXT,
    muutettu_kayttaja varchar(80) NOT NULL references kayttaja(oid),
    luotu_kayttaja varchar(80) NOT NULL references kayttaja(oid),
    muutettuaika timestamptz NOT NULL,
    luotuaika timestamptz NOT NULL
  ) ;

COMMENT ON COLUMN jatkovastaus.kylla_asteikko
IS
  'Jatkokysymyksen kyllä-vastaus' ;
  COMMENT ON COLUMN jatkovastaus.ei_vastausteksti
IS
  'Jatkokysymyksen ei-vastaus' ;
  ALTER TABLE jatkovastaus ADD CONSTRAINT jatkovastaus_PK PRIMARY KEY ( jatkovastausid ) ;

CREATE TABLE kysely
  (
    kyselyid          SERIAL NOT NULL ,
    voimassa_alkupvm  DATE ,
    voimassa_loppupvm DATE ,
    nimi_fi           VARCHAR (200) ,
    nimi_sv           VARCHAR (200) ,
    selite_fi TEXT ,
    selite_sv TEXT ,
    koulutustoimija VARCHAR(10),
    oppilaitos VARCHAR(5),
    toimipaikka VARCHAR(7),
    luotu_kayttaja    VARCHAR (80) NOT NULL ,
    muutettu_kayttaja VARCHAR (80) NOT NULL ,
    luotuaika TIMESTAMPTZ NOT NULL ,
    muutettuaika TIMESTAMPTZ NOT NULL
  ) ;
COMMENT ON COLUMN kysely.voimassa_alkupvm
IS
  'Kyselyn voimaantulopäivä' ;
  COMMENT ON COLUMN kysely.voimassa_loppupvm
IS
  'Kyselyn voimassaolon päättymispäivä' ;
  ALTER TABLE kysely ADD CONSTRAINT kysely_PK PRIMARY KEY ( kyselyid ) ;
  ALTER TABLE kysely ADD CONSTRAINT alkupvm_ennen_loppupvm CHECK (voimassa_alkupvm IS NULL OR voimassa_loppupvm IS NULL OR voimassa_alkupvm <= voimassa_loppupvm);

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
  ALTER TABLE kysely_kysymysryhma ADD CONSTRAINT kysely_kr_jarjestys_UN UNIQUE ( kyselyid , jarjestys ) DEFERRABLE ;

CREATE TABLE kyselykerta
  (
    kyselykertaid     SERIAL NOT NULL ,
    kyselyid          INTEGER NOT NULL ,
    nimi_fi           VARCHAR (200) NOT NULL ,
    nimi_sv           VARCHAR (200) ,
    voimassa_alkupvm  DATE NOT NULL ,
    voimassa_loppupvm DATE ,
    luotu_kayttaja    VARCHAR (80) NOT NULL ,
    muutettu_kayttaja VARCHAR (80) NOT NULL ,
    luotuaika TIMESTAMPTZ NOT NULL ,
    muutettuaika TIMESTAMPTZ NOT NULL
  ) ;
COMMENT ON COLUMN kyselykerta.voimassa_alkupvm
IS
  'Kyselykerran voimaantulopäivä' ;
  COMMENT ON COLUMN kyselykerta.voimassa_loppupvm
IS
  'Kyselykerran voimassaolon päättyminen' ;
  ALTER TABLE kyselykerta ADD CONSTRAINT kyselykerta_PK PRIMARY KEY ( kyselykertaid ) ;
  ALTER TABLE kyselykerta ADD CONSTRAINT alkupvm_ennen_loppupvm CHECK (voimassa_alkupvm IS NULL OR voimassa_loppupvm IS NULL OR voimassa_alkupvm <= voimassa_loppupvm);

CREATE TABLE kyselypohja
  (
    kyselypohjaid     SERIAL NOT NULL ,
    valtakunnallinen  BOOLEAN NOT NULL ,
    voimassa_alkupvm  DATE ,
    poistettu         DATE ,
    voimassa_loppupvm DATE ,
    nimi_fi           VARCHAR (200) ,
    nimi_sv           VARCHAR (200) ,
    selite_fi TEXT ,
    selite_sv TEXT ,
    koulutustoimija   VARCHAR(10),
    oppilaitos        VARCHAR(5),
    toimipaikka       VARCHAR(7),
    luotu_kayttaja    VARCHAR (80) NOT NULL ,
    muutettu_kayttaja VARCHAR (80) NOT NULL ,
    luotuaika TIMESTAMPTZ NOT NULL ,
    muutettuaika TIMESTAMPTZ NOT NULL
  ) ;
COMMENT ON COLUMN kyselypohja.valtakunnallinen
IS
  'Onko kyselypohja valtakunnallinen' ;
  COMMENT ON COLUMN kyselypohja.voimassa_alkupvm
IS
  'Kyselypohjan voimaantuloaika' ;
  COMMENT ON COLUMN kyselypohja.poistettu
IS
  'Kyselypohjan poistopäivä' ;
  COMMENT ON COLUMN kyselypohja.voimassa_loppupvm
IS
  'Kyselypohjan lakkautuspäivä' ;
  ALTER TABLE kyselypohja ADD CONSTRAINT kyselypohja_PK PRIMARY KEY ( kyselypohjaid ) ;
  ALTER TABLE kyselypohja ADD CONSTRAINT alkupvm_ennen_loppupvm CHECK (voimassa_alkupvm IS NULL OR voimassa_loppupvm IS NULL OR voimassa_alkupvm <= voimassa_loppupvm);

CREATE TABLE kysymys
  (
    kysymysid         SERIAL NOT NULL ,
    pakollinen        BOOLEAN NOT NULL ,
    poistettava       BOOLEAN NOT NULL ,
    vastaustyyppi     VARCHAR (20) NOT NULL ,
    kysymysryhmaid    INTEGER NOT NULL ,
    kysymys_fi        VARCHAR (500) NOT NULL ,
    kysymys_sv        VARCHAR (500) ,
    jarjestys         INTEGER ,
    jatkokysymysid    INTEGER ,
    monivalinta_max   INTEGER ,
    max_vastaus       INTEGER ,
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
COMMENT ON COLUMN kysymys.monivalinta_max IS 'Monivalintakysymyksen vastausvalintojen maksimimäärä';
  ALTER TABLE kysymys ADD CONSTRAINT kysymys_PK PRIMARY KEY ( kysymysid ) ;
  ALTER TABLE kysymys ADD CONSTRAINT kysymys_ryhma_jarjestys_UN UNIQUE ( kysymysryhmaid , jarjestys ) DEFERRABLE ;

CREATE TABLE kysymysryhma
  (
    kysymysryhmaid    SERIAL NOT NULL ,
    voimassa_alkupvm  DATE ,
    voimassa_loppupvm DATE ,
    taustakysymykset  BOOLEAN DEFAULT false NOT NULL ,
    valtakunnallinen  BOOLEAN DEFAULT false NOT NULL ,
    nimi_fi           VARCHAR (200) NOT NULL ,
    nimi_sv           VARCHAR (200) ,
    selite_fi TEXT ,
    selite_sv TEXT ,
    koulutustoimija   VARCHAR(10),
    oppilaitos        VARCHAR(5),
    toimipaikka       VARCHAR(7),
    luotu_kayttaja    VARCHAR (80) NOT NULL ,
    muutettu_kayttaja VARCHAR (80) NOT NULL ,
    luotuaika TIMESTAMPTZ NOT NULL ,
    muutettuaika TIMESTAMPTZ NOT NULL
  ) ;
COMMENT ON COLUMN kysymysryhma.voimassa_alkupvm
IS
  'Kysymysryhmän voimaantuloaika' ;
  COMMENT ON COLUMN kysymysryhma.voimassa_loppupvm
IS
  'Kysymysryhmän lakkautusaika' ;
  COMMENT ON COLUMN kysymysryhma.taustakysymykset
IS
  'Kuuluuko kysymysryhmä taustakysymyksiin' ;
  COMMENT ON COLUMN kysymysryhma.valtakunnallinen
IS
  'Onko kysymysryhmä valtakunnallinen' ;
  ALTER TABLE kysymysryhma ADD CONSTRAINT kysymysryhmä_PK PRIMARY KEY ( kysymysryhmaid ) ;
  ALTER TABLE kysymysryhma ADD CONSTRAINT alkupvm_ennen_loppupvm CHECK (voimassa_alkupvm IS NULL OR voimassa_loppupvm IS NULL OR voimassa_alkupvm <= voimassa_loppupvm);

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
    monivalintavaihtoehtoid SERIAL NOT NULL ,
    kysymysid               INTEGER NOT NULL ,
    jarjestys               INTEGER DEFAULT 0 NOT NULL ,
    teksti_fi               VARCHAR (400) NOT NULL ,
    teksti_sv               VARCHAR (400) NOT NULL ,
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

CREATE TABLE rahoitusmuoto
  (
    rahoitusmuotoid   SERIAL NOT NULL ,
    rahoitusmuoto     VARCHAR(80) NOT NULL,
    luotu_kayttaja    VARCHAR (80) NOT NULL ,
    muutettu_kayttaja VARCHAR (80) NOT NULL ,
    luotuaika TIMESTAMPTZ NOT NULL ,
    muutettuaika TIMESTAMPTZ NOT NULL
  ) ;
ALTER TABLE rahoitusmuoto ADD CONSTRAINT rahoitusmuoto_PK PRIMARY KEY ( rahoitusmuotoid ) ;

CREATE TABLE vastaaja
  (
    vastaajaid        SERIAL NOT NULL ,
    kyselykertaid     INTEGER NOT NULL ,
    vastaajatunnusid  INTEGER NOT NULL ,
    vastannut         BOOLEAN DEFAULT false NOT NULL ,
    luotu_kayttaja    VARCHAR (80) NOT NULL ,
    muutettu_kayttaja VARCHAR (80) NOT NULL ,
    luotuaika TIMESTAMPTZ NOT NULL ,
    muutettuaika TIMESTAMPTZ NOT NULL
  ) ;
COMMENT ON COLUMN vastaaja.vastannut
IS
  'Vastaaja on vastannut koko kyselyyn' ;
  ALTER TABLE vastaaja ADD CONSTRAINT vastaaja_PK PRIMARY KEY ( vastaajaid ) ;

CREATE TABLE vastaajatunnus
  (
    vastaajatunnusid  SERIAL NOT NULL ,
    kyselykertaid     INTEGER NOT NULL ,
    rahoitusmuotoid   INTEGER ,
    tutkintotunnus    VARCHAR (6) ,
    tunnus            VARCHAR (30) NOT NULL ,
    vastaajien_lkm    INTEGER NOT NULL ,
    lukittu           BOOLEAN DEFAULT false NOT NULL ,
    voimassa_alkupvm  DATE ,
    voimassa_loppupvm DATE ,
    luotu_kayttaja    VARCHAR (80) NOT NULL ,
    muutettu_kayttaja VARCHAR (80) NOT NULL ,
    luotuaika TIMESTAMPTZ NOT NULL ,
    muutettuaika TIMESTAMPTZ NOT NULL
  ) ;
COMMENT ON COLUMN vastaajatunnus.tunnus
IS
  'Generoitu tunnus vastaajille. Määrittelee samalla URL:n jossa kyselyyn voi vastata.' ;
  COMMENT ON COLUMN vastaajatunnus.vastaajien_lkm
IS
  'Maksimi vastaajien lukumäärä' ;
  COMMENT ON COLUMN vastaajatunnus.lukittu
IS
  'Onko tunnukset lukittu suoraan tai tunnusten loppumisen takia' ;
  ALTER TABLE vastaajatunnus ADD CONSTRAINT vastaajatunnus_PK PRIMARY KEY ( vastaajatunnusid ) ;
  ALTER TABLE vastaajatunnus ADD CONSTRAINT vastaajatunnus__UN UNIQUE ( tunnus ) ;
  ALTER TABLE vastaajatunnus ADD CONSTRAINT alkupvm_ennen_loppupvm CHECK (voimassa_alkupvm IS NULL OR voimassa_loppupvm IS NULL OR voimassa_alkupvm <= voimassa_loppupvm);

CREATE TABLE vastaus
  (
    vastausid   SERIAL NOT NULL ,
    kysymysid   INTEGER NOT NULL ,
    vastaajaid  INTEGER NOT NULL ,
    vastausaika DATE ,
    vapaateksti TEXT ,
    numerovalinta     INTEGER ,
    vaihtoehto        VARCHAR (10) ,
    jatkovastausid    INTEGER ,
    luotu_kayttaja    VARCHAR (80) NOT NULL ,
    muutettu_kayttaja VARCHAR (80) NOT NULL ,
    luotuaika TIMESTAMPTZ NOT NULL ,
    muutettuaika TIMESTAMPTZ NOT NULL
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


CREATE TABLE koulutustoimija (
  ytunnus VARCHAR(10) PRIMARY KEY,
  nimi_fi VARCHAR(200) NOT NULL,
  nimi_sv VARCHAR(200),
  sahkoposti VARCHAR(100),
  puhelin VARCHAR(100),
  osoite VARCHAR(100),
  postinumero VARCHAR(5),
  postitoimipaikka VARCHAR(40),
  www_osoite VARCHAR(200),
  oid VARCHAR(40),
  luotuaika TIMESTAMPTZ NOT NULL,
  muutettuaika TIMESTAMPTZ NOT NULL,
  luotu_kayttaja VARCHAR(80) NOT NULL,
  muutettu_kayttaja VARCHAR(80) NOT NULL);

CREATE TABLE oppilaitos (
  oppilaitoskoodi VARCHAR(5) PRIMARY KEY,
  koulutustoimija VARCHAR(10) NOT NULL,
  nimi_fi VARCHAR(200) NOT NULL,
  nimi_sv VARCHAR(200),
  sahkoposti VARCHAR(100),
  puhelin VARCHAR(100),
  osoite VARCHAR(100),
  postinumero VARCHAR(5),
  postitoimipaikka VARCHAR(40),
  www_osoite VARCHAR(200),
  oid VARCHAR(40),
  luotuaika TIMESTAMPTZ NOT NULL,
  muutettuaika TIMESTAMPTZ NOT NULL,
  luotu_kayttaja VARCHAR(80) NOT NULL,
  muutettu_kayttaja VARCHAR(80) NOT NULL);

CREATE TABLE toimipaikka (
  toimipaikkakoodi VARCHAR(7) PRIMARY KEY,
  oppilaitos VARCHAR(5) NOT NULL,
  nimi_fi VARCHAR(200) NOT NULL,
  nimi_sv VARCHAR(200),
  sahkoposti VARCHAR(100),
  puhelin VARCHAR(100),
  osoite VARCHAR(100),
  postinumero VARCHAR(5),
  postitoimipaikka VARCHAR(40),
  www_osoite VARCHAR(200),
  oid VARCHAR(40),
  luotuaika TIMESTAMPTZ NOT NULL,
  muutettuaika TIMESTAMPTZ NOT NULL,
  luotu_kayttaja VARCHAR(80) NOT NULL,
  muutettu_kayttaja VARCHAR(80) NOT NULL);

CREATE TABLE koulutusala (
  koulutusalatunnus VARCHAR(1) PRIMARY KEY,
  nimi_fi VARCHAR(200) NOT NULL,
  nimi_sv VARCHAR(200),
  luotu_kayttaja    VARCHAR (80) NOT NULL ,
  muutettu_kayttaja VARCHAR (80) NOT NULL ,
  luotuaika TIMESTAMPTZ NOT NULL ,
  muutettuaika TIMESTAMPTZ NOT NULL
);

CREATE TABLE opintoala (
  opintoalatunnus VARCHAR(3) PRIMARY KEY,
  koulutusala VARCHAR(1) NOT NULL,
  nimi_fi VARCHAR(200) NOT NULL,
  nimi_sv VARCHAR(200),
  luotu_kayttaja    VARCHAR (80) NOT NULL ,
  muutettu_kayttaja VARCHAR (80) NOT NULL ,
  luotuaika TIMESTAMPTZ NOT NULL ,
  muutettuaika TIMESTAMPTZ NOT NULL
);

CREATE TABLE tutkinto
  (
    tutkintotunnus    VARCHAR (6) NOT NULL PRIMARY KEY,
    opintoala         VARCHAR (3) NOT NULL,
    nimi_fi           VARCHAR (200) NOT NULL,
    nimi_sv           VARCHAR (200) ,
    voimassa_alkupvm  DATE,
    voimassa_loppupvm DATE,
    luotu_kayttaja    VARCHAR (80) NOT NULL ,
    muutettu_kayttaja VARCHAR (80) NOT NULL ,
    luotuaika TIMESTAMPTZ NOT NULL ,
    muutettuaika TIMESTAMPTZ NOT NULL
  ) ;

ALTER TABLE jatkokysymys ADD CONSTRAINT jatkokysymys_kayttaja_FK FOREIGN KEY ( luotu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;

ALTER TABLE jatkokysymys ADD CONSTRAINT jatkokysymys_kayttaja_FKv1 FOREIGN KEY ( muutettu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;

ALTER TABLE jatkovastaus ADD CONSTRAINT jatkovastaus_jatkokysymys_FK FOREIGN KEY ( jatkokysymysid ) REFERENCES jatkokysymys ( jatkokysymysid ) NOT DEFERRABLE ;

ALTER TABLE kayttaja ADD CONSTRAINT kayttaja_kayttaja_FK FOREIGN KEY ( luotu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;

ALTER TABLE kayttaja ADD CONSTRAINT kayttaja_kayttaja_FKv1 FOREIGN KEY ( muutettu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;

ALTER TABLE kysymysryhma_kyselypohja ADD CONSTRAINT kr_kp_kayttaja_FK FOREIGN KEY ( luotu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;

ALTER TABLE kysymysryhma_kyselypohja ADD CONSTRAINT kr_kp_kayttaja_FKv1 FOREIGN KEY ( muutettu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;

ALTER TABLE kysymysryhma_kyselypohja ADD CONSTRAINT kr_kp_kyselypohja_FK FOREIGN KEY ( kyselypohjaid ) REFERENCES kyselypohja ( kyselypohjaid ) NOT DEFERRABLE ;

ALTER TABLE kysymysryhma_kyselypohja ADD CONSTRAINT kr_kp_kysymysryhma_FK FOREIGN KEY ( kysymysryhmaid ) REFERENCES kysymysryhma ( kysymysryhmaid ) NOT DEFERRABLE ;

ALTER TABLE kysely ADD CONSTRAINT kysely_kayttaja_FK FOREIGN KEY ( luotu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;

ALTER TABLE kysely ADD CONSTRAINT kysely_kayttaja_FKv1 FOREIGN KEY ( muutettu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;

ALTER TABLE kysely ADD CONSTRAINT kysely_koulutustoimija_FK FOREIGN KEY ( koulutustoimija ) REFERENCES koulutustoimija ( ytunnus ) NOT DEFERRABLE ;
ALTER TABLE kysely ADD CONSTRAINT kysely_oppilaitos_FK FOREIGN KEY ( oppilaitos ) REFERENCES oppilaitos ( oppilaitoskoodi ) NOT DEFERRABLE ;
ALTER TABLE kysely ADD CONSTRAINT kysely_toimipaikka_FK FOREIGN KEY ( toimipaikka ) REFERENCES toimipaikka ( toimipaikkakoodi ) NOT DEFERRABLE ;

ALTER TABLE kysely ADD CONSTRAINT kysely_organisaatio_check CHECK (koulutustoimija IS NOT NULL OR oppilaitos IS NOT NULL OR toimipaikka IS NOT NULL) NOT DEFERRABLE ;

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

ALTER TABLE kyselypohja ADD CONSTRAINT kyselypohja_organisaatio_check CHECK (koulutustoimija IS NOT NULL OR oppilaitos IS NOT NULL OR toimipaikka IS NOT NULL OR valtakunnallinen) NOT DEFERRABLE ;

ALTER TABLE kysymys ADD CONSTRAINT kysymys_jatkokysymys_FK FOREIGN KEY ( jatkokysymysid ) REFERENCES jatkokysymys ( jatkokysymysid ) NOT DEFERRABLE ;

ALTER TABLE kysymys ADD CONSTRAINT kysymys_kayttaja_FK FOREIGN KEY ( luotu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;

ALTER TABLE kysymys ADD CONSTRAINT kysymys_kayttaja_FKv1 FOREIGN KEY ( muutettu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;

ALTER TABLE kysymys ADD CONSTRAINT kysymys_kysymysryhmä_FK FOREIGN KEY ( kysymysryhmaid ) REFERENCES kysymysryhma ( kysymysryhmaid ) NOT DEFERRABLE ;

ALTER TABLE kysymysryhma ADD CONSTRAINT kysymysryhma_kayttaja_FK FOREIGN KEY ( luotu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;

ALTER TABLE kysymysryhma ADD CONSTRAINT kysymysryhma_kayttaja_FKv1 FOREIGN KEY ( muutettu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;

ALTER TABLE kysymysryhma ADD CONSTRAINT kysymysryhma_organisaatio_check CHECK (koulutustoimija IS NOT NULL OR oppilaitos IS NOT NULL OR toimipaikka IS NOT NULL OR valtakunnallinen) NOT DEFERRABLE ;

ALTER TABLE monivalintavaihtoehto ADD CONSTRAINT mv_kayttaja_FK FOREIGN KEY ( luotu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;

ALTER TABLE monivalintavaihtoehto ADD CONSTRAINT mv_kayttaja_FKv1 FOREIGN KEY ( muutettu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;

ALTER TABLE monivalintavaihtoehto ADD CONSTRAINT mv_kysymys_FK FOREIGN KEY ( kysymysid ) REFERENCES kysymys ( kysymysid ) NOT DEFERRABLE ;

ALTER TABLE rahoitusmuoto ADD CONSTRAINT rahoitusmuoto_kayttaja_FK FOREIGN KEY ( luotu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;

ALTER TABLE rahoitusmuoto ADD CONSTRAINT rahoitusmuoto_kayttaja_FKv1 FOREIGN KEY ( muutettu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;

ALTER TABLE vastaaja ADD CONSTRAINT vastaaja_kayttaja_FK FOREIGN KEY ( luotu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;

ALTER TABLE vastaaja ADD CONSTRAINT vastaaja_kayttaja_FKv1 FOREIGN KEY ( muutettu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;

ALTER TABLE vastaaja ADD CONSTRAINT vastaaja_kyselykerta_FK FOREIGN KEY ( kyselykertaid ) REFERENCES kyselykerta ( kyselykertaid ) NOT DEFERRABLE ;

ALTER TABLE vastaaja ADD CONSTRAINT vastaaja_vastaajatunnus_FK FOREIGN KEY ( vastaajatunnusid ) REFERENCES vastaajatunnus ( vastaajatunnusid ) NOT DEFERRABLE ;

ALTER TABLE vastaajatunnus ADD CONSTRAINT vastaajatunnus_kayttaja_FK FOREIGN KEY ( luotu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;
ALTER TABLE vastaajatunnus ADD CONSTRAINT vastaajatunnus_kayttaja_FKv1 FOREIGN KEY ( muutettu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;
ALTER TABLE vastaajatunnus ADD CONSTRAINT vastaajatunnus_kyselykerta_FK FOREIGN KEY ( kyselykertaid ) REFERENCES kyselykerta ( kyselykertaid ) NOT DEFERRABLE ;
ALTER TABLE vastaajatunnus ADD CONSTRAINT vastaajatunnus_rahmuoto_FK FOREIGN KEY ( rahoitusmuotoid ) REFERENCES rahoitusmuoto ( rahoitusmuotoid ) NOT DEFERRABLE ;
ALTER TABLE vastaajatunnus ADD CONSTRAINT vastaajatunnus_tutkinto_FK FOREIGN KEY ( tutkintotunnus ) REFERENCES tutkinto ( tutkintotunnus ) NOT DEFERRABLE ;

ALTER TABLE vastaus ADD CONSTRAINT vastaus_jatkovastaus_FK FOREIGN KEY ( jatkovastausid ) REFERENCES jatkovastaus ( jatkovastausid ) NOT DEFERRABLE ;

ALTER TABLE vastaus ADD CONSTRAINT vastaus_kayttaja_FK FOREIGN KEY ( luotu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;

ALTER TABLE vastaus ADD CONSTRAINT vastaus_kayttaja_FKv1 FOREIGN KEY ( muutettu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;

ALTER TABLE vastaus ADD CONSTRAINT vastaus_kysymys_FK FOREIGN KEY ( kysymysid ) REFERENCES kysymys ( kysymysid ) NOT DEFERRABLE ;

ALTER TABLE vastaus ADD CONSTRAINT vastaus_vastaaja_FK FOREIGN KEY ( vastaajaid ) REFERENCES vastaaja ( vastaajaid ) NOT DEFERRABLE ;

ALTER TABLE koulutustoimija ADD CONSTRAINT koulutustoimija_kayttaja_FK FOREIGN KEY ( luotu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;

ALTER TABLE koulutustoimija ADD CONSTRAINT koulutustoimija_kayttaja_FKv1 FOREIGN KEY ( muutettu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;

ALTER TABLE oppilaitos ADD CONSTRAINT oppilaitos_kayttaja_FK FOREIGN KEY ( luotu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;

ALTER TABLE oppilaitos ADD CONSTRAINT oppilaitos_kayttaja_FKv1 FOREIGN KEY ( muutettu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;

ALTER TABLE oppilaitos ADD CONSTRAINT oppilaitos_koulutustoimija_FK FOREIGN KEY ( koulutustoimija ) REFERENCES koulutustoimija ( ytunnus ) NOT DEFERRABLE ;

ALTER TABLE toimipaikka ADD CONSTRAINT toimipaikka_kayttaja_FK FOREIGN KEY ( luotu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;

ALTER TABLE toimipaikka ADD CONSTRAINT toimipaikka_kayttaja_FKv1 FOREIGN KEY ( muutettu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;

ALTER TABLE toimipaikka ADD CONSTRAINT toimipaikka_oppilaitos_FK FOREIGN KEY ( oppilaitos ) REFERENCES oppilaitos ( oppilaitoskoodi ) NOT DEFERRABLE ;

ALTER TABLE tutkinto ADD CONSTRAINT tutkinto_kayttaja_FK FOREIGN KEY ( luotu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;
ALTER TABLE tutkinto ADD CONSTRAINT tutkinto_kayttaja_FKv1 FOREIGN KEY ( muutettu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;
ALTER TABLE tutkinto ADD CONSTRAINT tutkinto_opintoala_FK FOREIGN KEY ( opintoala ) REFERENCES opintoala ( opintoalatunnus ) NOT DEFERRABLE ;

ALTER TABLE opintoala ADD CONSTRAINT opintoala_kayttaja_FK FOREIGN KEY ( luotu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;
ALTER TABLE opintoala ADD CONSTRAINT opintoala_kayttaja_FKv1 FOREIGN KEY ( muutettu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;
ALTER TABLE opintoala ADD CONSTRAINT opintoala_koulutusala_FK FOREIGN KEY ( koulutusala ) REFERENCES koulutusala ( koulutusalatunnus ) NOT DEFERRABLE ;

ALTER TABLE koulutusala ADD CONSTRAINT koulutusala_kayttaja_FK FOREIGN KEY ( luotu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;
ALTER TABLE koulutusala ADD CONSTRAINT koulutusala_kayttaja_FKv1 FOREIGN KEY ( muutettu_kayttaja ) REFERENCES kayttaja ( oid ) NOT DEFERRABLE ;

insert into kayttajarooli(roolitunnus, kuvaus, muutettuaika, luotuaika)
    values ('YLLAPITAJA', 'Ylläpitäjäroolilla on kaikki oikeudet', current_timestamp, current_timestamp);
insert into kayttajarooli(roolitunnus, kuvaus, muutettuaika, luotuaika)
    values ('OPH-KATSELIJA', 'Opetushallituksen katselija', current_timestamp, current_timestamp);
insert into kayttajarooli(roolitunnus, kuvaus, muutettuaika, luotuaika)
    values ('OPL-VASTUUKAYTTAJA', 'Oppilaitoksen vastuukayttaja', current_timestamp, current_timestamp);
insert into kayttajarooli(roolitunnus, kuvaus, muutettuaika, luotuaika)
    values ('OPL-KATSELIJA', 'Oppilaitoksen katselija', current_timestamp, current_timestamp);
insert into kayttajarooli(roolitunnus, kuvaus, muutettuaika, luotuaika)
    values ('OPL-KAYTTAJA', 'Oppilaitoksen normaali käyttäjä (opettaja)', current_timestamp, current_timestamp);
insert into kayttajarooli(roolitunnus, kuvaus, muutettuaika, luotuaika)
    values ('TTK-KATSELIJA', 'Toimikunnan raportointirooli', current_timestamp, current_timestamp);
insert into kayttajarooli(roolitunnus, kuvaus, muutettuaika, luotuaika)
    values ('KATSELIJA', 'Yleinen katselijarooli erityistarpeita varten', current_timestamp, current_timestamp);
insert into kayttajarooli(roolitunnus, kuvaus, muutettuaika, luotuaika)
    values ('OPL-PAAKAYTTAJA', 'Oppilaitoksen pääkäyttäjä', current_timestamp, current_timestamp);
insert into kayttajarooli(roolitunnus, kuvaus, muutettuaika, luotuaika)
    values ('AIPAL-VASTAAJA', 'Vastaajasovelluksen käyttäjän rooli', current_timestamp, current_timestamp);

insert into kayttaja(oid, uid, etunimi, sukunimi, voimassa, muutettuaika, luotuaika, luotu_kayttaja, muutettu_kayttaja)
  values ('JARJESTELMA', 'JARJESTELMA', 'Järjestelmä', '', true, current_timestamp, current_timestamp, 'JARJESTELMA', 'JARJESTELMA');
insert into kayttaja(oid, uid, etunimi, sukunimi, voimassa, muutettuaika, luotuaika, luotu_kayttaja, muutettu_kayttaja)
  values ('KONVERSIO', 'KONVERSIO', 'Järjestelmä', '', true, current_timestamp, current_timestamp, 'JARJESTELMA', 'JARJESTELMA');
insert into kayttaja(oid, uid, etunimi, sukunimi, voimassa, muutettuaika, luotuaika, luotu_kayttaja, muutettu_kayttaja)
  values ('INTEGRAATIO', 'INTEGRAATIO', 'Järjestelmä', '', true, current_timestamp, current_timestamp, 'JARJESTELMA', 'JARJESTELMA');
insert into kayttaja(oid, uid, etunimi, sukunimi, voimassa, muutettuaika, luotuaika, luotu_kayttaja, muutettu_kayttaja)
  values ('VASTAAJA', 'VASTAAJA', 'Aipal-vastaus', '', true, current_timestamp, current_timestamp, 'JARJESTELMA', 'JARJESTELMA');

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

-- rahoitusmuoto
create trigger rahoitusmuoto_update before update on rahoitusmuoto for each row execute procedure update_stamp() ;
create trigger rahoitusmuotol_insert before insert on rahoitusmuoto for each row execute procedure update_created() ;
create trigger rahoitusmuotom_insert before insert on rahoitusmuoto for each row execute procedure update_stamp() ;
create trigger rahoitusmuoto_mu_update before update on rahoitusmuoto for each row execute procedure update_modifier() ;
create trigger rahoitusmuoto_cu_insert before insert on rahoitusmuoto for each row execute procedure update_creator() ;
create trigger rahoitusmuoto_mu_insert before insert on rahoitusmuoto for each row execute procedure update_modifier() ;

-- vastaajatunnus
create trigger vastaajatunnus_update before update on vastaajatunnus for each row execute procedure update_stamp() ;
create trigger vastaajatunnusl_insert before insert on vastaajatunnus for each row execute procedure update_created() ;
create trigger vastaajatunnusm_insert before insert on vastaajatunnus for each row execute procedure update_stamp() ;
create trigger vastaajatunnus_mu_update before update on vastaajatunnus for each row execute procedure update_modifier() ;
create trigger vastaajatunnus_cu_insert before insert on vastaajatunnus for each row execute procedure update_creator() ;
create trigger vastaajatunnus_mu_insert before insert on vastaajatunnus for each row execute procedure update_modifier() ;

-- vastaaja
create trigger vastaaja_update before update on vastaaja for each row execute procedure update_stamp() ;
create trigger vastaajal_insert before insert on vastaaja for each row execute procedure update_created() ;
create trigger vastaajam_insert before insert on vastaaja for each row execute procedure update_stamp() ;
create trigger vastaaja_mu_update before update on vastaaja for each row execute procedure update_modifier() ;
create trigger vastaaja_cu_insert before insert on vastaaja for each row execute procedure update_creator() ;
create trigger vastaaja_mu_insert before insert on vastaaja for each row execute procedure update_modifier() ;

-- vastaus
create trigger vastaus_update before update on vastaus for each row execute procedure update_stamp() ;
create trigger vastausl_insert before insert on vastaus for each row execute procedure update_created() ;
create trigger vastausm_insert before insert on vastaus for each row execute procedure update_stamp() ;
create trigger vastaus_mu_update before update on vastaus for each row execute procedure update_modifier() ;
create trigger vastaus_cu_insert before insert on vastaus for each row execute procedure update_creator() ;
create trigger vastaus_mu_insert before insert on vastaus for each row execute procedure update_modifier() ;

-- koulutustoimija
create trigger koulutustoimija_update before update on koulutustoimija for each row execute procedure update_stamp() ;
create trigger koulutustoimijal_insert before insert on koulutustoimija for each row execute procedure update_created() ;
create trigger koulutustoimijam_insert before insert on koulutustoimija for each row execute procedure update_stamp() ;
create trigger koulutustoimija_mu_update before update on koulutustoimija for each row execute procedure update_modifier() ;
create trigger koulutustoimija_cu_insert before insert on koulutustoimija for each row execute procedure update_creator() ;
create trigger koulutustoimija_mu_insert before insert on koulutustoimija for each row execute procedure update_modifier() ;

-- oppilaitos
create trigger oppilaitos_update before update on oppilaitos for each row execute procedure update_stamp() ;
create trigger oppilaitosl_insert before insert on oppilaitos for each row execute procedure update_created() ;
create trigger oppilaitosm_insert before insert on oppilaitos for each row execute procedure update_stamp() ;
create trigger oppilaitos_mu_update before update on oppilaitos for each row execute procedure update_modifier() ;
create trigger oppilaitos_cu_insert before insert on oppilaitos for each row execute procedure update_creator() ;
create trigger oppilaitos_mu_insert before insert on oppilaitos for each row execute procedure update_modifier() ;

-- toimipaikka
create trigger toimipaikka_update before update on toimipaikka for each row execute procedure update_stamp() ;
create trigger toimipaikkal_insert before insert on toimipaikka for each row execute procedure update_created() ;
create trigger toimipaikkam_insert before insert on toimipaikka for each row execute procedure update_stamp() ;
create trigger toimipaikka_mu_update before update on toimipaikka for each row execute procedure update_modifier() ;
create trigger toimipaikka_cu_insert before insert on toimipaikka for each row execute procedure update_creator() ;
create trigger toimipaikka_mu_insert before insert on toimipaikka for each row execute procedure update_modifier() ;

-- tutkinto
create trigger tutkinto_update before update on tutkinto for each row execute procedure update_stamp() ;
create trigger tutkintol_insert before insert on tutkinto for each row execute procedure update_created() ;
create trigger tutkintom_insert before insert on tutkinto for each row execute procedure update_stamp() ;
create trigger tutkinto_mu_update before update on tutkinto for each row execute procedure update_modifier() ;
create trigger tutkinto_cu_insert before insert on tutkinto for each row execute procedure update_creator() ;
create trigger tutkinto_mu_insert before insert on tutkinto for each row execute procedure update_modifier() ;

-- opintoala
create trigger opintoala_update before update on opintoala for each row execute procedure update_stamp() ;
create trigger opintoalal_insert before insert on opintoala for each row execute procedure update_created() ;
create trigger opintoalam_insert before insert on opintoala for each row execute procedure update_stamp() ;
create trigger opintoala_mu_update before update on opintoala for each row execute procedure update_modifier() ;
create trigger opintoala_cu_insert before insert on opintoala for each row execute procedure update_creator() ;
create trigger opintoala_mu_insert before insert on opintoala for each row execute procedure update_modifier() ;

-- koulutusala
create trigger koulutusala_update before update on koulutusala for each row execute procedure update_stamp() ;
create trigger koulutusalal_insert before insert on koulutusala for each row execute procedure update_created() ;
create trigger koulutusalam_insert before insert on koulutusala for each row execute procedure update_stamp() ;
create trigger koulutusala_mu_update before update on koulutusala for each row execute procedure update_modifier() ;
create trigger koulutusala_cu_insert before insert on koulutusala for each row execute procedure update_creator() ;
create trigger koulutusala_mu_insert before insert on koulutusala for each row execute procedure update_modifier() ;

-- jatkovastaus
create trigger jatkovastaus_update before update on jatkovastaus for each row execute procedure update_stamp() ;
create trigger jatkovastausl_insert before insert on jatkovastaus for each row execute procedure update_created() ;
create trigger jatkovastausm_insert before insert on jatkovastaus for each row execute procedure update_stamp() ;
create trigger jatkovastaus_mu_update before update on jatkovastaus for each row execute procedure update_modifier() ;
create trigger jatkovastaus_mu_insert before insert on jatkovastaus for each row execute procedure update_modifier() ;
create trigger jatkovastaus_cu_insert before insert on jatkovastaus for each row execute procedure update_creator() ;

CREATE TABLE rooli_organisaatio
  (
    rooli_organisaatio_id serial PRIMARY KEY,
    organisaatio varchar(9) references koulutustoimija(ytunnus),
    rooli varchar(32) references kayttajarooli(roolitunnus) NOT NULL,
    kayttaja varchar(80) references kayttaja(oid) NOT NULL,
    voimassa BOOLEAN DEFAULT false NOT NULL,
    muutettu_kayttaja varchar(80) NOT NULL references kayttaja(oid),
    luotu_kayttaja varchar(80) NOT NULL references kayttaja(oid),
    muutettuaika timestamptz NOT NULL,
    luotuaika timestamptz NOT NULL
    );
ALTER TABLE rooli_organisaatio ADD CONSTRAINT rooli_organisaatio_null
  CHECK (rooli IN ('YLLAPITAJA', 'OPH-KATSELIJA', 'TTK-KATSELIJA', 'KATSELIJA', 'AIPAL-VASTAAJA') OR organisaatio is not null);

INSERT INTO rooli_organisaatio (kayttaja, rooli, voimassa, muutettuaika, luotuaika, luotu_kayttaja, muutettu_kayttaja) values
('JARJESTELMA', 'YLLAPITAJA', 'true', current_timestamp, current_timestamp, 'JARJESTELMA', 'JARJESTELMA'),
('KONVERSIO', 'YLLAPITAJA', 'true', current_timestamp, current_timestamp, 'JARJESTELMA', 'JARJESTELMA'),
('INTEGRAATIO', 'YLLAPITAJA', 'true', current_timestamp, current_timestamp, 'JARJESTELMA', 'JARJESTELMA'),
('VASTAAJA', 'AIPAL-VASTAAJA', 'true', current_timestamp, current_timestamp, 'JARJESTELMA', 'JARJESTELMA');

create trigger rooli_organisaatio_update before update on rooli_organisaatio for each row execute procedure update_stamp() ;
create trigger rooli_organisaatiol_insert before insert on rooli_organisaatio for each row execute procedure update_created() ;
create trigger rooli_organisaatiom_insert before insert on rooli_organisaatio for each row execute procedure update_stamp() ;
create trigger rooli_organisaatio_mu_update before update on rooli_organisaatio for each row execute procedure update_modifier() ;
create trigger rooli_organisaatio_mu_insert before insert on rooli_organisaatio for each row execute procedure update_modifier() ;
create trigger rooli_organisaatio_cu_insert before insert on rooli_organisaatio for each row execute procedure update_creator() ;

COMMENT ON TABLE rooli_organisaatio IS 'Kytkee käyttäjän, käyttöoikeusroolin ja tietyn organisaation yhteen.';
COMMENT ON TABLE kayttajarooli IS 'AIPAL-käyttäjäroolit. Organisaatiokohtaiset oikeudet erillisen liitostaulun kautta.';


create or replace view kysely_omistaja_view as

select
 k.ytunnus, k.nimi_fi, k.oid, ro.organisaatio, ro.rooli, ro.kayttaja, ro.voimassa, ky.kyselyid, ky.oppilaitos, ky.toimipaikka
 from koulutustoimija k
  inner join rooli_organisaatio ro on ro.organisaatio = k.ytunnus
  inner join oppilaitos o on o.koulutustoimija = k.ytunnus
  inner join toimipaikka t on t.oppilaitos = o.oppilaitoskoodi
  inner join kysely ky on ky.toimipaikka = t.toimipaikkakoodi

union all
  select
 k.ytunnus, k.nimi_fi, k.oid, ro.organisaatio, ro.rooli, ro.kayttaja, ro.voimassa, ky.kyselyid, ky.oppilaitos, ky.toimipaikka
 from koulutustoimija k
  inner join rooli_organisaatio ro on ro.organisaatio = k.ytunnus
  inner join oppilaitos o on o.koulutustoimija = k.ytunnus
  inner join kysely ky on ky.oppilaitos = o.oppilaitoskoodi

 union all

  select
 k.ytunnus, k.nimi_fi, k.oid, ro.organisaatio, ro.rooli, ro.kayttaja, ro.voimassa, ky.kyselyid, ky.oppilaitos, ky.toimipaikka
 from koulutustoimija k
  inner join rooli_organisaatio ro on ro.organisaatio = k.ytunnus
  inner join kysely ky on ky.koulutustoimija = k.ytunnus;

COMMENT ON VIEW kysely_omistaja_view is 'Kyselyiden omistaja-organisaatio ja käyttäjät. Näkymästä voi helposti tarkastaa käyttäjien käyttöoikeudet kyselyihin.';

