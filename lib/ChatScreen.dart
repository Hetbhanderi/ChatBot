import 'dart:async';
import 'dart:convert';

import 'package:chatbot/db_helper.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:shimmer/shimmer.dart';

class Chatscreen extends StatefulWidget {
  final String TableName;

  const Chatscreen({super.key, required this.TableName});
  @override
  State<Chatscreen> createState() => _ChatscreenState();
}

final Formkey = GlobalKey<FormState>();
TextEditingController MessageController = TextEditingController();
final ScrollController _scrollController = ScrollController();
List<Map<String, dynamic>> _messages = [];
bool isLoading = false;

bool isconnectedTointernet = false;

StreamSubscription? _internetconnectionStreamSubscription;

class _ChatscreenState extends State<Chatscreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _internetconnectionStreamSubscription = InternetConnection().onStatusChange
        .listen((event) {
          print(
            "---------------------------------------------------$event------------------------------------------------------",
          );
          switch (event) {
            case InternetStatus.connected:
              setState(() {
                isconnectedTointernet = true;
              });
              break;
            case InternetStatus.disconnected:
              setState(() {
                isconnectedTointernet = false;
              });
              break;
            default:
              setState(() {
                isconnectedTointernet = false;
              });
              break;
          }
        });
    _loadMessages();
  }

  @override
  void dispose() {
    _internetconnectionStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.TableName}"),
        backgroundColor: const Color.fromARGB(255, 228, 239, 248),
        elevation: 5,
      ),
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller:
                  _scrollController, // 🔹 add this if you want auto-scroll
              itemCount: _messages.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                // Show shimmer for last message when loading
                if (isLoading && index == _messages.length) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            height: 16,
                            width: 150,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                }

                final msg = _messages[index];
                final isUser = msg["role"] == "user";

                return Container(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 12,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: GptMarkdown(
                      msg["text"],
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: Form(
              key: Formkey,
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.08,
                      child: TextFormField(
                        style: TextStyle(
                          fontSize:
                              (MediaQuery.of(context).size.height * 0.026) *
                              0.9,
                        ),
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.send,
                        controller: MessageController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical:
                                (MediaQuery.of(context).size.height * 0.08) *
                                0.28,
                            horizontal:
                                (MediaQuery.of(context).size.height * 0.08) *
                                0.2,
                          ),
                          hintText: "Search",
                          hintStyle: TextStyle(
                            fontSize:
                                (MediaQuery.of(context).size.height * 0.025) *
                                0.9,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                            ),
                            borderSide: BorderSide(width: 1.5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                            ),
                            borderSide: BorderSide(width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                            ),
                            borderSide: BorderSide(width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty || value == "") {
                            return "Enter Email for Search";
                          } else {
                            return null;
                          }
                        },
                        onFieldSubmitted: (value) {
                          if (Formkey.currentState!.validate()) {
                            ChatMessage(
                              message: MessageController.text.toString(),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.08,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        border: Border.all(color: Colors.black, width: 1.5),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: IconButton(
                        color: Colors.black,
                        onPressed: () async {
                          if (Formkey.currentState!.validate()) {
                            ChatMessage(
                              message: MessageController.text.toString(),
                            );
                            FocusScope.of(context).unfocus();
                          }
                        },
                        icon: Icon(Icons.send, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  ChatMessage({required String message}) async {
    if (isconnectedTointernet == false) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("⚠️ No Internet Connection")));
      return; // stop here
    }

    const apiKey = ""; // add your api key
    // if url not works use url that given in website when get api
    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent",
    );
    await DbHelper.getDbinstance().saveMessage(
      role: "user",
      text: message,
      TableName: widget.TableName,
    );
    await _loadMessages();
    final allMessages = await DbHelper.getDbinstance().getmessages(
      TableName: widget.TableName,
    );
    final List<Map<String, dynamic>> contents = allMessages.map((msg) {
      return {
        "role": msg["role"],
        "parts": [
          {"text": msg["text"]},
        ],
      };
    }).toList();

    if (contents.isEmpty) {
      contents.add({
        "role": "user",
        "parts": [
          {"text": message},
        ],
      });
    }

    setState(() {
      _messages = allMessages;
      isLoading = true; // 🔹 Show loader
      MessageController.clear();
    });
    // final body = {
    //   "contents": [
    //     {
    //       "role": "user",
    //       "parts": [
    //         {"text": "Hello"},
    //       ],
    //     },
    //     {
    //       "role": "model",
    //       "parts": [
    //         {"text": "Great to meet you. What would you like to know?"},
    //       ],
    //     },
    //     {
    //       "role": "user",
    //       "parts": [
    //         {
    //           "text":
    //               "I have two dogs in my house. How many paws are in my house?",
    //         },
    //       ],
    //     },
    //   ],
    // };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json", "x-goog-api-key": apiKey},
        body: jsonEncode({"contents": contents}),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        print(decoded);

        final reply =
            decoded["candidates"][0]["content"]["parts"][0]["text"] ??
            "No reply";

        // Save model reply
        await DbHelper.getDbinstance().saveMessage(
          role: "model",
          text: reply,
          TableName: widget.TableName,
        );

        final updatedMessages = await DbHelper.getDbinstance().getmessages(
          TableName: widget.TableName,
        );
        setState(() {
          _messages = updatedMessages;
          isLoading = false;
        });
      } else {
        print("Error: ${response.body}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print(e);
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadMessages() async {
    final data = await DbHelper.getDbinstance().getmessages(
      TableName: widget.TableName,
    );
    setState(() {
      _messages = data;
    });

    // scroll to bottom
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }
}
