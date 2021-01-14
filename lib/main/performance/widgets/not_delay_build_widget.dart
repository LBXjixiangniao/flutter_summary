import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_summary/main/performance/widgets/round_corners_image_provider.dart';
import 'package:flutter_summary/styles/color_helper.dart';
import 'package:flutter_summary/util/image_helper.dart';

import 'delay_build_widget.dart';

class NotDelayBuildWidget extends StatefulWidget {
  @override
  NotDelayBuildWidgetState createState() => NotDelayBuildWidgetState();
}

class NotDelayBuildWidgetState extends State<NotDelayBuildWidget> {
  List<GridInfo> dataList = [];
  ScrollController _firstScrollController = ScrollController();
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
    '4621378',
    '5965972',
    '5913391',
    '5312333',
    '5101217',
    '5855527',
    '6061293',
    '5770047',
    '4558306',
    '2109762',
    '5913949',
    '6070129',
    '2886574',
    '6032603',
    '5615782',
    '5997712',
  ];
  @override
  void initState() {
    super.initState();
    String content = '拉开就分开了拉萨附近都是六块腹肌饭撒的克己复礼看到撒酒疯黎噶搜ID股份分开那份礼物来自空间的佛i阿哥辣椒素的弗兰克为列宁格勒';
    Random random = Random();
    int i = 0;
    imageUrls.forEach((element) {
      int titleStart = random.nextInt(content.length - 5);
      int subTitleStart = random.nextInt(content.length - 5);
      dataList.add(
        GridInfo(
          index: i,
          aboveIcon: random.nextInt(3).toString(),
          icon: random.nextInt(9).toString(),
          subTitle: content.substring(titleStart, titleStart + random.nextInt(4) + 1),
          title: content.substring(subTitleStart, subTitleStart + random.nextInt(4) + 1),
          url: 'https://images.pexels.com/photos/$element/pexels-photo-$element.jpeg?auto=compress&cs=tinysrgb&dpr=2&w=500',
        ),
      );
      i++;
    });
  }

  Widget pageBuild({ScrollController controller, Widget childBuilder(GridInfo info)}) {
    return GridView.builder(
      controller: controller,
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
                // child: SizedBox(),
                child: childBuilder(info),
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
                  Image.asset(
                    ImageHelper.image('icon_${info.icon}.png'),
                    width: 30,
                  ),
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
    );
  }

  Widget item(GridInfo info) {
    return LayoutBuilder(
      builder: (_, constraints) {
        return Stack(
          children: [
            Image(
              image: RoundCornersNetworkImage(
                info.url,
                cornerRadius: 30,
                cornerColor: Colors.white,
                showWidth: constraints.maxWidth,
                showHeight: constraints.maxHeight,
              ),
              fit: BoxFit.cover,
              width: constraints.maxWidth,
              height: constraints.maxHeight,
            ),
            Column(
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [BoxShadow(color: ColorHelper.DividerColor, spreadRadius: 1, blurRadius: 4)],
                      ),
                      child: Text(
                        info.title + info.subTitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: ColorHelper.Black153,
                        ),
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.yellow.withOpacity(0.5),
                      child: Text(
                        info.index.toString(),
                      ),
                    ),
                  ],
                ),
                Image.asset(
                  ImageHelper.image(
                    'icon_a_${info.aboveIcon}.png',
                  ),
                  width: 35,
                ),
                Row(
                  children: [
                    Column(
                      children: [
                        Text(
                          info.title,
                          style: TextStyle(fontSize: 16, color: Colors.green),
                        ),
                        Text(
                          info.title,
                          style: TextStyle(fontSize: 16, color: Colors.purple),
                        ),
                      ],
                    ),
                    Text(
                      info.subTitle,
                      style: TextStyle(fontSize: 14, color: Colors.black12),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Colors.red,
                        ),
                      ),
                      child: Image.asset(
                        ImageHelper.image(
                          'icon_a_${info.aboveIcon}.png',
                        ),
                        width: 20,
                      ),
                    ),
                  ],
                ),
                Text(
                  info.subTitle + info.title,
                  style: TextStyle(fontSize: 18, color: Colors.yellow[100]),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Colors.red,
                    ),
                  ),
                  child: Text(
                    info.subTitle + info.title + info.subTitle,
                    style: TextStyle(fontSize: 13, color: Colors.blue[100]),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  String get pageTitle => '非延时构建小部件测试';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle),
        actions: [
          FlatButton(
            onPressed: () {
              // setState(() {

              // });
              ScrollController scrollController = _firstScrollController;
              if (scrollController.offset > 100) {
                scrollController.animateTo(0, duration: Duration(milliseconds: 2000), curve: Curves.linear);
              } else {
                scrollController.animateTo(7000, duration: Duration(milliseconds: 2000), curve: Curves.linear);
              }
            },
            child: Text('刷新'),
          ),
        ],
      ),
      body: pageBuild(
        controller: _firstScrollController,
        childBuilder: (info) {
          return item(info);
        },
      ),
    );
  }
}
