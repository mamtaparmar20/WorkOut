import 'package:flutter/material.dart';
import 'CreateWorkOutScreen.dart';
import 'DataBase/Model.dart';
import 'DataBase/SqlHelper.dart';

class WorkOutListingScreen extends StatefulWidget {
  const WorkOutListingScreen({super.key});

  @override
  State<WorkOutListingScreen> createState() => _WorkOutListingScreenState();
}

class _WorkOutListingScreenState extends State<WorkOutListingScreen> {
  final _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> workouts = [];

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  _loadWorkouts() async {
    final data = await _dbHelper.getAllWorkouts();
    setState(() {
      workouts = data;
    });
  }

  Future<void> _navigateToCreateWorkout(SetModel? existingSet) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateWorkOutScreen(existingSet: existingSet,),
      ),
    );
    if (result == true) {
      _loadWorkouts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Workout List',
          style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateWorkout(null),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child:
        workouts.isNotEmpty ?
        ListView.separated(
          itemCount: workouts.length,
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final workout = workouts[index];
            final set = SetModel(
              id: workout['id'],
              exercise: workout['exercise'],
              weight: workout['weight'],
              repetitions: workout['repetitions'],
            );
            return InkWell(
              onTap: () => _navigateToCreateWorkout(set),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  title: Text(
                    '${set.exercise} - ${set.weight}kg, ${set.repetitions} reps',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.black.withOpacity(0.8),
                    ),
                    onPressed: () {
                      _dbHelper.deleteWorkout(set.id);
                      _loadWorkouts(); // Refresh list after deletion
                    },
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (context, index) {
            return const SizedBox(height: 15);
          },
        ) : const Center(
          child: Text(
            'No Data Found',
            style: TextStyle(
              color: Colors.blueGrey,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}
