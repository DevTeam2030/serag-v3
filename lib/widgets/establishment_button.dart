import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mine/constants/app_colors.dart';
import 'package:mine/screens/home/presentation/view_model/establishment_state.dart';

import '../constants/app_text_styles.dart';
import '../core/helper/cache_helper.dart';
import '../screens/home/presentation/view/widgets/establishment_diaog.dart';
import '../screens/home/presentation/view_model/establishment_cubit.dart';
import '../screens/projects/presentation/view_model/projects_cubit.dart';

class EstablishmentButton extends StatefulWidget {
  const EstablishmentButton({super.key});

  @override
  State<EstablishmentButton> createState() => _EstablishmentButtonState();
}

class _EstablishmentButtonState extends State<EstablishmentButton> {
  String? _cachedDisplayText;

  @override
  void initState() {
    super.initState();
    // Load cached text immediately
    _loadCachedText();

    // Only fetch if not already loaded
    final currentState = context.read<EstablishmentCubit>().state;
    if (currentState is! EstablishmentLoaded) {
      context.read<EstablishmentCubit>().getEstablishments();
    }
  }

  void _loadCachedText() {
    final selectedEstablishmentName = CacheHelper.getData('selected_establishment_name');
    if (selectedEstablishmentName != null && selectedEstablishmentName.toString().isNotEmpty) {
      setState(() {
        _cachedDisplayText = selectedEstablishmentName.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EstablishmentCubit, EstablishmentState>(
      listener: (context, state) {
        // Cache the establishment name when loaded
        if (state is EstablishmentLoaded && state.establishments.isNotEmpty) {
          final selectedEstablishmentName = CacheHelper.getData('selected_establishment_name');

          if (selectedEstablishmentName == null || selectedEstablishmentName.toString().isEmpty) {
            // Find the first establishment with status = "1"
            final activeEstablishment = state.establishments.firstWhere(
                  (establishment) => establishment.status == "1",
              orElse: () => state.establishments.first,
            );

            // Cache it for next time
            CacheHelper.saveData('selected_establishment_name', activeEstablishment.name);

            setState(() {
              _cachedDisplayText = activeEstablishment.name;
            });
          }
        }
      },
      builder: (context, state) {
        // If we have cached text, show it immediately
        if (_cachedDisplayText != null) {
          return _buildButton(_cachedDisplayText!);
        }

        // Show loading while fetching
        if (state is EstablishmentLoading || state is! EstablishmentLoaded) {
          return _buildLoadingButton();
        }

        // Determine display text from loaded state
        String displayText = 'مدجنه';

        if (state is EstablishmentLoaded && state.establishments.isNotEmpty) {
          final activeEstablishment = state.establishments.firstWhere(
                (establishment) => establishment.status == "1",
            orElse: () => state.establishments.first,
          );
          displayText = activeEstablishment.name;
        }

        return _buildButton(displayText);
      },
    );
  }

  Widget _buildLoadingButton() {
    return Container(
      width: 150.w,
      height: 47.h,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: SpinKitThreeInOut(
        color: AppColors.white,
        size: 15,
      ),
    );
  }

  Widget _buildButton(String displayText) {
    return GestureDetector(
      onTap: () async {
        // Show establishment dialog
        final result = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => BlocProvider.value(
            value: context.read<EstablishmentCubit>(),
            child: const EstablishmentDialog(),
          ),
        );

        // If assignment was successful, reload cached text and trigger a rebuild
        if (result == true && context.mounted) {
          _loadCachedText();
          context.read<ProjectsCubit>().load(); // أو fetchProjects() حسب اسم دالتك

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم تحديث البيانات بنجاح'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: Container(
        width: 150.w,
        height: 47.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                displayText,
                style: AppTextStyles.boldWhite12,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(Icons.arrow_drop_down, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}