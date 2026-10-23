import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:todo/feature/data/date.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final title = TextEditingController();
  final description = TextEditingController();
  final time = TextEditingController();
  final date = TextEditingController();

  final titleEdit = TextEditingController();
  final descriptionEdit = TextEditingController();
  final timeEdit = TextEditingController();
  final dateEdit = TextEditingController();

  DateTime _parseTaskDate(String value) {
    return DateTime.parse(value).toLocal();
  }

  String _formatDate(DateTime value) {
    return DateFormat('dd/MM/yyyy').format(value);
  }

  String _formatTime(DateTime value) {
    return DateFormat('HH:mm').format(value);
  }

  DateTime _dateTimeFromControllers(
    TextEditingController dateController,
    TextEditingController timeController,
  ) {
    return DateFormat('dd/MM/yyyy HH:mm')
        .parseStrict('${dateController.text} ${timeController.text}');
  }

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    time.dispose();
    date.dispose();
    titleEdit.dispose();
    descriptionEdit.dispose();
    timeEdit.dispose();
    dateEdit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Hi, dear 👋",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<Task>>(
        future: DBHelper().read(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final tasks = [...snapshot.data!]
              ..sort(
                (first, second) =>
                    _parseTaskDate(first.date!)
                        .compareTo(_parseTaskDate(second.date!)),
              );

            return ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.all(8),
              itemCount: tasks.length,
              separatorBuilder: (context, index) {
                return SizedBox(height: 8);
              },
              itemBuilder: (context, index) {
                final task = tasks[index];
                DateTime currentDate = _parseTaskDate(task.date!);
                final previousDate = index > 0
                    ? _parseTaskDate(tasks[index - 1].date!)
                    : null;

                return Column(
                  spacing: 4,
                  crossAxisAlignment: .start,
                  children: [
                    if (previousDate == null ||
                        currentDate.year != previousDate.year ||
                        currentDate.month != previousDate.month ||
                        currentDate.day != previousDate.day)
                      Text(
                        DateFormat.MMMMd().format(currentDate),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ListTile(
                      leading: Checkbox(
                        value: task.isCompleted,
                        onChanged: (value) {
                          setState(() {
                            DBHelper().update(
                              Task(
                                id: task.id,
                                title: task.title,
                                description: task.description,
                                date: task.date,
                                isCompleted: value!,
                              ),
                              task.id!,
                            );
                          });
                        },
                      ),
                      title: Text(
                        task.title!,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: task.isCompleted ? Colors.grey : Colors.black,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: .start,
                        children: [
                          Text(task.description!),
                          Text(DateFormat('d MMMM h:mm a').format(currentDate)),
                        ],
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            icon: CircleAvatar(
                              radius: 40,
                              backgroundColor: Color(0xff3B82F6),
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
                                children: [
                                  TextField(
                                    controller: titleEdit..text = task.title!,
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
                                      ..text = task.description!,
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
                                            ..text = _formatDate(currentDate),
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
                                              dateEdit.text = _formatDate(
                                                pickedDate,
                                              );
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
                                            ..text = _formatTime(currentDate),
                                          keyboardType: TextInputType.none,
                                          textInputAction: TextInputAction.done,
                                          onTap: () async {
                                            TimeOfDay? pickedTime =
                                                await showTimePicker(
                                                  context: context,
                                                  initialTime: TimeOfDay.now(),
                                                );
                                            if (pickedTime != null) {
                                              timeEdit.text =
                                                  '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
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
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
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
                                  backgroundColor: Colors.green.shade100,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
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
                                          id: task.id,
                                          title: titleEdit.text,
                                          description: descriptionEdit.text,
                                          date: _dateTimeFromControllers(
                                            dateEdit,
                                            timeEdit,
                                          ).toIso8601String(),
                                          isCompleted: task.isCompleted,
                                        ),
                                        task.id!,
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
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      tileColor: Colors.grey.shade100,
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Task',
        backgroundColor: Colors.grey.shade300,
        child: Icon(Icons.add_rounded, color: Color(0xff3B82F6)),
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
                backgroundColor: Color(0xff3B82F6),
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
                                date.text = _formatDate(pickedDate);
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
                                time.text =
                                    '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
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
                      borderRadius: BorderRadius.circular(12),
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
                    backgroundColor: Colors.green.shade100,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
                            date: _dateTimeFromControllers(
                              date,
                              time,
                            ).toIso8601String(),
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
                    "Add Task",
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
      ),
    );
  }
}
