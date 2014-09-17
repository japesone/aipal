;; Käyttäjän vaihtoon liittyvä koodi on riippuvuussyklien välttämiseksi omassa
;; nimiavaruudessaan, koska se käyttää arkistoja, jotka puolestaan riippuvat
;; nimiavaruudesta aipal.infra.kayttaja.
(ns aipal.infra.kayttaja.vaihto
  (:require [clojure.tools.logging :as log]
            [aipal.infra.kayttaja :refer [*kayttaja*]]
            [aipal.arkisto.kayttaja :as kayttaja-arkisto]
            [aipal.arkisto.kayttajaoikeus :as kayttajaoikeus-arkisto]))

(defn kayttajan-nimi [k]
  (str (:etunimi k) " " (:sukunimi k)))

(defn with-kayttaja* [uid impersonoitu-oid f]
  (log/debug "Yritetään autentikoida käyttäjä" uid)
  ;; Poolista ei saa yhteyttä ilman että *kayttaja* on sidottu, joten tehdään
  ;; käyttäjän tietojen haku käyttäjänä JARJESTELMA.
  (if-let [k (binding [*kayttaja* {:oid "JARJESTELMA"}]
               (kayttaja-arkisto/hae-voimassaoleva uid))]
    (let [voimassaoleva-oid (or impersonoitu-oid (:oid k))
          voimassaolevat-roolit (binding [*kayttaja* {:oid "JARJESTELMA"}]
                                  (kayttajaoikeus-arkisto/hae-roolit voimassaoleva-oid))
          ik (when impersonoitu-oid
               (binding [*kayttaja* {:oid "JARJESTELMA"}]
                 (kayttaja-arkisto/hae impersonoitu-oid)))]
      (binding [*kayttaja*
                (assoc k
                       :voimassaoleva-oid voimassaoleva-oid
                       :voimassaolevat-roolit voimassaolevat-roolit
                       :nimi (kayttajan-nimi k)
                       :impersonoidun-kayttajan-nimi (if ik (kayttajan-nimi ik) ""))]
        (log/info "Käyttäjä autentikoitu:" (pr-str *kayttaja*))
        (f)))
    (throw (IllegalStateException. (str "Ei voimassaolevaa käyttäjää " uid)))))

(defmacro with-kayttaja [uid impersonoitu-oid & body]
  `(with-kayttaja* ~uid ~impersonoitu-oid (fn [] ~@body)))
