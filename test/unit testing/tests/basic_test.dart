import 'package:dart_express/src/support/functions.dart';
import 'package:dart_express/src/support/route_tree.dart';
import 'package:dart_express/src/support/types.dart';
import 'package:test/test.dart';

void basicTest() {
  group('initial', () {
    test(' "/" get should null ', () {
      RequestManager requestManager = RequestManager();
      expect(requestManager.getRequest('/', Method.get)?.callback, isNull);
    });
    group('able to add path and getpath', () {
      late RequestManager requestManager;
      setUpAll(() {
        requestManager = RequestManager();
      });

      test('should add a get request', () {
        requestManager.addRequest('/', Method.get, () => {prints("hi")});
        expect(
            requestManager.getRequest('/', Method.get), isA<RouteTreeNode>());
      });

      test('should add a post request', () {
        requestManager.addRequest('/', Method.post, () => {});
        expect(
            requestManager.getRequest('/', Method.post), isA<RouteTreeNode>());
      });

      test('should add a patch request', () {
        requestManager.addRequest('/', Method.patch, () => {});
        expect(
            requestManager.getRequest('/', Method.patch), isA<RouteTreeNode>());
      });

      test('should add a put request', () {
        requestManager.addRequest('/', Method.put, () => {});
        expect(
            requestManager.getRequest('/', Method.put), isA<RouteTreeNode>());
      });

      test('should add a delete request', () {
        requestManager.addRequest('/', Method.delete, () => {});
        expect(requestManager.getRequest('/', Method.delete),
            isA<RouteTreeNode>());
      });

      test('should return null if path is not found', () {
        expect(requestManager.getRequest('/new', Method.get), isNull);
      });

      ///
    });
  });
}
