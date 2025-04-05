import 'package:gotransfer/core/constants/colors.dart';
import 'package:gotransfer/core/constants/dimensions.dart';
import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final IconData icon;
  final bool isLoading;

  const LoginButton({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    required this.isLoading
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppDimensions.buttonHeight,
        decoration: BoxDecoration(
          color: isLoading ? AppColors.primaryColor.withOpacity(0.5) : AppColors.primaryColor,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isLoading ?
            CircularProgressIndicator(
              backgroundColor: isLoading ? AppColors.primaryColor.withOpacity(0.5) : AppColors.primaryColor,
              color: isLoading ? AppColors.secondaryColor.withOpacity(0.5) : AppColors.secondaryColor,
            ) :
            Icon(
              icon,
              size: AppDimensions.iconSize,
              color: AppColors.secondaryColor,
            ),
            SizedBox(width: 10),
            Center(
              child: Text(
                title,
                style: TextStyle(
                  color: AppColors.primaryTextColor,
                  fontSize: AppDimensions.defaultTextSize
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
