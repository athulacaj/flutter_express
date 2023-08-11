import 'package:dart_express/dart_express.dart';

void main() {
  final app = DartExpress();

  app.get('/', (Req req, res) {
    res.send('Hello World!');
  });

  app.get('/parent/*', (Req req, res) {
    // var subpath = req.params;
    print(req.params);
    res.send("parent 1");
  });

  app.listen(3000, () {
    print('Listening on port 3000');
  });
}
