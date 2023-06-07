import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import '../global/global.dart';
import '../splashScreen/splash_screen.dart';
import '../widgets/progress_dialog.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController confirmPasswordTextEditingController = TextEditingController();
  TextEditingController carMakeTextEditingController = TextEditingController();
  TextEditingController carModelTextEditingController = TextEditingController();
  TextEditingController carYearTextEditingController = TextEditingController();
  TextEditingController carColorTextEditingController = TextEditingController();
  TextEditingController carPlateNoTextEditingController = TextEditingController();

  List<String> carTypesList = ["Car","Van","Pick-Up","Motor"];
  String? selectedCarType;

  String imageUrl = "";

  File? _driverImage;
  File? _driverLibreImage;
  File? _driverLicenseImage;
  final _storage = FirebaseStorage.instance;


  Future<void> _pickDriverImage() async {
    final pickedImage =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _driverImage = File(pickedImage.path);
      });
    }
  }
  Future<void> _pickDriverLibreImage() async {
    final pickedImage =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _driverLibreImage = File(pickedImage.path);
      });
    }
  }
  Future<void> _pickDriverLicenseImage() async {
    final pickedImage =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _driverLicenseImage = File(pickedImage.path);
      });
    }
  }


  validateForm()
  {
    if(_driverImage == null){
      Fluttertoast.showToast(msg: "Image is required.");
    }
    else if(nameTextEditingController.text.length < 3){
      Fluttertoast.showToast(msg: "Name must be atleast 3 characters.");
    }
    else if(!emailTextEditingController.text.contains("@")){
      Fluttertoast.showToast(msg: "Email not valid.");
    }
    else if(phoneTextEditingController.text.isEmpty){
      Fluttertoast.showToast(msg: "Phone number required.");
    }
    else if(passwordTextEditingController.text.length < 8){
      Fluttertoast.showToast(msg: "Password must be at least 8 characters.");
    }
    else if(passwordTextEditingController.text != confirmPasswordTextEditingController.text){
      Fluttertoast.showToast(msg: "Password must be at least 8 characters.");
    }
    else if(carMakeTextEditingController.text.isEmpty){
      Fluttertoast.showToast(msg: "Car Make required.");
    }
    else if(carModelTextEditingController.text.isEmpty){
      Fluttertoast.showToast(msg: "Car Model required.");
    }
    else if(carColorTextEditingController.text.isEmpty){
      Fluttertoast.showToast(msg: "Car Color required.");
    }
    else if(carPlateNoTextEditingController.text.isEmpty){
      Fluttertoast.showToast(msg: "Car Plate Number required.");
    }
    else if(_driverLibreImage == null){
      Fluttertoast.showToast(msg: "Driver Libre required.");
    }
    else if(_driverLicenseImage == null){
      Fluttertoast.showToast(msg: "Driver License required.");
    }
    else{
     saveDriverInfo();
    }
  }

  saveDriverInfo() async
  {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext c){
          return ProgressDialog(message: "Processing, Pleasa wait...",);
        }
    );

    final User? firebaseUser = (
        await fAuth.createUserWithEmailAndPassword(
            email: emailTextEditingController.text.trim(),
            password: passwordTextEditingController.text.trim(),
        ).catchError((msg){
          Navigator.pop(context);
          Fluttertoast.showToast(msg: "Error: " + msg.toString());

        })
    ).user;
   /* final ref = _storage.ref()
  /      .child('images')
        .child('${DateTime.now().toIso8601String() + }');
*/
    final imageUploadTask = await _storage
        .ref('driverImages/${firebaseUser?.uid}.jpg')
        .putFile(_driverImage!);
    final userImageUrl = await imageUploadTask.ref.getDownloadURL();

    final libreUploadTask = await _storage
        .ref('libreImages/${firebaseUser?.uid}.jpg')
        .putFile(_driverLibreImage!);
    final libreImageUrl = await libreUploadTask.ref.getDownloadURL();

    final licenseUploadTask = await _storage
        .ref('licenseImages/${firebaseUser?.uid}.jpg')
        .putFile(_driverLicenseImage!);
    final licenseImageUrl = await licenseUploadTask.ref.getDownloadURL();
    List<double> list = List.generate(10, (index) => 0.0 );
    if(firebaseUser != null){
      Map driverMap =
      {
        "id": firebaseUser.uid,
        "name" : nameTextEditingController.text.trim(),
        "email": emailTextEditingController.text.trim(),
        "phone": phoneTextEditingController.text.trim(),
        "car_make": carMakeTextEditingController.text.trim(),
        "car_model": carModelTextEditingController.text.trim(),
        "car_year": carYearTextEditingController.text.trim(),
        "car_color": carColorTextEditingController.text.trim(),
        "car_plateNo": carPlateNoTextEditingController.text.trim(),
        "car_type": selectedCarType,
        "driver_image": userImageUrl,
        "driver_libre": libreImageUrl,
        "driver_license": licenseImageUrl,
        "ratings": list,

      };

      DatabaseReference driverRef = FirebaseDatabase.instance.ref().child("drivers");
      driverRef.child(firebaseUser.uid).set(driverMap);

      currentFirebaseUser = firebaseUser;
      Fluttertoast.showToast(msg: "Account has been created!");
      Navigator.push(context, MaterialPageRoute(builder: (c)=> const MySplashScreen() ));
    }
    else{
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Account has not been created!");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 10,),

              const Text(
                "Register as a Driver",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20,),

              CircleAvatar(
                radius: 50,
                backgroundImage: showImage(),
                /*_driverImage != null ? FileImage(_driverImage!) : null*/
              ),
              TextButton.icon(
                  onPressed: _pickDriverImage,
                  icon: const Icon(Icons.image),
                  label: const Text('Add User Image')),
              const SizedBox(height: 20,),
              TextField(
                controller: nameTextEditingController,
                style: const TextStyle(
                  color: Colors.grey
                ),
                decoration: InputDecoration(
                  labelText: "Full Name",
                  hintText: "Full Name",

                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10.0)
                  ),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)
                  ),
                  hintStyle: const TextStyle(
                    color:Colors.grey,
                    fontSize: 10,
                  ),
                  labelStyle: const TextStyle(
                    color:Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 10,),
              TextField(
                controller: emailTextEditingController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(
                    color: Colors.grey
                ),
                decoration: InputDecoration(
                  labelText: "Email",
                  hintText: "Email",

                  enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10.0)
                  ),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)
                  ),
                  hintStyle: const TextStyle(
                    color:Colors.grey,
                    fontSize: 10,
                  ),
                  labelStyle: const TextStyle(
                    color:Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 10,),
              TextField(
                controller: phoneTextEditingController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(
                    color: Colors.grey
                ),
                decoration: InputDecoration(
                  labelText: "Phone Number",
                  hintText: "Phone Number",

                  enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10.0)
                  ),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)
                  ),
                  hintStyle: const TextStyle(
                    color:Colors.grey,
                    fontSize: 10,
                  ),
                  labelStyle: const TextStyle(
                    color:Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 10,),
              TextField(
                controller: passwordTextEditingController,
                keyboardType: TextInputType.text,
                obscureText: true,
                style: const TextStyle(
                    color: Colors.grey
                ),
                decoration: InputDecoration(
                  labelText: "Password",
                  hintText: "Password",

                  enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10.0)
                  ),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)
                  ),
                  hintStyle: const TextStyle(
                    color:Colors.grey,
                    fontSize: 10,
                  ),
                  labelStyle: const TextStyle(
                    color:Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 10,),
              TextField(
                controller: confirmPasswordTextEditingController,
                keyboardType: TextInputType.text,
                obscureText: true,
                style: const TextStyle(
                    color: Colors.grey
                ),
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  hintText: "Confirm Password",

                  enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10.0)
                  ),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)
                  ),
                  hintStyle: const TextStyle(
                    color:Colors.grey,
                    fontSize: 10,
                  ),
                  labelStyle: const TextStyle(
                    color:Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 10,),
              Text('Car Details',
              textAlign: TextAlign.left,
              style: TextStyle(

              ),),
              const SizedBox(height: 5,),
              TextField(
                controller: carMakeTextEditingController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(
                    color: Colors.grey
                ),
                decoration: InputDecoration(
                  labelText: "Car Make",
                  hintText: "Car Make",

                  enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10.0)
                  ),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)
                  ),
                  hintStyle: const TextStyle(
                    color:Colors.grey,
                    fontSize: 10,
                  ),
                  labelStyle: const TextStyle(
                    color:Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 10,),
              TextField(
                controller: carModelTextEditingController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(
                    color: Colors.grey
                ),
                decoration: InputDecoration(
                  labelText: "Car Model",
                  hintText: "Car Model",

                  enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10.0)
                  ),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)
                  ),
                  hintStyle: const TextStyle(
                    color:Colors.grey,
                    fontSize: 10,
                  ),
                  labelStyle: const TextStyle(
                    color:Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 10,),
              TextField(
                controller: carYearTextEditingController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(
                    color: Colors.grey
                ),
                decoration: InputDecoration(
                  labelText: "Car Year",
                  hintText: "Car Year",

                  enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10.0)
                  ),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)
                  ),
                  hintStyle: const TextStyle(
                    color:Colors.grey,
                    fontSize: 10,
                  ),
                  labelStyle: const TextStyle(
                    color:Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 10,),
              TextField(
                controller: carPlateNoTextEditingController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(
                    color: Colors.grey
                ),
                decoration: InputDecoration(
                  labelText: "Car Plate No",
                  hintText: "Car Plate No",

                  enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10.0)
                  ),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)
                  ),
                  hintStyle: const TextStyle(
                    color:Colors.grey,
                    fontSize: 10,
                  ),
                  labelStyle: const TextStyle(
                    color:Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 10,),
              TextField(
                controller: carColorTextEditingController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(
                    color: Colors.grey
                ),
                decoration: InputDecoration(
                  labelText: "Car Color",
                  hintText: "Car Color",

                  enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10.0)
                  ),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)
                  ),
                  hintStyle: const TextStyle(
                    color:Colors.grey,
                    fontSize: 10,
                  ),
                  labelStyle: const TextStyle(
                    color:Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 10,),
              DropdownButtonFormField(
                  hint: const Text(
                      "Choose Car Type",
                      style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey
                      )
                  ),
                  value: selectedCarType,
                  onChanged: (newValue){
                    setState(() {
                      selectedCarType = newValue.toString();
                    });
                  },
                  items: carTypesList.map((car){
                    return DropdownMenuItem(
                      value : car,
                      child: Text(
                        car,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10.0)
                    ),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey)
                    ),
                  ),
              ),
              const SizedBox(height: 10,),
              Row(
                children: [
                  Text('Libre:'),
                  TextButton.icon(
                      onPressed: _pickDriverLibreImage,
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Add Libre')),
                ],
              ),
              const SizedBox(height: 10,),
              Row(
                children: [
                  Text('License:'),
                  TextButton.icon(
                      onPressed: _pickDriverLicenseImage,
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Add License')),
                ],
              ),
              const SizedBox(height: 20,),
              SizedBox(
                height: 50,
                width:300,
                child: ElevatedButton(
                    onPressed: (){
                      validateForm();

                      //Navigator.push(context, MaterialPageRoute(builder: (c)=> CarInfoScreen()));

                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.greenAccent,
                      elevation: 3,
                      shape: RoundedRectangleBorder( //to set border radius to button
                          borderRadius: BorderRadius.circular(10)
                      ),
                    ),
                    child: const Text(
                      "Create Account",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,

                      ),
                    )),
              ),
              RichText(
                  text: TextSpan(children: <TextSpan>[
                    const TextSpan(
                        text: "Already have an account? ",
                        style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w300,
                            fontFamily: 'Poppins',
                            color: Colors.black)),
                    TextSpan(
                        text: "Sign In",
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (c)=> LoginScreen())),
                        style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                            color: Colors.lightBlue)),
                  ])),

            ],
          ),
        ),
      )
    );
  }
  showImage(){
    if(_driverImage != null){
      return FileImage(_driverImage!);
    }
    else{
      return NetworkImage('https://cdn-icons-png.flaticon.com/512/149/149071.png?w=740&t=st=1683266721~exp=1683267321~hmac=8e779c28c4550a41532c0c72eb23cf01cbd8554efea491442d7f528bc84bdcc4');
    }
  }
}
