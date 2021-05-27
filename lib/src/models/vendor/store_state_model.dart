import 'package:scoped_model/scoped_model.dart';

import '../../resources/api_provider.dart';
import 'store_model.dart';

class StoreStateModel extends Model {

  static final StoreStateModel _storeStateModel = new StoreStateModel._internal();

  factory StoreStateModel() {
    return _storeStateModel;
  }

  StoreStateModel._internal();
  final apiProvider = ApiProvider();
  List<StoreModel> stores;
  int page = 1;
  var filter = new Map<String, String>();
  bool hasMoreItems = false;

  getAllStores() async {
   // print( 'here get start get stores');
    filter['page'] = page.toString();
    final response = await apiProvider.post('/wp-admin/admin-ajax.php?action=mstore_flutter-vendors', filter);
   // print(" post get all stores ${apiProvider.post('/wp-admin/admin-ajax.php?action=mstore_flutter-vendors', filter)}");
    stores = storeModelFromJson(response.body);
   // print(stores.first.name);
    hasMoreItems = stores.length > 9;
    notifyListeners();
  }

  loadMoreStores() async {
   // print( 'load more stores in store state model get start get stores');
    page = page + 1;
    filter['page'] = page.toString();
    final response = await apiProvider.post('/wp-admin/admin-ajax.php?action=mstore_flutter-vendors',filter);
    List<StoreModel> moreStore = storeModelFromJson(response.body);
    stores.addAll(moreStore);
    hasMoreItems = moreStore.length > 9;
    notifyListeners();
  }

  refresh() async {
   // print( 'refresh store method');
    page = 1;
    filter['page'] = page.toString();
    final response = await apiProvider.post('/wp-admin/admin-ajax.php?action=mstore_flutter-vendors', filter);
    stores = storeModelFromJson(response.body);
    hasMoreItems = stores.length > 9;
    notifyListeners();
    return true;
  }

}