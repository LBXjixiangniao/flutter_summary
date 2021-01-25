import 'package:flutter/material.dart';
import 'package:flutter_summary/main/performance/manager.dart/manager.dart';
import 'package:flutter_summary/main/performance/widgets/round_corners_image_provider.dart';
import 'package:flutter_summary/styles/color_helper.dart';
import 'package:flutter_summary/util/image_helper.dart';

import 'not_delay_build_widget.dart';

class RoundedCornderBuildPage extends NotDelayBuildWidget {
  @override
  _RoundedCornderBuildPageState createState() => _RoundedCornderBuildPageState();
}

class _RoundedCornderBuildPageState extends NotDelayBuildWidgetState {
  DelayBuildManager manager;
  DelayBuildManager managerTwo;
  DelayBuildManager managerThree;
  @override
  String get pageTitle => '延时build和延时layout和paint混合';

  @override
  void initState() {
    manager = DelayBuildManager(reverse: true);
    managerTwo = DelayBuildManager(reverse: true);
    managerThree = DelayBuildManager(reverse: true);
    managerTwo.dependentOn(manager);
    managerThree.dependentOn(managerTwo);
    super.initState();
  }

  @override
  Widget item(GridInfo info, {bool useRoundCornerImageProvider = false}) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: DelayBuildWidget(
        buildManager: manager,
        builder: (ctx) {
          return Column(
            children: [
              Expanded(
                child: DelayLayoutAndPaintChild(
                  height: itemHeight - 30,
                  width: itemWidth,
                  buildManager: managerTwo,
                  addRepaintBoundary: false,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DelayLayoutAndPaintChild(
                              height: 60,
                              width: 60,
                              buildManager: managerThree,
                            //   // child: ClipRRect(
                            //   //   borderRadius: BorderRadius.circular(8),
                            //   //   child: Image.network(
                            //   //     info.url,
                            //   //     fit: BoxFit.cover,
                            //   //     width: 60,
                            //   //     height: 60,
                            //   //     cacheWidth: 120,
                            //   //     cacheHeight: 120,
                            //   //   ),
                            //   // ),
                              child: Image(
                                image: RoundCornersNetworkImage(
                                  info.url,
                                  cornerRadius: 8,
                                  cornerColor: Colors.white,
                                  imageShowSize: Size(60, 60),
                                  cacheImageWidth: 120,
                                  cacheImageHeight: 120,
                                ),
                                fit: BoxFit.cover,
                                width: itemWidth,
                                height: itemHeight - 30,
                              ),
                            ),
                            Spacer(),
                            Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red[100],
                                    borderRadius: BorderRadius.circular(4),
                                    boxShadow: [BoxShadow(color: ColorHelper.DividerColor, spreadRadius: 1, blurRadius: 4)],
                                  ),
                                  child: Text(
                                    info.title,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: ColorHelper.Black153,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Container(
                                  width: 40,
                                  height: 40,
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.3),
                                    // color: Colors.orange,
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
                          ],
                        ),
                        Expanded(
                          child: LayoutBuilder(
                            builder: (_, constraints) {
                              return Row(
                                children: [
                                  Container(
                                    alignment: Alignment.center,
                                    width: constraints.maxHeight,
                                    height: constraints.maxHeight,
                                    decoration: BoxDecoration(
                                      color: Colors.yellow.withOpacity(0.5),
                                      // color: Colors.yellow,
                                      borderRadius: BorderRadius.circular(constraints.maxHeight / 2),
                                    ),
                                    child: Text(
                                      info.index.toString(),
                                    ),
                                  ),
                                  Image.asset(
                                    ImageHelper.image(
                                      'icon_a_${info.aboveIcon}.png',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        Row(
                          children: [
                            Column(
                              children: [
                                Text(
                                  info.title,
                                  style: TextStyle(fontSize: 12, color: Colors.green),
                                ),
                                Text(
                                  info.title,
                                  style: TextStyle(fontSize: 12, color: Colors.purple),
                                ),
                              ],
                            ),
                            Text(
                              info.subTitle,
                              style: TextStyle(fontSize: 14, color: Colors.black12),
                            ),
                          ],
                        ),
                        Text(
                          info.subTitle + info.title,
                          style: TextStyle(fontSize: 12, color: Colors.red[100]),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.3),
                            // color: Colors.orange,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: Colors.red,
                            ),
                          ),
                          child: Text(
                            info.subTitle + info.subTitle,
                            style: TextStyle(fontSize: 13, color: Colors.blue[100]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 30,
                child: Row(
                  children: [
                    Text(
                      info.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    Image.asset(
                      ImageHelper.image('icon_${info.icon}.png'),
                      width: 25,
                    ),
                    Spacer(),
                    Text(
                      info.subTitle,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
