import 'package:buff_helper/pkg_buff_helper.dart';

import 'mdl_ems_type_usage.dart';
import 'mdl_ems_type_usage_r2.dart';

class PagEmsTypeUsageCalc {
  //input
  late final int _costDecimals;
  late final double? _gst;
  late final Map<String, dynamic> _typeRateInfo;
  late final Map<String, dynamic> _usageFactor;

  late final Map<String, dynamic> _autoUsageSummary;
  late final List<Map<String, dynamic>> _subTenantUsageSummary;
  late final List<Map<String, dynamic>> _manualUsageList;
  late final List<Map<String, dynamic>> _lineItemList;

  //output
  EmsTypeUsageR2? _typeUsageE;
  EmsTypeUsageR2? _typeUsageW;
  EmsTypeUsageR2? _typeUsageB;
  EmsTypeUsageR2? _typeUsageN;
  EmsTypeUsageR2? _typeUsageG;

  final List<Map<String, dynamic>> _subTenantUsage = [];

  final List<Map<String, dynamic>> _trendingE = [];
  final List<Map<String, dynamic>> _trendingW = [];
  final List<Map<String, dynamic>> _trendingB = [];
  final List<Map<String, dynamic>> _trendingN = [];
  final List<Map<String, dynamic>> _trendingG = [];

  double? _subTotalCost;
  double? _gstAmount;
  double? _totalCost;

  String? _billBarFromMonth;

  List<PagEmsTypeUsageCalc> _singularCalcList = [];

  late final double? _balBf;
  late final double? _balBfUsage;
  late final double? _balBfInterest;

  EmsTypeUsageR2? get typeUsageE => _typeUsageE;
  EmsTypeUsageR2? get typeUsageW => _typeUsageW;
  EmsTypeUsageR2? get typeUsageB => _typeUsageB;
  EmsTypeUsageR2? get typeUsageN => _typeUsageN;
  EmsTypeUsageR2? get typeUsageG => _typeUsageG;

  List<Map<String, dynamic>> get subTenantUsage => _subTenantUsage;

  List<Map<String, dynamic>> get lineItemList => _lineItemList;

  List<Map<String, dynamic>> get trendingE => _trendingE;
  List<Map<String, dynamic>> get trendingW => _trendingW;
  List<Map<String, dynamic>> get trendingB => _trendingB;
  List<Map<String, dynamic>> get trendingN => _trendingN;
  List<Map<String, dynamic>> get trendingG => _trendingG;

  late final List<Map<String, dynamic>>? _billedTrendingSnapShot;

  double? get gst => _gst;
  double? get subTotalCost => _subTotalCost;
  double? get gstAmount => _gstAmount;
  double? get totalCost => _totalCost;

  String? get billBarFromMonth => _billBarFromMonth;

  double? get balBf => _balBf;
  double? get balBfUsage => _balBfUsage;
  double? get balBfInterest => _balBfInterest;

  List<PagEmsTypeUsageCalc> get singularCalcList => _singularCalcList;

  PagEmsTypeUsageCalc({
    required int costDecimals,
    double? gst,
    Map<String, dynamic> typeRates = const {},
    Map<String, dynamic> usageFactor = const {},
    Map<String, dynamic> autoUsageSummary = const {},
    List<Map<String, dynamic>> subTenantUsageSummary = const [],
    List<Map<String, dynamic>> manualUsageList = const [],
    List<Map<String, dynamic>> lineItemList = const [],
    billBarFromMonth,
    List<Map<String, dynamic>>? billedTrendingSnapShot,
    List<PagEmsTypeUsageCalc> singularUsageCalcList = const [],
    double? balBf,
    double? balBfUsage,
    double? balBfInterest,
  }) {
    if (usageFactor.isEmpty) {
      throw Exception('usageFactor is empty');
    }

    _costDecimals = costDecimals;

    _gst = gst;
    _typeRateInfo = typeRates;
    _usageFactor = usageFactor;

    _autoUsageSummary = autoUsageSummary;
    _subTenantUsageSummary = subTenantUsageSummary;
    _manualUsageList = manualUsageList;
    _lineItemList = lineItemList;
    _billBarFromMonth = billBarFromMonth;

    _billedTrendingSnapShot = billedTrendingSnapShot;

    _balBf = balBf;
    _balBfUsage = balBfUsage;
    _balBfInterest = balBfInterest;

    if (singularUsageCalcList.isNotEmpty) {
      for (var item in singularUsageCalcList) {
        _singularCalcList.add(item);
      }
    }
  }

  void doCalc() {
    _calcTypeUsage('E');
    _calcTypeUsage('W');
    _calcTypeUsage('B');
    _calcTypeUsage('N');
    _calcTypeUsage('G');

    _calcTotalCost();

    _sortSubTenantUsage();

    _getUsageTrending();
  }

  void doSingularCalc() {
    _calcTypeUsage('E');
    _calcTypeUsage('W');
    _calcTypeUsage('B');
    _calcTypeUsage('N');
    _calcTypeUsage('G');

    // _calcTotalCost();

    // _sortSubTenantUsage();

    // _getUsageTrending();
  }

  void doCompositeCalc() {
    _calcCompositeTypeUsage();
  }

  Map<String, dynamic>? getLineItem(int index) {
    int length = _lineItemList.length;
    if (index > length - 1) {
      return null;
    }

    Map<String, dynamic> lineItem = {};
    lineItem['label'] = _lineItemList[index]['label'];

    String amtStr = _lineItemList[index]['amount'];
    double? amt = double.tryParse(amtStr);
    if (amt != null) {
      amt = getRound(amt, _costDecimals);
      lineItem['amount'] = amt;
    } else {
      throw Exception('Invalid amount');
    }

    return lineItem;
  }

  double? getTypeUsageFactor(String typeTag) {
    return _usageFactor[typeTag];
  }

  void _sortSubTenantUsage() {
    for (var tenant in _subTenantUsageSummary) {
      final tenantUsageSummary = tenant['tenant_usage_summary'] ?? [];
      Map<String, dynamic> tenantUsageInfo = {
        'tenant_name': tenant['tenant_name'],
        'tenant_label': tenant['tenant_label'],
      };

      List<EmsTypeUsage> typeUsageList = [];
      for (var tenantUsage in tenantUsageSummary) {
        String usageType = tenantUsage['meter_type'].toUpperCase();

        final meterGroupUsageSummary =
            tenantUsage['meter_group_usage_summary'] ?? [];
        if (meterGroupUsageSummary.isNotEmpty) {
          List<Map<String, dynamic>> meterListUsageSummary = [];
          for (var mg in meterGroupUsageSummary['meter_list_usage_summary']) {
            meterListUsageSummary.add(mg);
          }
          double? subUsasgeTotal =
              _calcMeterGroupUsageTotal(meterListUsageSummary);
          double? subUsasgeTotalFactored;
          if (subUsasgeTotal != null) {
            subUsasgeTotalFactored = subUsasgeTotal * _usageFactor[usageType];
          }

          EmsTypeUsage typeUsage = EmsTypeUsage(
            typeTag: usageType,
            usage: subUsasgeTotal,
            usageFactored: subUsasgeTotalFactored,
            factor: _usageFactor[usageType],
            rate: _typeRateInfo[usageType],
            cost: subUsasgeTotalFactored == null ||
                    _typeRateInfo[usageType] == null
                ? null
                : subUsasgeTotalFactored * _typeRateInfo[usageType],
          );
          if (subUsasgeTotal != null) {
            typeUsageList.add(typeUsage);
          }
        }
      }
      tenantUsageInfo['type_usage_list'] = typeUsageList;
      _subTenantUsage.add(tenantUsageInfo);
    }
  }

  void _calcTypeUsage(String typeTag) {
    double? typeUsageTotal;
    double? typeUsageFactored;

    // auto usage
    double? typeAutoUsageTotal;
    final meterGroupUsageList =
        _autoUsageSummary['meter_group_usage_list'] ?? [];
    for (var item in meterGroupUsageList) {
      String? usageType = item['meter_type'].toUpperCase();
      if (usageType != typeTag) {
        continue;
      }
      final meterGroupUsageSummary = item['meter_group_usage_summary'] ?? [];
      if (meterGroupUsageSummary.isNotEmpty) {
        final meterUsageList = meterGroupUsageSummary['meter_usage_list'];
        List<Map<String, dynamic>> meterUsageSummaryList = [];
        for (var mg in meterUsageList) {
          meterUsageSummaryList.add(mg);
        }

        double? groupUsageTotal =
            _calcMeterGroupUsageTotal(meterUsageSummaryList);
        if (groupUsageTotal != null) {
          typeAutoUsageTotal ??= 0;
          typeAutoUsageTotal += groupUsageTotal;
        }
      }
    }

    double? typeSubTenantUsageTotal;
    for (var tenant in _subTenantUsageSummary) {
      final tenantUsageSummary = tenant['tenant_usage_summary'] ?? [];
      for (var tenantUsage in tenantUsageSummary) {
        String? usageType = tenantUsage['meter_type'].toUpperCase();
        if (usageType != typeTag) {
          continue;
        }
        final meterGroupUsageSummary =
            tenantUsage['meter_group_usage_summary'] ?? [];
        if (meterGroupUsageSummary.isNotEmpty) {
          List<Map<String, dynamic>> meterListUsageSummary = [];
          for (var mg in meterGroupUsageSummary['meter_list_usage_summary']) {
            meterListUsageSummary.add(mg);
          }
          double? subUsasgeTotal =
              _calcMeterGroupUsageTotal(meterListUsageSummary);
          if (subUsasgeTotal != null) {
            typeSubTenantUsageTotal ??= 0;
            typeSubTenantUsageTotal += subUsasgeTotal;
          }
        }
      }
    }

    double? typeManualUsageTotal;
    for (var item in _manualUsageList) {
      String? usageType = item['meter_type'].toUpperCase();
      if (usageType != typeTag) {
        continue;
      }

      double? manualUsageVal = item['usage'];
      if (manualUsageVal != null) {
        typeManualUsageTotal ??= 0;
        typeManualUsageTotal += manualUsageVal;
      }
    }

    if (typeAutoUsageTotal != null) {
      typeUsageTotal ??= 0;
      typeUsageTotal += typeAutoUsageTotal;

      // only apply sub tenant usage if auto usage is available
      if (typeSubTenantUsageTotal != null) {
        typeUsageTotal -= typeSubTenantUsageTotal;
      }

      // apply usage factor
      double usageFactor = _usageFactor[typeTag];
      typeUsageFactored = typeUsageTotal * usageFactor;
    }

    // apply manual usage
    // usage factor is not applied to manual usage
    if (typeManualUsageTotal != null) {
      typeUsageFactored ??= 0;
      // typeUsageTotal = typeUsageFactored + typeManualUsageTotal;
      typeUsageFactored = typeUsageFactored + typeManualUsageTotal;
      typeUsageTotal ??= typeUsageFactored;
    }

    EmsTypeUsageR2 emsTypeUsage = EmsTypeUsageR2(
      typeTag: typeTag,
      usage: typeUsageTotal,
      usageFactored: typeUsageFactored,
      factor: _usageFactor[typeTag],
      rate: _typeRateInfo[typeTag],
      // cost: typeUsageFactored == null || _typeRates[typeTag] == null
      //     ? null
      //     : typeUsageFactored * _typeRates[typeTag],
      costDecimals: _costDecimals,
    );

    switch (typeTag) {
      case 'E':
        _typeUsageE = emsTypeUsage;
        break;
      case 'W':
        _typeUsageW = emsTypeUsage;
        break;
      case 'B':
        _typeUsageB = emsTypeUsage;
        break;
      case 'N':
        _typeUsageN = emsTypeUsage;
        break;
      case 'G':
        _typeUsageG = emsTypeUsage;
        break;
    }
  }

  void _calcTotalCost() {
    double? subTotalCost;

    if (_typeUsageE?.hasCost() ?? false) {
      subTotalCost ??= 0;
      subTotalCost += _typeUsageE!.cost!;
    }
    if (_typeUsageW?.hasCost() ?? false) {
      subTotalCost ??= 0;
      subTotalCost += _typeUsageW!.cost!;
    }
    if (_typeUsageB?.hasCost() ?? false) {
      subTotalCost ??= 0;
      subTotalCost += _typeUsageB!.cost!;
    }
    if (_typeUsageN?.hasCost() ?? false) {
      subTotalCost ??= 0;
      subTotalCost += _typeUsageN!.cost!;
    }
    if (_typeUsageG?.hasCost() ?? false) {
      subTotalCost ??= 0;
      subTotalCost += _typeUsageG!.cost!;
    }

    for (var item in _lineItemList) {
      String? costStr = item['amount'];
      double? cost = double.tryParse(costStr ?? '');
      if (cost != null) {
        subTotalCost ??= 0;
        subTotalCost += cost;
      }
    }
    _subTotalCost = subTotalCost;
    if (_subTotalCost != null) {
      _subTotalCost = getRound(_subTotalCost!, 2);
      if (subTotalCost != null && _gst != null) {
        _gstAmount = subTotalCost * _gst / 100;
      }
      _gstAmount = getRoundUp(_gstAmount!, 2);
      _totalCost = _subTotalCost! + _gstAmount!;

      _totalCost = _totalCost! + _balBfUsage! + _balBfInterest!;
    }
  }

  void _calcCompositeTypeUsage() {
    double? compositeUsageE;
    double? compositeUsageW;
    double? compositeUsageB;
    double? compositeUsageN;
    double? compositeUsageG;
    double? compositeUsageFactoredE;
    double? compositeUsageFactoredW;
    double? compositeUsageFactoredB;
    double? compositeUsageFactoredN;
    double? compositeUsageFactoredG;
    double? compositeCostE;
    double? compositeCostW;
    double? compositeCostB;
    double? compositeCostN;
    double? compositeCostG;

    for (var singularCalc in _singularCalcList) {
      if (singularCalc.typeUsageE?.usage != null) {
        compositeUsageE ??= 0;
        compositeUsageE += singularCalc.typeUsageE!.usage!;
      }
      if (singularCalc.typeUsageW?.usage != null) {
        compositeUsageW ??= 0;
        compositeUsageW += singularCalc.typeUsageW!.usage!;
      }
      if (singularCalc.typeUsageB?.usage != null) {
        compositeUsageB ??= 0;
        compositeUsageB += singularCalc.typeUsageB!.usage!;
      }
      if (singularCalc.typeUsageN?.usage != null) {
        compositeUsageN ??= 0;
        compositeUsageN += singularCalc.typeUsageN!.usage!;
      }
      if (singularCalc.typeUsageG?.usage != null) {
        compositeUsageG ??= 0;
        compositeUsageG += singularCalc.typeUsageG!.usage!;
      }

      if (singularCalc.typeUsageE?.usageFactored != null) {
        compositeUsageFactoredE ??= 0;
        compositeUsageFactoredE += singularCalc.typeUsageE!.usageFactored!;
      }
      if (singularCalc.typeUsageW?.usageFactored != null) {
        compositeUsageFactoredW ??= 0;
        compositeUsageFactoredW += singularCalc.typeUsageW!.usageFactored!;
      }
      if (singularCalc.typeUsageB?.usageFactored != null) {
        compositeUsageFactoredB ??= 0;
        compositeUsageFactoredB += singularCalc.typeUsageB!.usageFactored!;
      }
      if (singularCalc.typeUsageN?.usageFactored != null) {
        compositeUsageFactoredN ??= 0;
        compositeUsageFactoredN += singularCalc.typeUsageN!.usageFactored!;
      }
      if (singularCalc.typeUsageG?.usageFactored != null) {
        compositeUsageFactoredG ??= 0;
        compositeUsageFactoredG += singularCalc.typeUsageG!.usageFactored!;
      }

      if (singularCalc.typeUsageE?.cost != null) {
        compositeCostE ??= 0;
        compositeCostE += singularCalc.typeUsageE!.cost!;
      }
      if (singularCalc.typeUsageW?.cost != null) {
        compositeCostW ??= 0;
        compositeCostW += singularCalc.typeUsageW!.cost!;
      }
      if (singularCalc.typeUsageB?.cost != null) {
        compositeCostB ??= 0;
        compositeCostB += singularCalc.typeUsageB!.cost!;
      }
      if (singularCalc.typeUsageN?.cost != null) {
        compositeCostN ??= 0;
        compositeCostN += singularCalc.typeUsageN!.cost!;
      }
      if (singularCalc.typeUsageG?.cost != null) {
        compositeCostG ??= 0;
        compositeCostG += singularCalc.typeUsageG!.cost!;
      }
    }

    _typeUsageE = EmsTypeUsageR2(
      typeTag: 'E',
      usage: compositeUsageE,
      usageFactored: compositeUsageFactoredE,
      factor: _usageFactor['E'],
      // rate: _typeRateInfo['E'],
      cost: compositeCostE,
      costDecimals: _costDecimals,
    );
    _typeUsageW = EmsTypeUsageR2(
      typeTag: 'W',
      usage: compositeUsageW,
      usageFactored: compositeUsageFactoredW,
      factor: _usageFactor['W'],
      // rate: _typeRateInfo['W'],
      cost: compositeCostW,
      costDecimals: _costDecimals,
    );
    _typeUsageB = EmsTypeUsageR2(
      typeTag: 'B',
      usage: compositeUsageB,
      usageFactored: compositeUsageFactoredB,
      factor: _usageFactor['B'],
      // rate: _typeRateInfo['B'],
      cost: compositeCostB,
      costDecimals: _costDecimals,
    );
    _typeUsageN = EmsTypeUsageR2(
      typeTag: 'N',
      usage: compositeUsageN,
      usageFactored: compositeUsageFactoredN,
      factor: _usageFactor['N'],
      // rate: _typeRateInfo['N'],
      cost: compositeCostN,
      costDecimals: _costDecimals,
    );
    _typeUsageG = EmsTypeUsageR2(
      typeTag: 'G',
      usage: compositeUsageG,
      usageFactored: compositeUsageFactoredG,
      factor: _usageFactor['G'],
      // rate: _typeRateInfo['G'],
      cost: compositeCostG,
      costDecimals: _costDecimals,
    );

    double? subTotalCost;

    for (var singularCalc in _singularCalcList) {
      if (singularCalc.typeUsageE?.hasCost() ?? false) {
        subTotalCost ??= 0;
        subTotalCost += singularCalc.typeUsageE!.cost!;
      }
      if (singularCalc.typeUsageW?.hasCost() ?? false) {
        subTotalCost ??= 0;
        subTotalCost += singularCalc.typeUsageW!.cost!;
      }
      if (singularCalc.typeUsageB?.hasCost() ?? false) {
        subTotalCost ??= 0;
        subTotalCost += singularCalc.typeUsageB!.cost!;
      }
      if (singularCalc.typeUsageN?.hasCost() ?? false) {
        subTotalCost ??= 0;
        subTotalCost += singularCalc.typeUsageN!.cost!;
      }
      if (singularCalc.typeUsageG?.hasCost() ?? false) {
        subTotalCost ??= 0;
        subTotalCost += singularCalc.typeUsageG!.cost!;
      }
    }

    _subTotalCost = subTotalCost;
    if (_subTotalCost != null) {
      _subTotalCost = getRound(_subTotalCost!, 2);
      if (subTotalCost != null && _gst != null) {
        _gstAmount = subTotalCost * _gst / 100;
      }
      _gstAmount = getRoundUp(_gstAmount!, 2);
      _totalCost = _subTotalCost! + _gstAmount!;
    }
  }

  double? _calcMeterGroupUsageTotal(
      List<Map<String, dynamic>> meterListUsageSummary) {
    double? usage;
    for (var meter in meterListUsageSummary) {
      final meterUsageSummary = meter['meter_usage_summary'];
      String usageStr = meterUsageSummary['usage'] ?? '';
      double? usageVal = double.tryParse(usageStr);
      String percentageStr = meterUsageSummary['percentage'];
      double? percentage = double.tryParse(percentageStr);

      if (usageVal != null) {
        usage ??= 0;

        if (percentage != null) {
          usage += usageVal * (percentage / 100);
        } else {
          usage += usageVal;
        }
      }
    }
    return usage;
  }

  void _getUsageTrending() {
    _getUsageTrendingReleased(_usageFactor);
    //   for (var item in _autoUsageSummary) {
    //     List<Map<String, dynamic>> conlidatedHistoryList = [];
    //     String meterType = item['meter_type'] ?? '';
    //     final mgTrendingSnapShot = item['meter_group_trending_snapshot'] ?? [];
    //     if (mgTrendingSnapShot.isEmpty) {
    //       continue;
    //     }
    //     final mgConsolidatedUsageHistory =
    //         mgTrendingSnapShot['meter_list_consolidated_usage_history'] ?? [];

    //     for (var meterHistory in mgConsolidatedUsageHistory) {
    //       String meterId = meterHistory['meter_id'];
    //       double percentage = meterHistory['percentage'];

    //       if (meterHistory['meter_usage_history'].isEmpty) {
    //         if (kDebugMode) {
    //           print('No history for meter $meterId');
    //         }
    //         continue;
    //       }

    //       for (var history in meterHistory['meter_usage_history']) {
    //         String consolidatedTimeLabel = history['consolidated_time_label'];

    //         if ((_billBarFromMonth ?? '').isNotEmpty) {
    //           if (!takeMonth(consolidatedTimeLabel, _billBarFromMonth!)) {
    //             continue;
    //           }
    //         }

    //         double? usage = double.tryParse(history['usage']);
    //         usage = usage == null ? 0 : usage * (percentage / 100);

    //         //check if the time label is already in the list
    //         bool isExist = false;
    //         for (var item in conlidatedHistoryList) {
    //           if (item['time'] == consolidatedTimeLabel) {
    //             isExist = true;
    //             break;
    //           }
    //         }
    //         if (!isExist) {
    //           conlidatedHistoryList.add({
    //             'time': consolidatedTimeLabel,
    //             'label': consolidatedTimeLabel,
    //             'value': usage,
    //           });
    //         } else {
    //           //add the consumption to the existing time label
    //           for (var item in conlidatedHistoryList) {
    //             if (item['time'] == consolidatedTimeLabel) {
    //               item['value'] += usage;
    //               break;
    //             }
    //           }
    //         }
    //       }
    //     }
    //     if (meterType == 'E') {
    //       _trendingE.clear();
    //       _trendingE.addAll(conlidatedHistoryList);
    //     } else if (meterType == 'W') {
    //       _trendingW.clear();
    //       _trendingW.addAll(conlidatedHistoryList);
    //     } else if (meterType == 'B') {
    //       _trendingB.clear();
    //       _trendingB.addAll(conlidatedHistoryList);
    //     } else if (meterType == 'N') {
    //       _trendingN.clear();
    //       _trendingN.addAll(conlidatedHistoryList);
    //     } else if (meterType == 'G') {
    //       _trendingG.clear();
    //       _trendingG.addAll(conlidatedHistoryList);
    //     }
    //   }
    // }
  }

  void _getUsageTrendingReleased(Map<String, dynamic> usageFactor) {
    if (_billedTrendingSnapShot == null) {
      return;
    }
    for (var item in _billedTrendingSnapShot) {
      if (item['billed_time_label'] == null) {
        continue;
      }
      double? billedTotalUsageE = item['billed_total_usage_e'];
      double? billedTotalUsageW = item['billed_total_usage_w'];
      double? billedTotalUsageB = item['billed_total_usage_b'];
      double? billedTotalUsageN = item['billed_total_usage_n'];
      double? billedTotalUsageG = item['billed_total_usage_g'];

      double? usageFactorE = usageFactor['E'];
      double? usageFactorW = usageFactor['W'];
      double? usageFactorB = usageFactor['B'];
      double? usageFactorN = usageFactor['N'];
      double? usageFactorG = usageFactor['G'];

      double? billedTotalUsageFactoredE;
      double? billedTotalUsageFactoredW;
      double? billedTotalUsageFactoredB;
      double? billedTotalUsageFactoredN;
      double? billedTotalUsageFactoredG;

      if (billedTotalUsageE != null && usageFactorE != null) {
        billedTotalUsageFactoredE = billedTotalUsageE * usageFactorE;
      }

      if (billedTotalUsageW != null && usageFactorW != null) {
        billedTotalUsageFactoredW = billedTotalUsageW * usageFactorW;
      }

      if (billedTotalUsageB != null && usageFactorB != null) {
        billedTotalUsageFactoredB = billedTotalUsageB * usageFactorB;
      }

      if (billedTotalUsageN != null && usageFactorN != null) {
        billedTotalUsageFactoredN = billedTotalUsageN * usageFactorN;
      }

      if (billedTotalUsageG != null && usageFactorG != null) {
        billedTotalUsageFactoredG = billedTotalUsageG * usageFactorG;
      }

      if (item['billed_time_label'] != null) {
        if (item['billed_time_label'].toString().contains('2024-01') ||
            item['billed_time_label'].toString().contains('2024-02') ||
            item['billed_time_label'].toString().contains('2024-03') ||
            item['billed_time_label'].toString().contains('2024-04')) {
          continue;
        }
      }
      if ((_billBarFromMonth ?? '').isNotEmpty) {
        String timeLabel = item['billed_time_label'];
        if (!takeMonth(timeLabel, _billBarFromMonth!)) {
          continue;
        }
      }

      if ((_billBarFromMonth ?? '').isNotEmpty) {
        String monthLabel = _billBarFromMonth!.substring(0, 7);
        if (item['billed_time_label'].toString().contains(monthLabel)) {
          continue;
        }
      }

      if (billedTotalUsageE != null) {
        _trendingE.add({
          'time': item['billed_time_label'],
          'label': item['billed_time_label'],
          'value': billedTotalUsageFactoredE,
        });
      }
      if (billedTotalUsageW != null) {
        _trendingW.add({
          'time': item['billed_time_label'],
          'label': item['billed_time_label'],
          'value': billedTotalUsageFactoredW,
        });
      }
      if (billedTotalUsageB != null) {
        _trendingB.add({
          'time': item['billed_time_label'],
          'label': item['billed_time_label'],
          'value': billedTotalUsageFactoredB,
        });
      }
      if (billedTotalUsageN != null) {
        _trendingN.add({
          'time': item['billed_time_label'],
          'label': item['billed_time_label'],
          'value': billedTotalUsageFactoredN,
        });
      }
      if (billedTotalUsageG != null) {
        _trendingG.add({
          'time': item['billed_time_label'],
          'label': item['billed_time_label'],
          'value': billedTotalUsageFactoredG,
        });
      }
    }
  }
}

bool takeMonth(String monthLabel, String billBarFrom) {
  //label is YYYY-MM
  //if monthLabel is greater than or equal to billBarFrom, return true
  List<String> monthLabelList = monthLabel.split('-');
  List<String> billBarFromList = billBarFrom.split('-');

  if (int.parse(monthLabelList[0]) > int.parse(billBarFromList[0])) {
    return true;
  } else if (int.parse(monthLabelList[0]) == int.parse(billBarFromList[0])) {
    if (int.parse(monthLabelList[1]) >= int.parse(billBarFromList[1])) {
      return true;
    }
  }
  return false;
}
