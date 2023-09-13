import 'package:dart_express/dart_express.dart';
import 'package:dart_express/src/middlewares/body_parser.dart';

void main() {
  final app = DartExpress();
  const portNumber = 7000;

  app.get("/hello", (req, res) {
    res.json({"hello": 'world'});
  });

  // app.use("*", [DEParser.jsonParser]);
  app.use("/*", [
    (req, res, next) {
      next();
    }
  ]);

  app.post("/post", (req, res) {
    res.json(req.body);
  });

  app.listen(portNumber, () {
    print('Listening on port $portNumber');
  });
}
