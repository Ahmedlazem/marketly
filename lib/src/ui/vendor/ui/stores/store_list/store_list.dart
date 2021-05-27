import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import './../../../../../models/app_state_model.dart';
import './../../../../../models/vendor/store_model.dart';
import 'store_list1.dart';
import 'store_list2.dart';
import 'store_list3.dart';
import 'store_list4.dart';
import 'store_list5.dart';
import 'store_list6.dart';
import 'store_list7.dart';

class StoresList extends StatelessWidget {
  final List<StoreModel> stores;
  StoresList({Key key, this.stores}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<AppStateModel>(
        builder: (context, child, model) {
          if (model.blocks.pageLayout.stores == 'layout1') {
            print(' layout1');
            return StoresList1(stores: stores);
          } else if (model.blocks.pageLayout.stores == 'layout2') {
            print(' layout2');
            return StoresList2(stores: stores);
          } else if (model.blocks.pageLayout.stores == 'layout3') {
            print(' layout3');
            return StoresList3(stores: stores);
          } else if (model.blocks.pageLayout.stores == 'layout4') {
            print(' layout4');
            return StoresList4(stores: stores);
          } else if (model.blocks.pageLayout.stores == 'layout5') {
            print(' layout5');
            return StoresList5(stores: stores);
          } else if (model.blocks.pageLayout.stores == 'layout6') {
            print(' layout6');
            return StoresList6(stores: stores);
          } else if (model.blocks.pageLayout.stores == 'layout7') {
            print(' layout7');
            return StoresList7(stores: stores);

          } else {
            print(' layout8');
            return StoresList1(stores: stores);
          }
        });
  }
}
