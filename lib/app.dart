import 'package:dox_core/dox_core.dart';
import 'package:dox_core/server/dox_server.dart';

class Dox {
  /// setup singleton
  static final Dox _singleton = Dox._internal();
  factory Dox() => _singleton;
  Dox._internal();

  late AppConfig _config;

  /// get dox http server
  DoxServer get server => DoxServer();

  /// get app config
  AppConfig get config => _config;

  /// initialize dox application
  /// - load env
  /// - start http server
  /// - register routes
  initialize(AppConfig c) {
    Env.load();
    Dox dox = Dox();
    dox._config = c;
    dox._startHttpServer();
    dox._registerFormRequests();
    dox._registerRoute();
  }

  _registerFormRequests() {
    _config.formRequests.forEach((key, value) {
      Global.ioc.registerByName(key.toString(), value);
    });
  }

  _registerRoute() {
    List<Router> routers = _config.routers;
    for (Router router in routers) {
      Route.prefix(router.prefix);
      Route.use([..._config.globalMiddleware, ...router.middleware]);
      router.register();
    }
  }

  _startHttpServer() {
    DoxServer server = DoxServer();
    server.setResponseHandler(_config.responseHandler);
    server.listen(_config.serverPort);
  }
}
