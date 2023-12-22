import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:snapping_bottom_sheet/snapping_bottom_sheet.dart';
import '../../http/api.dart';

class LocalBluetoothDevice extends BluetoothDevice {
  late Map? address;
  late double? latitude;
  late double? longitude;
  LocalBluetoothDevice({required super.remoteId});

  @override
  late String localName = '';

  // 格式化地址
  String get formattedAddress {
    if (address?['formattedAddress'] == null && address?['country'] == null) {
      return '';
    }
    debugPrint('address------------$address');
    return address?['formattedAddress'] ??
        address?['country'] +
            address?['province'] +
            address?['city'] +
            address?['district'] +
            address?['street'] +
            address?['poiName'];
  }

  formMap(Map map) {
    debugPrint('map000000000000000$map');
    localName = map['name'];
    address = map['address'];
    latitude = map['latitude'] is double
        ? map['latitude']
        : double.parse(map['latitude']);
    longitude = map['longitude'] is double
        ? map['longitude']
        : double.parse(map['longitude']);
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['localName'] = localName;
    data['address'] = address;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }

  @override
  @override
  String toString() {
    return 'LocalBluetoothDevice{'
        'remoteId: $id, '
        'localName: $localName, '
        'address: $address, '
        'latitude: $latitude, '
        'longitude: $longitude, '
        '}';
  }
}

class BluetoothDeviceModel extends ChangeNotifier {
  // 选中的设备，查看详情
  LocalBluetoothDevice? selectedDevice;

  // 设备 Sheet 窗体打开的高度
  double sheetSnapped = 0.43;

  // 改变列表视图位置
  void changeSnapped(double snap) {
    sheetSnapped = snap;
    notifyListeners();
  }

  // 蓝牙设备列表
  List<LocalBluetoothDevice> _list = [];

  // 列表选择设备
  void select(LocalBluetoothDevice? device) {
    selectedDevice = device;
    notifyListeners();
  }

  // 新增设备
  void add(LocalBluetoothDevice device) {
    _list.add(device);
    notifyListeners();
  }

  // 批量新增设备
  void addAll(List<LocalBluetoothDevice> devices) {
    _list.addAll(devices);
    notifyListeners();
  }

  // 删除设备
  void remove(LocalBluetoothDevice device) {
    _list.removeWhere((e) => e.remoteId == device.remoteId);
    notifyListeners();
  }

  List<LocalBluetoothDevice> get list => _list;

  // 更新设备信息
  void update(LocalBluetoothDevice device) {
    _list.addOrUpdate(device);
    notifyListeners();
  }

  // 获取设备列表
  Future getDevice() async {
    final result = await Api.getBoundDevice() as Map;
    if (result['success']) {
      final devices = (result['data'] as List).map((item) {
        final device =
            LocalBluetoothDevice(remoteId: DeviceIdentifier(item['deviceId']));
        device.formMap(item);
        return device;
      }).toList();
      addAll(devices);
    }
  }
}