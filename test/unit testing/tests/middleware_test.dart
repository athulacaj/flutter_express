import 'package:dart_express/src/models/req_model.dart';
import 'package:dart_express/src/models/res_model.dart';
import 'package:dart_express/src/support/functions.dart';
import 'package:dart_express/src/support/route_tree.dart';
import 'package:test/test.dart';

void middlewareTest() {
  // group("middleware", () {
  //   test("should run middleware", () {
  //     final MiddlewareManager _middlewareManager = MiddlewareManager();
  //     String path = '/hi/1';
  //     _middlewareManager.addMiddleware(path, [
  //       (Req req, Res res, Function next) {
  //         print('Middleware 1');
  //         next();
  //       }
  //     ]);
  //     _middlewareManager.addMiddleware("/*", [
  //       (Req req, Res res, Function next) {
  //         print('Middleware 1');
  //         next();
  //       }
  //     ]);

  //     List<RouteTreeNode> nodes = _middlewareManager.getMiddleware('/hi');
  //     expect(nodes.length, 2);
  //   });
  // });
}

void main() {
  middlewareTest();
}
