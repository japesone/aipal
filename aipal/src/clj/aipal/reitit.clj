(ns aipal.reitit
  (:require
          [clojure.pprint :refer [pprint]]
          [clojure.java.io :as io]
          [compojure.core :as c]
          [stencil.core :as s]
 
          aipal.rest-api.i18n
          [clj-cas-client.core :refer [cas]]
          aipal.rest-api.kysely
          aipal.rest-api.kyselykerta
          aipal.rest-api.raportti.kyselykerta
          aipal.rest_api.js-log
          aipal.rest_api.vastaajatunnus
            
          [aitu.infra.status :refer [status]]))

(def build-id (delay (if-let [resource (io/resource "build-id.txt")]
                       (.trim (slurp resource))
                       "dev")))

(defn reitit [asetukset]
  (c/routes
    (c/GET "/" [] (s/render-file "public/app/index.html" (merge {:base-url (-> asetukset :server :base-url)
                                                                 :build-id @build-id}
                                                                (when-let [cas-url (-> asetukset :cas-auth-server :url)]
                                                                  {:logout-url (str cas-url "/logout")}))))
    (c/GET "/status" [] (s/render-file "status" (assoc (status)
                                                  :asetukset (with-out-str
                                                               (-> asetukset
                                                                   (assoc-in [:db :password] "*****")
                                                                   pprint))
                                                  :build-id @build-id)))
    (c/context "/api/jslog" [] aipal.rest_api.js-log/reitit)
    
    (c/context "/api/i18n" [] aipal.rest-api.i18n/reitit)
    (c/context "/api/kyselykerta" [] aipal.rest-api.kyselykerta/reitit)
    (c/context "/api/raportti/kyselykerta" [] aipal.rest-api.raportti.kyselykerta/reitit)
    (c/context "/api/kysely" [] aipal.rest-api.kysely/reitit)
    (c/context "/api/vastaajatunnus" [] aipal.rest-api.vastaajatunnus/reitit)))