;; Copyright (c) 2013 The Finnish National Board of Education - Opetushallitus
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

(ns aipal.integraatio.sql.korma
  (:require
    [korma.core :as sql]
    [oph.korma.korma  :refer [defentity]]))

(declare kysymys koulutustoimija oppilaitos toimipaikka koulutusala opintoala tutkinto)

(defentity kyselykerta
  (sql/pk :kyselykertaid))

(defentity kysely
  (sql/pk :kyselyid)
  (sql/has-many kyselykerta {:fk :kyselyid}))

(defentity kysymysryhma
  (sql/pk :kysymysryhmaid)
  (sql/has-many kysymys {:fk :kysymysryhmaid}))

(defentity kysely_kysymysryhma)

(defentity kysely_kysymys)

(defentity kysymys
  (sql/pk :kysymysid)
  (sql/belongs-to kysymysryhma {:fk :kysymysryhmaid}))

(defentity vastaajatunnus
  (sql/pk :vastaajatunnusid))

(defentity rahoitusmuoto
  (sql/pk :rahoitusmuotoid))

(defentity rooli-organisaatio
  (sql/table :rooli_organisaatio))

(defentity kayttaja
  (sql/pk :oid))

(defentity koulutusala
  (sql/pk :koulutusalatunnus)
  (sql/has-many opintoala {:fk :koulutusala}))

(defentity opintoala
  (sql/pk :opintoalatunnus)
  (sql/belongs-to koulutusala {:fk :koulutusala})
  (sql/has-many tutkinto {:fk :opintoala}))

(defentity tutkinto
  (sql/pk :tutkintotunnus)
  (sql/belongs-to opintoala {:fk :opintoala}))

(defentity rooli_organisaatio)

(defentity kysely_omistaja_view
  (sql/has-one kysely {:fk :kyselyid})
  (sql/has-one koulutustoimija {:fk :ytunnus})
  (sql/has-one kayttaja {:fk :kayttaja}))

(defentity koulutustoimija
  (sql/pk :ytunnus)
  (sql/has-many oppilaitos {:fk :koulutustoimija}))

(defentity oppilaitos
  (sql/pk :oppilaitoskoodi)
  (sql/belongs-to koulutustoimija {:fk :koulutustoimija})
  (sql/has-many toimipaikka {:fk :oppilaitos}))

(defentity toimipaikka
  (sql/pk :toimipaikkakoodi)
  (sql/belongs-to oppilaitos {:fk :oppilaitos}))

(defentity kayttajarooli)
