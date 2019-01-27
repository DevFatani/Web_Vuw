import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PopupScreen extends StatefulWidget {
  @override
  createState() => _PopupScreenState();
}

class _PopupScreenState extends State<PopupScreen> {
  double boxWidth;
  double boxHeight;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black12,
        body: Stack(
          children: <Widget>[
            InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: null,
            ),
            Center(
              child: Container(
                width: boxWidth,
                height: boxHeight,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5.5)),
                child: SizedBox(
                  width: 250,
                  height: 250,
                  child: Center(
                      child: Text(
                    "Hello this Web Vuw",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  )),
                ),
              ),
            ),
          ],
        ));
  }
}
