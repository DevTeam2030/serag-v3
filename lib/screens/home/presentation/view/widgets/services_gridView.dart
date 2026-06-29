import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mine/screens/home/presentation/view/widgets/section_request_dialog.dart';

import '../../../../../constants/app_text_styles.dart';
import '../../../../../widgets/custom_button.dart';
import '../../../../auth/register/data/settings_model.dart';
import '../service_details_screen.dart';

class ServicesGridViewWidget extends StatelessWidget {
  const ServicesGridViewWidget({
    super.key,
    required this.categories,
    required this.crossAxisCount,
  });

  final List<Category> categories;
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = (constraints.maxWidth / 200).floor().clamp(2, 6);
        final int count = crossAxisCount;
        double spacing = 8;
        double totalSpacing =
            (count - 1) * spacing;

        double itemWidth =
            (constraints.maxWidth - totalSpacing)
                / count;
        // double itemWidth = (constraints.maxWidth - totalSpacing) / crossAxisCount;
        double itemHeight = itemWidth * 1.3;

        return GridView.builder(
          shrinkWrap: true,

          physics:
          const NeverScrollableScrollPhysics(),

          itemCount: categories.length,
          gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(

            crossAxisCount: count,

            crossAxisSpacing: spacing,

            mainAxisSpacing: spacing,

            childAspectRatio:
            itemWidth / itemHeight,
          ),
          itemBuilder: (context, index) {
            final category = categories[index];

            return GestureDetector(
              onTap: () {
                // Category ID 1 is "دجاج" - navigate to ServiceDetailsScreen
                if (category.id == 1) {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => ServiceDetailsScreen(
                        serviceName: category.name,
                      ),
                      transitionDuration: Duration(seconds: 1),
                      transitionsBuilder: (_, a, __, c) =>
                          FadeTransition(opacity: a, child: c),
                    ),
                  );
                } else {
                  // For other categories - show SectionRequestDialog
                  showDialog(
                    context: context,
                    builder: (context) => SectionRequestDialog(
                      categoryId: category.id,
                      categoryName: category.name,
                    ),
                  );
                }
              },
              child: Column(
                children: [
                  Container(
                    width: itemWidth,
                    height: itemHeight - 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDDCBA0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Image.network(
                      category.image,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: Colors.grey,
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category.name,
                    style: AppTextStyles.boldWhite20.copyWith(
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}