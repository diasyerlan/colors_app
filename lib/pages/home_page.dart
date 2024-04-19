import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colors_app/components/textfield.dart';
import 'package:colors_app/components/user_tile.dart';
import 'package:colors_app/database/firestore.dart';
import 'package:colors_app/helper/helper_functions.dart';
import 'package:colors_app/services/chat/chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final _chatService = ChatService();
    var firestoreInstance = FirebaseFirestore.instance;
    var firebaseUser = FirebaseAuth.instance.currentUser;
    final FirestoreDatabase db = FirestoreDatabase();
    TextEditingController _controller = TextEditingController();

    final email = FirebaseAuth.instance.currentUser!.email;
    return Column(
      children: [
        TabBar(
          labelPadding: EdgeInsets.symmetric(horizontal: 10),
          tabs: [
            Tab(
              text: 'Created By You'.toUpperCase(),
            ),
            Tab(
              text: 'Feed'.toUpperCase(),
            ),
            Tab(
              text: 'Favorites'.toUpperCase(),
            )
          ],
        ),
        Expanded(
            child: TabBarView(
          children: [
            Container(
                child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('Users')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.data == null) {
                          return Text('no data');
                        }
                        final docRef = snapshot.data!.docs
                            .firstWhere((element) => element.id == email);
                        Map<String, dynamic> data =
                            docRef.data() as Map<String, dynamic>;
                        List<dynamic> colors = data['colors'];
                        return GridView.count(
                          mainAxisSpacing: 10.0,
                          crossAxisSpacing: 10.0,
                          crossAxisCount: 3,
                          children: List.generate(colors.length, (index) {
                            final color = colors[index];
                            return GestureDetector(
                              onLongPressStart:
                                  (LongPressStartDetails details) {
                                showMenu(
                                  context: context,
                                  position: RelativeRect.fromLTRB(
                                    details.globalPosition.dx,
                                    details.globalPosition.dy,
                                    details.globalPosition.dx,
                                    details.globalPosition.dy,
                                  ),
                                  items: [
                                    PopupMenuItem(
                                      child: Text('Add to favorites'),
                                      onTap: () {
                                        firestoreInstance
                                            .collection('Users')
                                            .doc(firebaseUser!.email)
                                            .update({
                                          'favorites': FieldValue.arrayUnion(
                                              [color.toString()])
                                        });
                                        final snackBar = SnackBar(
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .inversePrimary,
                                            content: Text(
                                                'Added to favorites successfully!'));
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(snackBar);
                                      },
                                    ),
                                    PopupMenuItem(
                                      child: Text('Share'),
                                      onTap: () {
                                        showModalBottomSheet(
                                          context: context,
                                          builder: (context) {
                                            return SizedBox(
                                              height: 400,
                                              child: Center(
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Container(
                                                    child: StreamBuilder(
                                                      stream: FirebaseFirestore
                                                          .instance
                                                          .collection("Users")
                                                          .snapshots(),
                                                      builder:
                                                          (context, snapshot) {
                                                        if (snapshot
                                                                .connectionState ==
                                                            ConnectionState
                                                                .waiting) {
                                                          return Center(
                                                              child:
                                                                  CircularProgressIndicator());
                                                        } else if (snapshot
                                                                .hasData ==
                                                            false) {
                                                          return Text(
                                                              'No data');
                                                        }
                                                        final users =
                                                            snapshot.data!.docs;
                                                        return Column(
                                                          children: [
                                                            SizedBox(
                                                                height: 20),
                                                            Expanded(
                                                              child: ListView
                                                                  .builder(
                                                                itemCount: users
                                                                    .length,
                                                                itemBuilder:
                                                                    (context,
                                                                        index) {
                                                                  if (FirebaseAuth
                                                                          .instance
                                                                          .currentUser!
                                                                          .email !=
                                                                      users[index]
                                                                          [
                                                                          'email']) {
                                                                    return Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                      child: UserTile(
                                                                          onTap: () async {
                                                                            await _chatService.sendMessage(users[index]['uid'],
                                                                                color.toString());
                                                                            final snackBar =
                                                                                SnackBar(
                                                                              content: Text('Message is sent successfuly!'),
                                                                              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                                                                            );
                                                                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                          username: users[index]['username']),
                                                                    );
                                                                  }
                                                                },
                                                              ),
                                                            )
                                                          ],
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                    PopupMenuItem(
                                      child: Text('Post'),
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text(
                                                  'Please add a text to your post!'),
                                              content: Container(
                                                height: 130,
                                                child: Column(
                                                  children: [
                                                    MyTextField(
                                                        obscureText: false,
                                                        hintText:
                                                            'Write a description',
                                                        controller:
                                                            _controller),
                                                    SizedBox(height: 15),
                                                    ElevatedButton(
                                                        onPressed: () {
                                                          db.addPosts(
                                                              _controller.text,
                                                              color);
                                                          Navigator.pop(
                                                              context);
                                                          final snackBar = SnackBar(
                                                              backgroundColor: Theme
                                                                      .of(
                                                                          context)
                                                                  .colorScheme
                                                                  .inversePrimary,
                                                              content: Text(
                                                                  'Posted successfuly!'));
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                                  snackBar);
                                                        },
                                                        child: Text('Post'))
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: getColorFromString(color)),
                              ),
                            );
                          }),
                        );
                      },
                    ))),
            Container(
                child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: StreamBuilder(
                stream:
                    FirebaseFirestore.instance.collection('Posts').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasData == null) {
                    return Text('No data');
                  }
                  final users = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color:
                                      Theme.of(context).colorScheme.tertiary),
                              borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      '@' + users[index]['username'],
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ],
                                ),
                                ListTile(
                                  title: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 80),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: getColorFromString(
                                            users[index]['color']),
                                      ),
                                      height: 200,
                                      width: 10,
                                    ),
                                  ),
                                  subtitle: Column(
                                    children: [
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 30.0),
                                        child: Divider(
                                          thickness: 0.2,
                                        ),
                                      ),
                                      Center(
                                          child: Padding(
                                        padding: const EdgeInsets.only(top: 3),
                                        child: Text(users[index]['message']),
                                      )),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )),
            Container(
                child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('Users')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.data == null) {
                          return Text('no data');
                        }
                        final docRef = snapshot.data!.docs
                            .firstWhere((element) => element.id == email);
                        Map<String, dynamic> data =
                            docRef.data() as Map<String, dynamic>;
                        List<dynamic> colors = data['favorites'];
                        return GridView.count(
                          mainAxisSpacing: 10.0,
                          crossAxisSpacing: 10.0,
                          crossAxisCount: 3,
                          children: List.generate(colors.length, (index) {
                            final color = colors[index];
                            return GestureDetector(
                              onLongPressStart:
                                  (LongPressStartDetails details) {
                                showMenu(
                                  context: context,
                                  position: RelativeRect.fromLTRB(
                                    details.globalPosition.dx,
                                    details.globalPosition.dy,
                                    details.globalPosition.dx,
                                    details.globalPosition.dy,
                                  ),
                                  items: [
                                    PopupMenuItem(
                                      child: Text('Remove from favorites'),
                                      onTap: () {
                                        firestoreInstance
                                            .collection('Users')
                                            .doc(firebaseUser!.email)
                                            .update({
                                          'favorites': FieldValue.arrayRemove(
                                              [color.toString()])
                                        });
                                      },
                                    ),
                                    PopupMenuItem(child: Text('Share')),
                                    PopupMenuItem(child: Text('Post')),
                                  ],
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: getColorFromString(color)),
                              ),
                            );
                          }),
                        );
                      },
                    )))
          ],
        ))
      ],
    );
  }
}
