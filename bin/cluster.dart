import 'dart:isolate';
import 'package:angel_common/angel_common.dart';

main(_, [SendPort sendPort]) async {
  var app = new Angel();

  app.get('/', () => 'Adiós, nginx!');

  var server = await app.startServer();
  print('Cluster listening at http://${server.address.address}:${server.port}');
  sendPort?.send([server.address.address, server.port]);
}
