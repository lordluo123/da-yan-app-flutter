import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapping_bottom_sheet/snapping_bottom_sheet.dart';

import '/pages/bluetooth/device_list.dart';
import '/pages/bluetooth/device_pairing_widget.dart';
import '/pages/home/amap_widget.dart';
import '/pages/login/login_view.dart';
import '/utils/local_storage.dart';

class BluetoothDeviceView extends StatefulWidget {
  const BluetoothDeviceView({super.key});

  @override
  State<BluetoothDeviceView> createState() => _BluetoothDeviceViewState();
}

class _BluetoothDeviceViewState extends State<BluetoothDeviceView> {
  late final LocalStorage localStorage = LocalStorage();
  SheetController controller = SheetController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final model = Provider.of<BluetoothDeviceModel>(context, listen: false);
    if (model.selectedDevice != null) {
      controller.snapToExtent(
        0.43,
        duration: const Duration(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bleModel = Provider.of<BluetoothDeviceModel>(context);
    debugPrint('Sheet List----------------------------');
    return SnappingBottomSheet(
      controller: controller,
      color: Colors.white,
      shadowColor: Colors.transparent,
      elevation: 1,
      cornerRadius: 16,
      cornerRadiusOnFullscreen: 16,
      snapSpec: SnapSpec(
        initialSnap: bleModel.sheetSnapped,
        snap: true,
        positioning: SnapPositioning.relativeToAvailableSpace,
        snappings: const [
          SnapSpec.headerFooterSnap,
          0.43,
          0.99,
        ],
      ),
      liftOnScrollHeaderElevation: 12.0,
      liftOnScrollFooterElevation: 12.0,
      body: const Stack(
        children: [
          AMapViewWidget(),
        ],
      ),
      headerBuilder: buildHeader,
      customBuilder: buildInfiniteChild,
    );
  }

  void handleAdd() async {
    final token = localStorage.get('accessToken');
    if (token == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginView()),
      ).then((isLogin) async {
        debugPrint('isLogin------------------$isLogin');
        if (isLogin == null) return;
        final bleModel =
            Provider.of<BluetoothDeviceModel>(context, listen: false);
        bleModel.getDevice();
        await showBottomSheetDialog(context);
      });
      return;
    }
    await showBottomSheetDialog(context);
  }

// BottomSheet 头部
  Widget buildHeader(BuildContext context, SheetState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Padding(padding: EdgeInsets.only(top: 8)),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: 28,
              height: 4,
              color: Colors.grey[400],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text(
                '设备',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: handleAdd,
                icon: Icon(
                  Icons.add,
                  color: Theme.of(context).primaryColor,
                ),
                iconSize: 28,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildInfiniteChild(
    BuildContext context,
    ScrollController controller,
    SheetState state,
  ) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
      child: SingleChildScrollView(
        controller: controller,
        child: const DeviceListWidget(),
      ),
    );
  }

  Future<void> showBottomSheetDialog(BuildContext context) async {
    await showSnappingBottomSheet(
      context,
      // parentBuilder: (context, sheet) {
      //   return Theme(
      //     data: ThemeData.dark(),
      //     child: sheet,
      //   );
      // },
      builder: (context) {
        return SnappingBottomSheetDialog(
          // 控制工作表状态的控制器。
          controller: controller,
          // 工作表的基本动画持续时间。滑动和甩动的持续时间可能不同。
          duration: const Duration(milliseconds: 500),
          // [SnapSpec] 定义工作表应如何对齐或是否应该对齐。
          snapSpec: const SnapSpec(
            snap: true,
            initialSnap: 0.5,
            snappings: [0.5],
          ),
          color: Colors.white,
          maxWidth: double.infinity,
          minHeight: MediaQuery.of(context).size.height / 2,
          builder: (context, state) {
            return Material(
              child: Stack(
                children: [
                  Positioned(
                    top: 20,
                    right: 20,
                    child: SizedBox(
                      width: 32,
                      height: 32,
                      child: IconButton.filledTonal(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.close,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                  const DevicePairing(),
                ],
              ),
            );
          },
        );
      },
    );
  }
}