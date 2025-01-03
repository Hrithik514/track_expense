import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter(); // Initialize Hive
  await Hive.openBox<Map>('groupsBox'); // Open the Hive box before running the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Track your Expense'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController memberController = TextEditingController();
  List<String> members = [];

  final Box<Map> groupsBox = Hive.box<Map>('groupsBox'); // Access the Hive box

  void _showCreateGroupDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Create Group'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: groupNameController,
                    decoration: const InputDecoration(
                      labelText: 'Group Name',
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: memberController,
                          decoration: const InputDecoration(
                            labelText: 'Add Members',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          String memberName = memberController.text.trim();
                          if (memberName.isNotEmpty) {
                            setState(() {
                              members.add(memberName);
                              memberController.clear();
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                        ),
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: members.map((member) {
                      return Chip(
                        label: Text(member),
                        deleteIcon: const Icon(Icons.close),
                        onDeleted: () {
                          setState(() {
                            members.remove(member);
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    String groupName = groupNameController.text.trim();
                    if (groupName.isNotEmpty && members.isNotEmpty) {
                      groupsBox.put(groupName, {'members': members});
                      setState(() {
                        groupNameController.clear();
                        members.clear();
                      });
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                  child: const Text('Save'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _navigateToViewEditPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ViewEditGroupsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 5.0,
        shadowColor: Colors.black54,
      ),
      body: Stack(
        children: [
          Positioned(
            top: 20,
            left: 20,
            child: ElevatedButton(
              onPressed: _showCreateGroupDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Create Group',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: OutlinedButton(
              onPressed: _navigateToViewEditPage,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'View/Edit Group',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.deepPurple,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ViewEditGroupsPage extends StatelessWidget {
  const ViewEditGroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Box<Map> groupsBox = Hive.box<Map>('groupsBox'); // Access the Hive box

    return Scaffold(
      appBar: AppBar(
        title: const Text('View/Edit Groups'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        itemCount: groupsBox.keys.length,
        itemBuilder: (context, index) {
          final groupName = groupsBox.keys.toList()[index];
          final members = groupsBox.get(groupName)?['members'];

          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(groupName.toString()),
              subtitle: Text(members.join(', ')),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      // Add Edit functionality here
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      groupsBox.delete(groupName);
                      (context as Element).reassemble();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
