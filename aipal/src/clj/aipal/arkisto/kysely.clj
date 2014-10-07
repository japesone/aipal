;; Copyright (c) 2014 The Finnish National Board of Education - Opetushallitus
;;
;; This program is free software:  Licensed under the EUPL, Version 1.1 or - as
;; soon as they will be approved by the European Commission - subsequent versions
;; of the EUPL (the "Licence");
;;
;; You may not use this work except in compliance with the Licence.
;; You may obtain a copy of the Licence at: http://www.osor.eu/eupl/
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; European Union Public Licence for more details.

(ns aipal.arkisto.kysely
  (:require [korma.core :as sql]
            [aipal.arkisto.kyselykerta :as kyselykerta])
  (:use [aipal.integraatio.sql.korma]))

(defn hae-kyselyt
  "Hae kyselyt"
  ([]
    (hae-kyselyt nil))
  ([oid]
    (let [organisaatio-suodatus (fn [query]
                                  (if oid
                                    (-> query
                                      (sql/join kysely_omistaja_view (= :kysely_omistaja_view.kyselyid :kyselyid))
                                      (sql/where {:kysely_omistaja_view.kayttaja oid}))
                                    query))]
      (sql/select kysely
        (organisaatio-suodatus)
        (sql/fields :kysely.kyselyid :kysely.nimi_fi :kysely.nimi_sv :kysely.voimassa_alkupvm :kysely.voimassa_loppupvm)
        (sql/order :luotuaika :desc, :kyselyid :asc)))))

(defn ^:private yhdista-tietorakenteet [kyselyt kyselyid->kyselykerrat]
  (for [kysely kyselyt]
    (assoc kysely :kyselykerrat (kyselyid->kyselykerrat (:kyselyid kysely)))))

(defn hae-kaikki
  ([]
    (hae-kaikki nil))
  ([oid]
    (let [kyselyt (hae-kyselyt oid)
          kyselykerrat (kyselykerta/hae-kaikki)
          kyselyid->kyselykerrat (group-by :kyselyid kyselykerrat)]
      (yhdista-tietorakenteet kyselyt kyselyid->kyselykerrat))))

(defn hae
  "Hakee kyselyn tiedot pääavaimella"
  [kyselyid]
  (->
    (sql/select* kysely)
    (sql/fields :kysely.kyselyid :kysely.nimi_fi :kysely.nimi_sv :kysely.voimassa_alkupvm :kysely.voimassa_loppupvm :kysely.selite_fi :kysely.selite_sv)
    (sql/where (= :kyselyid kyselyid))

    sql/exec
    first))

(defn lisaa!
  "Lisää uuden kyselyn"
  [tiedot]
  (sql/insert kysely
    (sql/values tiedot)))

(defn muokkaa-kyselya [kyselydata]
  (->
    (sql/update* kysely)
    (sql/set-fields (select-keys kyselydata [:nimi_fi :nimi_sv :selite_fi :selite_sv :voimassa_alkupvm :voimassa_loppupvm]))
    (sql/where {:kyselyid (:kyselyid kyselydata)})
    (sql/update)))

; -- Kyselyn kautta, tieto poistetuista kysely_kysymys -taulusta
; SELECT kysymys.kysymysid,kysymys.poistettava,kysymys.kysymys_fi,kysely_kysymys.kysymysid IS NULL AS poistettu
; FROM kysely_kysymysryhma INNER JOIN kysymys ON kysely_kysymysryhma.kysymysryhmaid = kysymys.kysymysryhmaid LEFT JOIN kysely_kysymys ON kysymys.kysymysid = kysely_kysymys.kysymysid AND kysely_kysymys.kyselyid = 275
; WHERE kysely_kysymysryhma.kyselyid = 275
; AND kysely_kysymysryhma.kysymysryhmaid = 4;

(defn hae-kysymysryhmat [kyselyid]
  (->
    (sql/select* kysymysryhma)
    (sql/fields :kysymysryhmaid :nimi_fi :nimi_sv)
    (sql/join kysely_kysymysryhma (= :kysely_kysymysryhma.kysymysryhmaid :kysymysryhmaid))
    (sql/where {:kysely_kysymysryhma.kyselyid kyselyid})
    (sql/order :kysely_kysymysryhma.jarjestys)
    (sql/with kysymys
              (sql/fields :kysymysid :kysymys_fi :kysymys_sv :poistettava :pakollinen [(sql/raw "kysely_kysymys.kysymysid is null") :poistettu])
              (sql/join :left :kysely_kysymys (and (= :kysely_kysymys.kysymysid :kysymysid) (= :kysely_kysymys.kyselyid kyselyid)))
              (sql/order :kysymys.jarjestys))
    sql/exec))

(defn poistettava-kysymys? [kysymysid]
  (->
    (sql/select* kysymys)
    (sql/fields :poistettava)
    (sql/where {:kysymysid kysymysid})
    sql/exec
    first
    :poistettava))

(defn poista-kysymykset!
  [kyselyid]
  (sql/delete kysely_kysymys
    (sql/where {:kyselyid kyselyid})))

(defn poista-kysymysryhmat!
  [kyselyid]
  (sql/delete kysely_kysymysryhma
    (sql/where {:kyselyid kyselyid})))

(defn lisaa-kysymysryhma!
  [kyselyid ryhma]
  (sql/insert kysely_kysymysryhma
    (sql/values {:kyselyid kyselyid
                 :kysymysryhmaid (:kysymysryhmaid ryhma)
                 :kyselypohjaid (:kyselypohjaid ryhma)
                 :jarjestys (:jarjestys ryhma)})))

(defn lisaa-kysymys!
  [kyselyid kysymysid]
  (sql/insert kysely_kysymys
    (sql/values {:kyselyid kyselyid
                 :kysymysid kysymysid})))
