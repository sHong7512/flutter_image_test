import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_viewer/info.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

class ViewerPage extends StatefulWidget {
  const ViewerPage({Key? key}) : super(key: key);

  @override
  State<ViewerPage> createState() => _ViewerPageState();
}

class _ViewerPageState extends State<ViewerPage> {
  final List<Color> rainbowColors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
    Colors.white,
    Colors.black,
  ];

  Info? currentInfo;
  Widget _imageResult = Container();
  Color currentColor = Colors.black;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 20, child: _selectFile()),
              const Center(child: Text('공간 클릭시 이미지 선택')),
              _information(),
              const Center(child: Text('배경 색 선택')),
              Expanded(flex: 1, child: _colorSelector()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _information() {
    return Container(
      color: Colors.black.withOpacity(0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('파일 이름 : ${currentInfo?.name}'),
          Text('포맷 : ${currentInfo?.format}'),
          Text('파일 사이즈 : ${((currentInfo?.bytes ?? 0) / 1024).toStringAsFixed(2)}kb'),
        ],
      ),
    );
  }

  Widget _colorSelector() {
    return Row(
      children: rainbowColors
          .map(
            (e) => Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: () {
                  currentColor = e;
                  setState(() {});
                },
                child: Container(color: e),
              ),
            ),
          )
          .toList(),
    );
  }

  GestureDetector _selectFile() {
    return GestureDetector(
      onTap: () async {
        FilePickerResult? result = await FilePicker.platform.pickFiles();

        if (result != null) {
          File file = File(result.files.single.path!);
          final String path = file.path;

          final String name = path.substring(path.lastIndexOf('/') + 1, path.lastIndexOf('.'));
          final String format = path.substring(path.lastIndexOf('.') + 1, path.length);
          final bytes = (await file.readAsBytes()).length;
          currentInfo = Info(name: name, format: format, bytes: bytes);

          switch (format) {
            case 'json':
              _imageResult = await _lottie(file);
              break;
            case 'svg':
              _imageResult = await _svg(file);
              break;
            default:
              _imageResult = await _other(file);
              break;
          }
          setState(() {});
        }
      },
      child: Stack(
        children: [
          Container(color: currentColor),
          Center(child: _imageResult),
        ],
      ),
    );
  }

  _lottie(File file) => Lottie.file(
        file,
        errorBuilder: (_, e, s) {
          currentInfo = null;
          return _errorWidget(file);
        },
      );

  _svg(File file) => SvgPicture.file(
        file,
        placeholderBuilder: (_) {
          currentInfo = null;
          return _errorWidget(file);
        },
      );

  _other(File file) => Image.file(
        file,
        errorBuilder: (_, __, ___) {
          currentInfo = null;
          return _errorWidget(file);
        },
      );

  Widget _errorWidget(File file) {
    final lastIndex = file.path.lastIndexOf('/');
    final name = file.path.substring(lastIndex + 1, file.path.length);
    return Center(
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '$name 파일 로딩에 실패했습니다.',
            style: TextStyle(backgroundColor: Colors.white),
          ),
        ),
      ),
    );
  }
}
