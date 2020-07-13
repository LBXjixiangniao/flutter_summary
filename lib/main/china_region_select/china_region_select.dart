import 'package:flutter/material.dart';
import 'package:flutter_summary/widgets/china_region/china_region_select.dart';
import 'package:flutter_summary/widgets/default_app_bar.dart';

class ChinaRegionSelectPage extends StatefulWidget {
  @override
  _ChinaRegionSelectState createState() => _ChinaRegionSelectState();
}

class _ChinaRegionSelectState extends State<ChinaRegionSelectPage> {
  RegionModel _province;
  RegionModel _city;
  RegionModel _county;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(titleText: '省市区选择封装',),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            ChinaRegionSelect.show(
              ctx: context,
              isDismissible: false,
              initialProvince: _province,
              initialCity: _city,
              initialCounty: _county,
              onSelected: (province, city, county) {
                setState(() {
                  _province = province;
                  _city = city;
                  _county = county;
                });
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            color: Colors.white,
            height: 52,
            child: Row(
              children: [
                Text(
                  '所在地区',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Text(
                    '${_province?.name},${_city?.name},${_county?.name}',
                    textAlign: TextAlign.right,
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                SizedBox(
                  width: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
