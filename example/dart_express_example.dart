import 'package:dart_express/dart_express.dart';

void main() {
  final app = DartExpress();
  const portNumber = 3000;

  void m(Req req, Res res, Function next) {
    print('Middleware 1');
    next();
  }

  app.use("/*", [m]);

  app.get('/', (Req req, res) {
    print("sending response");
    res.send('Hello World! from "/"');
  });

  app.get('/parent/', (Req req, res) {
    res.send("parent 1");
  });

  app.listen(portNumber, () {
    print('Listening on port $portNumber');
  });
}
