<?php

require_once __DIR__.'/../vendor/autoload.php';
use Symfony\Component\HttpFoundation\Request;
use Guzzle\Http\StaticClient;

$app = new Silex\Application(); 
$app['debug'] = true;
StaticClient::mount();

$app->get('/weather', function(Request $request) use($app) { 
    $lat = $request->get('lat');
    $long = $request->get('long');
    $latLong = $lat.','.$long;

    $yqlBaseUrl = "http://query.yahooapis.com/v1/public/yql";
    $query = 'select woeid from geo.placefinder where text="'.$latLong.'" and gflags="R"';

    $response = Guzzle::get($yqlBaseUrl, array(
      'query' => array('q' => $query, 'format' => 'json')
    ));

    $result = $response->json();
    $woeid = $result['query']['results']['Result']['woeid'];

    $weatherBaseUrl = 'http://weather.yahooapis.com/forecastrss';
    $response = Guzzle::get($weatherBaseUrl, array(
      'query' => array('w' => $woeid, 'u' => 'c') 
    ));
    
    $result = $response->getBody();
    $xml = $xml = simplexml_load_string($result);
    $xml->registerXPathNamespace('yweather', 'http://xml.weather.yahoo.com/ns/rss/1.0');

    $location = $xml->channel->xpath('yweather:location');
    $city = ((string) $location['0']['city']);

    $conditions = $xml->channel->item->xpath('yweather:condition');
    $temperature = (string) $conditions['0']['temp']['0'];

    $data = array(
      'location' => $city,
      'temperature' => $temperature
    );

    return json_encode($data);
}); 

$app->run();

