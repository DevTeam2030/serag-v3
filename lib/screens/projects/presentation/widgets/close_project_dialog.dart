import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../widgets/custom_button.dart';
import '../../../auth/register/presentation/view_model/building_info_cubit.dart';
import '../view_model/projects_cubit.dart';

class CloseProjectDialog
    extends StatefulWidget {

  final String projectId;

  const CloseProjectDialog({
    super.key,

    required this.projectId,
  });

  @override
  State<CloseProjectDialog>
  createState() =>
      _CloseProjectDialogState();
}

class _CloseProjectDialogState
    extends State<CloseProjectDialog> {

  final priceController =
  TextEditingController();

  String? selectedCurrency;

  @override
  Widget build(
      BuildContext context,
      ) {

    final currencies =
        context
            .read<ProjectDataCubit>()
            .settingsData
            ?.currencies;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),

      shape:
      RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(
          20,
        ),
      ),

      child: Padding(

        padding:
        const EdgeInsets.all(20),

        child: Column(

          mainAxisSize:
          MainAxisSize.min,

          children: [

            Align(

              alignment:
              Alignment.topRight,

              child: InkWell(

                onTap: () {
                  Navigator.pop(
                    context,
                  );
                },

                child: const Icon(
                  Icons.close,
                ),
              ),
            ),



             Text(
              "من فضلك ادخل سعر البيع",

              style:AppTextStyles.boldGrey17
                  .copyWith(
                color: Colors.black,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            Row(

              children: [

                Expanded(

                  flex: 2,

                  child:
                  DropdownButtonFormField<String>(
                   hint:  Text(
                      "اختر العملة",
                      style: AppTextStyles
                          .regularBlack12
                          .copyWith(
                        color: Colors.black,
                      ),
                    ),
                    value:
                    selectedCurrency,

                    decoration:
                    const InputDecoration(
                      border:
                      OutlineInputBorder(),
                    ),

                    items:
                    currencies?.map(
                          (e) {

                        return DropdownMenuItem(

                          value:
                          e.key,

                          child:
                          Text(
                            e.value,
                            style: AppTextStyles
                                .regularBlack12
                                .copyWith(
                              color: Colors.black,
                            ),
                          ),

                        );

                      },
                    ).toList(),

                    onChanged:
                        (value) {

                      setState(() {

                        selectedCurrency =
                            value;

                      });

                    },
                  ),
                ),

                const SizedBox(
                  width: 5,
                ),

                Expanded(

                  flex: 3,

                  child: TextField(

                    controller:
                    priceController,

                    keyboardType:
                    TextInputType.number,

                    decoration:
                    const InputDecoration(

                      hintText:
                      '00:00',

                      border:
                      OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 30,
            ),

            CustomButton(

              title: "إضافة",

              backgroundColor:
              AppColors.green,

              withShadow: false,

              onPressed: () {

                if (priceController
                    .text
                    .isEmpty) {
                  return;
                }

                if (selectedCurrency ==
                    null) {
                  return;
                }

                context
                    .read<ProjectsCubit>()

                    .closeProject(

                  id:
                  widget.projectId,

                  sellingPrice:
                  priceController.text,

                  currency:
                  selectedCurrency!,
                );

                Navigator.pop(
                  context,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}