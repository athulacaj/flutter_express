import 'package:dart_express/src/models/req_model.dart';
import 'package:dart_express/src/models/res_model.dart';
import 'package:dart_express/src/support/functions.dart';
import 'package:dart_express/src/support/route_tree.dart';
import 'package:test/test.dart';

void middlewareTest() {
  group("testing common middleares", () {
    test("should run middleware", () {
      final MiddlewareManager middlewareManager = MiddlewareManager();
      String path = '/hi';
      middlewareManager.addMiddleware(path, [
        (Req req, Res res, Function next) {
          print('Middleware 1');
          next();
        }
      ]);
      middlewareManager.addMiddleware("/*", [
        (Req req, Res res, Function next) {
          print('Middleware 1');
          next();
        }
      ]);

      List<RouteTreeNode> nodes = middlewareManager.getMiddleware('/hi');
      expect(nodes.length, 2);
      expect(nodes, isA<List<RouteTreeNode>>());
    });

    test("multiple middlewares", () {
      final MiddlewareManager middlewareManager0 = MiddlewareManager();
      String path = '/hi/1';
      middlewareManager0.addMiddleware(path, [
        (Req req, Res res, Function next) {
          print('Middleware 1');
          next();
        }
      ]);
      middlewareManager0.addMiddleware("/*", [
        (Req req, Res res, Function next) {
          print('Middleware 1');
          next();
        }
      ]);

      middlewareManager0.addMiddleware("/hi/*", [
        (Req req, Res res, Function next) {
          print('Middleware 1');
          next();
        }
      ]);

      List<RouteTreeNode> nodes = middlewareManager0.getMiddleware('/hi/1');
      expect(nodes.length, 3);
      expect(nodes, isA<List<RouteTreeNode>>());
    });

    test("middleware path *", () {
      final MiddlewareManager middlewareManager1 = MiddlewareManager();
      String path = '*';
      middlewareManager1.addMiddleware(path, [
        (Req req, Res res, Function next) {
          print('Middleware 1');
          next();
        }
      ]);

      expect(
          middlewareManager1.getMiddleware("/any"), isA<List<RouteTreeNode>>());

      expect(middlewareManager1.getMiddleware("/any").length, 1);
    });

    test("middleware with path '/*", () {
      final MiddlewareManager middlewareManager2 = MiddlewareManager();
      String path = '/*';
      middlewareManager2.addMiddleware(path, [
        (Req req, Res res, Function next) {
          print('Middleware 1');
          next();
        }
      ]);

      middlewareManager2.addMiddleware('/user', [
        (Req req, Res res, Function next) {
          print('Middleware 1');
          next();
        }
      ]);

      middlewareManager2.addMiddleware('/any', [
        (Req req, Res res, Function next) {
          print('Middleware 1');
          next();
        }
      ]);

      expect(middlewareManager2.getMiddleware("/any/1"),
          isA<List<RouteTreeNode>>());

      expect(middlewareManager2.getMiddleware("/any/1").length, 1);
    });

    test("testing orders of middlewares", () {
      final MiddlewareManager middlewareManager3 = MiddlewareManager();
      String path = '/hi/1';
      middlewareManager3.addMiddleware(path, [
        (Req req, Res res, Function next) {
          print('Middleware 1');
          next();
        }
      ]);
      middlewareManager3.addMiddleware("/*", [
        (Req req, Res res, Function next) {
          print('Middleware 1');
          next();
        }
      ]);

      middlewareManager3.addMiddleware("/hi/*", [
        (Req req, Res res, Function next) {
          print('Middleware 1');
          next();
        }
      ]);

      List<RouteTreeNode> nodes = middlewareManager3.getMiddleware('/hi/1');

      expect(nodes[2].order, 2);
      expect(nodes[1].order, 1);
    });
  });

  group("testing route middlewares", () {
    test("test 1", () {
      final MiddlewareManager middlewareManager4 = MiddlewareManager();
      String addPath = '*';
      String requestPath = '/long/path/1/2/3/4';

      middlewareManager4.addMiddleware("/long/*", [
        (Req req, Res res, Function next) {
          print('Middleware 1');
          next();
        }
      ]);

      middlewareManager4.addMiddleware(addPath, [
        (Req req, Res res, Function next) {
          print('Middleware 2');
          next();
        }
      ]);

      middlewareManager4.addMiddleware("/long/path/3", [
        (Req req, Res res, Function next) {
          print('Middleware 2');
          next();
        }
      ]);

      List<RouteTreeNode> nodes = middlewareManager4.getMiddleware(requestPath);
      expect(nodes.length, 2);
      expect(nodes, isA<List<RouteTreeNode>>());
      expect(nodes[1].order, 1);
    });

    test("test 2", () {
      final MiddlewareManager middlewareManager4 = MiddlewareManager();
      String addPath = '/*';
      String requestPath = '/';

      middlewareManager4.addMiddleware(addPath, [
        (Req req, Res res, Function next) {
          print('Middleware 2');
          next();
        }
      ]);

      List<RouteTreeNode> nodes = middlewareManager4.getMiddleware(requestPath);
      expect(nodes.length, 1);
      expect(nodes, isA<List<RouteTreeNode>>());
    });
  });

  test("testing muiltiple adding middleware in same path", () {
    final MiddlewareManager middlewareManager4 = MiddlewareManager();
    String addPath = '/*';
    String requestPath = '/';

    middlewareManager4.addMiddleware(addPath, [
      (Req req, Res res, Function next) {
        res.send("middleware 1");
      },
      (Req req, Res res, Function next) {
        res.send("middleware 1");
      }
    ]);
    middlewareManager4.addMiddleware(addPath, [
      (Req req, Res res, Function next) {
        next();
      }
    ]);

    List<RouteTreeNode> nodes = middlewareManager4.getMiddleware(requestPath);
    expect(nodes.length, 1);
    expect(nodes[0].middlewares.length, 3);
    expect(nodes, isA<List<RouteTreeNode>>());
  });
}

void main() {
  middlewareTest();
}
