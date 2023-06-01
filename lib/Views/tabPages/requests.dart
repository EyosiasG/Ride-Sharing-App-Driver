import 'dart:async';

import 'package:car_pool_driver/global/global.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../Models/requests.dart';
import '../../Models/trip.dart';

class GetRequests {
  final databaseReference = FirebaseDatabase.instance.ref('requests');

  Future<List<Request>> getRequests(String driverID) async {
    List<Request> itemList = [];
    // Get a reference to the Firebase database

    try {
      // Retrieve all items with the specified color
      final dataSnapshot = await databaseReference
          .orderByChild('driverID')
          .equalTo(driverID)
          .once();

      // Convert the retrieved data to a list of Item objects

      Map<dynamic, dynamic> values =
      dataSnapshot.snapshot.value as Map<dynamic, dynamic>;
      values.forEach((key, value) {
        final item = Request(
            requestID: value['requestID'],
            tripID: value['tripID'],
            driverID: value['driverID'],
            userID: value['userID'],
            status: value['status']);
        itemList.add(item);
      });
    } catch (e) {
      // Log the error and return an empty list
      print('Error: $e');
    }
    return itemList;
  }
}

class MyRequests extends StatefulWidget {
  const MyRequests({Key? key}) : super(key: key);

  @override
  State<MyRequests> createState() => _MyRequestsState();
}

class _MyRequestsState extends State<MyRequests> {
  final GetRequests getRequests = GetRequests();
  List<Request> pendingRequest = [];
  List<Request> requests = [];
  List<bool> _isAcceptButtonClickedList = [];
  List<bool> _isDenyButtonClickedList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMyRequests();
  }

  Future<void> getMyRequests() async {
    List<Request> requests =
    await getRequests.getRequests(currentFirebaseUser!.uid.toString());
    setState(() {
      this.requests = requests;
      _isAcceptButtonClickedList = List.filled(requests.length, false);
      _isDenyButtonClickedList = List.filled(requests.length, false);
      for (var r in requests) {
        if (r.status == 'pending') pendingRequest.add(r);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: (pendingRequest.isNotEmpty)
          ? const Color(0xFFEDEDED)
          : Colors.white,
      body: ListView.builder(
          itemCount: (pendingRequest.isEmpty) ? 1 : pendingRequest.length,
          itemBuilder: (context, index) {
            if (pendingRequest.length == 0) {
              return Center(
                child:Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "images/noRequests.jpg",
                      height: 300,
                    ),
                    const SizedBox(height: 25,),
                    const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Center(
                        child: Text(
                          "It seems you have no ride requests for now!!! ",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 28,
                            color: Colors.blueGrey
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                  ],
                ),
              );
            }

            else {
              return Expanded(
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
                                //trips[index].destinationLocation.toString(),
                                'Lideta Condominium',
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const Divider(),
                            Container(
                              constraints: const BoxConstraints(maxWidth: 300),
                              child: Text(
                                //trips[index].pickUpLocation.toString(),
                                'Nefas Silk Lafto',
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
                            Text('3:00 PM'),
                            Text(pendingRequest[index].tripID.toString()),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Divider(),
                    Row(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(
                                'https://img.freepik.com/free-photo/indoor-shot-glad-young-bearded-man-mustache-wears-denim-shirt-smiles-happily_273609-8698.jpg?w=1060&t=st=1684762104~exp=1684762704~hmac=f48dc7b69b41deac29bbf849e5020a36b4e19b7f2c32048e2950f9f6028927bf',
                              ),
                              radius: 35,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text('Abebe Kebede',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      )),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        0.0, 0, 3.0, 0),
                                    child: Text('0911536221'),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        const Spacer(),
                        Column(
                          children: [
                            SizedBox(
                              height: 40,
                              width: 125,
                              child: ElevatedButton(
                                onPressed:
                                //acceptRequest(requests[index]);
                                _isAcceptButtonClickedList[index]
                                    ? null
                                    : () => _onAcceptButtonPressed(index),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.greenAccent,
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                child: Text(
                                  _isAcceptButtonClickedList[index]
                                      ? 'Accepted'
                                      : 'Accept',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              height: 40,
                              width: 125,
                              child: ElevatedButton(
                                onPressed: _isDenyButtonClickedList[index]
                                    ? null
                                    : () => _onDenyButtonPressed(index),
                                //denyRequest(requests[index]);

                                style: ElevatedButton.styleFrom(
                                  primary: Colors.redAccent,
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                child: Text(
                                  _isDenyButtonClickedList[index]
                                      ? 'Denied'
                                      : 'Deny',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ]),
                ),
              );
            }
          }),
    );
  }

  Future<void> acceptRequest(Request request) async {
    String totalSeats, availableSeats;
    final ref = FirebaseDatabase.instance.ref();
    final snapshot =
    await ref.child('trips/${request.tripID}/availableSeats').get();
    if (snapshot.exists) {
      availableSeats = snapshot.value.toString();
      updateAvailableSeats(request, availableSeats);
    } else {
      print('No data available.');
    }

    FirebaseDatabase.instance
        .ref("requests")
        .child(request.requestID)
        .update({"status": "accepted"});
  }

  Future<void> updateAvailableSeats(Request request, String data) async {
    String seat = "";
    final ref = FirebaseDatabase.instance.ref();
    final snapshot =
    await ref.child('trips/${request.tripID}/passengers').get();
    if (snapshot.exists) {
      seat = snapshot.value.toString()[0];
    } else {
      print('No data available.');
    }

    FirebaseDatabase.instance
        .ref("trips")
        .child(request.tripID)
        .update({"availableSeats": (int.parse(data) - 1).toString()});

    FirebaseDatabase.instance
        .ref("trips")
        .child(request.tripID)
        .child("passengerIDs")
        .update({"${int.parse(seat) - int.parse(data)}": request.userID});
  }

  Future<void> denyRequest(Request request) async {
    List<Object?> seats = [];
    final ref = FirebaseDatabase.instance.ref();
    final snapshot =
    await ref.child('trips/${request.tripID}/passengerIDs').get();
    if (snapshot.exists) {
      seats = snapshot.value as List<Object?>? ?? [];
    } else {
      print('No data available.');
    }
    String availableSeats;
    int i = 0;
    for (var seat in seats) {
      if (seat == request.userID) {
        final snapshot =
        await ref.child('trips/${request.tripID}/availableSeats').get();
        if (snapshot.exists) {
          availableSeats = snapshot.value.toString();
          FirebaseDatabase.instance.ref("trips").child(request.tripID).update(
              {"availableSeats": (int.parse(availableSeats) + 1).toString()});
          FirebaseDatabase.instance
              .ref("trips")
              .child(request.tripID)
              .child("passengerIDs")
              .update({"${i}": ""});
        } else {
          print('No data available.');
        }
      }
    }

    FirebaseDatabase.instance
        .ref("requests")
        .child(request.requestID)
        .update({"status": "rejected"});
  }

  void _onAcceptButtonPressed(int index) {
    setState(() {
      _isAcceptButtonClickedList[index] = true;
      _isDenyButtonClickedList[index] = false;
    });
    acceptRequest(pendingRequest[index]);
  }

  void _onDenyButtonPressed(int index) {
    setState(() {
      _isDenyButtonClickedList[index] = true;
      _isAcceptButtonClickedList[index] = false;
    });
    denyRequest(pendingRequest[index]);
    // Perform some action here...
  }
}
