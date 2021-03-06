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

(ns aipal-e2e.arkisto.koulutustoimija
  (:require [korma.core :as sql]
            [aipal-e2e.arkisto.sql.korma :refer :all]))

(defn lisaa! [tiedot]
  (sql/insert koulutustoimija
    (sql/values tiedot)))

(defn poista! [y-tunnus]
  (sql/delete koulutustoimija
    (sql/where {:ytunnus y-tunnus})))

(defn lisaa-tutkinto! [koulutustoimijan-tutkinto]
  (sql/insert koulutustoimija_ja_tutkinto
    (sql/values koulutustoimijan-tutkinto)))

(defn poista-tutkinto! [y-tunnus tutkintotunnus]
  (sql/delete koulutustoimija_ja_tutkinto
    (sql/where {:koulutustoimija y-tunnus
                :tutkinto tutkintotunnus})))
