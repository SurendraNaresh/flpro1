// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'newlogs.dart';
import 'dart:convert';
class LoggerWidget extends InheritedWidget {
  final Logger logger;

  LoggerWidget({
    required this.logger,
    required Widget child,
  }) : super(child: child);

  static Logger? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LoggerWidget>()?.logger;
  }

  @override
  bool updateShouldNotify(LoggerWidget oldWidget) {
    return oldWidget.logger != logger;
  }
}

class ShowSignatureApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Signature Campaign App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SignatureCampaignApp(),
    );
  }
}

class SignatureCampaignApp extends StatefulWidget {
  @override
  _SignatureCampaignAppState createState() => _SignatureCampaignAppState();
}

class _SignatureCampaignAppState extends State<SignatureCampaignApp> {
  String? userName = '';
  String? campaignDescription = '';
  //String? vote = '';
  String? vote = 'Yes';  // Initialize vote with 'Yes'
  String? remark = '';
  String? password = '';
  TextEditingController passwordController = TextEditingController();
  int? Userctr = 0; 	
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Signature Campaign'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'User Name',
              ),
              onChanged: (value) {
                setState(() {
                  userName = value;
                });
              },
            ),
            SizedBox(height: 16.0),
            TextField(
              decoration: InputDecoration(
                labelText: 'Campaign Description',
              ),
              onChanged: (value) {
                setState(() {
                  campaignDescription = value;
                });
              },
            ),
            SizedBox(height: 16.0),
            DropdownButtonFormField(
              value: vote,
              onChanged: (value) {
                setState(() {
                  vote = value.toString();
                });
              },
              items: [
                DropdownMenuItem(value: 'Yes', child: Text('Yes (pro) vote')),
                DropdownMenuItem(value: 'No', child: Text('Against vote')),
                DropdownMenuItem(value: 'Abstain', child: Text('Abstain vote')),
              ],
              decoration: InputDecoration(
                labelText: 'Vote',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              decoration: InputDecoration(
                labelText: 'Remark (Optional)',
              ),
              onChanged: (value) {
                setState(() {
                  remark = value;
                });
              },
            ),
            if (userName?.toLowerCase() == 'user-one') ...[
              SizedBox(height: 16.0),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
                onChanged: (value) {
                  setState(() {
                    password = value;
                  });
                },
              ),
            ],
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                String contextData=jsonEncode({'User_name': userName,
                                    	'campaign_desc': campaignDescription,
                                    	'vote': vote,
                                    	'remark': remark,});
                                 	
                if (userName?.toLowerCase() == 'user-(o)ne' && password != 'N0nekn0ws') {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text('Invalid Password'),
                      content: Text('Please enter the correct password.'),
                      actions: [
                          TextButton(
                          onPressed: () {// insted of pop should log message
                            print('<got-password-user-(o)ne)>');
                            //Navigator.pop(context);
                             Navigator.pop(context, contextData);
                          },
                          child: Text('OK on enterPassword dialog'),
                        ),
                        
                      ],
                    ),
                  );
                }  else {
					Userctr=Userctr + 1;
      LoggerWidget.of(context)?.addData('voter_${Userctr}','"data": ${contextData}'+ );
      LoggerWidget.of(context)?.writeLog();
                  // Logic to save the data and navigate back
                  Navigator.pop(context, contextData);
                } 
              },
              child: Text("Submit-vote"),
            ),
          ],
        ),
      ),
    );
  }
}
void main() async {
  //runApp(ShowSignatureApp());
  Logger logger = Logger('signLog', 'signLog.csv');
  logger.addData('Voter_0.24', '00.01');
  print("writing to ${logger.logFile}");
  runApp(
    LoggerWidget(
      logger: logger,
      child: ShowSignatureApp(),
    ),
  );
  logger.stop();
  await logger.writeLog();
}



