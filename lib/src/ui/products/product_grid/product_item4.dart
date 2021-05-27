import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import './../../../layout/adaptive.dart';
import './../../../layout/text_scale.dart';
import './../../../ui/products/product_grid/product_item.dart';
import '../../../models/app_state_model.dart';
import '../../../models/product_model.dart';
import '../../../ui/accounts/login/login.dart';
import '../../../ui/products/product_detail/product_detail.dart';
import 'package:app/src/ui/products/product_grid/products_widgets/add_to_cart_new.dart';
import 'package:app/src/models/category_model.dart';
double desktopCategoryMenuPageWidth({
  BuildContext context,
}) {
  return 232 * reducedTextScale(context);
}

class ProductGrid extends StatefulWidget {
  final List<Product> products;
  final String catName;
  const ProductGrid({Key key, this.products, this.catName}) : super(key: key);
  @override
  _ProductGridState createState() => _ProductGridState();
}

class _ProductGridState extends State<ProductGrid> {

  @override
  Widget build(BuildContext context) {

    final bool isDesktop = isDisplayDesktop(context);

    final containerWidth = isDesktop ? MediaQuery.of(context).size.width : MediaQuery.of(context).size.width;

    final crossAxisCount = containerWidth ~/ (isDesktop ? 200 : 180);

    final childAspectRatio = (containerWidth / (crossAxisCount * 16)) / ((containerWidth / (crossAxisCount * 16)) * 1.7);

    return SliverPadding(
      padding: const EdgeInsets.all(8.0),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
          childAspectRatio: childAspectRatio,
          crossAxisCount: crossAxisCount,
        ),
        delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
            return ProductItem(crossAxisCount: crossAxisCount, containerWidth: containerWidth,
                product: widget.products[index],category: widget.catName,);
          },
          childCount: widget.products.length,
        ),
      ),
    );
  }
}

class ProductItem extends StatefulWidget {

  final Product product;
  final crossAxisCount;
  final containerWidth;
  /// to add cat in product
  final String category;

  ProductItem({
    Key key,
    this.product,
    this.crossAxisCount,
    this.containerWidth, this.category
  }) : super(key: key);

  @override
  _ProductItemState createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  final appStateModel = AppStateModel();

  var isLoading = false;

  @override
  Widget build(BuildContext context) {
   // print(" product vendor is close closeeeeeeeeeeeeeeeeeeeee ${widget.product.vendor.is_close}");
    // print(widget.product.vendor.name );
    // print(widget.product.vendor.id);
   // print(widget.product.categories);



    int percentOff = 0;

    if ((widget.product.salePrice != null && widget.product.salePrice != 0)) {
      percentOff = (((widget.product.regularPrice - widget.product.salePrice) / widget.product.regularPrice) * 100).round();
    }
    bool onSale = false;

    if(widget.product.salePrice != 0) {
      onSale = true;
    }

    return Container(
      child: ScopedModelDescendant<AppStateModel>(builder: (context, child, model) {
        return Card(
          margin: EdgeInsets.all(0),
          elevation: 10.0,
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(
              Radius.circular(15.0),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            splashColor: Theme.of(context).splashColor.withOpacity(0.1),
            onTap: widget.product.vendor.is_close == false ? () {
              onProductClick(widget.product,widget.category         );
            } :(){},
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  height: widget.containerWidth/widget.crossAxisCount,
                  child: Stack(
                    children: <Widget>[
                      CachedNetworkImage(
                        imageUrl: widget.product.images[0].src,
                        imageBuilder: (context, imageProvider) => Ink.image(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                        placeholder: (context, url) => Container(
                          color: Theme.of(context).focusColor.withOpacity(0.02),
                        ),
                        errorWidget: (context, url, error) => Container(color: Theme.of(context).focusColor.withOpacity(1)),
                      ),
                      // Positioned(
                      //     top:5 ,
                      //     left: 0,
                      //    child:
                      //   widget.product.vendor.isClose ? Icon(Icons.lock_clock ,color:Theme.of(context).errorColor ,) : Icon(Icons.lock_open ,color:Theme.of(context).errorColor ,) ,
                      // ),
                      widget.product.vendor.is_close? Center(child: CircleAvatar(radius: 28,backgroundColor:Colors.white.withOpacity(0.4) ,
                          child: Icon(Icons.lock_clock,color: Theme.of(context).errorColor,size: 50,))): Container(),
                      Positioned(
                        //left: 10.0,
                        bottom: 0.0,
                        child:   Container(
                          width: 300,
                          padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                          height: 50,
                          //margin: EdgeInsets.only(bottom: 8, right:25, left: 25),
                          color: Colors.black12.withOpacity(0.3),
                          child: SizedBox(
                            child: Row(
                              mainAxisSize:MainAxisSize.min,

                             // mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                widget.product.vendor.icon!= null ? CircleAvatar(
                                  backgroundImage: CachedNetworkImageProvider(widget.product.vendor.icon),
                                  backgroundColor: Colors.black12,
                                ) : CircleAvatar(
                                  //TODO ADD AssetImage as placeholder
                                  backgroundImage: CachedNetworkImageProvider(widget.product.vendor.icon),
                                  backgroundColor: Colors.black12,
                                ),
                                SizedBox(
                                  width: 10.0,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      child: Center(
                                        child: Container(
                                          width: 100,
                                          child: new Text(widget.product.vendor.name,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: new TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.0,
                                                color: Colors.white,
                                              )),
                                        ),
                                      ),
                                    ),

                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0.0,
                        right: 0.0,
                        child: IconButton(
                            icon: model.wishListIds.contains(widget.product.id) ? Icon(Icons.favorite, color: Theme.of(context).accentColor) :
                            Icon(Icons.favorite_border, color: Colors.black87),
                            onPressed: () {
                              if (!model.loggedIn) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            Login()));
                              } else {
                                model.updateWishList(widget.product.id);
                              }
                            }
                        ),
                      ),
                      percentOff != 1 ? Positioned(
                        left: 0.0,
                        top: 0.0,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(bottomRight: Radius.circular(4.0)),
                          ),
                          clipBehavior: Clip.antiAlias,
                          elevation: 0.0,
                          margin: EdgeInsets.all(0.0),
                          color: Theme.of(context).accentColor,
                          child: percentOff != 0 ? Center(
                            child: Container(
                              padding: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                              child: Text('-'+percentOff.toString() + '%', style: Theme.of(context).accentTextTheme.bodyText1.copyWith(
                                  fontSize: 12.0
                              ),),
                            ),

                          ) : Container(),
                        ),
                      ) : Container()
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.fromLTRB(6.0, 10, 6, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        widget.product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                          color: Theme.of(context).textTheme.bodyText2.color.withOpacity(0.6),
                        ),
                      ),
                      SizedBox(height: 6.0),
                      Container(alignment: Alignment.topLeft, child: PriceWidget(onSale: onSale, product: widget.product)),
                      SizedBox(height: 8.0),
                      ScopedModelDescendant<AppStateModel>(
                          builder: (context, child, model) {
                            return AddToCart(model: model,
                              product: widget.product,
                            );
                          }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
      ),
    );
  }
  onProductClick(Product product , String catName) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ProductDetail(product: product, catName:catName);
    }));
  }
}

