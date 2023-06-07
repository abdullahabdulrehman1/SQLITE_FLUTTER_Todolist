// import 'dart:js_util';

import 'package:flutter/material.dart';
import 'package:sqlite_flutter_crud_connectivity/model/model.dart';
// import 'package:sqlite_flutter_crud_connectivity/model/database_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DBhelper? dbHelper;
  late Future<List<GroceryModel>> dataList;
  @override
  void initState() {
    super.initState();
    dbHelper = DBhelper();
    loaddata();
  }

  void loaddata() async {
    dataList = dbHelper!.getDataList();
  }

  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController();
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: TextField(controller: textController),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            print(textController.text);
          },
          child: Icon(Icons.add),
        ),
        body: Center(
          child: FutureBuilder<List<GroceryModel>>(
            future: dataList,
            builder: (BuildContext context,
                AsyncSnapshot<List<GroceryModel>> snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(snapshot.data![index].title ?? ''),
                      onLongPress: () async {
                        // Remove the task from the database
                        await dbHelper!.delete(snapshot.data![index].id as int);

                        // Update the UI
                        setState(() {
                          snapshot.data!.removeAt(index);
                        });
                      },
                      onTap: () async {
                        // Show a dialog to edit the task
                        String updatedTitle = await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            final TextEditingController _textController =
                                TextEditingController(
                                    text: snapshot.data![index].title);
                            return AlertDialog(
                              title: Text('Update Task'),
                              content: TextField(controller: _textController),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(
                                        context, _textController.text);
                                  },
                                  child: Text('Update'),
                                ),
                              ],
                            );
                          },
                        );

                        // Update the task in the database
                        if (updatedTitle.isNotEmpty) {
                          GroceryModel updatedTask = snapshot.data![index]
                              .copyWith(title: updatedTitle);
                          await dbHelper!.update(updatedTask);

                          // Update the UI
                          setState(() {
                            snapshot.data![index] = updatedTask;
                          });
                        }
                      },
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return CircularProgressIndicator();
              }
            },
          ),
        ),
      ),
    );
  }
}
