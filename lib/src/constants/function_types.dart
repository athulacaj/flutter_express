import 'package:flutter_express/src/models/req_model.dart';
import 'package:flutter_express/src/models/res_model.dart';

typedef FECallBack = void Function(Req req, Res res);
typedef FECallBackWithNext = void Function(Req req, Res res, Function next);
