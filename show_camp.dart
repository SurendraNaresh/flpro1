import 'package:flutter/material.dart';
import 'newlogs.dart';
import 'dart:async';
import 'dart:convert';
import 'LoggerWidget.dart';
import 'VoteSaveSubmit.dart';
import 'datacrud.dart';


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
  //String? contextData;
  late  Logger? vlog; // Declare logger outside initState
   
  Map<String, dynamic> getContextData() {
	Map<String, dynamic> cData = {};

	cData?['User_name'] = userName ;
	cData?['campaign_desc'] = campaignDescription ;
    cData?['vote'] = vote;
    cData?['remark'] = remark;
    //contextData = jsonEncode(cData); 
     
    return cData;
  }
  Future<void> saveData() async {
    // Simulate writing to a file (replace with actual SQL file operations)
    final data = getContextData();
      // Initialize the database
	  final dataCrud = DataCrud();
	  await dataCrud.initDatabase();
    // Insert or replace the record in the database
	  await dataCrud.insertRecord(jsonEncode(data));
	  print("Data saved to SQLite database");
    // vlog = Logger('signLog', 'signLog.csv');
    // vlog?.addData('voter_${clogctr} ', '"data": ${data}');
    // vlog?.writeLog();
	return null;
  }

  Future<void> saveAndSubmit() async {
    clogctr = clogctr + 1;
    String? ctxData = jsonEncode(getContextData());
    vlog?.addData('voter_${clogctr}', ctxData);
    vlog?.stop();
    vlog?.writeLog();
    return null;
  }
  // Placeholder for vlog and parent-context variables
  // dynamic vlog; // Placeholder for the vlog variable
  // dynamic parentContext; // Placeholder for the parent-context variable
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
    		// Wrapped ..[]..VoteAndSaveNavigation(saveAndSubmit, saveData),  
			VoteAndSaveNavigation (
              onSubmitCallback: () async {
                print("Submit button clicked");
                await saveAndSubmit();
        				if (Navigator.of(context).canPop()) {
				          	Navigator.of(context).pop(context); // Navigate back        
                }
        				//Navigator.of(context).pop(context);
              },
              onSaveCallback: () async {
				        await saveData();
                print("Save button clicked");
                // Optionally handle separate onSaveCallback logic here
              },
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
