import 'package:dart_express/dart_express.dart';

void main() {
  final app = DartExpress();
  const portNumber = 3000;

  app.get("*", (req, res) {
    req.headers;
    res.send("helllo");
  }, middlewares: [
    (req, res, next) {
      print("hello");
      next();
    }
  ]);
  app.get("/hello", (req, res) {
    res.json({"hello": 'world'});
  });

  app.listen(portNumber, () {
    print('Listening on port $portNumber');
  });
}
