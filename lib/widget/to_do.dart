import 'dart:async';
import 'package:flutter/material.dart';

// Modelo de tarea con título y estado completado
class Tarea {
  final String title;
  bool isCompleted;

  Tarea({required this.title, this.isCompleted = false});
}

class ListaStreams extends StatefulWidget {
  const ListaStreams({super.key});
  @override
  State<ListaStreams> createState() => _ListaStreamsState();
}

class _ListaStreamsState extends State<ListaStreams> {
  late StreamController<List<Tarea>> _streamController;
  late List<Tarea> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = [];
    _streamController = StreamController<List<Tarea>>();
    _streamController.add(_tasks);
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  void _addTask(String title) {
    _tasks.add(Tarea(title: title));
    _streamController.add(List.from(_tasks));
  }

  void _toggleTaskCompletion(int index) {
    _tasks[index].isCompleted = !_tasks[index].isCompleted;
    _streamController.add(List.from(_tasks));
  }

  void _removeTask(int index) {
    _tasks.removeAt(index);
    _streamController.add(List.from(_tasks));
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _textController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Streams'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(9.0),
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Nuevo item',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                _addTask(_textController.text);
                _textController.clear();
              }
            },
            child: const Text('Agregar'),
          ),
          Expanded(
            child: StreamBuilder<List<Tarea>>(
              stream: _streamController.stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No hay items'));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final task = snapshot.data![index];
                    return ListTile(
                      title: Text(
                        task.title,
                        style: TextStyle(
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: task.isCompleted,
                            onChanged: (value) {
                              _toggleTaskCompletion(index);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _removeTask(index);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
