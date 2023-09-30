import 'dart:convert';

import 'package:flutter_express/flutter_express.dart';
import 'package:http/http.dart';
import 'package:test/test.dart';

import '../functions/api_service.dart';

void main() {
  const portNumber = 3000;
  const basePath = "http://localhost:$portNumber";

  DartExpress app = DartExpress();
  app.listen(portNumber, () {
    print('Listening on port $portNumber');
  });

  group("testing path", () {
    test("if route not exist return 404", () async {
      final Response data = await ApiService.get("$basePath/nwe/434");
      expect(data.statusCode, 404);
    });
    test("testing path /", () async {
      app.get("/", (req, res) {
        res.send("hello");
      });
      app.get("/hello", (req, res) {
        res.send("{hello: 'world'}");
      });
      final Response data1 = await ApiService.get(basePath);
      final Response data2 = await ApiService.get("$basePath/hello");
      expect(data1.body, "hello");
      expect(data2.body, "{hello: 'world'}");
    });

    test("testing json", () async {
      const d = {"msg": "hello"};
      app.get("/json", (req, res) {
        res.json(d);
      });

      final Response data1 = await ApiService.get("$basePath/json");
      expect(jsonDecode(data1.body), d);
    });
  });

  group("testing query params and params", () {
    test("testing query params", () async {
      app.get("/query", (req, res) {
        res.json(req.query);
      });

      final Response data1 = await ApiService.get("$basePath/query?name=1");
      expect(jsonDecode(data1.body), {"name": "1"});
    });
    test("testing query params", () async {
      app.get("/query", (req, res) {
        res.json(req.query);
      });

      final Response data1 =
          await ApiService.get("$basePath/query?name=1&age=20");
      expect(jsonDecode(data1.body), {"name": "1", "age": "20"});
    });

    test("testing params", () async {
      app.get("/params/:name/*/:age/*", (req, res) {
        res.json(req.params);
      });

      final Response data1 =
          await ApiService.get("$basePath/params/athul/20/23/1");
      expect(jsonDecode(data1.body),
          {"name": "athul", "age": "23", "0": "20", "1": "1"});
    });
  });

  group("testing middlewares", () {
    // after all test
    tearDown(() {
      app.clear();
    });

    test("all", () async {
      app.use("*", [
        (Req req, Res res, Function next) {
          res.send("hi");
        }
      ]);
      final Response data = await ApiService.get("$basePath/any/path");
      expect(data.body, "hi");
    });
    test("testing muttiple middleware and checking next is working", () async {
      app.use("/any/123", [
        (Req req, Res res, Function next) {
          next();
        },
        (Req req, Res res, Function next) {
          next();
        },
        (Req req, Res res, Function next) {
          next();
        }
      ]);
      app.get("/any/123", (Req req, Res res) {
        res.send("hi");
      });

      final Response data = await ApiService.get("$basePath/any/123");
      expect(data.body, "hi");
    });

    test("testing muttiple middleware orders", () async {
      app.use("/any/*", [
        (Req req, Res res, next) {
          res.send("2");
        }
      ]);
      app.use("/any/123", [
        (Req req, Res res, next) {
          res.send("23");
        }
      ]);

      app.use("/*", [
        (Req req, Res res, Function next) {
          next();
        },
        (Req req, Res res, Function next) {
          next();
        },
        (Req req, Res res, Function next) {
          res.send("1");
        }
      ]);

      app.get("/any/123", (Req req, Res res) {
        res.send("123");
      });

      final Response data = await ApiService.get("$basePath/any/123");
      expect(data.body, "2");
    });

    test("if route not exist return 404 if middleware also there", () async {
      app.use("*", [
        (Req req, Res res, Function next) {
          next();
        }
      ]);
      final Response data = await ApiService.get("$basePath/nwe/434");
      expect(data.statusCode, 404);
    });
    test("testing in route middleware is only applied to that", () async {
      app.clear();

      app.use("/*", [
        (req, res, next) {
          next();
        }
      ]);

      app.post("1/2", (Req req, Res res) {
        res.send("hi");
      }, middlewares: [
        (Req req, Res res, Function next) {
          print("2---");
          res.send("2");
        }
      ]);

      app.post("/1/1", (Req req, Res res) {
        res.send("hi");
      }, middlewares: [
        (Req req, Res res, Function next) {
          res.send("1");
        }
      ]);

      final Response data = await ApiService.post("$basePath/1/1", body: {});
      expect(data.body, "1");
      final Response data2 = await ApiService.post("$basePath/1/2", body: {});
      expect(data2.body, "2");
    });
  });
}

// https://expressjs.com/en/api.html#req
