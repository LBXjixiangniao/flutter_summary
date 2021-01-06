import 'package:flutter/material.dart';

class GridInfo {
  final String url;
  final String title;
  final String subTitle;

  GridInfo({@required this.url, @required this.title, @required this.subTitle});
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

    imageUrls.forEach((element) {
      dataList.add(
        GridInfo(
          subTitle: '阿斯顿发',
          title: '大噶地方',
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          itemCount: dataList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.8,
          ),
          itemBuilder: (_, index) {
            GridInfo info = dataList[index];
            return Column(
              children: [
                Expanded(
                  child: Image.network(
                    info.url,
                    fit: BoxFit.cover,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      info.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    Text(
                      info.subTitle,
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
