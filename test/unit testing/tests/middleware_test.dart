import 'package:dart_express/src/models/req_model.dart';
import 'package:dart_express/src/models/res_model.dart';
import 'package:dart_express/src/support/functions.dart';
import 'package:dart_express/src/support/route_tree.dart';
import 'package:dart_express/src/support/types.dart';
import 'package:test/test.dart';

void middlewareTest() {
  group("testing common middleares", () {
    test("should run middleware", () {
      final MiddlewareManager _middlewareManager = MiddlewareManager();
      String path = '/hi';
      _middlewareManager.addMiddleware(path, [
        (Req req, Res res, Function next) {
          print('Middleware 1');
          next();
        }
      ]);
      _middlewareManager.addMiddleware("/*", [
        (Req req, Res res, Function next) {
          print('Middleware 1');
          next();
        }
      ]);

      List<RouteTreeNode> nodes = _middlewareManager.getMiddleware('/hi');
      expect(nodes.length, 2);
      expect(nodes, isA<List<RouteTreeNode>>());
    });

    test("multiple middlewares", () {
      final MiddlewareManager _middlewareManager = MiddlewareManager();
      String path = '/hi/1';
      _middlewareManager.addMiddleware(path, [
        (Req req, Res res, Function next) {
          print('Middleware 1');
          next();
        }
      ]);
      _middlewareManager.addMiddleware("/*", [
        (Req req, Res res, Function next) {
          print('Middleware 1');
          next();
        }
      ]);

      _middlewareManager.addMiddleware("/hi/*", [
        (Req req, Res res, Function next) {
          print('Middleware 1');
          next();
        }
      ]);

      List<RouteTreeNode> nodes = _middlewareManager.getMiddleware('/hi/1');
      expect(nodes.length, 3);
      expect(nodes, isA<List<RouteTreeNode>>());
    });

    test("middleware path *", () {
      final MiddlewareManager _middlewareManager = MiddlewareManager();
      String path = '*';
      _middlewareManager.addMiddleware(path, [
        (Req req, Res res, Function next) {
          print('Middleware 1');
          next();
        }
      ]);

      expect(
          _middlewareManager.getMiddleware("/any"), isA<List<RouteTreeNode>>());

      expect(_middlewareManager.getMiddleware("/any").length, 1);
    });

    test("middleware with path '/*", () {
      final MiddlewareManager _middlewareManager = MiddlewareManager();
      String path = '/*';
      _middlewareManager.addMiddleware(path, [
        (Req req, Res res, Function next) {
          print('Middleware 1');
          next();
        }
      ]);

      _middlewareManager.addMiddleware('/user', [
        (Req req, Res res, Function next) {
          print('Middleware 1');
          next();
        }
      ]);

      _middlewareManager.addMiddleware('/any', [
        (Req req, Res res, Function next) {
          print('Middleware 1');
          next();
        }
      ]);

      expect(_middlewareManager.getMiddleware("/any/1"),
          isA<List<RouteTreeNode>>());

      expect(_middlewareManager.getMiddleware("/any/1").length, 1);
    });

    test("testing orders of middlewares", () {
      final MiddlewareManager _middlewareManager = MiddlewareManager();
      String path = '/hi/1';
      _middlewareManager.addMiddleware(path, [
        (Req req, Res res, Function next) {
          print('Middleware 1');
          next();
        }
      ]);
      _middlewareManager.addMiddleware("/*", [
        (Req req, Res res, Function next) {
          print('Middleware 1');
          next();
        }
      ]);

      _middlewareManager.addMiddleware("/hi/*", [
        (Req req, Res res, Function next) {
          print('Middleware 1');
          next();
        }
      ]);

      List<RouteTreeNode> nodes = _middlewareManager.getMiddleware('/hi/1');

      expect(nodes[2].order, 2);
      expect(nodes[1].order, 1);
    });
  });

  group("testing route middlewares", () {
    test("test 1", () {
      final MiddlewareManager _middlewareManager = MiddlewareManager();
      String addPath = '*';
      String requestPath = '/long/path/1/2/3/4';

      _middlewareManager.addMiddleware("/long/*", [
        (Req req, Res res, Function next) {
          print('Middleware 1');
          next();
        }
      ]);

      _middlewareManager.addMiddleware(addPath, [
        (Req req, Res res, Function next) {
          print('Middleware 2');
          next();
        }
      ]);

      _middlewareManager.addMiddleware("/long/path/3", [
        (Req req, Res res, Function next) {
          print('Middleware 2');
          next();
        }
      ]);

      List<RouteTreeNode> nodes = _middlewareManager.getMiddleware(requestPath);
      expect(nodes.length, 2);
      expect(nodes, isA<List<RouteTreeNode>>());
      expect(nodes[1].order, 1);
    });

    test("test 2", () {
      final MiddlewareManager _middlewareManager = MiddlewareManager();
      String addPath = '/*';
      String requestPath = '/';

      _middlewareManager.addMiddleware(addPath, [
        (Req req, Res res, Function next) {
          print('Middleware 2');
          next();
        }
      ]);

      List<RouteTreeNode> nodes = _middlewareManager.getMiddleware(requestPath);
      expect(nodes.length, 1);
      expect(nodes, isA<List<RouteTreeNode>>());
    });
  });
}

void main() {
  middlewareTest();
}
