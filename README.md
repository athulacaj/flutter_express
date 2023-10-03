
Flutter_Express is a lightweight and user-friendly routing package. It's perfect for swiftly crafting web applications, prototypes, or smaller projects without drowning in unnecessary complexity. Just like Express, it empowers developers to stay focused on their goals, making it a valuable asset whether you're a beginner or a pro seeking efficiency in smaller web development tasks.

## Features

* Routing Made Easy: Flutter_express simplifies URL routing, allowing developers to define routes and handle HTTP requests effortlessly. Define routes with clear, concise syntax and attach custom logic to each route.

* Middleware Support: Implement powerful middleware functions to handle tasks such as authentication, logging, and input validation. Flutter_express makes it seamless to insert middleware at various stages of the request-response cycle.

* Flexible Request and Response Handling: flutter_express provides intuitive request and response objects, giving developers fine-grained control over data input and output. Easily parse JSON, form data, or other request types.

## Getting started

```dart
import 'package:flutter_express/flutter_express.dart';

final app = DartExpress();
const portNumber = 3000;

app.get("/", (req, res) {
    res.send("hello");
});

app.listen(portNumber, () {
    print('Listening on port $portNumber');
  });
```

## Usage

```dart
import 'package:flutter_express/flutter_express.dart';
import 'package:flutter_express/middlewares.dart';

void main() {
  final app = FlutterExpress();
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
  }, middlewares: [Parser.jsonParser]);

  app.listen(portNumber, () {
    print('Listening on port $portNumber');
  });
}

```

