import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_app/services/database_helper.dart';
import 'package:money_app/services/salary_history_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> salaryHistories = [];
  final formKey = GlobalKey<FormState>();

  bool _isLoading = true;

  void _refreshData() async {
    final data = await SalaryHistoryService.getSalaryHistoryList();
    setState(() {
      salaryHistories = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _gettingSalaryDateController =
      TextEditingController();

  void showMyForm(int? id) async {
    if (id != null) {
      final existingData =
          salaryHistories.firstWhere((element) => element['id'] == id);
      _salaryController.text = existingData['salary'].toString();
      _gettingSalaryDateController.text =
          existingData['getting_salary_date'].toString();
    } else {
      _salaryController.text = "";
      _gettingSalaryDateController.text = "";
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isDismissible: false,
        isScrollControlled: true,
        builder: (_) => Container(
            padding: EdgeInsets.only(
              top: 15,
              left: 15,
              right: 15,
              bottom: MediaQuery.of(context).viewInsets.bottom + 120,
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextFormField(
                    controller: _salaryController,
                    keyboardType: TextInputType.number,
                    validator: formValidator,
                    decoration: const InputDecoration(hintText: 'Enter salary'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                      validator: formValidator,
                      controller: _gettingSalaryDateController,
                      decoration: const InputDecoration(
                          hintText: 'Getting salary date'),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            //DateTime.now() - not to allow to choose before today.
                            lastDate: DateTime(2101));

                        if (pickedDate != null) {
                          String formattedDate =
                              DateFormat('yyyy-MM-dd').format(pickedDate);

                          setState(() {
                            _gettingSalaryDateController.text = formattedDate;
                          });
                        }
                      }),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("Exit")),
                      ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            if (id == null) {
                              await addItem();
                            }

                            if (id != null) {
                              await updateItem(id);
                            }

                            // Clear the text fields
                            setState(() {
                              _salaryController.text = '';
                              _gettingSalaryDateController.text = '';
                            });

                            Navigator.pop(context);
                          }
                        },
                        child: Text(id == null ? 'Create New' : 'Update'),
                      ),
                    ],
                  )
                ],
              ),
            )));
  }

  String? formValidator(String? value) {
    if (value!.isEmpty) return 'Field is Required';
    return null;
  }

  Future<void> addItem() async {
    double salary = double.parse(_salaryController.text);
    String gettingSalaryDate = _gettingSalaryDateController.text;
    await SalaryHistoryService.createSalaryHistoryItem(
        salary, gettingSalaryDate);
    _refreshData();
  }

  // Update an existing data
  Future<void> updateItem(int id) async {
    double salary = double.parse(_salaryController.text);
    String gettingSalaryDate = _gettingSalaryDateController.text;

    await SalaryHistoryService.updateSalaryHistoryItem(
        id, salary, gettingSalaryDate);
    _refreshData();
  }

  // Delete an item
  void deleteItem(int id) async {
    await SalaryHistoryService.deleteSalaryHistoryItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Successfully deleted!'), backgroundColor: Colors.green));
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Money app'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : salaryHistories.isEmpty
              ? const Center(child: Text("No Data Available!!!"))
              : DataTable(
                  columns: const <DataColumn>[
                      DataColumn(
                        label: Expanded(
                          child: Text(
                            'Salary',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Expanded(
                          child: Text(
                            'Getting Date',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Expanded(
                          child: Text(
                            'Static tax',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Expanded(
                          child: Text(
                            '5% tax',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Expanded(
                          child: Text(
                            'Total tax',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Expanded(
                          child: Text(
                            'Clear salary',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                      ),
                    ],
                  rows: List.generate(salaryHistories.length, (index) {
                    double fullTax = salaryHistories[index]["static_tax"] +
                        salaryHistories[index]["five_percent_tax"];
                    double clearSalary =
                        salaryHistories[index]["salary"] - fullTax;
                    return DataRow(cells: <DataCell>[
                      DataCell(
                          Text(salaryHistories[index]["salary"].toString())),
                      DataCell(Text(salaryHistories[index]
                              ["getting_salary_date"]
                          .toString())),
                      DataCell(Text(
                          salaryHistories[index]["static_tax"].toString())),
                      DataCell(Text(salaryHistories[index]["five_percent_tax"]
                          .toString())),
                      DataCell(Text(fullTax.toString())),
                      DataCell(Text(clearSalary.toString())),
                    ]);
                  })),

      // child: ListTile(
      //     title: Text(myData[index]['salary'].toString()),
      //     subtitle: Text(myData[index]['getting_salary_date'].toString()),
      //     trailing: SizedBox(
      //       width: 100,
      //       child: Row(
      //         children: [
      //           IconButton(
      //             icon: const Icon(Icons.edit),
      //             onPressed: () =>
      //                 showMyForm(myData[index]['id']),
      //           ),
      //           IconButton(
      //             icon: const Icon(Icons.delete),
      //             onPressed: () =>
      //                 deleteItem(myData[index]['id']),
      //           ),
      //         ],
      //       ),
      //     )),
      //   ),
      // ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => showMyForm(null),
      ),
    );
  }
}
