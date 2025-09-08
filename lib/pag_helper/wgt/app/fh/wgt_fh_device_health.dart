import 'package:buff_helper/pag_helper/def_helper/dh_device.dart';
import 'package:buff_helper/pag_helper/wgt/wgt_comm_button.dart';
import 'package:buff_helper/pkg_buff_helper.dart';
import 'package:buff_helper/xt_ui/wdgt/wgt_pag_wait.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'dart:developer' as dev;

import '../../../comm/comm_fh.dart';
import '../../../model/acl/mdl_pag_svc_claim.dart';
import '../../../model/mdl_pag_app_config.dart';
import '../../ls/wgt_pag_dashboard_list.dart';
import 'wgt_scope_issue_panel.dart';

class WgtFhDeviceHealth extends StatefulWidget {
  const WgtFhDeviceHealth({
    super.key,
    required this.appConfig,
    required this.loggedInUser,
    required this.deviceCat,
    required this.deviceInfo,
    this.height = 500,
  });

  final MdlPagAppConfig appConfig;
  final MdlPagUser loggedInUser;
  final PagDeviceCat deviceCat;
  final Map<String, dynamic> deviceInfo;
  final double height;

  @override
  State<WgtFhDeviceHealth> createState() => _WgtFhDeviceHealthState();
}

class _WgtFhDeviceHealthState extends State<WgtFhDeviceHealth> {
  late final TextStyle keyStyle = TextStyle(color: Theme.of(context).hintColor);
  late final TextStyle valueStyle =
      const TextStyle(fontWeight: FontWeight.bold, fontSize: 18);
  final keyWidth = 30.0;
  final valueWidth = null;
  final contentWidth = 365.0;

  final okColor = Colors.teal;
  late final errorColor = Theme.of(context).colorScheme.error.withAlpha(210);

  bool _isFetching = false;
  bool _isFetched = false;
  String _errorText = '';
  String _message = '';

  Map<String, dynamic> _selectedMeterInfo = {};
  bool? _isCheckingMeter;
  String _checkMeterErrorText = '';

  final Map<String, dynamic> _gatewayHealthData = {};
  final Map<String, dynamic> _meterHealthData = {};

  Future<void> _fetchDeviceHealth() async {
    if (_isFetching || _isFetched) {
      return;
    }

    _isFetching = true;
    _errorText = '';
    _message = '';

    Map<String, dynamic> queryMap = {
      'scope': widget.loggedInUser.selectedScope.toScopeMap(),
      'device_cat': widget.deviceCat.name,
      'device_info': widget.deviceInfo,
    };

    try {
      // Simulate a network call to fetch device health data
      // await Future.delayed(const Duration(seconds: 2));
      final result = await getDeviceHealthInfo(
          widget.appConfig,
          queryMap,
          MdlPagSvcClaim(
            scope: '',
            target: '',
            operation: '',
          ));
      if (result['info'] != null) {
        _message = result['message'];
      } else {
        final gatewayHealthInfo = result['gateway_health_info'];
        _gatewayHealthData.clear();
        _gatewayHealthData.addAll(gatewayHealthInfo);
      }
    } catch (e) {
      _errorText = 'Error getting device health info';
    } finally {
      setState(() {
        _isFetching = false;
        _isFetched = true;
      });
    }
  }

  Future<void> _checkMeterStatus() async {
    if (_selectedMeterInfo.isEmpty) {
      return;
    }
    if (_isCheckingMeter == true) {
      return;
    }

    setState(() {
      _isCheckingMeter = true;
      _checkMeterErrorText = '';
      _message = '';
    });

    Map<String, dynamic> queryMap = {
      'scope': widget.loggedInUser.selectedScope.toScopeMap(),
      'device_cat': PagDeviceCat.meter.name,
      'device_info': {
        'meter_sn': _selectedMeterInfo['meter_sn'],
        'meter_tag': _selectedMeterInfo['meter_tag'],
        'gateway_tag': widget.deviceInfo['tag'],
      },
    };

    try {
      final result = await getDeviceHealthInfo(
          widget.appConfig,
          queryMap,
          MdlPagSvcClaim(
            scope: '',
            target: '',
            operation: '',
          ));
      if (result['info'] != null) {
        _message = result['message'];
      } else {
        final meterHealthInfo = result['meter_health_info'];
        _meterHealthData.clear();
        _meterHealthData.addAll(meterHealthInfo);

        String commCheckResult = _meterHealthData['comm_check_result'] ?? '';
        if (commCheckResult == 'ok') {
          // remove the meter tag from the error list
          final content = _gatewayHealthData['content'];
          final errorList = content['el'] ?? [];
          for (var errMeterTag in errorList) {
            if (errMeterTag == _selectedMeterInfo['meter_tag']) {
              errorList.remove(errMeterTag);
              break;
            }
          }
        }
      }
    } catch (e) {
      dev.log('Error checking meter status: $e');
      _checkMeterErrorText = 'Error checking meter status';
    } finally {
      setState(() {
        _isCheckingMeter = false;
        _isFetching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool fetch = _gatewayHealthData.isEmpty && !_isFetched;

    if (_errorText.isNotEmpty) {
      return getErrorTextPrompt(context: context, errorText: _errorText);
    }
    if (_message.isNotEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text(_message)],
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: contentWidth,
            child: fetch
                ? FutureBuilder(
                    future: _fetchDeviceHealth(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          dev.log('device health: pulling data');

                          return const SizedBox(
                            height: 200,
                            child: Align(
                              alignment: Alignment.center,
                              child: WgtPagWait(),
                            ),
                          );
                        default:
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            return completedWidget();
                          }
                      }
                    },
                  )
                : completedWidget(),
          ),
        ],
      ),
    );
  }

  Widget completedWidget() {
    if (_gatewayHealthData.isEmpty) {
      return const SizedBox.shrink();
    }

    String submittedTimestamp = _gatewayHealthData['submitted_timestamp'] ?? '';
    final content = _gatewayHealthData['content'];
    final version = content['v'];
    final temperature = content['t'];
    final signal = content['s'];
    final errorList = content['el'] ?? [];

    final meterGroupLabel =
        _gatewayHealthData['meter_group_label'] ?? 'Unknown';

    final meterInfoList = _gatewayHealthData['meter_info_list'] ?? [];

    List<Map<String, dynamic>> issueList = [];
    for (var error in errorList) {
      issueList.add({
        'issue_value': error ?? '',
      });
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        getTopStatPnl(),
        verticalSpaceSmall,
        getMeterGroupStatus(),
        verticalSpaceSmall,
        getMeterIssuePanel(),
        if (false)
          // if (issueList.isNotEmpty)
          WgtPagDashboardList(
            maxWidth: 120,
            title: 'Error List',
            itemList: issueList,
            reportNamePrefix: 'issue_list',
            listConfig: const [
              {
                'title': 'Value',
                'col_key': 'issue_value',
                'width': 50.0,
                'use_widget': 'box',
              },
            ],
          ),
        verticalSpaceSmall,
      ],
    );
  }

  Widget getTopStatPnl() {
    String submittedTimestamp = _gatewayHealthData['submitted_timestamp'] ?? '';
    final content = _gatewayHealthData['content'];
    final version = content['v'];
    final temperature = content['t'];
    final signal = content['s'];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).hintColor.withAlpha(130)),
        borderRadius: BorderRadius.circular(5.0),
      ),
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                  width: keyWidth,
                  child: Icon(Symbols.clock_arrow_up,
                      color: Theme.of(context).hintColor)),
              // horizontalSpaceTiny,
              SizedBox(
                  width: valueWidth,
                  child: Text(submittedTimestamp, style: valueStyle)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                  width: keyWidth,
                  child: Icon(Symbols.deployed_code,
                      color: Theme.of(context).hintColor)),
              // horizontalSpaceTiny,
              SizedBox(
                  width: valueWidth, child: Text(version, style: valueStyle)),
              horizontalSpaceSmall,
              SizedBox(
                  width: keyWidth,
                  child: Icon(Symbols.thermostat,
                      color: Theme.of(context).hintColor)),
              // horizontalSpaceTiny,
              SizedBox(
                  width: valueWidth,
                  child: Text(temperature, style: valueStyle)),
              horizontalSpaceSmall,
              SizedBox(
                  width: keyWidth,
                  child: Icon(Symbols.signal_cellular_alt,
                      color: Theme.of(context).hintColor)),
              // horizontalSpaceTiny,
              SizedBox(
                  width: valueWidth, child: Text(signal, style: valueStyle)),
            ],
          ),
        ],
      ),
    );
  }

  Widget getMeterGroupStatus() {
    final meterGroupLabel =
        _gatewayHealthData['meter_group_label'] ?? 'Unknown';

    final content = _gatewayHealthData['content'];
    final errorList = content['el'] ?? [];
    final meterInfoList = _gatewayHealthData['meter_info_list'] ?? [];

    // sort by tag strings
    meterInfoList.sort((a, b) {
      String tagA = a['meter_tag'] ?? '';
      String tagB = b['meter_tag'] ?? '';
      return tagA.compareTo(tagB);
    });

    // get a array of meeters,
    List<Widget> meterRowList = [];
    for (var meterInfo in meterInfoList) {
      final meterSn = meterInfo['meter_sn'] ?? 'Unknown';
      final meterTag = meterInfo['meter_tag'] ?? 'Unknown';

      bool hasError = false;
      for (var errMeterTag in errorList) {
        if (errMeterTag == meterTag) {
          hasError = true;
          break;
        }
      }

      meterRowList.add(getMeterBox(meterTag, meterSn, hasError));
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).hintColor.withAlpha(130)),
        borderRadius: BorderRadius.circular(5.0),
      ),
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                  width: keyWidth,
                  child: Icon(PagDeviceCat.meterGroup.iconData,
                      color: Theme.of(context).hintColor)),
              horizontalSpaceTiny,
              SizedBox(
                  width: valueWidth,
                  child: Text(meterGroupLabel, style: valueStyle)),
            ],
          ),
          verticalSpaceSmall,
          Wrap(
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              ...meterRowList,
            ],
          ),
        ],
      ),
    );
  }

  Widget getMeterBox(String meterTag, String meterSn, bool hasError) {
    return InkWell(
      onTap: () {
        setState(() {
          if (meterSn == _selectedMeterInfo['meter_sn']) {
            _selectedMeterInfo = {};
            return;
          }
          _selectedMeterInfo = {
            'meter_sn': meterSn,
            'meter_tag': meterTag,
          };
          _checkMeterErrorText = '';
          _meterHealthData.clear();
        });
      },
      child: Container(
        width: 60,
        decoration: BoxDecoration(
          border: _selectedMeterInfo['meter_sn'] == meterSn
              ? Border.all(
                  color: Theme.of(context).hintColor.withAlpha(130), width: 5)
              : null,
          borderRadius: BorderRadius.circular(5.0),
          color: hasError ? errorColor : okColor,
        ),
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 3),
        child: Center(
            child: Text(meterTag,
                style: valueStyle.copyWith(
                    color: Theme.of(context).colorScheme.onSecondary))),
      ),
    );
  }

  Widget getMeterIssuePanel() {
    if (_selectedMeterInfo.isEmpty) {
      return const SizedBox.shrink();
    }

    final content = _gatewayHealthData['content'];
    final errorList = content['el'] ?? [];
    final meterInfoList = _gatewayHealthData['meter_info_list'] ?? [];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).hintColor.withAlpha(130)),
        borderRadius: BorderRadius.circular(5.0),
      ),
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //copy button for meter sn
              InkWell(
                child: Icon(Icons.copy,
                    size: 20, color: Theme.of(context).hintColor),
                onTap: () {
                  Clipboard.setData(
                      ClipboardData(text: _selectedMeterInfo['meter_sn']));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied to clipboard')),
                  );
                },
              ),
              horizontalSpaceTiny,
              SelectableText('S/N: ${_selectedMeterInfo['meter_sn']}',
                  style: valueStyle),
              horizontalSpaceSmall,
              WgtCommButton(
                  enabled: _isCheckingMeter != true &&
                      _isFetching != true &&
                      _meterHealthData.isEmpty &&
                      (_checkMeterErrorText.isEmpty),
                  label: 'Check Status',
                  labelWidget: Icon(Symbols.wifi_find,
                      color: Theme.of(context).colorScheme.onSecondary),
                  onPressed: () async {
                    await _checkMeterStatus();
                  }),
            ],
          ),
          if (_checkMeterErrorText.isNotEmpty)
            getErrorTextPrompt(
                context: context, errorText: _checkMeterErrorText),
          if (_meterHealthData.isNotEmpty) getMeterHealth(),
        ],
      ),
    );
  }

  Widget getMeterHealth() {
    if (_meterHealthData.isEmpty) {
      return const SizedBox.shrink();
    }

    String commCheckResult = _meterHealthData['comm_check_result'] ?? '';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      child: commCheckResult.isEmpty
          ? Container()
          : commCheckResult == 'ok'
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Symbols.check_circle, color: okColor, size: 25),
                    horizontalSpaceTiny,
                    Text('Meter Comm Check OK', style: valueStyle),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Symbols.error,
                        color:
                            Theme.of(context).colorScheme.error.withAlpha(180),
                        size: 30),
                    horizontalSpaceSmall,
                    Text('Meter is offline', style: valueStyle),
                  ],
                ),
    );
  }

  // Widget getOpPanel(Map<String, dynamic> fhStat) {
  //   if (widget.opPanelType == 'issue') {
  //     return WgtScopeEventIssuePanel(
  //       issueData: fhStat,
  //       title: 'Device Issues',
  //     );
  //   }

  //   return Container();
  // }
}
