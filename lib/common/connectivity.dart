import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../ViewModel.dart';

class ConnectionStatus extends StatefulWidget {
  final bool isShow;

  ConnectionStatus({super.key, this.isShow=false});
  @override
  _ConnectionStatusState createState() => _ConnectionStatusState();
}

class _ConnectionStatusState extends State<ConnectionStatus> {
  var connectivityResult;
  late AppViewModel appViewModel;

  @override
  void initState() {
    super.initState();
    checkConnectivity();
  }

  Future<void> checkConnectivity() async {
    var result = await Connectivity().checkConnectivity();
    setState(() {
      connectivityResult = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    appViewModel = Provider.of<AppViewModel>(context);
    return widget.isShow?Center(
      child: Text(
        'Connection Status: ${_getStatusString(connectivityResult)}',
        style: TextStyle(fontSize: 18),
      ),
    ):Container();
  }

  String _getStatusString(var status) {
    switch (status) {
      case ConnectivityResult.none:
        appViewModel.connectivity = 'No Internet Connection';
        return 'No Internet Connection';
      case ConnectivityResult.mobile:
        appViewModel.connectivity = 'Mobile Data Connection';
        return 'Mobile Data Connection';
      case ConnectivityResult.wifi:
        appViewModel.connectivity = 'WiFi Connection';
        return 'WiFi Connection';
      default:
        return 'Unknown';
    }
  }
}