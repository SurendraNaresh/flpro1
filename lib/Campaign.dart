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
  final Map<String, dynamic> info;
  Campaign({required this.info}) { // Use static counter for ID
  //  Campaign({required this.info}) : fld1 = 0 { // Use static counter for ID
    if (info.isEmpty) {
      throw ArgumentError('Campaign info cannot be empty.');
    }
  }
  static int nextId = 1; // Initialize counter to avoid conflicts
  factory Campaign.fromJson(Map<String, dynamic>? json) {
    final info = json?['info'] as Map<String, dynamic>?;
    if (info != null) {
      return Campaign(info: info);
    } else {
      throw Exception('Missing or invalid "info" field in JSON data');
    }
  }
  Map<String, dynamic> toMap() {
    return {'data': info}; // Return only the 'data' part
    //return {'Person-$id': info}; // Always use "Person-$id" for unique key
  }

@override
  Future<String?> insertRecordOverride(Database db, String tableName) async {
    try{
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
        //final List<String> fieldNames = data.keys.toList()..remove('id'); // Exclude 'id'
        final List<String> fieldNames = this.info.keys.toList();
        final List<String> placeholders = List.generate(fieldNames.length, (i) => '?');
        final insertSql = "INSERT INTO campaign (" + fieldNames.join(',') + ") VALUES (" + placeholders.join(',') + ")";
        // Bind data values securely using a list
        final List<dynamic> bindValues = fieldNames.map((name) => this.info[name]).toList();
        print("$insertSql, ${bindValues.join(', ')}");
        // Execute the parameterized query
        await db.rawInsert(insertSql, bindValues);
        return "$insertSql ${bindValues.join(', ')}";
     } catch(err){
         print('Database errors: ${err}');
         // Fallback for other tables (use default insertRecord behavior)
        //#await super.insertRecord(tableName, data); // Call the base class method
    }
    return null;
  }
}
void main() async{
  List<Campaign> pList = [];
    pList.add(Campaign.fromJson({"info":{"fld2":"Paul Dunkirk", "fld3": "Campaing1","fld4":"yes","fld5": "Campgaign1_Yes"}}));
    pList.add(Campaign.fromJson({"info":{"fld2":"Rebecca Pauline","fld3":"Campaingn2","fld4":"No", "fld5": "Campaign2_No"}}));
  try {
    final dataCrud = DataCrud();
    await dataCrud.initDatabase();
    Database dd = dataCrud.db;
    pList.forEach( (camp) => camp.insertRecordOverride(dd, "campaign")  );
    // Insert or replace the record in the database
    //pList.forEach((p) => dataCrud.insertRecord('infotab',p.info.toString()));
    print("Data saved to SQLite database");
    print("Now read-back data from SQLite database");
    List<Map<String, dynamic>> pL = await dataCrud.getRecords('campaign');
    if (pL != Null) {
      pL.forEach((p) {
        //print (p.toString());
          final id = p?['fld1'];
        //final data = jsonDecode(p['data']);
         print("Data for voter: $id...");
         print("\tUser:          $p['fld2`']}");
         print("\tCampaign_Desc: ${p['fld3']}");
         print("\tVote_for:      ${p['fld4']}");
         print("\tRemoarks:      ${p['fld5']}");
      });
    }
  }catch(err){
    print('Database errors: ${err}');
  }
}
