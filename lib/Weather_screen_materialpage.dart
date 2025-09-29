import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:weather_app/additional_info_item.dart';
import 'package:weather_app/hourly_weather.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/secrets.dart';

String cityName = '';

class CustomSearchDelegate extends SearchDelegate {
  List<String> searchTerms = [
    "New York",
    "London",
    "Tokyo",
    "Paris",
    "Sydney",
    "Toronto",
    "Dubai",
    "Barcelona",
    "Mumbai",
  ];

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<String> matchQuery = [];
    for (var city in searchTerms) {
      if (city.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(city);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result),
          onTap: () {
            query = result;
            cityName = result; 
            close(context, result); 
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> matchQuery = [];
    for (var city in searchTerms) {
      if (city.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(city);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result),
          onTap: () {
            query = result;
            cityName = result; 
            showResults(context);
          },
        );
      },
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Future<Map<String, dynamic>> getCurrentWeather() async {
    final res = await http.get(
      Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openweatherAPIkey',
      ),
    );
    final data = jsonDecode(res.body);
    if (data['cod'] != '200') {
      throw ('An error occured');
    }

    return data;
  }

  void _showSearch() async {
    final selectedCity = await showSearch(
      context: context,
      delegate: CustomSearchDelegate(),
    );

    if (selectedCity != null && selectedCity is String) {
      setState(() {
        cityName = selectedCity;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Align(
            alignment: AlignmentDirectional.center,
            child: Text(
              'Weather App',
              style: TextStyle(
                fontSize: 24,
              ),
            ),
          ),
        ),
        titleTextStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {});
            },
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder(
        future: getCurrentWeather(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          final data = snapshot.data!;

          final currentWeatherData = data['list'][0];
          final currenttemp = currentWeatherData['main']['temp'];
          final currentSky = currentWeatherData['weather'][0]['main'];
          final currentHumidity = currentWeatherData['main']['humidity'];
          final currentPressure = currentWeatherData['main']['pressure'];
          final currentwindspeed = currentWeatherData['wind']['speed'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        color: Colors.white12,
                        child: IconButton(
                          alignment: Alignment.centerLeft,
                          onPressed: _showSearch,
                          icon: Icon(Icons.search),
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: ClipRRect(
                            borderRadius: BorderRadiusGeometry.circular(16),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Text(
                                      '$currenttemp K',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 16,
                                    ),
                                    Icon(
                                      currentSky == 'Clouds' ||
                                              currentSky == 'Rain'
                                          ? Icons.cloud
                                          : Icons.sunny,
                                      size: 64,
                                    ),
                                    SizedBox(
                                      height: 16,
                                    ),
                                    Text(
                                      currentSky,
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Hourly Forecast',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      SizedBox(
                        height: 140,
                        child: ListView.builder(
                          itemCount: 5,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            final hourlyForecast = data['list'][index + 1];
                            final hourlySky =
                                hourlyForecast['weather'][0]['main'];
                            final hourlyTemp = hourlyForecast['main']['temp'];
                            final hourlyTime =
                                DateTime.fromMillisecondsSinceEpoch(
                                  hourlyForecast['dt'] * 1000,
                                  isUtc: true,
                                );

                            return HourlyWeather(
                              time: '${hourlyTime.hour}:00',
                              value: hourlyTemp.toString(),
                              icon: hourlySky == 'Clouds' || hourlySky == 'Rain'
                                  ? Icons.cloud
                                  : Icons.sunny,
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Additional Information',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          AdditionalInfoItem(
                            icon: Icons.water_drop,
                            condition: 'Humidity',
                            value: currentHumidity.toString(),
                          ),
                          AdditionalInfoItem(
                            icon: Icons.air,
                            condition: 'Wind Speed',
                            value: currentwindspeed.toString(),
                          ),
                          AdditionalInfoItem(
                            icon: Icons.beach_access,
                            condition: 'Pressure',
                            value: currentPressure.toString(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
