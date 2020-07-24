import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_summary/dart_class/extension/Iterable_extension.dart';
part 'china_region_json.dart';

class ChinaRegionSelect extends StatefulWidget {
  final RegionModel initialProvince;
  final RegionModel initialCity;
  final RegionModel initialCounty;
  final void Function(RegionModel province, RegionModel city, RegionModel county) onSelected;
  const ChinaRegionSelect({Key key, this.initialProvince, this.initialCity, this.initialCounty, this.onSelected})
      : assert((initialProvince != null || initialCity == null) && (initialCity != null || initialCounty == null)),
        super(key: key);

  static show(
      {@required BuildContext ctx,
      bool isDismissible = false,
      RegionModel initialProvince,
      RegionModel initialCity,
      RegionModel initialCounty,
      void Function(RegionModel province, RegionModel city, RegionModel county) onSelected}) {
    showModalBottomSheet(
        isDismissible: isDismissible,
        context: ctx,
        builder: (_) {
          return ChinaRegionSelect(
            initialProvince: initialProvince,
            initialCity: initialCity,
            initialCounty: initialCounty,
            onSelected: onSelected,
          );
        });
  }

  @override
  _ChinaRegionSelectState createState() => _ChinaRegionSelectState();
}

class _ChinaRegionSelectState extends State<ChinaRegionSelect> {
  List<RegionModel> allProvince;
  List<RegionModel> pickerCity;
  List<RegionModel> pickerCounty;
  Map<String, List<RegionModel>> allCity;
  Map<String, List<RegionModel>> allCounty;

  RegionModel selectedProvince;
  RegionModel selectedCity;
  RegionModel selectedCounty;

  StateSetter cityRefresh;
  StateSetter countyRefresh;

  double itemExtent = 50;

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    await getAllProvince().then((value) => allProvince = value);
    await getAllCity().then((value) => allCity = value);
    await getAllCounty().then((value) => allCounty = value);
    selectedProvince = widget.initialProvince ?? allProvince.firstOrNull;
    if (selectedProvince != null) {
      pickerCity = allCity != null ? allCity[selectedProvince?.id] : null;
      selectedCity = widget.initialCity ?? pickerCity?.firstOrNull;
    }
    if (selectedCity != null) {
      pickerCounty = allCounty != null ? allCounty[selectedCity?.id] : null;
      selectedCounty = widget.initialCounty ?? pickerCounty?.firstOrNull;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: SizedBox(
          height: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                color: Colors.white,
                height: 40,
                child: Row(
                  children: <Widget>[
                    InkWell(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            '取消',
                            style: TextStyle(
                              // fontFamily: PingFangType.regular,
                              fontSize: 16,
                              // color: ColorHelper.Black153,
                            ),
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    Spacer(),
                    InkWell(
                      child: Center(
                        child: StatefulBuilder(builder: (_, __) {
                          return Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              '确定',
                              style: TextStyle(
                                // fontFamily: PingFangType.regular,
                                fontSize: 16,
                                // color: ColorHelper.ThemeColor,
                              ),
                            ),
                          );
                        }),
                      ),
                      onTap: () {
                        widget.onSelected?.call(selectedProvince, selectedCity, selectedCounty);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
              ),
              if (allProvince.isNotNullAndEmpty && allCity.isNotNullAndEmpty && allCounty.isNotNullAndEmpty)
                /////province
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: StatefulBuilder(
                          builder: (context, refresh) {
                            int initialIndex = 0;
                            if (selectedProvince != null) {
                              for (int i = 0; i < allProvince.notNullLength; i++) {
                                if (allProvince[i].id == selectedProvince.id) {
                                  initialIndex = i;
                                  break;
                                }
                              }
                            } else {
                              selectedProvince = allProvince.firstOrNull;
                            }

                            return CupertinoPicker(
                              scrollController: FixedExtentScrollController(initialItem: initialIndex),
                              itemExtent: itemExtent,
                              onSelectedItemChanged: (int value) {
                                selectedProvince = allProvince[value];
                                pickerCity = allCity != null ? allCity[selectedProvince?.id] : null;
                                selectedCity = pickerCity.firstOrNull;
                                pickerCounty = allCounty != null ? allCounty[selectedCity?.id] : null;
                                selectedCounty = pickerCounty.firstOrNull;
                                cityRefresh?.call(() {});
                                countyRefresh?.call(() {});
                              },
                              children: <Widget>[
                                ...(allProvince
                                        ?.map(
                                          (e) => Padding(
                                            padding: const EdgeInsets.only(left: 8),
                                            child: FittedBox(
                                              alignment: Alignment.center,
                                              fit: BoxFit.scaleDown,
                                              child: Text(e.name),
                                            ),
                                          ),
                                        )
                                        ?.toList() ??
                                    [])
                              ],
                            );
                          },
                        ),
                      ),
                      //////city
                      Expanded(
                        child: StatefulBuilder(
                          builder: (context, refresh) {
                            cityRefresh = refresh;
                            int initialIndex = 0;
                            if (selectedCity != null) {
                              for (int i = 0; i < pickerCity.notNullLength; i++) {
                                if (pickerCity[i].id == selectedCity.id) {
                                  initialIndex = i;
                                  break;
                                }
                              }
                            }
                            return CupertinoPicker(
                              key: ValueKey(selectedProvince.id),
                              scrollController: FixedExtentScrollController(initialItem: initialIndex),
                              itemExtent: itemExtent,
                              onSelectedItemChanged: (int value) {
                                selectedCity = pickerCity[value];
                                pickerCounty = allCounty != null ? allCounty[selectedCity?.id] : null;
                                selectedCounty = pickerCounty.firstOrNull;
                                countyRefresh?.call(() {});
                              },
                              children: <Widget>[
                                ...(pickerCity
                                        ?.map(
                                          (e) => Padding(
                                            padding: const EdgeInsets.only(left: 4, right: 4),
                                            child: FittedBox(
                                              alignment: Alignment.center,
                                              fit: BoxFit.scaleDown,
                                              child: Text(e.name),
                                            ),
                                          ),
                                        )
                                        ?.toList() ??
                                    [])
                              ],
                            );
                          },
                        ),
                      ),
                      ////county
                      Expanded(
                        child: StatefulBuilder(
                          builder: (context, refresh) {
                            countyRefresh = refresh;
                            List<RegionModel> countyList = allCounty != null ? allCounty[selectedCity.id] : null;
                            int initialIndex = 0;
                            if (selectedCounty != null) {
                              for (int i = 0; i < countyList.notNullLength; i++) {
                                if (countyList[i].id == selectedCounty.id) {
                                  initialIndex = i;
                                  break;
                                }
                              }
                            } else {
                              selectedCounty = countyList.firstOrNull;
                            }

                            return CupertinoPicker(
                              key: ValueKey(selectedCity.id),
                              scrollController: FixedExtentScrollController(initialItem: initialIndex),
                              itemExtent: itemExtent,
                              onSelectedItemChanged: (int value) {
                                selectedCounty = countyList[value];
                              },
                              children: <Widget>[
                                ...(countyList
                                        ?.map(
                                          (e) => Padding(
                                            padding: const EdgeInsets.only(right: 8),
                                            child: FittedBox(
                                              alignment: Alignment.center,
                                              fit: BoxFit.scaleDown,
                                              child: Text(e.name),
                                            ),
                                          ),
                                        )
                                        ?.toList() ??
                                    [])
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
