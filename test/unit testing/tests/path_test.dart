import 'package:flutter_express/flutter_express.dart';
import 'package:flutter_express/src/support/functions.dart';
import 'package:flutter_express/src/support/route_tree.dart';
import 'package:flutter_express/src/constants/route_methods.dart';
import 'package:test/test.dart';

void pathTest() {
  group('path different test', () {
    test('testing long path', () {
      RequestManager requestManager = RequestManager();
      String path = '/long/path/1/2/3';
      // expect(requestManager.getRequest(path, Method.get), isNull);
      requestManager.addRequest(path, Method.get, () => {});
      expect(requestManager.getRequest(path, Method.get), isA<RouteTreeNode>());
    });

    test("if / in the end", () {
      RequestManager requestManager = RequestManager();
      String path = '/path/';
      requestManager.addRequest(path, Method.get, () => {});
      expect(requestManager.getRequest(path, Method.get), isA<RouteTreeNode>());
    });

    test("* - path", () {
      RequestManager requestManager = RequestManager();
      String addPath = '*';
      String requestPath = '/long/path/1/2/3/4';
      requestManager.addRequest(addPath, Method.get, () => {});
      expect(requestManager.getRequest(requestPath, Method.get),
          isA<RouteTreeNode>());
    });
    test('path with *', () {
      RequestManager requestManager = RequestManager();
      String addPath = '/long/path/1/2/3/*';
      String requestPath = '/long/path/1/2/3/4';
      requestManager.addRequest(addPath, Method.get, () => {});
      expect(requestManager.getRequest(requestPath, Method.get),
          isA<RouteTreeNode>());
    });
    test("params of * path", () {
      RequestManager requestManager = RequestManager();
      String addPath = '/long/path/1/2/3/*';
      String requestPath = '/long/path/1/2/3/4';
      requestManager.addRequest(addPath, Method.get, () => {});
      expect(requestManager.getRequest(requestPath, Method.get),
          isA<RouteTreeNode>());
      expect(requestManager.getRequest(requestPath, Method.get)?.params,
          equals({'0': '4'}));

      addPath = '/long/path/1/2/3/*';
      requestPath = '/long/path/1/2/3/4/5';
      requestManager.addRequest(addPath, Method.get, () => {});
      expect(requestManager.getRequest(requestPath, Method.get),
          isA<RouteTreeNode>());
      expect(requestManager.getRequest(requestPath, Method.get)?.params,
          equals({'0': '4/5'}));
    });

    test('multiple * path', () {
      RequestManager requestManager = RequestManager();
      String addPath = '/long/path/1/2/3/*/*';
      String requestPath = '/long/path/1/2/3/4/5';
      requestManager.addRequest(addPath, Method.get, () => {});
      expect(requestManager.getRequest(requestPath, Method.get),
          isA<RouteTreeNode>());
      expect(requestManager.getRequest(requestPath, Method.get)?.params,
          equals({'0': '4', '1': '5'}));
    });
    test("named args", () {
      RequestManager requestManager = RequestManager();
      String addPath = '/long/path/1/2/3/:name';
      String requestPath = '/long/path/1/2/3/4';
      requestManager.addRequest(addPath, Method.get, () => {});
      expect(requestManager.getRequest(requestPath, Method.get),
          isA<RouteTreeNode>());
      expect(requestManager.getRequest(requestPath, Method.get)?.params,
          equals({'name': '4'}));
    });
    test('multiple named args', () {
      RequestManager requestManager = RequestManager();
      String addPath = '/long/path/1/2/3/:name/:name2';
      String requestPath = '/long/path/1/2/3/4/5';
      requestManager.addRequest(addPath, Method.get, () => {});
      expect(requestManager.getRequest(requestPath, Method.get),
          isA<RouteTreeNode>());
      expect(requestManager.getRequest(requestPath, Method.get)?.params,
          equals({'name': '4', 'name2': '5'}));
    });

    test("named params with * path", () {
      RequestManager requestManager = RequestManager();
      String addPath = '/long/path/1/2/3/:name/*';
      String requestPath = '/long/path/1/2/3/4/5';
      requestManager.addRequest(addPath, Method.get, () => {});
      expect(requestManager.getRequest(requestPath, Method.get),
          isA<RouteTreeNode>());
      expect(requestManager.getRequest(requestPath, Method.get)?.params,
          equals({'name': '4', '0': '5'}));
    });
    test("multiple named params with multiple * path", () {
      RequestManager requestManager = RequestManager();
      String addPath = '/long/path/1/2/3/:name/:name2/*/*';
      String requestPath = '/long/path/1/2/3/4/5/6/7';
      requestManager.addRequest(addPath, Method.get, () => {});
      expect(requestManager.getRequest(requestPath, Method.get),
          isA<RouteTreeNode>());
      expect(requestManager.getRequest(requestPath, Method.get)?.params,
          equals({'name': '4', 'name2': '5', '0': '6', '1': '7'}));
    });

    test("priority of the route ", () {
      RequestManager requestManager = RequestManager();
      String addPath1 = '/long/path/*';
      String addPath2 = '/long/path/1/*';
      String addPath3 = '/long/path/*/*';
      String requestPath = '/long/path/1/2/3/4/5/6/7';
      requestManager.addRequest(addPath1, Method.get, () => {});
      requestManager.addRequest(addPath2, Method.get, () => {});
      requestManager.addRequest(addPath3, Method.get, () => {});
      expect(requestManager.getRequest(requestPath, Method.get)?.path,
          equals(addPath2));
      requestPath = '/long/path/2/3';
      expect(requestManager.getRequest(requestPath, Method.get)?.path,
          equals(addPath3));
    });
    test("is * calling correct 1", () {
      RequestManager requestManager = RequestManager();
      requestManager.addRequest("/*/new", Method.get, () => {});
      expect(requestManager.getRequest("/users/1", Method.get), isNull);
    });

    test("is * calling correct 2", () {
      RequestManager requestManager = RequestManager();
      requestManager.addRequest("/*/*/3", Method.get, () => {});
      expect(requestManager.getRequest("/users/1/2", Method.get), isNull);
    });
  });

  group("test params", () {
    test("middle params 1", () {
      RequestManager requestManager = RequestManager();
      String addPath = '/long/path/1/:name/3/4/:name2';
      String requestPath = '/long/path/1/2/3/4/5';
      requestManager.addRequest(addPath, Method.get, () => {});
      expect(requestManager.getRequest(requestPath, Method.get),
          isA<RouteTreeNode>());
      expect(requestManager.getRequest(requestPath, Method.get)?.params,
          equals({'name': '2', 'name2': '5'}));
    });

    test("middle params 2", () {
      RequestManager requestManager = RequestManager();
      String addPath = '/:abc/path/1/:name/3/4/:name2';
      String requestPath = '/long/path/1/2/3/4/5';
      requestManager.addRequest(addPath, Method.get, () => {});
      expect(requestManager.getRequest(requestPath, Method.get),
          isA<RouteTreeNode>());
      expect(requestManager.getRequest(requestPath, Method.get)?.params,
          equals({'name': '2', 'name2': '5', 'abc': 'long'}));
    });

    test("testing mixed * and :", () {
      RequestManager requestManager = RequestManager();
      String addPath = '/*/path/1/:name/*/4/:name2';
      String requestPath = '/long/path/1/2/3/4/5';
      requestManager.addRequest(addPath, Method.get, () => {});
      expect(requestManager.getRequest(requestPath, Method.get),
          isA<RouteTreeNode>());
      expect(requestManager.getRequest(requestPath, Method.get)?.params,
          equals({'name': '2', 'name2': '5', '0': 'long', '1': '3'}));
    });
  });
  test("all path if the specific path is not available", () {
    RequestManager requestManager = RequestManager();
    String path = '/*';
    requestManager.addRequest(
      path,
      Method.get,
      () => {},
    );

    requestManager.addRequest(
      "/user",
      Method.get,
      () => {},
    );

    requestManager.addRequest(
      "/any",
      Method.get,
      () => {},
    );

    expect(requestManager.getRequest("/any/1", Method.get)?.path, "/*");
  });

  test("check backtrack is working in routes", () {
    RequestManager requestManager = RequestManager();
    String path = '/*';
    requestManager.addRequest(
      path,
      Method.get,
      () => {},
    );

    requestManager.addRequest(
      "/hello/*",
      Method.get,
      () => {},
    );

    requestManager.addRequest(
      "/hello/1/*",
      Method.get,
      () => {},
    );

    requestManager.addRequest(
      "/hello/1/2/*",
      Method.get,
      () => {},
    );

    expect(requestManager.getRequest("/hello/1", Method.get)?.path, "/hello/*");
    expect(
        requestManager.getRequest("/any/2/34/12/31/2", Method.get)?.path, "/*");
    expect(
        requestManager.getRequest("/hello/2/2", Method.get)?.path, "/hello/*");
    expect(requestManager.getRequest("/hello/1/2", Method.get)?.path,
        "/hello/1/*");
    expect(requestManager.getRequest("/hello/1/2/3", Method.get)?.path,
        "/hello/1/2/*");
  });

  test("testing path / is working", () {
    RequestManager requestManager = RequestManager();
    requestManager.addRequest("/", Method.get, () {});
    requestManager.addRequest("/hi", Method.get, () {});
    requestManager.addRequest("/hi/1", Method.get, () {});

    expect(requestManager.getRequest("/", Method.get)?.path, "");
  });

  test("testing other possibilities", () {
    RequestManager requestManager = RequestManager();
    requestManager.addRequest("/", Method.get, () {});

    expect(requestManager.getRequest("/hi", Method.get), isNull);
  });

  test("testing path '*' ", () {
    RequestManager requestManager = RequestManager();
    requestManager.addRequest("*", Method.get, () {});

    expect(requestManager.getRequest("/", Method.get), isNotNull);
  });
  test("testing path '/*' ", () {
    RequestManager requestManager = RequestManager();
    requestManager.addRequest("/*", Method.get, () {});

    expect(requestManager.getRequest("/", Method.get), isNotNull);
  });
  test("test middle to specific route work only for that route", () {
    RequestManager requestManager = RequestManager();

    requestManager.addRequest("/post/1", Method.get, () {}, middlewares: [
      (Req req, Res res, next) {
        next();
      }
    ]);
    requestManager.addRequest("/post", Method.get, () {}, middlewares: [
      (Req req, Res res, next) {
        next();
      }
    ]);

    // expect(requestManager.getRequest("/post/1", Method.get), isNotNull);
    expect(requestManager.getRequest("/post/1", Method.get)!.middlewares.length,
        1);
  });
}

void main() {
  pathTest();
}
