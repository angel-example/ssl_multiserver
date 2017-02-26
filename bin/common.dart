import 'dart:io';
import 'package:angel_common/angel_common.dart';

AngelConfigurer catchErrorsAndDiagnose(String logFile) {
  return (Angel app) async {
    var errors = new ErrorHandler()
      ..fatalErrorHandler = (AngelFatalError e) {
        print('Fatal: ${e.error}');
        print(e.stack);
      };

    app.after.add(errors.throwError());
    await app.configure(errors);
    await app.configure(logRequests(new File(logFile)));
  };
}
