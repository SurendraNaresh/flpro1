import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

void main() => runApp(myWidget_show());

class myWidget_show extends StatelessWidget {
  myWidget_show({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navigating using push-MaterialPageRoute',
      home: myWidget_home(),
    );
  }
}

class myWidget_home extends myWidget_show {
  final String title = 'Hello World';
   
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('This is the New widget page...'),
            ElevatedButton(
              child: Text('Press to go back'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            Row(
               //mainAxisAlignment: MainAxisAlignment.evenlySpaced,
            children: <Widget>[
              Column(
          		children: [
            		Icon(Icons.forward, size: 33),
            		Text('+3+', style: TextStyle(color: Colors.red, fontSize: 33)),
          		],),
           	  Column(
              children: [
            		Icon(Icons.star, size: 33),
            		Text('+4+', style: TextStyle(color: Colors.yellow, fontSize: 33)),
          		],),
              Column(
          		children: [
            		Icon(Icons.bluetooth, size: 33),
            		Text('+5+', style: TextStyle(color: Colors.deepPurple, fontSize: 33)),
          		],
          	  ),
           ],
         ),
        ],
      ),
     ),
    );
  }
}
