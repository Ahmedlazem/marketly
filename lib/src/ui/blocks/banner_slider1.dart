import 'package:app/src/models/app_state_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

import '../../models/blocks_model.dart';
import 'hex_color.dart';
import 'list_header.dart';

class BannerSlider1 extends StatefulWidget {
  final Block block;
  final Function onBannerClick;
  final String lang;
  //final AppStateModel model = AppStateModel();
  BannerSlider1({Key key, this.block, this.onBannerClick, this.lang})
      : super(key: key);
  @override
  _BannerSlider1State createState() => _BannerSlider1State();
}

class _BannerSlider1State extends State<BannerSlider1> {
  List<Child> newChildren = [];

  void getNewChildren() {
    newChildren.clear();
    final x = widget.block.children;
    x.forEach((e) {
      if ((e.description[0] + e.description[1]) == widget.lang) {
        newChildren.add(e);
      } else {
        return;
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getNewChildren();
  }

  @override
  Widget build(BuildContext context) {
    print(" new childrennnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn${newChildren}");

    Color bgColor = HexColor(widget.block.bgColor);
    return SliverPadding(
      padding: EdgeInsets.all(0.0),
      sliver: SliverList(
        delegate: SliverChildListDelegate(
          [
            ListHeader(block: widget.block),
            Container(
              color: Theme.of(context).brightness != Brightness.dark
                  ? bgColor
                  : Theme.of(context).canvasColor,
              height: widget.block.childHeight.toDouble() + 30,
              // padding: EdgeInsets.fromLTRB(double.parse(widget.block.paddingLeft.toString()),
              //   0.0,
              //   double.parse(widget.block.paddingRight
              //       .toString()),
              //   double.parse(widget.block.paddingBottom
              //       .toString()),
              // ),
              child: Swiper(


                itemBuilder: (BuildContext context, int index) {

                  return
                      //( widget.lang== x)?
                      InkWell(
                    splashColor:
                        HexColor(widget.block.bgColor).withOpacity(0.1),
                    onTap: () => widget.onBannerClick(newChildren[index]),
                    child: Container(
                      child: Column(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(widget.block.borderRadius)),
                              ),
                              elevation: widget.block.elevation.toDouble(),
                              clipBehavior: Clip.antiAlias,
                              child: CachedNetworkImage(
                                imageUrl: newChildren[index].image != null
                                    ? newChildren[index].image
                                    : '',
                                imageBuilder: (context, imageProvider) =>
                                    Ink.image(
                                  child: InkWell(
                                    splashColor: HexColor(widget.block.bgColor)
                                        .withOpacity(0.1),
                                    onTap: () => widget
                                        .onBannerClick(newChildren[index]),
                                  ),
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                                placeholder: (context, url) =>
                                    Container(color: Colors.black12),
                                errorWidget: (context, url, error) =>
                                    Container(color: Colors.black12),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Center(
                              child: new Text(
                                " ${newChildren[index].title}",
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2
                                    .copyWith(fontSize: 12),
                              ),
                            ),
                          ),
                          SizedBox(height: 10.0),
                        ],
                      ),
                    ),
                  );
                  //: Container();
                },
                itemCount: newChildren.length,
                pagination: SwiperPagination.rect,
                autoplay: true,
                containerHeight: widget.block.childHeight,
                viewportFraction: 0.8,
                scale: 0.9,
              ),
            )
          ],
        ),
      ),
    );
  }
}
