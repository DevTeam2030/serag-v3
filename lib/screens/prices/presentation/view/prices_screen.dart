import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mine/constants/app_colors.dart';
import 'package:mine/screens/auth/register/presentation/view/widgets/register_header.dart';

import '../../data/prices_model.dart';
import '../view_model/prices_cubit.dart';
import '../view_model/prices_state.dart';

class PricesScreen extends StatefulWidget {

  const PricesScreen({super.key});

  @override
  State<PricesScreen> createState() => _PricesScreenState();

}

class _PricesScreenState extends State<PricesScreen> {

  @override
  void initState() {

    context.read<PricesCubit>().loadPrices();

    super.initState();

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(


      body: Column(
        children: [
          SizedBox(height: 30.h,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: CustomHeader(title: 'الأسعار',showBack: Navigator.canPop(context),),
          ),
          SizedBox(height: 10.h,),
          Expanded(
            child: BlocBuilder<PricesCubit,PricesState>(

              builder: (context,state){

                if(state is PricesLoading){

                  return const Center(
                    child: SpinKitWave(color: AppColors.green),
                  );

                }

                if(state is PricesFailure){

                  return Center(
                    child: Text(state.message),
                  );

                }

                if(state is PricesLoaded){
                  if (state.prices.isEmpty) {
                    return const _EmptyPricesWidget();
                  }
                  return ListView.builder(

                    padding: const EdgeInsets.all(16),

                    itemCount: state.prices.length,

                    itemBuilder: (context,index){

                      final entry = state.prices.entries.elementAt(index);

                      return _buildSection(
                        title: entry.key,
                        category: entry.value,
                      );

                    },

                  );

                }

                return const SizedBox();

              },

            ),
          ),
        ],
      ),

    );

  }

  Widget _buildSection({
    required String title,
    required PriceCategoryModel category,
  }) {
    final items = category.items;

    return Card(

      margin: const EdgeInsets.only(bottom: 20),

      child: Column(

        children: [

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            color: Colors.green,
            child: Row(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(width: 5,),
                Text(
                  "( اخر تحديث ${category.lastUpdated})",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w700
                  ),
                ),
              ],
            ),
          ),

          Directionality(
            textDirection: TextDirection.rtl,

            child: DataTable(
              decoration:   BoxDecoration(
                borderRadius:   BorderRadius.circular(12),
                color: AppColors.white
              ),
                headingRowColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                    return Colors.grey.shade200; // Set the background color for header row
                  },
                ),
                   border:  TableBorder(borderRadius: BorderRadius.circular(12) ),
            dataRowHeight: 70,
                   dataRowColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.selected)) {
                      return AppColors.green;
                    }
                    return null; // Use default color for unselected rows
                  },
                ),
              columns: const [

                DataColumn(

                  label: Text("الكمية"),
                ),

                DataColumn(
                  label: Text("الوحدة"),
                ),

                DataColumn(
                  label: Text("السعر"),
                ),

                DataColumn(
                  label: Text("العملة"),
                ),

              ],

              rows: items.map((item){

                return DataRow(

                  cells: [

                    DataCell(
                      Text(item.quantity),
                    ),

                    DataCell(
                      Text(item.unit),
                    ),

                    DataCell(

                      Row(

                        children: [
                          Text(
                            item.price.toString(),
                          ),
                          if(item.priceDirection=="up")

                            const Icon(
                              Icons.arrow_upward,
                              color: Colors.green,
                              size: 16,
                            ),

                          if(item.priceDirection=="down")

                            const Icon(
                              Icons.arrow_downward,
                              color: Colors.red,
                              size: 16,
                            ),



                        ],

                      ),

                    ),

                    DataCell(
                      Text(item.currency),
                    ),

                  ],

                );

              }).toList(),

            ),
          )

        ],

      ),

    );

  }

}


class _EmptyPricesWidget extends StatelessWidget {
  const _EmptyPricesWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.price_check_outlined,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 20),
            Text(
              'لا توجد أسعار حتى الآن',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'سيتم عرض الأسعار بمجرد إضافتها.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}