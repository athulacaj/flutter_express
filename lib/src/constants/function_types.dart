import 'package:flutter_express/src/models/req_model.dart';
import 'package:flutter_express/src/models/res_model.dart';

typedef DECallBack = void Function(Req req, Res res);
typedef DECallBackWithNext = void Function(Req req, Res res, Function next);
