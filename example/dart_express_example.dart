import 'package:dart_express/dart_express.dart';
import 'package:dart_express/src/middlewares/body_parser.dart';

void main() {
  final app = DartExpress();
  const portNumber = 3000;

  // app.get("/hello", (req, res) {
  //   res.json({"hello": 'world'});
  // });

  // app.use("/*", [
  //   (req, res, next) {
  //     next();
  //   }
  // ]);

  app.get("/post/1", (req, res) {
    res.send("/post/1");
  }, middlewares: [DEParser.formUrlEncoded]);

  app.get("/post", (req, res) {
    res.json(req.body);
  }, middlewares: [DEParser.formDataParser]);

  app.listen(portNumber, () {
    print('Listening on port $portNumber');
  });
}
