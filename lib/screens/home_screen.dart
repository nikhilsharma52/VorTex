import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vortex/api/apis.dart';
import 'package:vortex/main.dart';
import 'package:vortex/models/chat_user.dart';
import 'package:vortex/widgets/chat_user_card.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // for storing all users
  List<ChatUser> _list = [];

  // for storing searched items
  final List<ChatUser> _searchList = [];

  // for storing searched status
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // for hiding the keyboard when a tap is detected on screen
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        // if search is on & back button is pressed then close search
        // or else simple close current screen on back button click
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          }else{
            return Future.value(true);
          }
        },
        child: Scaffold(
            // app bar
            appBar: AppBar(
              leading: Icon(CupertinoIcons.home),
              title: _isSearching
                  ? TextField(
                      decoration: InputDecoration(
                          border: InputBorder.none, hintText: 'Name, Email,...'),
                      autofocus: true,
                      style: TextStyle(fontSize: 17, letterSpacing: 0.5),
          
                      // when search text changes then updated search list
                      onChanged: (value) {
                        // search logic
                        _searchList.clear();
          
                        for (var i in _list) {
                          if (i.name.toLowerCase().contains(value.toLowerCase()) ||
                              i.email.toLowerCase().contains(value.toLowerCase())) {
                            _searchList.add(i);
                          }
                          setState(() {
                            _searchList;
                          });
          
                        }
                      },
                    )
                  : Text('VorTex'),
              actions: [
                // search user button
                IconButton(
                    onPressed: () {
                      setState(() {
                        _isSearching = !_isSearching;
                      });
                    },
                    icon: Icon(_isSearching
                        ? CupertinoIcons.clear_circled_solid
                        : Icons.search)),
          
                // User Profile button
                IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ProfileScreen(user: APIs.me)));
                    },
                    icon: const Icon(CupertinoIcons.person)
                    // icon: Image.asset('images/google.png'),
                    )
              ],
            ),
          
            // Floating button to add new user
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: FloatingActionButton(
                  onPressed: () {}, child: Icon(Icons.add_comment_rounded)),
            ),

            // body
            body: StreamBuilder(
                stream: APIs.getAllUsers(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    // if data is loading
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return const Center(child: CircularProgressIndicator());
          
                    // if some or all data is loaded then show it
                    case ConnectionState.active:
                    case ConnectionState.done:
                      final data = snapshot.data?.docs;
                      _list =
                          data?.map((e) => ChatUser.fromJson(e.data())).toList() ??
                              [];
          
                      if (_list.isNotEmpty) {
                        return ListView.builder(
                            itemCount: _isSearching ? _searchList.length : _list.length,
                            padding: EdgeInsets.only(top: mq.height * .006),
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return ChatUserCard(
                                user: _isSearching ? _searchList[index] : _list[index],
                              );
                              // return Text('Name: ${list[index]}');
                            });
                      } else {
                        return const Center(
                            child: Text('No Connections Found!',
                                style: TextStyle(fontSize: 20)));
                      }
                  }
                })),
      ),
    );
  }
}
