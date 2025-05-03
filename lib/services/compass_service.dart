import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_compass/flutter_compass.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompassService {
  static final CompassService _instance = CompassService._internal();
  
  // Stream controllers
  StreamController<double>? _compassController;
  StreamSubscription? _compassSubscription;
  StreamSubscription? _accelerometerSubscription;
  StreamSubscription? _magnetometerSubscription;
  
  // Sensor data
  double? _heading;
  List<double> _accelerometerValues = [0, 0, 0];
  List<double> _magnetometerValues = [0, 0, 0];
  bool _hasMagnetometer = false;
  bool _hasAccelerometer = false;
  bool _useFusedSensors = false;
  
  // Calibration
  double _calibrationOffset = 0.0;
  bool _needsCalibration = true;
  static const String _calibrationKey = 'compass_calibration_offset';
  
  // Flags
  bool _isInitialized = false;
  
  factory CompassService() {
    return _instance;
  }
  
  CompassService._internal();
  
  Stream<double>? get compassStream => _compassController?.stream;
  bool get hasCompass => FlutterCompass.events != null;
  bool get needsCalibration => _needsCalibration;
  double get calibrationOffset => _calibrationOffset;
  double? get lastHeading => _heading;
  
  Future<void> init() async {
    if (_isInitialized) return;
    
    // Load saved calibration
    await _loadCalibration();
    
    // Check if compass is available
    if (FlutterCompass.events == null) {
      print('Compass not available');
      return;
    }
    
    // Initialize controller
    _compassController = StreamController<double>.broadcast();
    
    // Initialize sensor fusion if available
    _useFusedSensors = await _checkSensors();
    
    if (_useFusedSensors) {
      // Set up accelerometer
      _accelerometerSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
        _accelerometerValues = [event.x, event.y, event.z];
        _computeFusedOrientation();
      });
      
      // Set up magnetometer
      _magnetometerSubscription = magnetometerEvents.listen((MagnetometerEvent event) {
        _magnetometerValues = [event.x, event.y, event.z];
        _computeFusedOrientation();
      });
    } else {
      // Use basic compass if sensor fusion not available
      _compassSubscription = FlutterCompass.events!.listen((event) {
        if (event.heading != null) {
          _heading = _applyCalibration(event.heading!);
          _compassController?.add(_heading!);
        }
      });
    }
    
    _isInitialized = true;
  }
  
  // Check if the required sensors are available
  Future<bool> _checkSensors() async {
    try {
      // Check accelerometer
      await accelerometerEvents.first.timeout(const Duration(seconds: 1));
      _hasAccelerometer = true;
      
      // Check magnetometer
      await magnetometerEvents.first.timeout(const Duration(seconds: 1));
      _hasMagnetometer = true;
      
      return _hasAccelerometer && _hasMagnetometer;
    } catch (e) {
      print('Error checking sensors: $e');
      return false;
    }
  }
  
  // Compute orientation using sensor fusion
  void _computeFusedOrientation() {
    if (!_hasAccelerometer || !_hasMagnetometer) return;
    
    try {
      // Get the accelerometer and magnetometer readings
      final List<double> accel = _accelerometerValues;
      final List<double> magnet = _magnetometerValues;
      
      // Normalize the accelerometer and magnetometer readings
      final double normA = math.sqrt(accel[0] * accel[0] + accel[1] * accel[1] + accel[2] * accel[2]);
      if (normA == 0.0) return;
      
      final double normM = math.sqrt(magnet[0] * magnet[0] + magnet[1] * magnet[1] + magnet[2] * magnet[2]);
      if (normM == 0.0) return;
      
      final List<double> a = [accel[0] / normA, accel[1] / normA, accel[2] / normA];
      final List<double> m = [magnet[0] / normM, magnet[1] / normM, magnet[2] / normM];
      
      // Compute the east vector (east = magnetic_field × down)
      final List<double> east = [
        a[1] * m[2] - a[2] * m[1],
        a[2] * m[0] - a[0] * m[2],
        a[0] * m[1] - a[1] * m[0],
      ];
      
      final double eastNorm = math.sqrt(east[0] * east[0] + east[1] * east[1] + east[2] * east[2]);
      if (eastNorm == 0.0) return;
      
      final List<double> e = [east[0] / eastNorm, east[1] / eastNorm, east[2] / eastNorm];
      
      // Compute the north vector (north = down × east)
      final List<double> north = [
        a[1] * e[2] - a[2] * e[1],
        a[2] * e[0] - a[0] * e[2],
        a[0] * e[1] - a[1] * e[0],
      ];
      
      // Compute the heading
      final double heading = math.atan2(e[0], north[0]) * 180 / math.pi;
      final double adjustedHeading = (heading + 360) % 360;
      
      // Apply calibration and update the heading
      _heading = _applyCalibration(adjustedHeading);
      _compassController?.add(_heading!);
    } catch (e) {
      print('Error computing orientation: $e');
    }
  }
  
  // Apply calibration to the compass reading
  double _applyCalibration(double heading) {
    return (heading + _calibrationOffset + 360) % 360;
  }
  
  // Set calibration offset
  Future<void> setCalibration(double offset) async {
    _calibrationOffset = offset;
    _needsCalibration = false;
    
    // Save calibration
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_calibrationKey, offset);
  }
  
  // Load calibration from preferences
  Future<void> _loadCalibration() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _calibrationOffset = prefs.getDouble(_calibrationKey) ?? 0.0;
      _needsCalibration = prefs.getBool('needs_compass_calibration') ?? true;
    } catch (e) {
      print('Error loading compass calibration: $e');
    }
  }
  
  // Start calibration process
  void startCalibration() {
    _needsCalibration = true;
  }
  
  // Detect magnetic interference
  bool detectMagneticInterference() {
    if (!_hasMagnetometer) return false;
    
    // Check for abnormal readings in the magnetometer
    final double magnitude = math.sqrt(
      _magnetometerValues[0] * _magnetometerValues[0] +
      _magnetometerValues[1] * _magnetometerValues[1] +
      _magnetometerValues[2] * _magnetometerValues[2]
    );
    
    // Typical earth's magnetic field is around 25-65 μT (microTesla)
    // Very high or low values indicate interference
    return magnitude < 10 || magnitude > 100;
  }
  
  void dispose() {
    _compassSubscription?.cancel();
    _accelerometerSubscription?.cancel();
    _magnetometerSubscription?.cancel();
    _compassController?.close();
    _isInitialized = false;
  }
} 