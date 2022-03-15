import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:udemy_flutter/modules/todo_app/archived_tasks/archived_tasks_screen.dart';
import 'package:udemy_flutter/modules/todo_app/done_tasks/done_tasks_screen.dart';
import 'package:udemy_flutter/modules/todo_app/new_tasks/new_tasks_screen.dart';
import 'package:udemy_flutter/shared/cubit/states.dart';
import 'package:udemy_flutter/shared/network/local/cache_helper.dart';

class AppCubit extends Cubit<AppStates>{
  AppCubit():super(AppInitialState());

  static AppCubit  get(context) => BlocProvider.of(context);

  int currentIndex = 0;
  List<Widget> screens = [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen(),
  ];
  List<String> titles = [
    'New Tasks',
    'Done Tasks',
    'Archived Tasks'
  ];

  void changeIndex(int index){
    currentIndex = index;
    emit(AppChangeBottomNavBarState());
  }
  late Database database;
  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];
  void createDatabase() async
  {
    database = await openDatabase(
      'todo.db',
      version: 1,
      onCreate: (database,version) async{
        print('database created');
        await database.execute('create table tasks(id INTEGER PRIMARY KEY,'
            'title TEXT, date TEXT,time TEXT,status TEXT)').then((value) {
          print('table created');

        }).catchError((error){
          print('error when creating table ${error.toString()}');

        });


      },
      onOpen: (database){
        getData(database);
        print('database opened');
        emit(AppCreateDatabaseState());
      },
    );

  }

  Future  insertToDatabase({
    required String title,
    required String time,
    required String date,
  }) async
  {
   await database.transaction((txn)
    => txn.rawInsert('INSERT INTO tasks(title,time,date,status) VALUES("$title","$date","$time","new")')
        .then((value) {
      print('$value inserted successfully');
      emit(AppInsertDatabaseState());

      getData(database);
    }).catchError((error){
      print('error when inserting into table ${error.toString()}');
    }));
  }

  void getData(database)
  {
    newTasks=[];
    doneTasks=[];
    archivedTasks=[];
    emit(AppGetDatabaseLoadingState());
     database.rawQuery('SELECT * FROM tasks').then((value) {

       value.forEach((element) {
         if(element['status'] == 'new')
           {
             newTasks.add(element);
           }
         else if(element['status'] == 'done')
           {
             doneTasks.add(element);
           }
         else
         {
           archivedTasks.add(element);
         }

       });
       emit(AppGetDatabaseState());
     });
  }

 void updateData({
  required String status,
   required int id,
}) async
  {
    database.rawUpdate(
     'UPDATE tasks Set status = ? WHERE id = ?',
     ['$status', id]
   ).then((value) => {
     getData(database),
     emit(AppUpdateDatabaseState())
    });

  }

  void deleteData({
    required int id,
  }) async
  {
    database.rawDelete(
        'DELETE FROM tasks WHERE id = ?', [id]
    ).then((value) => {
      getData(database),
      emit(AppDeleteDatabaseState())
    });

  }

  bool isBottomSheetShown = false;
  IconData fabIcon = Icons.edit;

  void changeBottomSheetState({
  required bool isShow,
    required IconData icon,
})
  {
    isBottomSheetShown = isShow;
    fabIcon = icon;

    emit(AppChangeBottomSheetState());
  }

  bool isDark = false;
  void changeAppMode({bool? fromShared})
  {
    if(fromShared != null)
      {
        isDark = fromShared;
        emit(AppChangeModeState());
      }

    else
      {
        isDark = !isDark;
        CacheHelper.putData(key: 'isDark', value: isDark).then((value) {
          emit(AppChangeModeState());
        }
        );

      }



  }
}