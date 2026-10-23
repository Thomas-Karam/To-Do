import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To Do',
      debugShowCheckedModeBanner: false,
      home: App(),
    );
  }
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final title = TextEditingController();
  final description = TextEditingController();
  final time = TextEditingController();
  final date = TextEditingController();

  final titleEdit = TextEditingController();
  final descriptionEdit = TextEditingController();
  final timeEdit = TextEditingController();
  final dateEdit = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.grey.shade200),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
        ),
        title: Text("Hi, dear", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder(
        future: DBHelper().read(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.all(8),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: ListTile(
                    leading: Checkbox(
                      value: snapshot.data![index].isCompleted,
                      onChanged: (value) {
                        setState(() {
                          DBHelper().update(
                            Task(
                              id: snapshot.data![index].id,
                              title: snapshot.data![index].title,
                              description: snapshot.data![index].description,
                              date: snapshot.data![index].date,
                              isCompleted: value!,
                            ),
                            snapshot.data![index].id!,
                          );
                        });
                      },
                    ),
                    title: Text(
                      snapshot.data![index].title!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: snapshot.data![index].isCompleted
                            ? Colors.grey
                            : Colors.black,
                        decoration: snapshot.data![index].isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: .start,
                      children: [
                        Text(snapshot.data![index].description!),
                        Text(snapshot.data![index].date!),
                      ],
                    ),
                    trailing: IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            icon: CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.blue,
                              child: Icon(
                                Icons.edit,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              "Edit Task",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            content: SizedBox(
                              width: double.maxFinite,
                              child: ListView(
                                shrinkWrap: true,
                                padding: EdgeInsets.all(0),
                                children: [
                                  TextField(
                                    controller: titleEdit
                                      ..text = snapshot.data![index].title!,
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.next,
                                    decoration: InputDecoration(
                                      hintText: "Title",
                                      prefixIcon: Icon(Icons.title),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  TextField(
                                    controller: descriptionEdit
                                      ..text =
                                          snapshot.data![index].description!,
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.next,
                                    decoration: InputDecoration(
                                      hintText: "Description",
                                      prefixIcon: Icon(Icons.description),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    spacing: 4,
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: dateEdit
                                            ..text = snapshot.data![index].date!
                                                .split(" - ")
                                                .first,
                                          keyboardType: TextInputType.none,
                                          textInputAction: TextInputAction.next,
                                          onTap: () async {
                                            DateTime? pickedDate =
                                                await showDatePicker(
                                                  context: context,
                                                  initialDate: DateTime.now(),
                                                  firstDate: DateTime(2000),
                                                  lastDate: DateTime(2101),
                                                );
                                            if (pickedDate != null) {
                                              setState(() {
                                                dateEdit.text =
                                                    "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                                              });
                                            }
                                          },
                                          decoration: InputDecoration(
                                            hintText: "Date",
                                            prefixIcon: Icon(
                                              Icons.calendar_today,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: TextField(
                                          controller: timeEdit
                                            ..text = snapshot.data![index].date!
                                                .split(" - ")
                                                .last,
                                          keyboardType: TextInputType.none,
                                          textInputAction: TextInputAction.done,
                                          onTap: () async {
                                            TimeOfDay? pickedTime =
                                                await showTimePicker(
                                                  context: context,
                                                  initialTime: TimeOfDay.now(),
                                                );
                                            if (pickedTime != null) {
                                              setState(() {
                                                timeEdit.text = pickedTime
                                                    .format(context);
                                              });
                                            }
                                          },
                                          decoration: InputDecoration(
                                            hintText: "Time",
                                            prefixIcon: Icon(Icons.access_time),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red[100],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[100],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  if (titleEdit.text.isNotEmpty &&
                                      descriptionEdit.text.isNotEmpty &&
                                      dateEdit.text.isNotEmpty &&
                                      timeEdit.text.isNotEmpty) {
                                    Navigator.pop(context);
                                    setState(() {
                                      DBHelper().update(
                                        Task(
                                          id: snapshot.data![index].id,
                                          title: titleEdit.text,
                                          description: descriptionEdit.text,
                                          date:
                                              "${dateEdit.text} - ${timeEdit.text}",
                                          isCompleted:
                                              snapshot.data![index].isCompleted,
                                        ),
                                        snapshot.data![index].id!,
                                      );
                                    });
                                    titleEdit.clear();
                                    descriptionEdit.clear();
                                    dateEdit.clear();
                                    timeEdit.clear();
                                  }
                                },
                                child: Text(
                                  "Save",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          Colors.grey[200],
                        ),
                        foregroundColor: WidgetStateProperty.all(Colors.blue),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      icon: Icon(Icons.edit, color: Colors.blue),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tileColor: Colors.white,
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              icon: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.green,
                child: Icon(
                  Icons.add_alarm_sharp,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              title: Text(
                "Add New Task",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.all(0),
                  children: [
                    TextField(
                      controller: title,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: "Title",
                        prefixIcon: Icon(Icons.title),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: description,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: "Description",
                        prefixIcon: Icon(Icons.description),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      spacing: 4,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: date,
                            keyboardType: TextInputType.none,
                            textInputAction: TextInputAction.next,
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  date.text =
                                      "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                                });
                              }
                            },
                            decoration: InputDecoration(
                              hintText: "Date",
                              prefixIcon: Icon(Icons.calendar_today),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: time,
                            keyboardType: TextInputType.none,
                            textInputAction: TextInputAction.done,
                            onTap: () async {
                              TimeOfDay? pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (pickedTime != null) {
                                setState(() {
                                  time.text = pickedTime.format(context);
                                });
                              }
                            },
                            decoration: InputDecoration(
                              hintText: "Time",
                              prefixIcon: Icon(Icons.access_time),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[100],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[100],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    if (title.text.isNotEmpty &&
                        description.text.isNotEmpty &&
                        date.text.isNotEmpty &&
                        time.text.isNotEmpty) {
                      Navigator.pop(context);
                      setState(() {
                        DBHelper().insert(
                          Task(
                            title: title.text,
                            description: description.text,
                            date: "${date.text} - ${time.text}",
                            isCompleted: false,
                          ),
                        );
                      });
                      title.clear();
                      description.clear();
                      date.clear();
                      time.clear();
                    }
                  },
                  child: Text(
                    "Add",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        tooltip: 'Add Task',
        child: Icon(Icons.add),
      ),
    );
  }
}

class Task {
  int? id;
  String? title;
  String? description;
  String? date;
  bool isCompleted;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.isCompleted,
  });

  Map<String, Object?> toMap() {
    return {
      'title': title,
      'description': description,
      'date': date,
      'isCompleted': isCompleted,
    };
  }
}

class DBHelper {
  Database? db;

  Future openDB() async {
    WidgetsFlutterBinding.ensureInitialized();
    if (db != null) return db;
    db = await openDatabase(
      join(await getDatabasesPath(), 'tasks.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE tasks(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, description TEXT, date TEXT, isCompleted BOOLEAN)',
        );
      },
      version: 1,
    );
    return db;
  }

  Future<void> insert(Task task) async {
    final db = await openDB();
    await db.insert('tasks', task.toMap());
  }

  Future<List<Task>> read() async {
    final db = await openDB();
    final List<Map<String, Object?>> taskMaps = await db.query('tasks');
    return [
      for (final {
            'id': id as int,
            'title': title as String,
            'description': description as String,
            'date': date as String,
            'isCompleted': isCompleted as int,
          }
          in taskMaps)
        Task(
          id: id,
          title: title,
          description: description,
          date: date,
          isCompleted: isCompleted == 1,
        ),
    ];
  }

  Future<void> update(Task task, int id) async {
    final db = await openDB();
    await db.update('tasks', task.toMap(), where: 'id = ?', whereArgs: [id]);
  }

  Future<void> delete(int id) async {
    final db = await openDB();
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}
