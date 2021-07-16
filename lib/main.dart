import 'dart:async';
import 'package:http/http.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      title: 'Dictionary App',
      theme: ThemeData(primarySwatch: Colors.pink),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _url = 'https://owlbot.info/api/v4/dictionary/';
  String _token = '39339710a9a024d889eb26ab1bee4286e3f8fdc4';
  TextEditingController _controller = TextEditingController();
  StreamController _streamController;
  Stream _stream;
  Timer _debounce;

  _search() async {
    if (_controller.text == null || _controller.text.length == 0) {
      _streamController.add(null);
      return;
    }
    _streamController.add('waiting');
    Response response =
        await get(Uri.parse(_url + _controller.text.trim()), headers: {
      'Authorization': 'Token ' + _token,
    });
    response.statusCode == 200 ? _streamController.add(json.decode(response.body)): _streamController.add("Doesn't Exist");
  }

  @override
  void initState() {
    super.initState();
    _streamController = StreamController();
    _stream = _streamController.stream;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          'Dictionary',
          style: TextStyle(color: Colors.grey[300], fontSize: 25),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(left: 12, bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextFormField(
                    onChanged: (String text) {
                      if (_debounce?.isActive ?? false) _debounce.cancel();
                      _debounce = Timer(const Duration(milliseconds: 1000), () {
                        _search();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search..',
                      contentPadding: const EdgeInsets.only(left: 24),
                      border: InputBorder.none,
                    ),
                    controller: _controller,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                onPressed: () {
                  _search();
                },
              )
            ],
          ),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.all(8),
        child: StreamBuilder(
          stream: _stream,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return Center(
                child: Text('Please, Enter the word you are looking for...'),
              );
            }
            if (snapshot.data == 'waiting') {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.data == "Doesn't Exist"){
              return Container(
                child: Center(child: Text("404 NOT FOUND!!", style: TextStyle(color: Colors.black,fontSize: 30, fontWeight: FontWeight.bold),)),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data['definitions'].length,
              itemBuilder: (BuildContext context, int index) {
                return ListBody(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      margin: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(15),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.grey[200],
                            Colors.grey[300],
                            Colors.grey[400],
                            Colors.grey[500]
                          ],
                          stops: [0.1, 0.3, 0.8, 1],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey[600],
                            offset: Offset(3.0, 3.0),
                            blurRadius: 9.0,
                            spreadRadius: 1.0,
                          ),
                          BoxShadow(
                            color: Colors.white,
                            offset: Offset(-5.0, -5.0),
                            blurRadius: 15.0,
                            spreadRadius: 1.0,
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: snapshot.data['definitions'][index]
                                    ['image_url'] ==
                                null
                            ? null
                            : CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(snapshot
                                    .data['definitions'][index]['image_url']),
                              ),
                        title: snapshot.data['definitions'][index]['type'] == null ? Text(_controller.text.trim(), style: TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),) : Text(
                          _controller.text.trim() +
                              "(" +
                              snapshot.data['definitions'][index]['type'] +
                              ")",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Container(
                        padding:const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                            '"' +
                                snapshot.data['definitions'][index]
                                    ['definition'] +
                                '"',
                            style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 18,
                                fontWeight: FontWeight.w300
                            ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
