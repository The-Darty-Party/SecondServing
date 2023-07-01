import 'package:flutter/material.dart';
import '../../constants/ui_constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  CustomAppBar({required this.title});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.backgroundColor,
      title: Text(
        title,
        style: TextStyle(
          color: AppColors.textColor,
        ),
      ),
      iconTheme: IconThemeData(
        color: AppColors.textColor,
      ),
    );
  }
}
