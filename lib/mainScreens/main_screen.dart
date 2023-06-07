import 'package:car_pool_driver/Models/requests.dart';
import 'package:car_pool_driver/Views/tabPages/myTrips.dart';
import 'package:car_pool_driver/Views/tabPages/requests.dart';
import 'package:flutter/material.dart';

import '../Views/tabPages/dashboard.dart';
import '../Views/tabPages/home_tab.dart';
import '../Views/tabPages/profile_tab.dart';
import '../Views/tabPages/trip_history_tab.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  TabController? tabController;
  int selectedIndex = 0;

  onItemClicked(int index){
    setState(() {
      selectedIndex = index;
      tabController!.index = selectedIndex;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    tabController = TabController(length: 5, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: tabController,
        children: const [
          Dashboard(),
          TripHistoryTabPage(),
          MyTrips(),
          MyRequests(),
          ProfileTabPage(),

        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "History",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.directions_bus_filled_rounded),
            label: "Trips",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: "Requests",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.greenAccent,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontSize: 14),
        showUnselectedLabels: true,
        currentIndex: selectedIndex,
        onTap: onItemClicked,
      ),
    );
  }
}


