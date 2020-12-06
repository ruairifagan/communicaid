import 'package:flutter/material.dart';

class UserImageAvatar extends StatelessWidget {
  final String imageUrl;
  final double height;
  final double width;
  final double borderRad;
  final Function() onTap;

  const UserImageAvatar({
    @required this.imageUrl,
    @required this.borderRad,
    @required this.onTap,
    this.height = 40.0,
    this.width = 40.0,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 7.0,
        horizontal: 7.0,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRad),
        image: DecorationImage(
          image: imageUrl == null || imageUrl.isEmpty
              ? AssetImage('assets/images/icon_user.png')
              : NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      height: height,
      width: width,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}
