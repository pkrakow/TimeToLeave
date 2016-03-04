
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
// https://maps.googleapis.com/maps/api/distancematrix/json?origins=2043+Mezes+Avenue+Belmont+CA+94002&destinations=701+North+First+Street+Sunnyvale+CA+94089&mode=driving&language=en-US&units=imperial&key=AIzaSyAmFk8PdN-erkkgeg0PReI4DvWXUX0Mfmo
// Server Key: AIzaSyAmFk8PdN-erkkgeg0PReI4DvWXUX0Mfmo
// Browser Key: AIzaSyAZMCeSZBjBJn9nnfMpWJhF1uvmB6q_3gg

Parse.Cloud.define("httpRequestTest", function(request, response) {


    Parse.Cloud.httpRequest({
      //url: 'http://www.parse.com/'
      url: 'https://maps.googleapis.com/maps/api/distancematrix/json?origins=2043+Mezes+Avenue+Belmont+CA+94002&destinations=701+North+First+Street+Sunnyvale+CA+94089&mode=driving&language=en-US&units=imperial&key=AIzaSyAmFk8PdN-erkkgeg0PReI4DvWXUX0Mfmo'
    }).then(function(httpResponse) {
      // success with www.parse.com
      //console.log(httpResponse.text);
      //response.success('httpResponse basic test with www.parse.com successful')

      //success with maps.googleapis.com

      // Pull the duration using httpResponse.text and JSON.parse
      var jsonobj = JSON.parse(httpResponse.text);
      var dur = jsonobj.rows[0].elements[0].duration.text;

      // Pull the duration using httpResponse.data
      var jsonobj2 = httpResponse.data.rows[0].elements[0].duration.text;

      // Log the output
      console.log(jsonobj);
      console.log(dur);
      console.log(jsonobj2);
      response.success('httpResponse test with Google Maps API trip duration: ' + jsonobj2);
      
    },function(httpResponse) {
      // error
      console.error('Request failed with response code ' + httpResponse.status);
      response.error('httpResponse returned with an error');
    });



});
