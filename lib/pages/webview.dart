import 'package:Thilogi/blocs/user_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late WebViewController controller;
  late UserBloc? ub;

  @override
  void initState() {
    super.initState();
    ub = Provider.of<UserBloc>(context, listen: false);
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            // await _fillLoginForm();

            // Inject JavaScript to remove unwanted elements
            controller.runJavaScript("""
                document.querySelector('header').style.display = 'none';
                document.querySelector('footer').style.display = 'none';
                document.querySelector('.div_frame').scrollIntoView();
                """);
          },
        ),
      )
      ..loadRequest(
          Uri.parse('https://bms.thilogi.vn/danh-muc-kho-wms/so-do-kho'));
  }

//   Future<void> _fillLoginForm() async {
//     if (ub?.maNhanVien != null) {
//       // Inject JavaScript to fill in the login form
//       await controller.runJavaScript("""
//   setTimeout(function() {
//     // Create a MutationObserver to monitor changes in the DOM
//     var observer = new MutationObserver(function(mutations) {
//       mutations.forEach(function(mutation) {
//         if (mutation.type === 'childList') {
//           document.getElementById('basic_username').value = '${ub?.maNhanVien}';
//           document.getElementById('basic_password').value = '${ub?.maNhanVien}';
//         }
//       });
//     });

//     // Observe changes in the form element
//     var targetNode = document.querySelector('form');
//     if (targetNode) {
//       observer.observe(targetNode, { childList: true, subtree: true });
//     }

//     // Set initial values
//     document.getElementById('basic_username').value = '${ub?.maNhanVien}';
//     document.getElementById('basic_password').value = '${ub?.maNhanVien}';

//     // Function to select the "Cá nhân" option from the dropdown
//     function selectOption() {
//       var selectElement = document.querySelector('.ant-select-selector');
//       if (selectElement) {
//         selectElement.click(); // Open the dropdown
//         setTimeout(function() {
//           var option = Array.from(document.querySelectorAll('.ant-select-item-option-content'))
//             .find(option => option.textContent === 'Cá nhân');
//           if (option) {
//             option.click(); // Select the option
//           }
//         }, 500); // Adjust the timeout as necessary
//       }
//     }

//     // Call the function to select the option
//     selectOption();
//   }, 1000); // Adjust the timeout as necessary
// """);
//     }
//   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar is removed by not including it here
      resizeToAvoidBottomInset: false,
      body: WebViewWidget(
        controller: controller,
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: MyApp(),
  ));
}
