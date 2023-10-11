import 'package:flutter_express/src/support/functions.dart';
import 'package:flutter_express/src/support/route_tree.dart';
import 'package:flutter_express/src/constants/route_methods.dart';
import 'package:test/test.dart';

void basicTest() {
  group('initial', () {
    // test(' "/" get should null ', () {
    //   RequestManager requestManager = RequestManager();
    //   expect(requestManager.getRequest('/', Method.get)?.callback, isNull);
    // });

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
        requestManager.addRequest('/', Method.put, () => {});
        expect(requestManager.getRequest('/new123', Method.get), isNull);
      });

      test('testing put method', () {
        requestManager.addRequest('/123445', Method.put, () => {});
        expect(
            requestManager.getRequest('/123445', Method.put)?.path, '/123445');
      });

      test('testing delete method', () {
        requestManager.addRequest('/123445', Method.delete, () => {});
        expect(requestManager.getRequest('/123445', Method.delete)?.path,
            '/123445');
      });

      test('testing patch method', () {
        requestManager.addRequest('/123445', Method.patch, () => {});
        expect(requestManager.getRequest('/123445', Method.patch)?.path,
            '/123445');
      });

      ///
    });
  });
}

void main() {
  basicTest();
}
