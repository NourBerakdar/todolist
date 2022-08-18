import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/shared/cubit/cubit.dart';
import 'package:todo_app/shared/cubit/states.dart';


class HomeLayout extends StatelessWidget {


  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  var titleController = TextEditingController();
  var dateController = TextEditingController();
  var timeController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context)=>AppCubit()..createDataBase(),
      child: BlocConsumer<AppCubit,AppStates>(
        listener:(BuildContext context,AppStates state){
          if(state is AppInsertDatabaseState){
            Navigator.pop(context);
          }
        } ,
        builder:(BuildContext context,AppStates state){
          AppCubit cubit=AppCubit.get(context);
          return Scaffold(
            appBar: AppBar(
              title: Text(cubit.Titles[cubit.currentIndex]),
            ),
            body: ConditionalBuilder(
              condition: state is! AppGetDatabaseLoadingState,
              builder: (context) => cubit.Screens[cubit.currentIndex],
              fallback: (context) => Center(child: CircularProgressIndicator()),
            ),
            key: scaffoldKey,
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                if (cubit.isBottomSheet) {
                  if (formKey.currentState!.validate()) {
                  cubit.insertToDataBase(title: titleController.text, time: timeController.text, date: dateController.text);
                  titleController.clear();timeController.clear();dateController.clear();
                  }
                } else {
                  scaffoldKey.currentState
                      ?.showBottomSheet(
                          (context) => Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(20.0),
                        child: Form(
                          key: formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextFormField(
                                controller: titleController,
                                validator: (String? value) {
                                  return (value!.isEmpty)
                                      ? 'title must not empty'
                                      : null;
                                },
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Task Title',
                                  icon: Icon(Icons.title),
                                ),
                              ),
                              const SizedBox(height: 15.0),
                              TextFormField(
                                onTap: () {
                                  showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now())
                                      .then((value) {
                                    timeController.text =
                                        value!.format(context).toString();
                                  });
                                },
                                controller: timeController,
                                validator: (String? value) {
                                  return (value!.isEmpty)
                                      ? 'time must not empty'
                                      : null;
                                },
                                keyboardType: TextInputType.datetime,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Task Time',
                                  icon: Icon(Icons.watch_later_outlined),
                                ),
                              ),
                              const SizedBox(height: 15.0),
                              TextFormField(
                                onTap: () async {
                                  DateTime? date = DateTime(1900);
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());

                                  date = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.parse("2022-12-31"),
                                  );
                                  dateController.text =
                                      DateFormat.yMMMd().format(date!);
                                },
                                controller: dateController,
                                validator: (String? value) {
                                  return (value!.isEmpty)
                                      ? 'date must not empty'
                                      : null;
                                },
                                keyboardType: TextInputType.datetime,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Task Date',
                                  icon: Icon(Icons.calendar_today),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      elevation: 20.0)
                      .closed
                      .then((value) {
                    cubit.changeBottomSheetState(isShow: false, icon: Icons.edit);

                  });
                  cubit.changeBottomSheetState(isShow: true, icon: Icons.add);
                }
              },
              child: Icon(cubit.fabIcon),
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: cubit.currentIndex,
              onTap: (index) {
                cubit.changeIndex(index);
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.menu,
                  ),
                  label: 'Tasks',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.check_circle_outline,
                  ),
                  label: 'Done',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.archive_outlined,
                  ),
                  label: 'Archive',
                ),
              ],
            ),
          );
        },

      ),
    );
  }



  Future<void> deleteDatabase(String path) =>
      databaseFactory.deleteDatabase(path);
}

