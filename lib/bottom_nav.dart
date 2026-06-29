import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mine/core/helper/cache_helper.dart';
import 'package:mine/screens/ads/presentation/view/ads_screen.dart';
import 'package:mine/screens/home/presentation/view/home_screen.dart';
import 'package:mine/screens/prices/presentation/view/prices_screen.dart';
import 'package:mine/screens/projects/presentation/view/project_screen.dart';
import 'package:mine/screens/settings/presentation/view/edit_profile_screen.dart';
import 'package:mine/screens/settings/presentation/view/notification_screen.dart';
import 'package:mine/screens/settings/presentation/view/settings_screen.dart';

class BottomNav extends StatefulWidget {
  final bool isGuest;

  const BottomNav({
    super.key,
    this.isGuest = false,
  });

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _currentIndex = 0;

  late List<Widget> _pages;

  late List<NavItem> _navItems;

  late String establishmentTypeId;

  late int pricesIndex;

  @override
  void initState() {
    super.initState();

    establishmentTypeId =
        CacheHelper.getData(
          'establishment_type_id',
        )?.toString() ??
            '1';

    _setupNavigationBasedOnType();

    /// Auto open prices for guest
    if (widget.isGuest) {
      _currentIndex = pricesIndex;
    }
  }

  void _setupNavigationBasedOnType() {
    /// المدجنة

    if (establishmentTypeId == '1') {
      _pages = [
        LivestockHomePage(),

        ProjectsScreen(),

        const AdsScreen(),

        const PricesScreen(),

        EditProfileScreen(),

        const MenuScreen(),
      ];

      _navItems = [
        NavItem(
          'assets/home.svg',
          'الرئيسية',
        ),

        NavItem(
          'assets/projects.svg',
          'الأفواج',
        ),
        NavItem(
          'assets/ads.svg',
          'الإعلانات',
        ),
        NavItem(
          'assets/price.svg',
          'الأسعار',
        ),

        NavItem(
          'assets/pen.svg',
          'بياناتي',
        ),

        NavItem(
          'assets/settings.svg',
          'القائمة',
        ),
      ];

      pricesIndex = 3;
    }

    /// باقي الأنواع

    else {
      _pages = [
        const NotificationScreen(),

        const AdsScreen(),

        const PricesScreen(),

        EditProfileScreen(),

        const MenuScreen(),
      ];

      _navItems = [
        NavItem(
          'assets/home.svg',
          'الرئيسية',
        ),

        NavItem(
          'assets/ads.svg',
          'الإعلانات',
        ),

        NavItem(
          'assets/price.svg',
          'الأسعار',
        ),

        NavItem(
          'assets/pen.svg',
          'بياناتي',
        ),

        NavItem(
          'assets/settings.svg',
          'القائمة',
        ),
      ];

      pricesIndex = 2;
    }
  }

  void _onTabTapped(int index) {
    /// Guest can only access prices

    if (widget.isGuest && index != pricesIndex) {
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: _pages[_currentIndex],

        bottomNavigationBar: Container(
          padding: EdgeInsets.all(10.h),

          decoration: const BoxDecoration(
            color: Colors.white,

            border: Border(
              top: BorderSide(
                color: Color(0xFFE3E3E3),

                width: 1,
              ),
            ),
          ),

          child: BottomAppBar(
            color: Colors.white,

            elevation: 0,

            padding: EdgeInsets.only(
              top: 2.h,

              right: 17,

              left: 17,

              bottom: 0,
            ),

            child: Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,

              children: List.generate(
                _navItems.length,

                    (index) => _buildNavItem(
                  _navItems[index],

                  index,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      NavItem item,
      int index,
      ) {
    final isSelected =
        _currentIndex == index;

    final isDisabled =
        widget.isGuest &&
            index != pricesIndex;

    const unSelectedColor =
    Color(0xFFE8E8E8);

    const selectedColor =
    Color(0xFFD9CBA2);

    return InkWell(
      onTap: () => _onTabTapped(index),

      child: Column(
        mainAxisSize: MainAxisSize.min,

        children: [
          Container(
            alignment: Alignment.center,

            height: 44.h,

            width: 44.w,

            decoration: BoxDecoration(
              shape: BoxShape.circle,

              color: isDisabled
                  ? Colors.grey.shade300
                  : isSelected
                  ? selectedColor
                  : unSelectedColor,
            ),

            child: Opacity(
              opacity: isDisabled
                  ? .4
                  : 1,

              child: SvgPicture.asset(
                item.icon,

                height: 18.h,

                width: 18.w,
              ),
            ),
          ),

          const SizedBox(
            height: 4,
          ),

          Text(
            item.label,

            style: TextStyle(
              fontSize: 14,

              fontFamily: 'Cairo',

              fontWeight: FontWeight.w500,

              color: isDisabled
                  ? Colors.grey
                  : isSelected
                  ? Colors.black
                  : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}

class NavItem {
  final String icon;

  final String label;

  NavItem(
      this.icon,
      this.label,
      );
}