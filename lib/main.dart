import 'package:flutter/material.dart';
import 'package:sqlitetoexcel_example/screens/splash_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

	@override
  Widget build(BuildContext context) {

    return MaterialApp(
	    title: 'UserKeeper',
	    debugShowCheckedModeBanner: false,
	    theme: ThemeData(
		    primarySwatch: Colors.deepPurple
	    ),
	    home: SplashScreen(),
    );
  }
}
