import 'dart:io';
import 'package:angel_common/angel_common.dart';
import 'package:angel_multiserver/angel_multiserver.dart';
import 'common.dart';

final Uri cluster = Platform.script.resolve('cluster.dart');

final RegExp _leadingSlashes = new RegExp(r'^\/+');

main() async {
  await enforceHttps();
  await startLoadBalancer();
}

enforceHttps() async {
  var enforcer = new Angel()..before.add(forceHttps());
  await enforcer.configure(catchErrorsAndDiagnose('logs/enforcer.txt'));
  var server = await enforcer.startServer(InternetAddress.ANY_IP_V4, 80);
  print(
      'HTTPS enforcer listening at http://${server.address.address}:${server.port}');
}

startLoadBalancer() async {
  var context = new SecurityContext()
    ..useCertificateChain('keys/server.crt')
    ..usePrivateKey('keys/server.key');
  var loadBalancer =
      new LoadBalancer.fromSecurityContext(context);

  await loadBalancer
      .configure(catchErrorsAndDiagnose('logs/load_balancer.txt'));

  await loadBalancer.spawnIsolates(cluster, count: 5);

  loadBalancer.onCrash.listen((_) {
    // Start a new node whenever one crashes
    loadBalancer.spawnIsolates(cluster);
  });

  // `503 Service Unavailable` as fallback
  loadBalancer.after.add(serviceUnavailable());

  // Usually we'll cache responses, or add GZIPPING
  await loadBalancer.configure(cacheResponses());
  loadBalancer.responseFinalizers.add(gzip());

  var server = await loadBalancer.startServer(InternetAddress.ANY_IP_V4, 443);
  print(
      'Load balancer listening at https://${server.address.address}:${server.port}');
}
