import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mine/constants/app_colors.dart';
import 'package:mine/screens/prices/presentation/view_model/prices_cubit.dart';
import 'package:mine/screens/prices/presentation/view_model/prices_state.dart';

class HomePricesWidget extends StatelessWidget {
  const HomePricesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PricesCubit, PricesState>(
      builder: (context, state) {
        if (state is! PricesLoaded) {
          return const SizedBox();
        }

        final categories = state.prices.entries.toList();

        return SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            reverse: true,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final category = categories[index];

              if (category.value.items.isEmpty) {
                return const SizedBox();
              }

              final price = category.value.items.first;

              return _PriceChip(
                title: category.key,
                price: price.price.toString(),
                quantity: price.quantity,
                unit: price.unit,
                currency: price.currency,
                direction: price.priceDirection,
                lastUpdated: category.value.lastUpdated,
              );
            },
          ),
        );
      },
    );
  }
}
class _PriceChip extends StatelessWidget {
  final String title;
  final String quantity;
  final String unit;
  final String price;
  final String currency;
  final String? direction;
  final String lastUpdated;

  const _PriceChip({
    required this.title,
    required this.quantity,
    required this.unit,
    required this.price,
    required this.currency,
    required this.direction,
    required this.lastUpdated,
  });

  @override
  Widget build(BuildContext context) {
    Color iconColor = Colors.grey;
    IconData? icon;

    switch (direction) {
      case "up":
        icon = Icons.arrow_upward;
        iconColor = Colors.green;
        break;

      case "down":
        icon = Icons.arrow_downward;
        iconColor = Colors.red;
        break;

      case "same":
        icon = Icons.remove;
        iconColor = Colors.orange;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$title ($quantity $unit)",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            "$price $currency",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          // if (icon != null) ...[
          //   const SizedBox(width: 4),
          //   Icon(
          //     icon,
          //     color: iconColor,
          //     size: 16,
          //   ),
          // ],
        ],
      ),
    );
  }
}