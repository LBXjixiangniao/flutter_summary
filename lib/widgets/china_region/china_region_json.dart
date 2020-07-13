part of 'china_region_select.dart';

enum RegionType {
  Province,
  City,
  County,
}

class RegionModel {
  String name;
  String id;
  RegionType type;
  RegionModel({this.name, this.id, this.type});
  RegionModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    id = json['id'];
  }
}

Future<dynamic> loadRegionJson(RegionType type) {
  String path;
  switch (type) {
    case RegionType.Province:
      path = 'assets/files/china_region/province.json';
      break;
    case RegionType.City:
      path = 'assets/files/china_region/city.json';
      break;
    case RegionType.County:
      path = 'assets/files/china_region/county.json';
      break;
  }
  if (path != null) {
    return rootBundle.loadString(path).then((value) {
      return jsonDecode(value);
    });
  } else {
    return Future.value(null);
  }
}

Future<List<RegionModel>> getAllProvince() {
  return loadRegionJson(RegionType.Province).then((value) {
    if (value is List) {
      return value.map((e) {
        RegionModel model = RegionModel.fromJson(e);
        model.type = RegionType.Province;
        return model;
      }).toList();
    }
    return null;
  });
}

Future<Map<String, List<RegionModel>>> getAllCity() {
  return loadRegionJson(RegionType.City).then((value) {
    if (value is Map) {
      Map<String, List<RegionModel>> tmpMap = {};
      value.forEach(
        (key, cityJsonList) {
          if (cityJsonList is List) {
            tmpMap[key] = cityJsonList.map(
              (e) {
                RegionModel model = RegionModel.fromJson(e);
                model.type = RegionType.City;
                return model;
              },
            ).toList();
          }
        },
      );
      return tmpMap;
    }
    return null;
  });
}

Future<List<RegionModel>> getAllCityForProvince({@required String provinceId}) {
  assert(provinceId != null);
  return loadRegionJson(RegionType.City).then((value) {
    if (value is Map) {
      if (provinceId != null) {
        List cityList = value[provinceId];
        if (cityList is List) {
          return cityList.map((e) {
            RegionModel model = RegionModel.fromJson(e);
            model.type = RegionType.City;
            return model;
          }).toList();
        }
      }
    }
    return null;
  });
}

Future<Map<String, List<RegionModel>>> getAllCounty() {
  return loadRegionJson(RegionType.County).then((value) {
    if (value is Map) {
      Map<String, List<RegionModel>> tmpMap = {};
      value.forEach(
        (key, cityJsonList) {
          if (cityJsonList is List) {
            tmpMap[key] = cityJsonList.map(
              (e) {
                RegionModel model = RegionModel.fromJson(e);
                model.type = RegionType.County;
                return model;
              },
            ).toList();
          }
        },
      );
      return tmpMap;
    }
    return null;
  });
}

Future<List<RegionModel>> getAllCountyForCity({@required String cityId}) {
  assert(cityId != null);
  return loadRegionJson(RegionType.County).then((value) {
    if (value is Map) {
      if (cityId != null) {
        List cityList = value[cityId];
        if (cityList is List) {
          return cityList.map((e) {
            RegionModel model = RegionModel.fromJson(e);
            model.type = RegionType.County;
            return model;
          }).toList();
        }
      }
    }
    return null;
  });
}
