import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/shared/cubit/states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../modules/archive_task/archived_task_screen.dart';
import '../../modules/done_task/done_task_screen.dart';
import '../../modules/new_task/new_task_screen.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;
  late Database database;
  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archiveTasks = [];


  List<Widget> Screens = [
    NewTaskScreen(),
    DoneTaskScreen(),
    ArchivedTaskScreen()
  ];
  List<String> Titles = ['New Tasks', 'Done Tasks', 'Archived Tasks'];

  void changeIndex(int index) {
    currentIndex = index;
    emit(AppChangeBottomNavBarState());
  }

  void createDataBase() {
    openDatabase('todo.db', version: 1, onCreate: (database, version) {
      print('database created');
      database
          .execute(
              'create TABLE tasks(id INTEGER PRIMARY KEY,title TEXT,date Text,time TEXT,status TEXT)')
          .then((value) {
        print('table created');
      }).catchError((error) {
        print('Error when creating the table ${error.toString()}');
      });
    }, onOpen: (database) {
      getDataFromDataBase(database);
      print('database opened');
    }).then((value) {
      database = value;
      emit(AppCreateDatabaseState());
    });
  }

   insertToDataBase({
    required String title,
    required String time,
    required String date,
  }) async {
     await database.transaction((txn) async {
      txn.rawInsert(
              'INSERT INTO tasks(title,time,date,status)VALUES("$title","$time","$date","new")'
      ).then((value) {
        print('insert sucssefuly');
        emit(AppInsertDatabaseState());
        getDataFromDataBase(database);

      }).catchError((error) {
        print('error  when insert the raw');
        return null;
      });
    });
  }

  void getDataFromDataBase(database)  {
    newTasks=[];
    doneTasks=[];
    archiveTasks=[];
    emit(AppGetDatabaseLoadingState());
    database.rawQuery('SELECT * FROM tasks ').then((value) {

      value.forEach((element) {

        if(element['status']=='new')
          newTasks.add(element);
        else if(element['status']=='done')
          doneTasks.add(element);
        else archiveTasks.add(element);
      });
      emit(AppGetDatabaseState());
    });
  }


  bool isBottomSheet = false;
  IconData fabIcon = Icons.edit;

  void changeBottomSheetState({required bool isShow,required IconData icon}){
    isBottomSheet=isShow;
    fabIcon=icon;

    emit(AppChangeBottomSheetState());

  }

 void updateData({required String status,required int id})async{
      await database.rawUpdate(
        'UPDATE tasks SET status = ? WHERE id = ?',
        ['$status', '$id']).then((value) {
          getDataFromDataBase(database);
          emit(AppUpdateDatabaseState());
      });
  }

  void deleteData({required int id})async{
    await database.rawDelete(
        'DELETE FROM tasks WHERE id = ?', [id],
        ).then((value) {
      getDataFromDataBase(database);
      emit(AppDeleteDatabaseState());
    });
  }
}
