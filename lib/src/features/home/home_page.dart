import 'package:flutter/material.dart';
import 'package:workwith_admin/src/features/home/tab_enum.dart';
import 'package:workwith_admin/src/features/home/tab_item.dart';

class HomePage extends StatefulWidget {
  final TabsEnum? tab;

  const HomePage({super.key, this.tab});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late TabsEnum _selectedTab;
  late final List<TabItem> _tabItems;

  @override
  initState() {
    super.initState();
    _selectedTab = widget.tab ?? TabsEnum.editVenue;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tabItems = getTabItems(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Center(
            child: IndexedStack(
          index: _selectedTab.index,
          children: _tabItems.map((item) => item.page).toList(),
        )),
        bottomNavigationBar: Container(
          color: Colors.black,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: BottomNavigationBar(
                currentIndex: _selectedTab.index,
                onTap: (index) {
                  setState(() {
                    _selectedTab = _tabItems[index].tabEnum;
                  });
                },
                backgroundColor: Colors.black,
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.grey.shade600,
                items: _tabItems
                    .map((item) => BottomNavigationBarItem(
                          icon: Icon(item.icon),
                          label: item.label,
                        ))
                    .toList()),
          ),
        ),
      ),
    );
  }
}
