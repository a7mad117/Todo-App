import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../shared/components/cubit/cubit.dart';
import '../shared/components/cubit/states.dart';
import '../shared/components/components.dart';
import 'package:buildcondition/buildcondition.dart';

class HomeLayout extends StatelessWidget {
  HomeLayout({Key? key}) : super(key: key);

  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppStates>(
          listener: (context, state) {
            if(state is AppInsertDatabaseState) Navigator.pop(context);
          },
          builder: (context, state) {
            AppCubit cubit = AppCubit.get(context);
            return Scaffold(
              key: scaffoldKey,
              appBar: AppBar(
                title: Text(cubit.titles[cubit.currentIndex]),
              ),
              bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: cubit.currentIndex,
                onTap: (index) {
                  cubit.changeIndex(index);
                },
                items: const [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.menu), label: 'Tasks'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.check_circle_outline), label: 'Done'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.archive_outlined), label: 'Archive'),
                ],
              ),
              floatingActionButton: FloatingActionButton(
                  child: Icon(cubit.fabIcon),
                  onPressed: () {
                    if (cubit.isBottomSheetShown) {
                      if (formKey.currentState!.validate()) {
                         cubit.insertToDatabase(
                           title: titleController.text,
                           time: timeController.text,
                           date: dateController.text,

                         );
                      }
                    } else {
                      scaffoldKey.currentState
                          ?.showBottomSheet(
                            (context) => Container(
                              padding: const EdgeInsets.all(20),
                              child: Form(
                                key: formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    defaultFormField(
                                      prefixIcon: Icons.title,
                                      controller: titleController,
                                      keyboardType: TextInputType.text,
                                      labelText: 'Task Title',
                                      validator: (String? value) {
                                        if (value!.isEmpty) {
                                          return 'Title must not be empty';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    defaultFormField(
                                      prefixIcon: Icons.watch_later_outlined,
                                      controller: timeController,
                                      keyboardType: TextInputType.datetime,
                                      labelText: 'Task time',
                                      readOnly: true,
                                      onTap: () {
                                        showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.now(),
                                        ).then((value) {
                                          timeController.text =
                                              value!.format(context).toString();
                                          debugPrint('Time is ' +
                                              value.format(context).toString());
                                        });
                                      },
                                      validator: (String? value) {
                                        if (value!.isEmpty) {
                                          return 'Time must not be empty';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    defaultFormField(
                                      prefixIcon: Icons.calendar_today,
                                      controller: dateController,
                                      keyboardType: TextInputType.datetime,
                                      labelText: 'Task date',
                                      readOnly: true,
                                      onTap: () {
                                        showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime.now()
                                              .add(const Duration(days: 30)),
                                        ).then((value) {
                                          dateController.text =
                                              DateFormat.yMMMd().format(value!);
                                          debugPrint(
                                              'Date is ' + value.toString());
                                        });
                                      },
                                      validator: (String? value) {
                                        if (value!.isEmpty) {
                                          return 'Time must not be empty';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            elevation: 20,
                          )
                          .closed
                          .then((value) {
                        cubit.changeBottomSheetState(
                            icon: Icons.edit, isShown: false);
                      });
                      cubit.changeBottomSheetState(
                          icon: Icons.add, isShown: true);
                    }
                  }),
              body: BuildCondition(
                condition: state is! AppGetDatabaseLoadingState,
                builder: (context) => cubit.screens[cubit.currentIndex],
                fallback: (context) =>
                    const Center(child: CircularProgressIndicator()),
              ),
            );
          }),
    );
  }

// screens[currentIndex]
// Future<String> getName() async {
//   return 'ahmed badwee';
// }

}
