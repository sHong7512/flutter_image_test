import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

import 'format.dart';

void main() {
  runApp(
    MaterialApp(home: HomeScreen()),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  LottieBuilder? lottieBuilder;
  Widget? svgPicture;
  Image? image;
  Color currentColor = Colors.black;
  ImageFormat currentFormat = ImageFormat.lottie;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(color: Colors.white, child: const Center(child: Text('아래 공간 클릭시 이미지 선택'))),
              Expanded(flex: 10, child: imageSelector()),
              Expanded(flex: 1, child: checkBox()),
              Container(color: Colors.white, child: const Center(child: Text('배경 색 선택'))),
              Expanded(flex: 1, child: colorSelector()),
            ],
          ),
        ),
      ),
    );
  }

  Widget checkBox() {
    return Row(
        children: ImageFormat.values
            .map((e) => Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(e.name),
                      Switch(
                        value: currentFormat == e,
                        onChanged: (value) {
                          log('$e ::: $value');
                          if (value) {
                            currentFormat = e;
                          }
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ))
            .toList());
  }

  Widget imageSelector() {
    switch (currentFormat) {
      case ImageFormat.lottie:
        return selectFile(child: Container(color: currentColor, child: lottieBuilder));
      case ImageFormat.svg:
        return selectFile(child: Container(color: currentColor, child: svgPicture));
      case ImageFormat.others:
        return selectFile(child: Container(color: currentColor, child: image));
    }
  }

  Widget colorSelector() {
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

  GestureDetector selectFile({required Widget child}) {
    return GestureDetector(
      onTap: () async {
        FilePickerResult? result = await FilePicker.platform.pickFiles();

        if (result != null) {
          File file = File(result.files.single.path!);
          switch (currentFormat) {
            case ImageFormat.lottie:
              await _lottie(file);
              break;
            case ImageFormat.svg:
              final name = file.path.substring(file.path.length - 3, file.path.length);
              if (name != 'svg') {
                svgPicture = errorWidget(file);
              } else {
                await _svg(file);
              }
              break;
            case ImageFormat.others:
              await _other(file);
              break;
          }
          setState(() {});
        }
      },
      child: child,
    );
  }

  _lottie(File file) => lottieBuilder = Lottie.file(
        file,
        errorBuilder: (_, e, s) {
          lottieBuilder = null;
          return errorWidget(file);
        },
      );

  _svg(File file) => svgPicture = SvgPicture.file(
        file,
        placeholderBuilder: (_) {
          return errorWidget(file);
        },
      );

  _other(File file) => image = Image.file(
        file,
        errorBuilder: (_, __, ___) {
          image = null;
          return errorWidget(file);
        },
      );

  Widget errorWidget(File file) {
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
