// Copyright (c) 2014 The Finnish National Board of Education - Opetushallitus
//
// This program is free software:  Licensed under the EUPL, Version 1.1 or - as
// soon as they will be approved by the European Commission - subsequent versions
// of the EUPL (the "Licence");
//
// You may not use this work except in compliance with the Licence.
// You may obtain a copy of the Licence at: http://www.osor.eu/eupl/
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// European Union Public Licence for more details.

'use strict';

angular.module('yhteiset.direktiivit.kyselyjen-listaus', ['yhteiset.palvelut.i18n', 'yhteiset.palvelut.ilmoitus'])

  .directive('kyselyjenListaus', [function() {
    return {
      restrict: 'E',
      replace: true,
      scope : {
        kyselyt: '=',
        suodatus: '='
      },
      templateUrl : 'template/yhteiset/direktiivit/kyselyjen-listaus.html',
      controller: ['$scope', '$modal', '$location', 'Kysely', 'ilmoitus', 'i18n', function($scope, $modal, $location, Kysely, ilmoitus, i18n) {
        $scope.julkaiseKyselyModal = function(kysely) {
          var modalInstance = $modal.open({
            templateUrl: 'template/kysely/julkaise-kysely.html',
            controller: 'JulkaiseKyselyModalController',
            resolve: { kysely: function() { return kysely; } }
          });
          modalInstance.result.then(function (kyselyid) {
            Kysely.julkaise(kyselyid)
            .success(function() {
              $location.path('/kyselyt');
              ilmoitus.onnistuminen(i18n.hae('kysely.julkaisu_onnistui'));
            })
            .error(function() {
              ilmoitus.virhe(i18n.hae('kysely.julkaisu_epaonnistui'));
            });
          });
        };

        $scope.uusiKyselykerta = function (kysely) {
          $location.url('/kyselyt/' + kysely.kyselyid + '/kyselykerta/uusi');
        };
      }]
    };
  }])

  .controller('JulkaiseKyselyModalController', ['$modalInstance', '$scope', 'kysely', function ($modalInstance, $scope, kysely) {
    $scope.kysely = kysely;

    $scope.julkaise = function () {
      $modalInstance.close(kysely.kyselyid);
    };
    $scope.cancel = function () {
      $modalInstance.dismiss('cancel');
    };
  }]);
