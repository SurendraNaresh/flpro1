
// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'newlogs.dart';
import 'dart:convert';
import 'LoggerWidget.dart';

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
  int clogctr = 0; 	
  String? contextData;
  late  Logger? vlog; // Declare logger outside initState
   
  Map<String, dynamic> getContextData() {
	Map<String, dynamic> cData = {};

	cData?['User_name'] = userName ;
	cData?['campaign_desc'] = campaignDescription ;
    cData?['vote'] = vote;
    cData?['remark'] = remark;
    contextData = jsonEncode(cData); 
     
    return cData;
  }
  @override
  Widget build(BuildContext context) {
	vlog = LoggerWidget?.of(context); // Access context here
	vlog?.addData('import_show_comp', 'version_001'); // Use pre-fetched logger
	vlog?.writeLog();

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
				var dcode = (clogctr % 3 == 0) ? 'No' : ((clogctr % 2 == 0) ? 'Yes' : 'Abs');
                if (userName?.toLowerCase() == 'user-(o)ne' && password != 'N0nekn0ws') {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text('Invalid Password'),
                      content: Text('Please enter the correct password.'),
                      actions: [
                        TextButton(
							onPressed: () 
							{
								if ( Navigator.of(context).canPop() ) 
								{
									Navigator.of(context).pop();
                                }
                            },
                            child: Text('OK on enterPassword dialog'),
						),
                     ],
                    ),
                   );
                }
                else
                {
					clogctr = clogctr + 1;
					getContextData();
					vlog?.addData('voter_${clogctr}','"data": ${contextData}' );
					vlog?.writeLog();
					// Write Logic here to save the data and navigate back
					Navigator.pop(context, contextData);
                } 
                
              },
              child: Container(
					  color: Colors.grey,
					  child: Row( children: <Widget> [
						Text("Submit-vote", style: TextStyle(color: Colors.deepPurple)),
						Spacer(),
						Text("Save-data", style: TextStyle(color: Colors.green )),
					  ]),
					),
            ),   //Submit_ElevatedButton
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
