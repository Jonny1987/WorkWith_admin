import 'package:flutter/material.dart';
import 'package:workwith_admin/src/features/add_venue/presentation/add_venue_tab/add_venue_tab.dart';
import 'package:workwith_admin/src/features/edit_venue/presentation/edit_venue_tab/edit_venue_tab.dart';
import 'package:workwith_admin/src/features/home/tab_enum.dart';
import 'package:workwith_admin/src/features/profile/presentation/profile_tab.dart';

class TabItem {
  final Widget page;
  final IconData icon;
  final String label;
  final TabsEnum tabEnum;

  TabItem({
    required this.page,
    required this.icon,
    required this.label,
    required this.tabEnum,
  });
}

List<TabItem> getTabItems(BuildContext context) {
  var tabItems = [
    TabItem(
      page: const EditVenueTab(),
      icon: Icons.place,
      label: "Edit",
      tabEnum: TabsEnum.editVenue,
    ),
    TabItem(
      page: const AddVenueTab(),
      icon: Icons.add_box_rounded,
      label: "Add",
      tabEnum: TabsEnum.addVenue,
    ),
    TabItem(
      page: const ProfileTab(),
      icon: Icons.person,
      label: "Account",
      tabEnum: TabsEnum.account,
    ),
  ];
  return tabItems;
}
