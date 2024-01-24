import 'package:flutter/material.dart';
import 'package:sqflite_crud_application/services/sql_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  List<Map<String, dynamic>> notes = [];
  bool isLoading = true;

  @override
  void initState() {
    refreshNotes();
    super.initState();
  }

  void refreshNotes() async {
    setState(() {
      isLoading = true;
    });
    final List<Map<String, dynamic>> data = await SqlService.getAllItems();
    setState(() {
      notes = data;
      isLoading = false;
    });
  }

  Future<void> addItem() async {
    await SqlService.createItem(title: titleController.text, description: descriptionController.text);
    refreshNotes();
  }

  Future<void> updateItem(int id, String title, String description) async {
    await SqlService.updateItem(id: id, title: title, description: description);
    refreshNotes();
  }

  Future<void> deleteItem(int id) async {
    await SqlService.deleteItem(id: id);
    refreshNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Sqflite CRUD Operations'),
      ),
      body: notes.isEmpty
          ? const Center(
              child: Text("Empty Notes"),
            )
          : ListView.builder(
              itemBuilder: (context, index) {
                final Map<String, dynamic> data = notes[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12).copyWith(top: 12),
                  child: Card(
                    child: ListTile(
                      title: Text(data['title']),
                      subtitle: Text(data['description']),
                      trailing: Wrap(
                        spacing: 10,
                        direction: Axis.horizontal,
                        children: [
                          InkWell(
                            onTap: () {
                              showForm(id: data['id']);
                            },
                            child: const Icon(
                              Icons.edit,
                              size: 22,
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              await deleteItem(data['id']);
                            },
                            child: const Icon(
                              Icons.delete,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              itemCount: notes.length,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showForm(id: null);
        },
        tooltip: 'Add Note',
        child: const Icon(Icons.add),
      ),
    );
  }

  void showForm({required int? id}) async {
    if (id != null) {
      final existingNotes = notes.firstWhere((element) => element['id'] == id);
      titleController.text = existingNotes['title'];
      descriptionController.text = existingNotes['description'];
    } else {
      titleController.text = '';
      descriptionController.text = '';
    }

    return showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16).copyWith(bottom: MediaQuery.of(context).size.width / 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(hintText: "Title"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(hintText: "Description"),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (id == null && titleController.text.isNotEmpty && descriptionController.text.isNotEmpty) {
                    await addItem();
                  } else if (id != null) {
                    await updateItem(id, titleController.text, descriptionController.text);
                  }
                  titleController.text = '';
                  descriptionController.text = '';
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: Text(id == null ? "Create Note" : "Update Note"),
              ),
            ],
          ),
        );
      },
    );
  }
}
