import 'commodityCategory.dart';

class OnCallBacks {
  final Function(CommodityCategorys) onDeleteCategory;
  final Function(int, String) onUpdateCategory;
  
  OnCallBacks({required this.onDeleteCategory, required this.onUpdateCategory});
}
