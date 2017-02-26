import 'dart:isolate';
import 'package:angel_common/angel_common.dart';

main(_, [SendPort sendPort]) async {
  var app = new Angel()
    ..get('/', () => 'Adiós, nginx!')
    ..get('/foo', () => 'bar')
    ..after.add((RequestContext req, ResponseContext res) async {
      res
        ..statusCode = 404
        ..write('404 Not Found: ${req.uri}');
      return false;
    });

  var server = await app.startServer();
  print('Cluster listening at http://${server.address.address}:${server.port}');
  sendPort?.send([server.address.address, server.port]);
}
