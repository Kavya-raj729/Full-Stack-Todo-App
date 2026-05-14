import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {

  List<dynamic> tasks = [];

  final taskController =
  TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    loadTasks();
  }

  // =========================
  // LOAD TASKS
  // =========================

  Future<void> loadTasks() async {

    setState(() {
      isLoading = true;
    });

    final fetchedTasks =
    await ApiService.getTasks();

    setState(() {
      tasks = fetchedTasks;
      isLoading = false;
    });
  }

  // =========================
  // ADD TASK
  // =========================

  Future<void> addTask() async {

    if (taskController.text
        .trim()
        .isEmpty) {
      return;
    }

    bool success =
    await ApiService.createTask(
      taskController.text.trim(),
    );

    if (success) {

      taskController.clear();

      await loadTasks();
    }
  }

  // =========================
  // DELETE TASK
  // =========================

  Future<void> deleteTask(
      int id,
      ) async {

    bool success =
    await ApiService.deleteTask(
      id,
    );

    if (success) {

      tasks.removeWhere(
            (task) =>
        task['id'] == id,
      );

      setState(() {});
    }
  }

  // =========================
  // LOGOUT
  // =========================

  Future<void> logout() async {

    SharedPreferences prefs =
    await SharedPreferences
        .getInstance();

    await prefs.clear();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) =>
        const LoginScreen(),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          'Todo App',
        ),

        centerTitle: true,

        actions: [

          IconButton(

            onPressed: logout,

            icon: const Icon(
              Icons.logout,
            ),
          )
        ],
      ),

      body: Padding(

        padding:
        const EdgeInsets.all(20),

        child: Column(
          children: [

            // ===================
            // ADD TASK
            // ===================

            Row(
              children: [

                Expanded(
                  child: TextField(

                    controller:
                    taskController,

                    decoration:
                    InputDecoration(

                      hintText:
                      'Add New Task',

                      filled: true,

                      fillColor:
                      Colors.white,

                      border:
                      OutlineInputBorder(

                        borderRadius:
                        BorderRadius.circular(
                          12,
                        ),

                        borderSide:
                        BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                ElevatedButton(

                  style:
                  ElevatedButton.styleFrom(

                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                  ),

                  onPressed: addTask,

                  child: const Text(
                    'Add',
                  ),
                )
              ],
            ),

            const SizedBox(height: 20),

            // ===================
            // TASK LIST
            // ===================

            Expanded(

              child: isLoading

                  ? const Center(
                child:
                CircularProgressIndicator(),
              )

                  : tasks.isEmpty

                  ? const Center(
                child: Text(
                  'No Tasks Yet',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              )

                  : ListView.builder(

                itemCount:
                tasks.length,

                itemBuilder:
                    (context, index) {

                  final task =
                  tasks[index];

                  return Card(

                    elevation: 3,

                    margin:
                    const EdgeInsets.only(
                      bottom: 15,
                    ),

                    shape:
                    RoundedRectangleBorder(

                      borderRadius:
                      BorderRadius.circular(
                        16,
                      ),
                    ),

                    child: ListTile(

                      leading: const Icon(
                        Icons.task_alt,
                        color: Colors.deepPurple,
                      ),

                      title: Text(

                        task['title'],

                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),

                      trailing:
                      IconButton(

                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),

                        onPressed: () {

                          deleteTask(
                            task['id'],
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}