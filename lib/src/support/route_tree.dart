// ignore_for_file: public_member_api_docs, sort_constructors_first
class RouteTreeNode {
  final String path;
  final String pathPart;
  Function? _callback;
  final Map<String, RouteTreeNode> children = {};
  final String? paramKey;

  Map<dynamic, String> _params = {};

  RouteTreeNode(this.path, this.pathPart, {this.paramKey});

  setCallback(Function callback) {
    _callback = callback;
  }

  get callback => _callback;

  setParam(Map<dynamic, String> params) {
    _params = params;
  }

  get params => _params;

  @override
  String toString() =>
      'RouteTreeNode(path: $path, pathPart: $pathPart,params:$params)';
}

class RouteTree {
  final RouteTreeNode root = RouteTreeNode("", "");

  addRoute(String path, Function callback) {
    if (path == "/") {
      root.setCallback(callback);
      return;
    }

    List<String> pathParts = path.split("/");
    RouteTreeNode currentNode = root;
    String currentPath = '';
    for (int i = 0; i < pathParts.length; i++) {
      String pathPart = pathParts[i];
      if (pathPart == "") {
        continue;
      }
      currentPath += "/$pathPart";
      if (currentNode.children.containsKey(pathPart)) {
        currentNode = currentNode.children[pathPart]!;
      } else {
        String? paramKey;
        if (pathPart.contains(":")) {
          paramKey = pathPart.replaceAll(":", "");
          pathPart = "*";
        }
        RouteTreeNode newNode =
            RouteTreeNode(currentPath, pathPart, paramKey: paramKey);
        currentNode.children[pathPart] = newNode;
        currentNode = newNode;
      }
      currentNode.setCallback(callback);
    }
  }

  RouteTreeNode? getRoute(String path) {
    List<String> pathParts = path.split("/");
    RouteTreeNode currentNode = root;
    String previousPathPart = "";
    int paramCount = 0;
    Map<dynamic, String> params = {};
    for (String pathPart in pathParts) {
      if (pathPart == "") {
        continue;
      }
      if (currentNode.children.containsKey(pathPart)) {
        currentNode = currentNode.children[pathPart]!;
        previousPathPart = pathPart;
      } else if (currentNode.children.containsKey("*")) {
        currentNode = currentNode.children["*"]!;

        if (currentNode.paramKey != null) {
          params[currentNode.paramKey] = pathPart;
        } else {
          previousPathPart = "*";
          params[paramCount] = pathPart;
          paramCount++;
        }
      } else {
        if (previousPathPart != "*") {
          return null;
        } else if (paramCount != 0) {
          final String existingParams = params[paramCount - 1] ?? '';
          params[paramCount - 1] = "$existingParams/$pathPart";
        }
      }
    }
    currentNode.setParam(params);
    return currentNode;
  }

  void traverse(RouteTreeNode node) {
    node.children.forEach((key, RouteTreeNode value) {
      print(value);
      traverse(value);
    });
  }

  @override
  String toString() {
    traverse(root);
    return '';
  }
}

void main() {
  RouteTree tree = RouteTree();
  tree.addRoute("/", () => print("root"));
  // // tree.addRoute("/parent/new/21/*", () => print("new21*"));
  // tree.addRoute("/parent/*", () => print("*"));
  // tree.addRoute("/parent/:name/:age/*", () => print("**"));
  // // tree.addRoute("/parent/new/*", () => print("new*"));
  // tree.addRoute("/parent/child", () => print("child"));
  tree.addRoute("/parent/:name", () => print("parent"));
  RouteTreeNode? t = tree.getRoute("/parent/athul/21/31/42");
  t?.callback?.call();
  print(t);
}
