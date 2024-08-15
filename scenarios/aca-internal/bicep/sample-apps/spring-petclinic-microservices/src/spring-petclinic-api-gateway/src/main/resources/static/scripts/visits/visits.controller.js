'use strict';

angular.module('visits')
    .controller('VisitsController', ['$http', '$state', '$stateParams', '$filter', function ($http, $state, $stateParams, $filter) {
        var self = this;
        var petId = $stateParams.petId || 0;
        var url = "api/visit/owners/" + ($stateParams.ownerId || 0) + "/pets/" + petId + "/visits";
        self.date = new Date();
        self.desc = "";

        $http.get(url).then(function (resp) {
            self.visits = resp.data;
        });

        self.submit = function () {
            var data = {
                date: $filter('date')(self.date, "yyyy-MM-dd"),
                description: self.desc
            };

            $http.post(url, data).then(function () {
                $state.go('ownerDetails', { ownerId: $stateParams.ownerId });
            });
        };
    }]);
