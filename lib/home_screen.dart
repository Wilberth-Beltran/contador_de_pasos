import 'package:flutter/material.dart';
import 'dart:async';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _stepCountValue = "sin_datos";
  String _km = "sin_datos";
  String _calories = "sin_datos";
  int _totalSteps = 0;
  int _previousTotalSteps = 0;
  int _dailySteps = 0;
  DateTime? _lastSavedDate;
  StreamSubscription<StepCount>? _subscription;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _loadSavedData();
  }

  Future<void> _requestPermissions() async {
    PermissionStatus activityRecognitionStatus =
        await Permission.activityRecognition.request();
    if (activityRecognitionStatus == PermissionStatus.granted) {
      setUpPedometer();
    } else {
      print("Permisos denegados.");
    }
  }

  Future<void> _loadSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int savedSteps = prefs.getInt('totalSteps') ?? 0;
    int previousTotalSteps = prefs.getInt('previousTotalSteps') ?? 0;
    int dailySteps = prefs.getInt('dailySteps') ?? 0;
    String? savedDateStr = prefs.getString('date');
    _lastSavedDate = savedDateStr != null ? DateTime.parse(savedDateStr) : null;

    setState(() {
      _totalSteps = savedSteps;
      _previousTotalSteps = previousTotalSteps;
      _dailySteps = dailySteps;
    });

    if (_lastSavedDate == null ||
        DateTime.now().difference(_lastSavedDate!).inDays >= 1) {
      _resetDailySteps();
    }
  }

  Future<void> _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('totalSteps', _totalSteps);
    await prefs.setInt('previousTotalSteps', _previousTotalSteps);
    await prefs.setInt('dailySteps', _dailySteps);
    await prefs.setString('date',
        _lastSavedDate?.toIso8601String() ?? DateTime.now().toIso8601String());
  }

  void _resetDailySteps() {
    setState(() {
      _lastSavedDate = DateTime.now();
      _previousTotalSteps = _totalSteps;
      _dailySteps = 0;
      _stepCountValue = "0";
    });
    _saveData();
  }

  void setUpPedometer() {
    _subscription = Pedometer.stepCountStream.listen(
      _onData,
      onError: _onError,
      onDone: _onDone,
      cancelOnError: true,
    );
  }

  void _onDone() {}

  void _onError(error) {
    print("Flutter error de podometro: $error");
  }

  void _onData(StepCount stepCountValue) {
    DateTime now = DateTime.now();
    if (_lastSavedDate == null || now.difference(_lastSavedDate!).inDays >= 1) {
      _resetDailySteps();
    }

    setState(() {
      int stepsSinceLastSave = stepCountValue.steps - _previousTotalSteps;
      _stepCountValue = "$stepsSinceLastSave";
      _totalSteps = stepCountValue.steps;
      _dailySteps = stepsSinceLastSave;
      _saveData();
    });

    double distance = _totalSteps.toDouble();
    setState(() {
      _km = (distance * 78 / 100000).toStringAsFixed(2);
      _calories = (distance * 0.04).toStringAsFixed(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Contador de pasos'),
          backgroundColor: Colors.pinkAccent,
        ),
        body: Container(
          color: Colors.white24,
          child: ListView(
            padding: EdgeInsets.all(5.0),
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 5.0),
                width: 250,
                height: 350,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Color(0xFFA9F5F2), Color(0xFF01DFD7)],
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(27.0)),
                ),
                child: CircularPercentIndicator(
                  radius: 150.0,
                  lineWidth: 13.0,
                  animation: true,
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Fecha: ${DateTime.now().toLocal().toString().split(' ')[0]}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                          color: Colors.purpleAccent,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            FontAwesomeIcons.walking,
                            size: 30.0,
                            color: Colors.white,
                          ),
                          SizedBox(width: 10),
                          Text(
                            '$_stepCountValue',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                              color: Colors.purpleAccent,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Total de pasos: $_dailySteps',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                          color: Colors.purpleAccent,
                        ),
                      ),
                    ],
                  ),
                  percent: _totalSteps != null ? (_totalSteps / 10000) : 0.0,
                  progressColor: Colors.purpleAccent,
                  backgroundColor: Colors.white,
                ),
              ),
              Container(
                padding: EdgeInsets.all(10.0),
                margin: EdgeInsets.only(top: 10.0),
                width: 250,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Color.fromARGB(255, 168, 187, 255),
                      Color.fromARGB(255, 150, 245, 242)
                    ],
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(27.0)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Kilómetros: $_km',
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.purpleAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Calorías: $_calories',
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.purpleAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
