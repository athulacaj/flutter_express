import 'package:dart_express/src/models/req_model.dart';
import 'package:dart_express/src/models/res_model.dart';

typedef DECallBack = void Function(Req req, Res res);
typedef DECallBackWithNext = void Function(Req req, Res res, Function next);
