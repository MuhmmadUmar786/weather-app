import 'package:flutter/material.dart';

import '../constants/my_app_theme.dart';

class HomeSmallWidget extends StatelessWidget {
  var image,title,value;
   HomeSmallWidget({
     required this.image,
     required this.title,
     required this.value,
     super.key});

  @override
  Widget build(BuildContext context) {
    var h=MediaQuery.of(context).size.height;
    var w=MediaQuery.of(context).size.width;
    return Container(
        height: 65,
        width: w*0.42,
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(image,height: 25,width: 25,color: Colors.white,),
            SizedBox(width: 10,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title,
                  style: TextStyle(color: Colors.grey[300],fontSize: 13),
                ),
                Text(value,
                  style: TextStyle(color: Colors.white,fontSize: 13),
                )
              ],
            )
          ],
        ));
  }
}
