import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:workwith_admin/tabs/add_tab/add_tab.dart';
import 'package:workwith_admin/tabs/edit_tab/edit_tab.dart';
import 'package:workwith_admin/tabs/profile_tab.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  static Route<void> route() {
    return MaterialPageRoute(builder: (context) => HomePage());
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = const [EditTab(), AddTab(), ProfileTab()];

  static const TextStyle gButtonStyle = TextStyle(
    fontSize: 16,
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Center(
            child: IndexedStack(index: _selectedIndex, children: _pages)),
        bottomNavigationBar: Container(
          color: Colors.black,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: GNav(
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              backgroundColor: Colors.black,
              color: Colors.white,
              activeColor: Colors.white,
              tabBackgroundColor: Colors.grey.shade800,
              gap: 8,
              padding: EdgeInsets.all(16),
              tabs: const [
                GButton(
                  icon: Icons.edit,
                  text: 'Edit',
                  textStyle: gButtonStyle,
                ),
                GButton(
                  icon: Icons.add_box_rounded,
                  text: 'Add',
                  textStyle: gButtonStyle,
                ),
                GButton(
                  icon: Icons.person,
                  text: 'Profile',
                  textStyle: gButtonStyle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
