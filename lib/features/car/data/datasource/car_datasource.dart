import '../models/car_hive_model.dart';

abstract interface class ICarDatasource {
  Future<List<CarHiveModel>> getMyCars();
  Future<CarHiveModel> addCar(CarHiveModel car);
  Future<bool> deleteCar(String id);
}
