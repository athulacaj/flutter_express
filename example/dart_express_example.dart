import 'package:dart_express/dart_express.dart';
import 'package:dart_express/src/middlewares/cors.dart';

void main() {
  final app = DartExpress();
  const portNumber = 3000;

  app.use("*", [
    cors(
        options: CorsOptions(
            origin: ["http://localhost:8080"],
            methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"]))
  ]);

  app.get("/post/1", (req, res) {
    res.send("/post/1");
  }, middlewares: []);

  app.get("/post", (req, res) {
    res.json(req.body);
  }, middlewares: []);

  app.listen(portNumber, () {
    print('Listening on port $portNumber');
  });
}
