import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_summary/styles/color_helper.dart';
import 'package:flutter_summary/util/image_helper.dart';

class GridInfo {
  final String url;
  final String title;
  final String icon;
  final String subTitle;

  GridInfo({@required this.icon, @required this.url, @required this.title, @required this.subTitle});
}

class DelayBuildWidgetTestPage extends StatefulWidget {
  @override
  _DelayBuildWidgetTestPageState createState() => _DelayBuildWidgetTestPageState();
}

class _DelayBuildWidgetTestPageState extends State<DelayBuildWidgetTestPage> {
  List<GridInfo> dataList = [];
  List<String> imageUrls = [
    '2774198',
    '6194942',
    '2209382',
    '3614942',
    '1906802',
    '5193557',
    '6161317',
    '5859431',
    '6341566',
    '5484328',
    '4685127',
    '3206433',
    '4852349',
    '1376889',
    '5560899',
    '4987688',
    '5949511',
    '6126297',
    '3467152',
    '5707732',
    '5591661',
    '5727545',
    '4617820',
    '4333606',
    '5273001',
    '3673521',
    '5232105',
    '5722868',
    '5567002',
    '1669072',
    '6334707',
    '5716323',
    '6212297',
    '3220237',
    '5855535',
    '5272575',
    '6021588',
    '4000213',
    '5993563',
    '3402578',
    '6066993',
    '5390006',
    '3410287',
    '6070378',
    '6167767',
    '5968900',
    '1030934',
    '1683994',
    '6102555',
    '4468058',
    '5914166',
    '6291566',
  ];
  @override
  void initState() {
    super.initState();
    String content = '拉开就分开了拉萨附近都是六块腹肌饭撒的克己复礼看到撒酒疯黎噶搜ID股份分开那份礼物来自空间的佛i阿哥辣椒素的弗兰克为列宁格勒';
    Random random = Random();
    imageUrls.forEach((element) {
      int titleStart = random.nextInt(content.length - 5);
      int subTitleStart = random.nextInt(content.length - 5);
      dataList.add(
        GridInfo(
          icon: random.nextInt(9).toString(),
          subTitle: content.substring(titleStart, titleStart + random.nextInt(4) + 1),
          title: content.substring(subTitleStart, subTitleStart + random.nextInt(4) + 1),
          url:
              'https://images.pexels.com/photos/$element/pexels-photo-$element.jpeg?auto=compress&cs=tinysrgb&dpr=2&w=500',
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('延时构建小部件测试'),
        actions: [
          FlatButton(
            onPressed: () {},
            child: Text('刷新'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          itemCount: dataList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 0,
            mainAxisSpacing: 0,
            childAspectRatio: 0.8,
          ),
          itemBuilder: (_, index) {
            GridInfo info = dataList[index];
            return Padding(
              padding: const EdgeInsets.all(4),
              child: Column(
                children: [
                  Expanded(
                    child: 
                    // SizedBox(),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        children: [
                          Image.network(
                            info.url,
                            fit: BoxFit.contain,
                          ),
                          Text(
                            info.title + info.subTitle,
                            style: TextStyle(
                              fontSize: 13,
                              color: ColorHelper.Black153,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        info.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      Image.asset(ImageHelper.image('icon_${info.icon}.png'),width: 30,),
                      Spacer(),
                      Text(
                        info.subTitle,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class DelayBuildChild extends StatefulWidget {
  final Widget child;
  final Widget placeholder;
  const DelayBuildChild({Key key, this.child, this.placeholder}) : super(key: key);
  @override
  _DelayBuildChildState createState() => _DelayBuildChildState();
}

class _DelayBuildChildState extends State<DelayBuildChild> {
  RenderObject a;
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: widget.child,
    );
  }
}
