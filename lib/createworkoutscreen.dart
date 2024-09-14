import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'DataBase/Model.dart';
import 'DataBase/SqlHelper.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class CreateWorkOutScreen extends StatefulWidget {
  final SetModel? existingSet;

  const CreateWorkOutScreen({super.key, required this.existingSet});

  @override
  State<CreateWorkOutScreen> createState() => _CreateWorkOutScreenState();
}

class _CreateWorkOutScreenState extends State<CreateWorkOutScreen> {
  final _dbHelper = DatabaseHelper();
  final exercises = ['Barbell row', 'Bench press', 'Shoulder press', 'Deadlift', 'Squat'];
  final _weightController = TextEditingController();
  final _repsController = TextEditingController();
  String _selectedExercise = 'Bench press';

  @override
  void initState() {
    super.initState();
    if (widget.existingSet != null) {
      final set = widget.existingSet!;
      _selectedExercise = set.exercise;
      _weightController.text = set.weight.toString();
      _repsController.text = set.repetitions.toString();
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 25),
        ),
        title: const Text(
          'Record Workout',
          style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                isExpanded: true,
                hint: Row(
                  children: [
                    const Icon(
                      Icons.list,
                      size: 16,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Select Exercise',
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                items: exercises
                    .map((String exercise) => DropdownMenuItem<String>(
                  value: exercise,
                  child: Text(
                    exercise,
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ))
                    .toList(),
                value: _selectedExercise.isEmpty ? null : _selectedExercise,
                onChanged: (value) {
                  setState(() {
                    _selectedExercise = value!;
                  });
                },
                buttonStyleData: ButtonStyleData(
                  height: 50,
                  width: double.infinity,
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.grey.withOpacity(0.2),
                  ),
                ),
                iconStyleData: const IconStyleData(
                  icon: Icon(
                    Icons.arrow_forward_ios_outlined,
                  ),
                  iconSize: 14,
                  iconEnabledColor: Colors.black,
                  iconDisabledColor: Colors.grey,
                ),
                dropdownStyleData: DropdownStyleData(
                  maxHeight: 200,
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                  ),
                  scrollbarTheme: ScrollbarThemeData(
                    radius: const Radius.circular(40),
                    thickness: MaterialStateProperty.all<double>(6),
                    thumbVisibility: MaterialStateProperty.all<bool>(true),
                  ),
                ),
                menuItemStyleData: const MenuItemStyleData(
                  padding: EdgeInsets.only(left: 15, right: 15),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextFormField(
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              //Validate weight input
              // onChanged: (value) {
              //   final weight = double.tryParse(value);
              //   if (weight != null && (weight < 0 || weight > 200)) {
              //     ScaffoldMessenger.of(context).showSnackBar(
              //       SnackBar(content: Text('Weight must be between 0 and 200 kg')),
              //     );
              //   }
              // },
              controller: _weightController,
              //keyboardType: TextInputType.number,
              keyboardType: TextInputType.numberWithOptions(decimal: true),

              decoration: InputDecoration(
                labelText: 'Weight (kg)',
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: Colors.grey.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: Colors.black.withOpacity(0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: TextStyle(
                color: Colors.black.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _repsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Repetitions',
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: Colors.grey.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: Colors.black.withOpacity(0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 30),
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                // Validate inputs
                if (_selectedExercise == null || _selectedExercise.isEmpty) {
                  _showError('Please select an exercise');
                  return;
                }

                if (_weightController.text.isEmpty || double.tryParse(_weightController.text) == null) {
                  _showError('Please enter a valid weight');
                  return;
                }

                if (_repsController.text.isEmpty || int.tryParse(_repsController.text) == null) {
                  _showError('Please enter a valid number of repetitions');
                  return;
                }

                final newSet = SetModel(
                  id: widget.existingSet?.id, // Keep the id if editing
                  exercise: _selectedExercise,
                  weight: double.parse(_weightController.text),
                  repetitions: int.parse(_repsController.text),
                );

                if (widget.existingSet != null) {
                  _dbHelper.updateWorkout(newSet).then((_) {
                    Navigator.pop(context, true);
                  });
                } else {
                  _dbHelper.insertSet(newSet.exercise, newSet.weight, newSet.repetitions).then((_) {
                    Navigator.pop(context, true);
                  });
                }
              },
              child: Container(
                height: 40,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    'Save Workout',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
