import 'package:chatbot/db_helper.dart';
import 'package:flutter/material.dart';
import 'package:chatbot/ChatScreen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> conversations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadConversations();
  }

  Future<void> loadConversations() async {
    final db = DbHelper.getDbinstance();
    final data = await db.getAllConversations();
    setState(() {
      conversations = data;
      isLoading = false;
    });
  }

  Future<void> _deleteNote({required String DeleteTableName}) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(
            "Are You ShyureYou Want To delete This Conversition",
            style: TextStyle(fontSize: 15),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.green),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(10),
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (DeleteTableName != null) {
                      final db = DbHelper.getDbinstance();
                      await db.DeleteConversation(dbTableName: DeleteTableName);
                      await loadConversations();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Conversition Deleted Successfully.....",
                          ),
                          backgroundColor: Colors.greenAccent,
                        ),
                      );
                    }
                  },
                  child: const Text("Delete"),
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.redAccent),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _showCreateConversationDialog() async {
    final TextEditingController controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("New Conversation"),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: "Conversation Name",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  final db = DbHelper.getDbinstance();
                  await db.createTable(TableName: name); // ✅ your function
                  await loadConversations(); // refresh list
                  Navigator.pop(context); // close dialog
                }
              },
              child: const Text("Create"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.08,
        title: const Text(
          "Conversations",
          style: TextStyle(fontWeight: FontWeight.w400),
        ),
        backgroundColor: const Color.fromARGB(255, 228, 239, 248),
        elevation: 5,
      ),
      body: conversations.isEmpty
          ? Center(
              child: ElevatedButton.icon(
                onPressed: _showCreateConversationDialog,
                icon: const Icon(Icons.add, size: 28),
                label: const Text(
                  "Start New Conversation",
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 25,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            )
          : ListView.builder(
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final convo = conversations[index];
                final String tableName = convo['table_name'].toString();
                return Card(
                  color: const Color.fromARGB(255, 237, 237, 237),
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    trailing: IconButton(
                      onPressed: () async {
                        await _deleteNote(DeleteTableName: tableName);
                      },
                      icon: Icon(Icons.delete, size: 37),
                    ),
                    title: Text(convo['table_name']),
                    subtitle: Text(
                      "Last updated: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(convo['last_updated']))}",
                      style: const TextStyle(fontSize: 12),
                    ),
                    onTap: () {
                      // open that conversation
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              Chatscreen(TableName: convo['table_name']),
                        ),
                      ).then((_) {
                        loadConversations();
                      });
                    },
                  ),
                );
              },
            ),
      floatingActionButton: conversations.isNotEmpty
          ? FloatingActionButton(
              backgroundColor: const Color.fromARGB(255, 228, 239, 248),
              onPressed: _showCreateConversationDialog,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
