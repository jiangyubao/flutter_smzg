import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> providers = [
  ...independentServices,
  ...dependentServices,
  ...uiConsumableProviders
];

/// 独立的model
List<SingleChildWidget> independentServices = [];

/// 需要依赖的model
List<SingleChildWidget> dependentServices = [];

List<SingleChildWidget> uiConsumableProviders = [
];
