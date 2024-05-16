/*//#:[Campaign.dart] : 
* purpose to insert sqlformat data for camp.db (campaign)
*
*
*********************************/
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'datacrud.dart';
import 'dart:convert';
import 'dart:io';

class Campaign extends DataCrud {
// ... other Campaign class members (if any) ...
@override
  Future<String?> insertRecordOverride(Database db, String tableName, Map<String, dynamic> data) async {
    try{
      if (tableName == 'campaign') {
        // Create the campaign table if it doesn't exist
        await db.execute('''
          CREATE TABLE IF NOT EXISTS campaign (
            fld1 INTEGER PRIMARY KEY AUTOINCREMENT,
            fld2 TEXT NOT NULL,
            fld3 TEXT NOT NULL,
            fld4 TEXT NOT NULL,
            fld5 TEXT
          );
        ''');
        // Build the list of field names and placeholders for parameterized query
        final List<String> fieldNames = data.keys.toList()..remove('id'); // Exclude 'id'
        final List<String> placeholders = List.generate(fieldNames.length, (i) => '?');
        final insertSql = "INSERT INTO $tableName (" + fieldNames.join(',') + ") VALUES (" + placeholders.join(',') + ")";

        // Bind data values securely using a list
        final List<dynamic> bindValues = fieldNames.map((name) => data[name]).toList();
        print("$insertSql, ${bindValues.join(', ')}");
        // Execute the parameterized query
        //await db.rawInsert(insertSql, bindValues);
        return insertSql;
      }
    } catch(err){
      print('Database errors: ${err}');
    }
    // Fallback for other tables (use default insertRecord behavior)
    //#await super.insertRecord(tableName, data); // Call the base class method
  }

}
class TestModule extends StatefulWidget {
  const TestModule({Key? key}) : super(key: key);

  @override
  State<TestModule> createState() => _TestModuleState();
}

class _TestModuleState extends State<TestModule> {
  final dataCrud = DataCrud(); // Create a DataCrud instance
  final String title = 'Overide DBhandler subclass module';

  final voterNameController = TextEditingController();
  final campaignDescController = TextEditingController();
  final voteController = TextEditingController();
  final remarkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initDatabase();
  }

  Future<void> initDatabase() async {
    try {
      await dataCrud.initDatabase();
    } catch (error) {
      print('Error initializing database: $error');
    }
  }

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
            Text('This is the Campaign widget test page...'),
            TextField(
              controller: voterNameController,
              decoration: InputDecoration(
                labelText: 'Voter Name',
              ),
            ),
            TextField(
              controller: campaignDescController,
              decoration: InputDecoration(
                labelText: 'Campaign Description',
              ),
            ),
            TextField(
              controller: voteController,
              decoration: InputDecoration(
                labelText: 'Vote',
              ),
            ),
            TextField(
              controller: remarkController,
              decoration: InputDecoration(
                labelText: 'Remark',
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final voterName = voterNameController.text;
                final campaignDesc = campaignDescController.text;
                final vote = voteController.text;
                final remark = remarkController.text;

                if (voterName.isEmpty || campaignDesc.isEmpty || vote.isEmpty) {
                  // Show error message (optional)
                  print('Please fill in all required fields');
                  return;
                }

                final campaignData = {
                  "Voter_Name": voterName,
                  "Campaign_Desc": campaignDesc,
                  "Vote": vote,
                  "Remark": remark,
                };

                try {
                  final db = dataCrud.db;
                  //await dataCrud.insertRecordOverride(db, 'campaign', campaignData);
                  Campaign myCamp = Campaign(); //#: insert sqlformat row/column campaign table    
                  //await myCamp.insertRecordOverride(dataCrud.db, 'Campaign', {"Campaign":"$campData"});  
                  await myCamp.insertRecordOverride(db, 'Campaign', campaignData);  
                  print('Campaign data inserted successfully');

                  // Clear text fields after successful insertion (optional)
                  voterNameController.text = '';
                  campaignDescController.text = '';
                  voteController.text = '';
                  remarkController.text = '';

                  // Potentially show a success message (optional)
                } catch (error) {
                  print('Error inserting campaign data: $error');
                }
              },
              child: const Text('Insert Campaign Data'),
            ),
            Spacer(),
            ElevatedButton(
              child: Text('Press to go back'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
void main() => runApp(myTestPage());

class myTestPage extends StatelessWidget {
  myTestPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navigating dbHandler Campaign Test ',
      home: TestModule(),
    );
  }
}
