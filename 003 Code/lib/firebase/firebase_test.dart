import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
class FireBaseTest extends StatefulWidget {
  const FireBaseTest({super.key});

  @override
  State<FireBaseTest> createState() => _FireBaseTestState();
}

class _FireBaseTestState extends State<FireBaseTest> {
  void click()async {

    CollectionReference ref = FirebaseFirestore.instance.collection('test');

    await ref.add({
      'email': 'id',
      'docId': '',
      'createDate':'${DateTime.now()}'
    }).then((doc) {
      // print('doc ?? ${doc.id}'); /// 고유키
      ref.doc(doc.id).update({'docId': doc.id});
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FirstPage'),
      ),
      body: Column(
        children: [
          GestureDetector(
            onTap: (){
              click();
            },
            child: Text("추가"),
          )
        ],
      ),
    );
  }
}


// Future<void> firebaseTestUpload() async {
//   CollectionReference ref = FirebaseFirestore.instance.collection('test');
//   ref.add({
//     'answer': '',
//     'id': '01048544580',
//     'answerDocid': '',
//     'teacher': ''
//   });
// }