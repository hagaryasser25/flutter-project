import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udemy_flutter/shared/components/components.dart';
import 'package:udemy_flutter/shared/cubit/cubit.dart';
import 'package:udemy_flutter/shared/cubit/states.dart';

class ArchivedTasksScreen  extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit,AppStates>(
      listener: (context,state){},
      builder: (context,state){
        var tasks = AppCubit.get(context).archivedTasks;
        return  ListView.separated(
            itemBuilder: (context,index) => buildTaskItem(tasks[index],context),
            separatorBuilder: (context,index) =>Padding(
              padding: const EdgeInsetsDirectional.only(
                start: 20.0,
                end: 20.0,
              ),
              child: Container(
                width: double.infinity,
                height: 1.0,
                color: Colors.grey[300],
              ),
            ) ,
            itemCount: tasks.length);
      },
    );
  }
}