import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vernet/pages/host_scan_page/device_in_the_network.dart';
import 'package:vernet/pages/host_scan_page/host_scna_bloc/host_scan_bloc.dart';
import 'package:vernet/pages/network_troubleshoot/port_scan_page.dart';

class HostScanWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<HostScanBloc, HostScanState>(
          builder: (context, state) {
            return state.map(
              initial: (_) => Container(),
              loadInProgress: (value) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        CircularProgressIndicator(),
                        SizedBox(
                          height: 30,
                        ),
                        Text(
                          'Searching for devices in your local network',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              foundNewDevice: (FoundNewDevice value) {
                final List<DeviceInTheNetwork> activeHostList =
                    value.activeHostList;

                return Expanded(
                  child: ListView.builder(
                    itemCount: activeHostList.length,
                    itemBuilder: (context, index) {
                      final DeviceInTheNetwork host = activeHostList[index];
                      return FutureBuilder(
                        future: host.make,
                        builder: (context, snapshot) {
                          /// TODO: Change back to comment when https://github.com/dart-lang/sdk/issues/49608 is fixed
                          // String deviceName = 'Searching Device Name';
                          String deviceName = 'Generic Device';
                          if (snapshot.connectionState ==
                                  ConnectionState.done &&
                              snapshot.data != null) {
                            deviceName = snapshot.data.toString();
                          }
                          return ListTile(
                            leading: Icon(host.iconData),
                            title: Text(deviceName),
                            subtitle: Text(host.ip),
                            trailing: IconButton(
                              tooltip: 'Scan open ports for this target',
                              icon: const Icon(Icons.radar),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PortScanPage(target: host.ip),
                                  ),
                                );
                              },
                            ),
                            onLongPress: () {
                              Clipboard.setData(ClipboardData(text: host.ip));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('IP copied to clipboard'),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                );
              },
              loadFailure: (value) {
                return const Text('Failure');
              },
              loadSuccess: (value) {
                return const Text('Done');
              },
              error: (Error value) {
                return const Text('Error');
              },
            );
          },
        ),
      ],
    );
  }
}
