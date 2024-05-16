import 'dart:io' as io;
import 'package:path/path.dart' as p;
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
//import 'package:path_provider/path_provider.dart';

Future main() async {
  // Init ffi loader if needed.
  try{
    sqfliteFfiInit();

    var databaseFactory = databaseFactoryFfi;
    final io.Directory appDocumentsDir = io.Directory.current;   //await getApplicationDocumentsDirectory();
    
    //Create path for database
    String dbPath = p.join(appDocumentsDir.path, "ddir", "myDb.db");
    var db = await databaseFactory.openDatabase(
      dbPath,
    );

    await db.execute('''
    CREATE TABLE Product (
        id INTEGER PRIMARY KEY,
        title TEXT
    )
    ''');
    await db.insert('Product', <String, Object?>{'title': 'Product 1'});
    await db.insert('Product', <String, Object?>{'title': 'Product 1'});

    var result = await db.query('Product');
    print(result);
    // prints [{id: 1, title: Product 1}, {id: 2, title: Product 1}]
    await db.close();
  }catch(err){
    print("Errors encounterd: ${err}");
  }
}
