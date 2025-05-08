import 'package:flutter/material.dart';

Future<void> showErrorDialog(BuildContext context, String text)
{
  return showDialog(context: context, builder: (context){
    return AlertDialog(
      title : const Text("Une erreur s'est produite !"),
      content : Text(text),
      actions : [
        TextButton(onPressed: () { Navigator.of(context).pop();}, child: const Text('OK'),),
      ],
    );
  },
  );
}

Future<void> showDialogMessage(BuildContext context, String message)
{
  return showDialog(context: context,builder: (context) {
      return AlertDialog(
        title: Row(
        children: const [ Text("Succés !", style: TextStyle(color: Color.fromARGB(255, 243, 118, 29),fontWeight: FontWeight.bold,),),SizedBox(width: 8),Icon(Icons.check, color: Color.fromARGB(255, 243, 118, 29)),],),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      );
    },
  );
}