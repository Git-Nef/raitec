class SessionManager {
  static final SessionManager _instance = SessionManager._internal();

  String? _numControl;

  factory SessionManager() {
    return _instance;
  }

  SessionManager._internal();

  void setNumControl(String clave) {
    _numControl = clave;
  }

  String? get numControl => _numControl;
}
