import 'package:dart_express/src/support/functions.dart';
import 'package:dart_express/src/support/route_tree.dart';
import 'package:dart_express/src/support/types.dart';
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
}

void main() {
  pathTest();
}
