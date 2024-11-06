import 'package:Thilogi/blocs/user_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class qrCode extends StatefulWidget {
  const qrCode({Key? key}) : super(key: key);

  @override
  _qrCodeState createState() => _qrCodeState();
}

class _qrCodeState extends State<qrCode> with SingleTickerProviderStateMixin {
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
        title: Text('QR Code'),
      ),
      body: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red, width: 14.0), // Viền đỏ với độ dày 3
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
                data: ub?.qrCode ?? "",
                version: QrVersions.auto,
                size: 250,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square, // Hoặc QrEyeShape.circle
                  color: Color(0xFFA71C20), // Đổi màu của "mắt" QR code
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square, // Hoặc QrDataModuleShape.circle
                  color: Color(0xFFA71C20), // Đổi màu của các ô dữ liệu nhỏ
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
