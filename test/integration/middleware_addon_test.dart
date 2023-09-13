import 'dart:convert';

import 'package:dart_express/src/express.dart';
import 'package:dart_express/src/middlewares/body_parser.dart';
import 'package:dart_express/src/middlewares/cors.dart';
import 'package:http/http.dart';
import 'package:test/test.dart';

import '../functions/api_service.dart';

void main() {
  const portNumber = 3000;
  const basePath = "http://localhost:$portNumber";

  final app = DartExpress();
  app.listen(portNumber, () {
    print('Listening on port $portNumber');
  });

  group("testing cors middleware", () {
    app.use("*", [cors()]);
    test("1", () async {
      final Response data = await ApiService.options(basePath);
      expect(data.headers['access-control-allow-origin'], "*");
      expect(data.headers['access-control-allow-methods'],
          "GET, POST, PUT, DELETE");
      expect(data.body, "");
    });
  });

  group("testing body parser", () {
    test("json parser", () async {
      app.use("*", [DEParser.jsonParser]);
      app.post("/", (req, res) {
        res.json(req.body);
      });
      const mock = {"name": "athul"};
      final Response data = await ApiService.post(basePath, body: mock);
      expect(jsonDecode(data.body), mock);
    });
    test("form data parser", () async {
      app.use("*", [DEParser.jsonParser]);
      app.post("/", (req, res) {
        res.json(req.body);
      });
      const mock = {"name": "athul"};
      final Response data = await ApiService.post(basePath,
          body: mock, bodyType: BodyType.formData);
      expect(jsonDecode(data.body), mock);
    });
  });
}
