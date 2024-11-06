import 'package:Thilogi/blocs/user_bloc.dart';
import 'package:Thilogi/config/config.dart';
import 'package:Thilogi/widgets/custom_title.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class qrCodeRutXe extends StatefulWidget {
  const qrCodeRutXe({Key? key}) : super(key: key);

  @override
  _qrCodeRutXeState createState() => _qrCodeRutXeState();
}

class _qrCodeRutXeState extends State<qrCodeRutXe> with SingleTickerProviderStateMixin {
  late UserBloc? ub;

  @override
  void initState() {
    super.initState();
    ub = Provider.of<UserBloc>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'QR CODE RÚT XE TẠI NHÀ MÁY',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontFamily: 'Comfortaa',
            fontSize: 17,
            color: Colors.red,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue, width: 14.0), // Viền đỏ với độ dày 3
          borderRadius: BorderRadius.circular(8.0),
          // Góc bo tròn (tuỳ chọn)
        ),
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Center(
              child: QrImageView(
                data: ub?.maNhanVien ?? "",
                version: QrVersions.auto,
                size: 230,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square, // Hoặc QrEyeShape.circle
                  color: Colors.black, // Đổi màu của "mắt" QR code
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square, // Hoặc QrDataModuleShape.circle
                  color: Colors.black, // Đổi màu của các ô dữ liệu nhỏ
                ),
              ),
            ),
            Text(
              "${ub?.name?.toUpperCase() ?? ""} - ${ub?.maNhanVien ?? ""}",
              style: TextStyle(
                fontFamily: 'Comfortaa',
                fontSize: 17,
                color: Colors.red,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              ub?.tenPhongBan ?? "",
              style: TextStyle(
                fontFamily: 'Comfortaa',
                fontSize: 17,
                color: Colors.red,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 12,
      padding: EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: AppConfig.bottom,
      ),
      child: Center(
        child: customTitle(
          'QRCODE RÚT XE NHÀ MÁY ',
        ),
      ),
    );
  }
}
