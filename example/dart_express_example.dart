import 'package:flutter_express/flutter_express.dart';
import 'package:flutter_express/dart_middlewares.dart';

void main() {
  final app = DartExpress();
  const portNumber = 3000;

  // add middleware for every routes
  app.use("*", [cors()]);

  app.use("/*", [
    (req, res, next) {
      print(req.method);
      next();
    }
  ]);

  app.get("/", (req, res) {
    res.json({"hello": 'world'});
  });

  app.get("/names/:name/*", (req, res) {
    print("name ${req.params['name']}");
    res.json({"name": req.params['name']});
  });

  // add a middleware for "/post" route
  app.post("/post", (req, res) {
    res.json(req.body);
  }, middlewares: [DEParser.jsonParser]);

  app.listen(portNumber, () {
    print('Listening on port $portNumber');
  });
}
