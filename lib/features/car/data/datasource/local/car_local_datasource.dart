import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../../../../core/constants/hive_constants.dart';
import '../../models/car_hive_model.dart';
import '../car_datasource.dart';

final carLocalDatasourceProvider = Provider<ICarDatasource>((ref) {
  return CarLocalDatasource();
});

class CarLocalDatasource implements ICarDatasource {
  Box<CarHiveModel> get _carBox =>
      Hive.box<CarHiveModel>(HiveTableConstant.carTable);

  @override
  Future<List<CarHiveModel>> getMyCars() async {
    return _carBox.values.toList();
  }

  @override
  Future<CarHiveModel> addCar(CarHiveModel car) async {
    await _carBox.put(car.id, car);
    return car;
  }

  @override
  Future<bool> deleteCar(String id) async {
    await _carBox.delete(id);
    return true;
  }
}
