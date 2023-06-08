import 'package:car_pool_driver/Views/tabPages/startTrip_tab.dart';
import 'package:car_pool_driver/Views/tabPages/support_tab.dart';
import 'package:car_pool_driver/global/global.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../Models/trip.dart';

class MyTrips extends StatefulWidget {
  const MyTrips({Key? key}) : super(key: key);

  @override
  State<MyTrips> createState() => _MyTripsState();
}

class _MyTripsState extends State<MyTrips> {
  final databaseReference = FirebaseDatabase.instance.ref('trips');
  List<Trip> trips = [];

  Future<List<Trip>> getTrips() async {
    List<Trip> itemList = [];

    try {
      final dataSnapshot = await databaseReference
          .orderByChild('driver_id')
          .equalTo(currentFirebaseUser!.uid)
          .once();

      Map<dynamic, dynamic> values =
          dataSnapshot.snapshot.value as Map<dynamic, dynamic>;
      values.forEach((key, value) {
        final item = Trip(
            tripID: value['tripID'],
            driverID: value['driver_id'],
            pickUpLatPos: value['locationLatitude'],
            pickUpLongPos: value['locationLongitude'],
            dropOffLatPos: value['destinationLatitude'],
            dropOffLongPos: value['destinationLongitude'],
            pickUpDistance: 0,
            dropOffDistance: 0,
            destinationLocation: value['destinationLocation'],
            pickUpLocation: value['pickUpLocation'],
            userIDs: [],
            price: value['price'],
            date: value['date'],
            time: value['time'],
            availableSeats: value['availableSeats'],
            passengers: value['passengers']);
        itemList.add(item);
      });
    } catch (e) {
      AlertDialog(semanticLabel: 'Error: $e');
    }
    return itemList;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMyTrips();
  }

  Future<void> getMyTrips() async {
    List<Trip> trips = await getTrips();
    setState(() {
      this.trips = trips;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
          itemCount: trips.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (c)=> MyWidget()));
              },
              child: Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(children: [
                    Row(children: [
                      Image.asset(
                        "images/PickUpDestination.png",
                        width: 40,
                        height: 50,
                      ),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              constraints: const BoxConstraints(maxWidth: 300),
                              child: Text(
                                trips[index].destinationLocation,
                                style: const TextStyle(
                                  fontSize: 16,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            const Divider(),
                            Container(
                              constraints: const BoxConstraints(maxWidth: 300),
                              child: Text(
                                trips[index].pickUpLocation,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                          ])
                    ]),
                    const SizedBox(
                      height: 30,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(trips[index].time),
                            Text(trips[index].date),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Divider(),
                  ])),
            );
          }),
    );
  }
}
