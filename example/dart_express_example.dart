import 'package:dart_express/dart_express.dart';

void main() {
  final app = DartExpress();
  const portNumber = 6969;

  app.get('/', (Req req, res) {
    res.send('Hello World!');
  });

  app.get('/parent/*', (Req req, res) {
    // var subpath = req.params;
    print(req.params);
    res.send("parent 1");
  });

  app.listen(6900, () {
    print('Listening on port $portNumber');
  });
}
