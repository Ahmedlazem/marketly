import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import '../../../ui/products/product_grid/products_widgets/product_addons.dart';
import '../reviews/reviewDetail.dart';
import '../reviews/write_review.dart';
import '../reviews/review_list.dart';
import '../../../ui/checkout/cart/cart4.dart';
import '../../../functions.dart';
import './../product_grid/products_widgets/add_button_detail.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_icons/flutter_icons.dart';
import '../../../blocs/vendor/vendor_detail_state_model.dart';
import '../../vendor/ui/products/vendor_detail/vendor_detail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:share/share.dart';
import '../../../models/app_state_model.dart';
import '../../accounts/login/login.dart';
import '../../../models/releated_products.dart';
import '../../../models/review_model.dart';
import '../../../blocs/product_detail_bloc.dart';
import '../../../models/product_model.dart';
import '../product_grid/products_scroll.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'gallery_view.dart';
import '../../../models/vendor/store_model.dart';
import 'package:app/src/models/category_model.dart';
import 'package:app/src/ui/products/products.dart';

double expandedAppBarHeight = 350;

class ProductDetail1 extends StatefulWidget {
  final ProductDetailBloc productDetailBloc = ProductDetailBloc();
  Product product;
  String catName;
  final vendorDetailsBloc = VendorDetailStateModel();
  AppStateModel appStateModel = AppStateModel();

  ProductDetail1({this.product ,this.catName});

  @override
  _ProductDetail1State createState() => _ProductDetail1State();
}

class _ProductDetail1State extends State<ProductDetail1> {
  Map<String, dynamic> addOnsFormData = Map<String, dynamic>();
  final addonFormKey = GlobalKey<FormState>();

  var saved;
  ScrollController _scrollController = new ScrollController();

  List<ReviewModel> reviews;
  bool _visible = false;
  int _quantity = 1;

  var addingToCart = false;

  bool lastStatus = true;

  _scrollListener() {
    if (isShrink != lastStatus) {
      setState(() {
        lastStatus = isShrink;
      });
    }
  }

  bool get isShrink {
    return _scrollController.hasClients &&
        _scrollController.offset > (350 - kToolbarHeight);
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    if (widget.product.description == null) {
      getProduct();
    }
    widget.productDetailBloc.getProductsDetails(widget.product.id);
    widget.productDetailBloc.getReviews(widget.product.id);
  }

  Future<void> addToCart(BuildContext context) async {
    setState(() {
      addingToCart = true;
    });
    var data = new Map<String, dynamic>();
    data['product_id'] = widget.product.id.toString();
    data['quantity'] = _quantity.toString();
    var doAdd = true;
    if (widget.product.type == 'variable' &&
        widget.product.variationOptions != null) {
      for (var i = 0; i < widget.product.variationOptions.length; i++) {
        if (widget.product.variationOptions[i].selected != null) {
          data['variation[attribute_' +
              widget.product.variationOptions[i].attribute +
              ']'] = widget.product.variationOptions[i].selected;
        } else if (widget.product.variationOptions[i].selected == null &&
            widget.product.variationOptions[i].options.length != 0) {
          Fluttertoast.showToast(
              msg: widget.appStateModel.blocks.localeText.select +
                  ' ' +
                  widget.product.variationOptions[i].name);
          doAdd = false;
          break;
        } else if (widget.product.variationOptions[i].selected == null &&
            widget.product.variationOptions[i].options.length == 0) {
          setState(() {
            widget.product.stockStatus = 'outofstock';
          });
          doAdd = false;
          break;
        }
      }
      if (widget.product.variationId != null) {
        data['variation_id'] = widget.product.variationId;
      }
    }
    if (doAdd) {
      if (addonFormKey != null && addonFormKey.currentState.validate()) {
        addonFormKey.currentState.save();
        data.addAll(addOnsFormData);
      }
      await widget.appStateModel.addToCart(data);
    }
    setState(() {
      addingToCart = false;
    });
  }

  @override
  Widget build(BuildContext context) {
print(' product iddddddddddddddddddddddddddddddddddd     ${widget.product.id}');
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: widget.product.description != null
          ? buildBody()
          : CustomScrollView(
              slivers: <Widget>[
                _buildDBackgroundImage(),
                _buildDBackgroundCircleIndicator()
              ],
            ),
    );
  }

  List<Widget> buildSliverList() {
    List<Widget> list = new List<Widget>();
    list.add(_buildProductImages());
    list.add(buildNamePrice());

    list.add(ProductAddons(
        product: widget.product,
        addOnsFormData: addOnsFormData,
        addonFormKey: addonFormKey));
    /*if (widget.product.vendor?.name != null &&
        widget.product.vendor?.icon != null) list.add(buildStore());
    if (widget.product.availableVariations != null &&
        widget.product.availableVariations?.length != 0) {
      for (var i = 0; i < widget.product.variationOptions.length; i++) {
        if (widget.product.variationOptions[i].options.length != 0) {
          list.add(buildOptionHeader(widget.product.variationOptions[i].name));
          list.add(buildProductVariations(widget.product.variationOptions[i]));
        }
      }
    }*/
    //list.add(buildProductDetail());
    list.add(buildProductSortDescriptoion());
    list.add(buildProductDescriptoion());
    //list.add(buildCatInfo() );
    list.add(buildVendorInfo());

    list.add(buildLisOfReleatedProducts());
    list.add(buildLisOfCrossSellProducts());
    list.add(buildLisOfUpSellProducts());
    list.add(buildWriteYourReview());
    list.add(ReviewList(productDetailBloc: widget.productDetailBloc));
    return list;
  }
  /// categories info
  // Widget buildCatInfo() {
  //
  //   return SliverList(
  //       delegate: SliverChildListDelegate([
  //       // Container(
  //       //
  //       // width:  100,
  //       // child: Column(
  //       //   children: <Widget>[
  //       //     Card(
  //       //         shape: StadiumBorder(),
  //       //         //margin: EdgeInsets.all(0.0),
  //       //         clipBehavior: Clip.antiAlias,
  //       //         elevation: 2,
  //       //         child: InkWell(
  //       //          //splashColor: HexColor(widget.block.bgColor).withOpacity(0.1),
  //       //          // onTap: () => widget.onCategoryClick(categories[index], widget.categories),
  //       //           child: Column(
  //       //             crossAxisAlignment: CrossAxisAlignment.center,
  //       //             children: <Widget>[
  //       //               AspectRatio(
  //       //                   aspectRatio: 1,
  //       //                   child: widget.catName.image != null ? CachedNetworkImage(
  //       //                     imageUrl: categories[index].image,
  //       //                     imageBuilder: (context, imageProvider) => Ink.image(
  //       //                       child: InkWell(
  //       //                         splashColor: HexColor(widget.block.bgColor).withOpacity(0.1),
  //       //                         onTap: () => widget.onCategoryClick(categories[index], widget.categories),
  //       //                       ),
  //       //                       image: imageProvider,
  //       //                       fit: BoxFit.cover,
  //       //                     ),
  //       //                     placeholder: (context, url) =>
  //       //                         Container(color: HexColor(widget.block.bgColor).withOpacity(0.5)),
  //       //                     errorWidget: (context, url, error) => Container(color: Colors.white),
  //       //                   )  : Container(color: Colors.white)
  //       //               ),
  //       //             ],
  //       //           ),
  //       //         )),
  //       //     Padding(
  //       //       padding: const EdgeInsets.all(8.0),
  //       //       child: new Text(
  //       //         parseHtmlString(categories[index].name),
  //       //         maxLines: 1,
  //       //         overflow: TextOverflow.ellipsis,
  //       //         textAlign: TextAlign.center,
  //       //         style: Theme.of(context).textTheme.bodyText2,
  //       //       ),
  //       //     ),
  //       //   ],
  //       // )),
  //         Wrap(
  //           children: <Widget>[
  //             Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: <Widget>[
  //                 Container(
  //                   height: 50,
  //                   child: Padding(
  //                     padding: const EdgeInsets.all(8.0),
  //                     child:     GestureDetector(
  //                       onTap: () {
  //                         Navigator.push(
  //                             context,
  //                             MaterialPageRoute(
  //                                 builder: (context) =>
  //                                     ProductsWidget(filter: widget.product.categories.whereType().where((element) =>element.), name: widget.catName)));
  //                       },
  //                       child: Row(
  //                         children: <Widget>[
  //                           widget.product.vendor.icon != null
  //                               ? CircleAvatar(radius: 50,
  //                             backgroundImage: CachedNetworkImageProvider(
  //                                 widget.product.vendor.icon),
  //                             backgroundColor: Colors.black12,
  //                           )
  //                               :Container(),
  //                           // : CircleAvatar(
  //                           //     //TODO ADD AssetImage as placeholder
  //                           //     backgroundImage: CachedNetworkImageProvider(
  //                           //         widget.product.vendor.icon),
  //                           //     backgroundColor: Colors.black12,radius:50,
  //                           //   ),
  //                           SizedBox(
  //                             width: 15.0,
  //                           ),
  //                           Container(
  //
  //                             child: new Text(widget.product.vendor.name,
  //                                 maxLines: 1,
  //                                 overflow: TextOverflow.ellipsis,
  //                                 style: new TextStyle(
  //                                   fontWeight: FontWeight.bold,
  //                                   fontSize: 20.0,
  //                                   color: Colors.black,
  //                                 )),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //                 Container(
  //                   padding: const EdgeInsets.fromLTRB(6.0, 10, 6, 4),
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     mainAxisSize: MainAxisSize.min,
  //                     children: <Widget>[
  //
  //
  //                       //AddToCart(model: model, product: widget.product,)
  //                     ],
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ]));
  // }
  Widget buildVendorInfo() {
    return SliverList(
        delegate: SliverChildListDelegate([
      Wrap(
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                height: 100,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child:     GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                            return VendorDetails(
                              vendorId: widget.product.vendor.id.toString(),
                            );
                          }));
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        widget.product.vendor.icon != null
                            ? CircleAvatar(radius: 50,
                                backgroundImage: CachedNetworkImageProvider(
                                    widget.product.vendor.icon),
                                backgroundColor: Colors.black12,
                              )
                        :Container(),
                            // : CircleAvatar(
                            //     //TODO ADD AssetImage as placeholder
                            //     backgroundImage: CachedNetworkImageProvider(
                            //         widget.product.vendor.icon),
                            //     backgroundColor: Colors.black12,radius:50,
                            //   ),
                        SizedBox(
                          width: 15.0,
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(

                                child: new Text(widget.product.vendor.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: new TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.0,
                                      color: Colors.black,
                                    )),
                              ),
                              SizedBox(
                                width: 15.0,
                              ),
                              Text(
                                widget.catName.toString(),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: Theme.of(context).textTheme.bodyText2.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyText2
                                      .color
                                      .withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
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
                            color: Theme.of(context)
                                .textTheme
                                .bodyText2
                                .color
                                .withOpacity(0.6),
                          ),
                    ),

                    //AddToCart(model: model, product: widget.product,)
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ]));
  }

  Widget buildNamePrice() {
    bool onSale = false;

    if (widget.product.salePrice != null && widget.product.salePrice != 0) {
      onSale = true;
    }

    return SliverList(
        delegate: SliverChildListDelegate([
      Wrap(
        children: <Widget>[
          Container(
              padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0,10.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        widget.product.stockStatus == 'outofstock'
                            ? Text(
                                widget
                                    .appStateModel.blocks.localeText.outOfStock,
                                style: TextStyle(
                                  color: Colors.red[900],
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              )
                            : Text(
                                widget.appStateModel.blocks.localeText.inStock,
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            // color: Colors.orangeAccent.withOpacity(0.08),
                          ),
                          child: ScopedModelDescendant<AppStateModel>(
                              builder: (context, child, model) {
                            return IconButton(
                              onPressed: () {
                                if (!model.loggedIn) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Login()));
                                } else {
                                  model.updateWishList(widget.product.id);
                                }
                              },
                              icon:
                                  model.wishListIds.contains(widget.product.id)
                                      ? Icon(
                                          Icons.favorite,
                                        )
                                      : Icon(
                                          Icons.favorite_border,
                                        ),
                            );
                          }),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      widget.product.name,
                      maxLines: 3,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          fontFamily: 'Lexend_Deca'),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: <Widget>[
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                (widget.product.formattedSalesPrice != null &&
                                        widget.product.formattedSalesPrice
                                            .isNotEmpty)
                                    ? parseHtmlString(
                                        widget.product.formattedSalesPrice)
                                    : '',
                                style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 20,
                                    fontFamily: 'Lexend_Deca'),
                              ),
                              widget.product.onSale
                                  ? SizedBox(width: 6)
                                  : SizedBox(width: 0),
                              Text(
                                (widget.product.formattedPrice != null &&
                                        widget
                                            .product.formattedPrice.isNotEmpty)
                                    ? parseHtmlString(
                                        widget.product.formattedPrice)
                                    : '',
                                style: TextStyle(
                                  fontFamily: 'Lexend_Deca',
                                  fontWeight: onSale
                                      ? FontWeight.w400
                                      : FontWeight.w900,
                                  fontSize: onSale ? 16 : 20,
                                  color: onSale
                                      ? Theme.of(context).hintColor
                                      : Theme.of(context)
                                          .textTheme
                                          .bodyText1
                                          .color,
                                  decoration: onSale
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(),

                    /*Expanded(
                      child: Container(
                          child:  StreamBuilder<VendorDetailsModel>(
                              stream: widget.vendorDetailsBloc.allVendorDetails,
                              builder: (context, AsyncSnapshot<VendorDetailsModel> snapshot) {
                                return buildStore(snapshot, context);
                              }
                          )

                      ),
                    )*/
                  ])),
        ],
      ),
    ]));
  }

  Widget buildLisOfReleatedProducts() {
    String title =
        widget.appStateModel.blocks.localeText.relatedProducts.toUpperCase();
    return StreamBuilder<ReleatedProductsModel>(
        stream: widget.productDetailBloc.relatedProducts,
        builder: (context, AsyncSnapshot<ReleatedProductsModel> snapshot) {
          if (snapshot.hasData) {
            return ProductScroll(
                products: snapshot.data.relatedProducts,
                context: context,
                title: title);
          } else {
            return SliverToBoxAdapter();
          }
        });
  }

  Widget buildLisOfCrossSellProducts() {
    String title =
        widget.appStateModel.blocks.localeText.justForYou.toUpperCase();
    return StreamBuilder<ReleatedProductsModel>(
        stream: widget.productDetailBloc.relatedProducts,
        builder: (context, AsyncSnapshot<ReleatedProductsModel> snapshot) {
          if (snapshot.hasData) {
            return ProductScroll(
                products: snapshot.data.crossProducts,
                context: context,
                title: title);
          } else {
            return SliverToBoxAdapter();
          }
        });
  }

  Widget buildLisOfUpSellProducts() {
    String title =
        widget.appStateModel.blocks.localeText.youMayAlsoLike.toUpperCase();
    return StreamBuilder<ReleatedProductsModel>(
        stream: widget.productDetailBloc.relatedProducts,
        builder: (context, AsyncSnapshot<ReleatedProductsModel> snapshot) {
          if (snapshot.hasData) {
            return ProductScroll(
                products: snapshot.data.upsellProducts,
                context: context,
                title: title);
          } else {
            return SliverToBoxAdapter();
          }
        });
  }

  onProductClick(data) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ProductDetail1(product: data);
    }));
  }

  _buildProductImages() {
    return SliverAppBar(
      iconTheme: IconThemeData(
        color:
            isShrink ? Theme.of(context).primaryIconTheme.color : Colors.black,
      ),
      floating: false,
      pinned: true,
      snap: false,
      actions: <Widget>[
        IconButton(
            icon: Icon(
              FlutterIcons.share_fea,
              semanticLabel: 'Share',
              color: isShrink
                  ? Theme.of(context).primaryIconTheme.color
                  : Colors.black,
            ),
            onPressed: () {
              Share.share('check out product ' + widget.product.permalink);
            }),
      ],
      expandedHeight: expandedAppBarHeight,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
            padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
            child: InkWell(
              onTap: () => null,
              child: Swiper(
                //control: new SwiperControl(),
                //viewportFraction: 0.8,
                //scale: 0.9,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    splashColor: Theme.of(context).hintColor,
                    onTap: () => null,
                    child: Card(
                      margin: EdgeInsets.all(0.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(0.0)),
                      ),
                      elevation: 0.0,
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: [
                          CachedNetworkImage(
                            imageUrl: widget.product.images[index].src,
                            imageBuilder: (context, imageProvider) => Ink.image(
                              child: InkWell(
                                splashColor: Theme.of(context).hintColor,
                                onTap: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return GalleryView(
                                        images: widget.product.images);
                                  }));
                                },
                              ),
                              image: imageProvider,
                              fit: BoxFit.contain,
                            ),
                            placeholder: (context, url) =>
                                Container(color: Colors.black12),
                            errorWidget: (context, url, error) =>
                                Container(color: Colors.black12),
                          ),
                          Positioned(
                            bottom: 20,
                            child: Container(
                              margin:EdgeInsets.all(5.0),
                              padding: EdgeInsets.all(10.0),
                              child: Row(
                                children: <Widget>[
                                  widget.product.vendor.icon != null
                                      ? CircleAvatar(
                                    radius: 30,
                                          backgroundImage:
                                              CachedNetworkImageProvider(
                                                  widget.product.vendor.icon),
                                          backgroundColor: Colors.black12,
                                        )
                                      : CircleAvatar(
                                          //TODO ADD AssetImage as placeholder
                                          backgroundImage:
                                              CachedNetworkImageProvider(
                                                  widget.product.vendor.icon),
                                          backgroundColor: Colors.white,
                                        ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    width: 340,
                                    child: new Text(widget.product.vendor.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: new TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20.0,
                                          color: Colors.white,
                                        )),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                itemCount: widget.product.images.length,
                pagination: new SwiperPagination(),
                autoplay: true,
              ),
            )),
      ),
    );
  }

  buildProductVariations(VariationOption variationOption) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 10.0),
      sliver: SliverGrid(
        gridDelegate: new SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 80.0,
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
          childAspectRatio: 3,
        ),
        delegate: new SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            return InkWell(
              onTap: () {
                setState(() {
                  variationOption.selected = variationOption.options[index];
                  widget.product.stockStatus = 'instock';
                });
                if (widget.product.variationOptions
                    .every((option) => option.selected != null)) {
                  var selectedOptions = new List<String>();
                  var matchedOptions = new List<String>();
                  for (var i = 0;
                      i < widget.product.variationOptions.length;
                      i++) {
                    selectedOptions
                        .add(widget.product.variationOptions[i].selected);
                  }
                  for (var i = 0;
                      i < widget.product.availableVariations.length;
                      i++) {
                    matchedOptions = new List<String>();
                    for (var j = 0;
                        j < widget.product.availableVariations[i].option.length;
                        j++) {
                      if (selectedOptions.contains(widget.product
                              .availableVariations[i].option[j].value) ||
                          widget.product.availableVariations[i].option[j].value
                              .isEmpty) {
                        matchedOptions.add(widget
                            .product.availableVariations[i].option[j].value);
                      }
                    }
                    if (matchedOptions.length == selectedOptions.length) {
                      setState(() {
                        widget.product.variationId = widget
                            .product.availableVariations[i].variationId
                            .toString();
                        widget.product.regularPrice = widget
                            .product.availableVariations[i].displayPrice
                            .toDouble();
                        widget.product.formattedPrice = widget
                            .product.availableVariations[i].formattedPrice;
                        widget.product.formattedSalesPrice = widget
                            .product.availableVariations[i].formattedSalesPrice;
                        if (widget.product.availableVariations[i]
                                .displayRegularPrice !=
                            widget.product.availableVariations[i].displayPrice)
                          widget.product.salePrice = widget.product
                              .availableVariations[i].displayRegularPrice
                              .toDouble();
                        else
                          widget.product.formattedSalesPrice = null;
                      });
                      if (!widget.product.availableVariations[i].isInStock) {
                        setState(() {
                          widget.product.stockStatus = 'outofstock';
                        });
                      }
                      break;
                    }
                  }
                  if (matchedOptions.length != selectedOptions.length) {
                    setState(() {
                      widget.product.stockStatus = 'outofstock';
                    });
                  }
                }
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border:
                      variationOption.selected == variationOption.options[index]
                          ? Border.all(
                              color: Theme.of(context).accentColor, width: 2)
                          : Border.all(color: Colors.grey, width: 2),
                  borderRadius: BorderRadius.all(Radius.circular(
                          1.0) //                 <--- border radius here
                      ),
                ),
                child: Text(
                  variationOption.options[index].toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.0,
                    color: variationOption.selected ==
                            variationOption.options[index]
                        ? Theme.of(context).accentColor
                        : Theme.of(context).textTheme.title.color,
                  ),
                ),
              ),
            );
          },
          childCount: variationOption.options.length,
        ),
      ),
    );
  }

  Widget buildOptionHeader(String name) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      sliver: SliverList(
        delegate: SliverChildListDelegate(
          [
            Container(
                child: Text(
              name,
              style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Lexend_Deca',
                  fontWeight: FontWeight.w900),
            )),
          ],
        ),
      ),
    );
  }

  Widget buildBody() {
    return Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 50.0),
          child: CustomScrollView(
              controller: _scrollController, slivers: buildSliverList()),
        ),
        Positioned(
          bottom: 0,
          child: _qSelector(),
        ),
        Positioned(
          bottom: 55,
          child: _animContainer(),
        )
      ],
    );
  }

  Future _openWhatsApp(String number) async {
    final url = 'https://wa.me/' + number;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget buildProductSortDescriptoion() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 0.0),
        child: Html(
          data: widget.product.shortDescription,
        ),
      ),
    );
  }

  Widget buildProductDescriptoion() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 1.0),
        child: Html(
          data: widget.product.description,
        ),
      ),
    );
  }

  _buildDBackgroundImage() {
    return SliverAppBar(
      floating: true,
      pinned: true,
      snap: true,
      backgroundColor: Colors.black12,
      actions: <Widget>[
        IconButton(
            icon: Icon(
              Icons.share,
              semanticLabel: 'Share',
              color: isShrink
                  ? Theme.of(context).appBarTheme.iconTheme.color
                  : Colors.black,
            ),
            onPressed: () {
              Share.share('check out product ' + widget.product.permalink);
            }),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Container(
              color: Colors.black12,
              padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
              child: Container(),
            )
          ],
        ),
      ),
      expandedHeight: expandedAppBarHeight,
    );
  }

  _buildDBackgroundCircleIndicator() {
    return SliverList(
        delegate: SliverChildListDelegate([
      Container(
        padding: EdgeInsets.all(60.0),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      )
    ]));
  }

  getProduct() async {
    Product product =
        await widget.productDetailBloc.getProduct(widget.product.id);
    if (product.id != null) {
      setState(() {
        widget.product = product;
      });
    }
  }

  Widget _qSelector() {
    return Container(
        width: MediaQuery.of(context).size.width,
        color: Theme.of(context).canvasColor,
        height: 55,
        child: Row(
          children: <Widget>[
            InkWell(
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: 70,
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        FlutterIcons.shopping_cart_fea,
                        semanticLabel: 'Cart',
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => CartPage(),
                              fullscreenDialog: true,
                            ));
                      },
                    ),
                    Positioned(
                      top: 2,
                      right: 2.0,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) => CartPage(),
                                fullscreenDialog: true,
                              ));
                        },
                        child: ScopedModelDescendant<AppStateModel>(
                            builder: (context, child, model) {
                          if (model.count != 0) {
                            return Card(
                                elevation: 0,
                                clipBehavior: Clip.antiAlias,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                color: Theme.of(context).accentColor,
                                child: Container(
                                    padding: EdgeInsets.all(2),
                                    constraints: BoxConstraints(minWidth: 20.0),
                                    child: Center(
                                        child: Text(
                                      model.count.toString(),
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: Theme.of(context)
                                              .accentIconTheme
                                              .color,
                                          backgroundColor:
                                              Theme.of(context).accentColor),
                                    ))));
                          } else
                            return Container();
                        }),
                      ),
                    )
                  ],
                ),
              ),
              onTap: () {
                setState(() {
                  _visible = !_visible;
                });
              },
            ),
            ScopedModelDescendant<AppStateModel>(
                builder: (context, child, model) {
              return Container(
                height: 55,
                child: AddButtonDetail(
                  product: widget.product,
                  model: model,
                  addonFormKey: addonFormKey,
                  addOnsFormData: addOnsFormData,
                ),
              );
            })
          ],
        ));
  }

  Widget _animContainer() {
    TextStyle textStyle = Theme.of(context).textTheme.bodyText1;
    return _visible
        ? AnimatedContainer(
            duration: Duration(
              seconds: 2,
            ),
            height: 110,
            width: MediaQuery.of(context).size.width,
            curve: Curves.fastOutSlowIn,
            child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0.0),
                ),
                margin: EdgeInsets.all(0.0),
                elevation: 0,
                child: Padding(
                  padding: EdgeInsets.only(left: 15, top: 6, bottom: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            widget.appStateModel.blocks.localeText.qty,
                            style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Lexend_Deca',
                                fontWeight: FontWeight.w900),
                          ),
                          IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              setState(() {
                                _visible = false;
                              });
                            },
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            width: 50,
                            child: OutlineButton(
                              // width: 50,
                              //height: 70,
                              borderSide: _quantity == 1
                                  ? BorderSide(
                                      color: Theme.of(context).accentColor,
                                      width: 1.5)
                                  : null,
                              onPressed: () {
                                setState(() {
                                  _quantity = 1;
                                });
                                _visible = false;
                              },
                              // color: Colors.white,
                              child: Center(
                                child: Text(
                                  '1',
                                  style: textStyle,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          SizedBox(
                            width: 50,
                            child: OutlineButton(
                              // width: 50,
                              //height: 70,
                              borderSide: _quantity == 2
                                  ? BorderSide(
                                      color: Theme.of(context).accentColor,
                                      width: 1.5)
                                  : null,
                              onPressed: () {
                                setState(() {
                                  _quantity = 2;
                                });
                                _visible = false;
                              },
                              //color: Colors.white,
                              child: Center(
                                child: Text(
                                  '2',
                                  style: textStyle,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          SizedBox(
                            width: 50,
                            child: OutlineButton(
                              borderSide: _quantity == 3
                                  ? BorderSide(
                                      color: Theme.of(context).accentColor,
                                      width: 1.5)
                                  : null,
                              onPressed: () {
                                setState(() {
                                  _quantity = 3;
                                });
                                _visible = false;
                              },
                              child: Center(
                                child: Text(
                                  '3',
                                  style: textStyle,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          SizedBox(
                            width: 50,
                            child: OutlineButton(
                              borderSide: _quantity == 4
                                  ? BorderSide(
                                      color: Theme.of(context).accentColor,
                                      width: 1.5)
                                  : null,
                              onPressed: () {
                                setState(() {
                                  _quantity = 4;
                                });
                                _visible = false;
                              },
                              //color: Colors.white,
                              child: Center(
                                child: Text(
                                  '4',
                                  style: textStyle,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          SizedBox(
                            width: 50,
                            child: OutlineButton(
                              // width: 50,
                              //height: 70,
                              borderSide: _quantity == 5
                                  ? BorderSide(
                                      color: Theme.of(context).accentColor,
                                      width: 1.5)
                                  : null,
                              onPressed: () {
                                setState(() {
                                  _quantity = 5;
                                });
                                _visible = false;
                              },
                              //color: Colors.white,
                              child: Center(
                                child: Text(
                                  '5',
                                  style: textStyle,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
          )
        : Container();
  }

  Widget buildStore() {
    return SliverToBoxAdapter(
        child: buildStoreTile(context, widget.product.vendor));
  }

  buildStoreTile(BuildContext context, Vendor store) {
    return InkWell(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  VendorDetails(vendorId: store.id.toString()))),
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 16.0, 16.0, 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                CircleAvatar(
                  radius: 20.0,
                  backgroundImage: NetworkImage(store.icon),
                ),
                SizedBox(
                  width: 16.0,
                ),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(store.name,
                              style: TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.w400)),
                        ],
                      ),
                    ]),
              ],
            ),
            SizedBox(height: 8.0),
            //  Text(store.email),
          ],
        ),
      ),
    );
  }

  Widget buildWriteYourReview() {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
      sliver: SliverList(
        delegate: SliverChildListDelegate(
          [
            StreamBuilder<List<ReviewModel>>(
                stream: widget.productDetailBloc.allReviews,
                builder: (context, AsyncSnapshot<List<ReviewModel>> snapshot) {
                  if (snapshot.hasData && snapshot.data.length > 0) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ReviewsDetail(
                                    product: widget.product,
                                    productDetailBloc:
                                        widget.productDetailBloc)));
                      },
                      child: Column(
                        children: [
                          ListTile(
                            trailing: Icon(Icons.keyboard_arrow_right),
                            title: Text(
                              'Customer Reviews (${snapshot.data.length})',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6
                                  .copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 0),
                            child: Row(
                              children: [
                                RichText(
                                  text: TextSpan(
                                    text:
                                        widget.product.averageRating.toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline5
                                        .copyWith(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: '/5',
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1
                                            .copyWith(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                RatingBar.builder(
                                  initialRating: double.parse(
                                      widget.product.averageRating),
                                  itemSize: 20,
                                  minRating: 1,
                                  direction: Axis.horizontal,
                                  allowHalfRating: true,
                                  ignoreGestures: true,
                                  itemCount: 5,
                                  itemPadding:
                                      EdgeInsets.symmetric(horizontal: 0.0),
                                  itemBuilder: (context, _) => Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  onRatingUpdate: (rating) {},
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  } else {
                    return Container();
                  }
                }),
            Container(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ReviewsPage(productId: widget.product.id)));
                },
                child: ListTile(
                  trailing: Icon(Icons.keyboard_arrow_right),
                  title: Text('Write Your Review'),
                ),
              ),
            ),
            Divider(
              thickness: 1,
            ),
          ],
        ),
      ),
    );
  }
}
