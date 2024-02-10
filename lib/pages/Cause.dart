
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:incidents_crud/pages/Incidents.dart';
import 'package:incidents_crud/pages/Ouvrages.dart';
import 'package:incidents_crud/pages/Postes.dart';
import '../classes/Pagination.dart';

class Cause extends StatefulWidget {
  @override
  _CauseState createState() => _CauseState();
}

class _CauseState extends State<Cause> {
  List<Map<String, dynamic>> itemList = [];
  bool isLoading = true;
  int currentPage = 1;
  int rowsPerPage = 10;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response =
      await http.get(Uri.parse('http://localhost:8080/cause/getAll'));
      if (response.statusCode == 200) {
        // Decode the response body
        List<dynamic> data = json.decode(response.body);
        // Convert the decoded data to a list of Map<String, dynamic>
        List<Map<String, dynamic>> fetchedItemList =
        data.map((item) => Map<String, dynamic>.from(item)).toList();
        // Update the itemList with the fetched data
        setState(() {
          itemList = fetchedItemList;
        });
      } else {
        throw Exception('Failed to load data from API');
      }
    } catch (e) {
      print('Error fetching data: $e');
      // Handle error, display a message to the user, etc.
    } finally {
      // Hide the loading indicator after 5 seconds
      Future.delayed(Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      });
    }
  }

  Future<void> findCauseByDesignation(String designation) async {
    try {
      final response = await http.get(Uri.parse(
          'http://localhost:8080/cause/findCauseByDesignation/$designation'));

      if (response.statusCode == 200) {
        // Parse the JSON response and update your UI with the search results
        List<dynamic> searchResults = json.decode(response.body);
        List<Map<String, dynamic>> mappedResults = searchResults.cast<
            Map<String, dynamic>>();
        setState(() {
          // Update your itemList with the searchResults
          itemList = mappedResults;
        });
      } else {
        // Handle error response from the backend
        print('Failed to find causes by designation');
      }
    } catch (e) {
      // Handle any exceptions that occur during the HTTP request
      print('Error finding causes by designation: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> paginatedItems = itemList
        .skip((currentPage - 1) * rowsPerPage)
        .take(rowsPerPage)
        .toList();
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(125.0), // Set the desired height
        child: AppBar(
          backgroundColor: Colors.white70,
          elevation: 1.0,
          // Set elevation to 0.0 to remove the shadow
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(0),
              bottomRight: Radius.circular(0),
            ),
          ),
          title: Row(
            children: [
              InkWell(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Incidents()),
                  );
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Text(
                    'Incidents',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 20),
              InkWell(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Cause()),
                  );
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Text(
                    'Causes',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 20),
              InkWell(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Ouvrages()),
                  );
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Text(
                    'Ouvrages',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 20),
              InkWell(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Postes()),
                  );
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Text(
                    'Postes',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 20), // Add spacing between the elements
            ],
          ),
          actions: [

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 200, // Set the desired width for the TextField
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (designation) {
                    if (designation.isEmpty) {
                      fetchData(); // Fetch original list when search field is empty
                    } else {
                      findCauseByDesignation(designation);
                    }
                  },
                ),
              ),
            ),
          ],
          toolbarHeight: 125.0,
        ),
        // Set the desired height

      ),
      body: isLoading
          ? Center(
          child:
          CircularProgressIndicator()) // Show loading indicator if data is loading
          : itemList.isEmpty
          ? Center(
          child: Text(
              'No data available')) // Show loading indicator if data is loading
          : Center(
        child: SingleChildScrollView(

          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: itemList.isEmpty
                ? CircularProgressIndicator()
                : SizedBox(
              width: 800,
              child: DataTable(
                columns: [
                  DataColumn(
                    label: Text(
                      'Code Cause',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Designation',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Actions',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],

                rows: paginatedItems.map((item) {
                  int index = itemList.indexOf(item);
                  return DataRow(cells: [
                    DataCell(Text(item['code_cause'].toString())),
                    DataCell(Text(item['designation'])),
                    DataCell(Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _editItem(context, index);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _deleteItem(context, index);
                          },
                        ),
                      ],
                    )),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Pagination(
        currentPage: currentPage,
        totalPages: (itemList.length / rowsPerPage).ceil(),
        onPageChanged: (page) {
          setState(() {
            currentPage = page;
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addItem(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _addItem(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        // Variables to hold edited values
        String editedCauseDes = '';
        int editedCauseCode = 0;


        return AlertDialog(
          title: Text('Edit Cause'),
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: 400, // Set width as per your requirement
            padding: EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) {
                      editedCauseCode = int.tryParse(value) ?? 0;
                    },
                    controller: TextEditingController(text: ''),
                    decoration: InputDecoration(labelText: 'Code de Cause'),
                  ),
                  TextField(
                    onChanged: (value) {
                      editedCauseDes = value;
                    },
                    controller: TextEditingController(text: ''),
                    decoration: InputDecoration(labelText: 'Designation'),
                  ),

                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Check if any field is empty
                if (editedCauseCode.isNaN ||
                    editedCauseDes.isEmpty) {
                  // Show an error message if any field is empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('All fields are required')),
                  );
                  return;
                }

                // Here you can implement the API call to update the item
                // Make sure to send the edited values to the backend API
                // Then, handle the response accordingly
                try {
                  Map<String, dynamic> requestBody = {
                    "code_cause": editedCauseCode,
                    "designation": editedCauseDes,

                  };

                  // Make the PUT request to update the item
                  final response = await http.post(
                    Uri.parse('http://localhost:8080/cause/add'),
                    // Adjust the API URL accordingly
                    body: json.encode(requestBody),
                    headers: {'Content-Type': 'application/json'},
                  );

                  // Check the response status code
                  if (response.statusCode == 200) {
                    setState(() {
                      fetchData();
                    });
                  } else {
                    // Error updating item
                    // You may want to handle this case and show an error message
                    print('Failed to update item');
                  }
                } catch (e) {
                  // Exception occurred during API call
                  // You may want to handle this case and show an error message
                  print('Error updating item: $e');
                }

                // For simplicity, we are just popping the dialog here
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _editItem(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) {
        // Variables to hold edited values
        String editedCauseDes = itemList[index]['designation'];
        int editedCauseCode= itemList[index]['code_cause'];


        return AlertDialog(
          title: Text('Edit Item'),
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: 400, // Set width as per your requirement
            padding: EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) {
                      editedCauseCode = int.tryParse(value) ?? 0;
                    },
                    controller: TextEditingController(
                        text: itemList[index]['code_cause'].toString()),
                    decoration: InputDecoration(labelText: 'Code de cause'),
                  ),

                  TextField(
                    onChanged: (value) {
                      editedCauseDes = value;
                    },
                    controller: TextEditingController(
                        text: itemList[index]['designation']),
                    decoration: InputDecoration(
                        labelText: 'designation de cause'),
                  ),


                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                // Check if any field is empty
                if (editedCauseDes.isEmpty || editedCauseCode.toString().isEmpty) {
                  // Show an error message if any field is empty
                  ScaffoldMessenger.of(context!).showSnackBar(
                    SnackBar(content: Text('Tous les champs sont obligatoires')),
                  );
                  return;
                }

                // Here you can implement the API call to update the item
                // Make sure to send the edited values to the backend API
                // Then, handle the response accordingly
                try {
                  Map<String, dynamic> requestBody = {
                    "code_cause": editedCauseCode,
                    "designation": editedCauseDes,

                  };

                  // Make the PUT request to update the item
                  final response = await http.put(
                    Uri.parse(
                        'http://localhost:8080/cause/update/${itemList[index]['code_cause']}'),
                    // Adjust the API URL accordingly
                    body: json.encode(requestBody),
                    headers: {'Content-Type': 'application/json'},
                  );

                  // Check the response status code
                  if (response.statusCode == 200) {
                    setState(() {
                      itemList[index]['designation'] = editedCauseDes;
                      itemList[index]['code_cause'] = editedCauseCode;
                    });

                    print('Item updated successfully');
                  } else {
                    // Error updating item
                    // You may want to handle this case and show an error message
                    print('Failed to update item');
                  }
                } catch (e) {
                  // Exception occurred during API call
                  // You may want to handle this case and show an error message
                  print('Error updating item: $e');
                }

                // For simplicity, we are just popping the dialog here
                Navigator.pop(context);
              },
              child: Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }
  Future<void> _deleteItemFromApi(int index) async {
    try {
      final response = await http.delete(
        Uri.parse(
            'http://localhost:8080/cause/delete/${itemList[index]['code_cause']}'), // Replace 'id' with your item identifier
      );
      if (response.statusCode == 200) {
        setState(() {
          itemList.removeAt(
              index); // Remove the item locally from the itemList
        });
        // Show success message or handle the response as needed
      } else {
        // Show error message or handle the response as needed
        throw Exception('Failed to delete item');
      }
    } catch (e) {
      // Handle error, display a message to the user, etc.
      print('Error deleting item: $e');
    }
  }
  void _deleteItem(BuildContext context, int index) {
    {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Delete Item'),
            content: Text('Are you sure you want to delete this item?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  // Make DELETE request to API
                  _deleteItemFromApi(index);
                  Navigator.pop(context);
                },
                child: Text('Delete'),
              ),
            ],
          );
        },
      );
    }


  }
}