import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<String> createFolderInAppDocDir(String folderName) async {
    //Get this App Document Directory

    final Directory _appDocDir = await getApplicationDocumentsDirectory();
    //App Document Directory + folder name
    final Directory _appDocDirFolder =
        Directory('${_appDocDir.path}/$folderName/');

    if (await _appDocDirFolder.exists()) {
      //if folder already exists return path
      return _appDocDirFolder.path;
    } else {
      //if folder not exists create folder and then return its path
      final Directory _appDocDirNewFolder =
          await _appDocDirFolder.create(recursive: true);
      return _appDocDirNewFolder.path;
    }
  }

  callFolderCreationMethod(String folderInAppDocDir) async {
    // ignore: unused_local_variable
    String actualFileName = await createFolderInAppDocDir(folderInAppDocDir);
    print(actualFileName);
    setState(() {});
  }

  final folderController = TextEditingController();
  String nameOfFolder;
  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            children: [
              Text(
                'ADD FOLDER',
                textAlign: TextAlign.left,
              ),
              Text(
                'Type a folder name to add',
                style: TextStyle(
                  fontSize: 14,
                ),
              )
            ],
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return TextField(
                controller: folderController,
                autofocus: true,
                decoration: InputDecoration(hintText: 'Enter folder name'),
                onChanged: (val) {
                  setState(() {
                    nameOfFolder = folderController.text;
                    print(nameOfFolder);
                  });
                },
              );
            },
          ),
          actions: <Widget>[
            FlatButton(
              color: Colors.blue,
              child: Text(
                'Add',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                if (nameOfFolder != null) {
                  await callFolderCreationMethod(nameOfFolder);
                  getDir();
                  setState(() {
                    folderController.clear();
                    nameOfFolder = null;
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
            FlatButton(
              color: Colors.redAccent,
              child: Text(
                'No',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  List<FileSystemEntity> _folders;
  Future<void> getDir() async {
    final directory = await getApplicationDocumentsDirectory();
    final dir = directory.path;
    String pdfDirectory = '$dir/';
    final myDir = new Directory(pdfDirectory);
    setState(() {
      _folders = myDir.listSync(recursive: true, followLinks: false);
    });
    print(_folders);
  }

  Future<void> _showDeleteDialog(int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Are you sure to delete this folder?',
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Yes'),
              onPressed: () async {
                await _folders[index].delete();
                getDir();
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    getDir();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _showMyDialog();
            },
          ),
        ],
      ),
      body: GridView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 25,
        ),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 180,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemBuilder: (context, index) {
          return Material(
            elevation: 6.0,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.folder,
                        size: 100,
                        color: Colors.orange,
                      ),
                      Text(
                        '${_folders[index].path.split('/').last}',
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () {
                      _showDeleteDialog(index);
                    },
                    child: Icon(
                      Icons.delete,
                      color: Colors.grey,
                    ),
                  ),
                )
              ],
            ),
          );
        },
        itemCount: _folders.length,
      ),
    );
  }
}
