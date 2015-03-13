// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require angular/angular
//= require angular-route/angular-route
//= require angular-rails-templates
//= require angular-resource/angular-resource
//= require_tree .


var doozerdisplay;
var controllers;
var session_cookie = $.cookie('session_id');

$(document).ready(function() {
  if($.cookie('session_id'))
    $('textarea#current_session_id').val($.cookie('session_id'))
});


doozerdisplay = angular.module('doozerdisplay', ['templates', 'ngRoute', 'ngResource', 'controllers']);

doozerdisplay.config([
  '$routeProvider', function($routeProvider) {
    return $routeProvider.when('/', {
      templateUrl: "display.html",
      controller: 'ItemsController'
    });
  }
]);



controllers = angular.module('controllers', []);

controllers.controller("ItemsController", [
  '$scope', '$routeParams', '$location', '$resource', function($scope, $routeParams, $location, $resource) {}, 


  $.ajax({
    url: '/api/items/index',
    type: 'GET',
    dataType: 'json',
    headers: {session_id: session_cookie},
    success: function(data) {
      var text;
      text = JSON.stringify(data);
      return $('body').append("Successful AJAX call: " + text);
    }
   })




]);







