import 'package:dart_express/dart_express.dart';

void main() {
  final app = DartExpress();
  const portNumber = 6969;

  app.get('/', (Req req, res) {
    print("sending response");
    res.send('Hello World!');
  }, middlewares: [
    (Req req, Res res, Function next) {
      print('Middleware 1');
      // next();
      print('Middleware 1: after next');
      res.send('middleware 1');
    },
    (Req req, Res res, Function next) {
      print('Middleware 2');
      next();
    }
  ]);

  app.get('/parent/*', (Req req, res) {
    // var subpath = req.params;
    print(req.params);
    print(req.headers);
    res.send("parent 1");
  });

  // app.use("path", (req, res) { },)

  app.get("*", (req, res) {
    res.send("404");
  });

  // app.use("path", (req, res) { },)

  app.get("*", (req, res) {
    res.send("404");
  });

  app.listen(portNumber, () {
    print('Listening on port $portNumber');
  });
}
