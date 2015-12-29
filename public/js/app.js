(function() {
  var app = angular.module('testapp', [ ]);
  app.controller('TestController', function() {
    this.testprop = test;
  });

  var test = [
  {
    fieldA: 'A',
    fieldB: false
  },
  {
    fieldA: 'B',
    fieldB: true
  }]
})();