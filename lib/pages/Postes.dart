import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../classes/Pagination.dart';
import 'Cause.dart';
import 'Incidents.dart';
import 'Ouvrages.dart';

class Postes extends StatefulWidget {
  @override
  _PostesState createState() => _PostesState();
}

class _PostesState extends State<Postes> {
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
          await http.get(Uri.parse('http://localhost:8080/poste/getAll'));
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
  Future<void> findPostByDesignation(String PostName) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8080/poste/findPosteByPostName/$PostName'));

      if (response.statusCode == 200) {
        // Parse the JSON response and update your UI with the search results
        List<dynamic> searchResults = json.decode(response.body);
        List<Map<String, dynamic>> mappedResults = searchResults.cast<Map<String, dynamic>>();
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
          elevation: 1.0, // Set elevation to 0.0 to remove the shadow
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(0),
              bottomRight: Radius.circular(0),
            ),
          ),
          title: Row(
            // Center the elements
            children: [
              InkWell(
                onTap: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => Incidents()));
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
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => Cause()));
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
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => Ouvrages()));
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
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => Postes()));
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

              // Add other elements here as needed
            ],
          ),
          actions: [

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 200, // Set the desired width for the TextField
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Chercher...',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (PostName) {
                    if (PostName.isEmpty) {
                      fetchData(); // Fetch original list when search field is empty
                    } else {
                      findPostByDesignation(PostName);
                    }
                  },
                ),
              ),
            ),
          ],
          toolbarHeight: 125.0, // Set the desired height
        ),
      ),
      body: isLoading
          ? Center(
              child:
                  CircularProgressIndicator()) // Show loading indicator if data is loading
          : itemList.isEmpty
              ? Center(child: Text('Aucune donnée disponible'))
              : Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        columns: [
                          DataColumn(
                            label: Text(
                              'Nom du poste',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Désignation',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Type',
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
                            DataCell(Text(item['nom_Poste'])),
                            DataCell(Text(item['designation'])),
                            DataCell(Text(item['type'])),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    // Implement edit action
                                    _editItem(index);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    // Implement delete action
                                    _deleteItem(index);
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
      onPressed: _addItem,
      child: Icon(Icons.add),
    ),
    );
  }
  void _addItem() {
    showDialog(
      context: context,
      builder: (context) {
        // Variables to hold edited values
        String editedNomPoste = '';

        String editedDesignation = '';
        String Type='';


        return AlertDialog(
          title: Text('Ajouter Poste'),
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
                      editedNomPoste = value;
                    },
                    controller: TextEditingController(text: ''),
                    decoration: InputDecoration(labelText: 'Nom du Poste'),
                  ),
                  TextField(
                    onChanged: (value) {
                      editedDesignation = value;
                    },
                    controller: TextEditingController(text: ''),
                    decoration: InputDecoration(labelText: 'Désignation'),
                  ),
                  TextField(
                    onChanged: (value) {
                      Type = value;
                    },
                    controller: TextEditingController(text: ''),
                    decoration: InputDecoration(labelText: 'Type'),
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
                if (editedNomPoste.isEmpty ||
                    editedDesignation.isEmpty ||
                    Type.isEmpty) {
                  // Show an error message if any field is empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Tous les champs sont obligatoires')),
                  );
                  return;
                }

                // Here you can implement the API call to update the item
                // Make sure to send the edited values to the backend API
                // Then, handle the response accordingly
                try {

                  Map<String, dynamic> requestBody = {
                    "nom_Poste": editedNomPoste,
                    "type": Type,

                    "designation": editedDesignation,


                  };

                  // Make the PUT request to update the item
                  final response = await http.post(
                    Uri.parse('http://localhost:8080/poste/add'),
                    // Adjust the API URL accordingly
                    body: json.encode(requestBody),
                    headers: {'Content-Type': 'application/json'},
                  );

                  // Check the response status code
                  if (response.statusCode == 200) {
                    setState(() {
                      fetchData();
                    });

                    print('Article mis à jour avec succès');
                  } else {
                    // Error updating item
                    // You may want to handle this case and show an error message
                    print('Échec de la mise à jour de l\'élément');

                  }
                } catch (e) {
                  // Exception occurred during API call
                  // You may want to handle this case and show an error message
                  print('Erreur lors de la mise à jour de l\'élément: $e');
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

  void _editItem(int index) {
    showDialog(
      context: context,
      builder: (context) {
        // Variables to hold edited values
        String editedNomPoste = itemList[index]['nom_Poste'];
        String editedDesignation = itemList[index]['designation'];
        String Type=itemList[index]['type'];

        return AlertDialog(
          title: Text('Modifier Poste'),
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
                      editedNomPoste = value;
                    },
                    controller: TextEditingController(text: editedNomPoste),
                    decoration: InputDecoration(labelText: 'Nom du Poste'),
                  ),
                  TextField(
                    onChanged: (value) {
                      editedDesignation = value;
                    },
                    controller: TextEditingController(text: editedDesignation),
                    decoration: InputDecoration(labelText: 'Désignation'),
                  ),
                  TextField(
                    onChanged: (value) {
                      Type= value;
                    },
                    controller: TextEditingController(text: Type),
                    decoration: InputDecoration(labelText: 'Type'),
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
                if (editedNomPoste.isEmpty ||
                    editedDesignation.isEmpty ||
                    Type.isEmpty) {
                  // Show an error message if any field is empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Tous les champs sont obligatoires')),
                  );
                  return;
                }

                // Here you can implement the API call to update the item
                // Make sure to send the edited values to the backend API
                // Then, handle the response accordingly
                try {
                  Map<String, dynamic> requestBody = {
                    "nom_Poste": editedNomPoste,
                    "type": Type,
                    "designation": editedDesignation,

                  };
                  // Make the PUT request to update the item
                  final response = await http.put(
                    Uri.parse(
                        'http://localhost:8080/poste/update/${itemList[index]['nom_Poste']}'),
                    // Adjust the API URL accordingly
                    body: json.encode(requestBody),
                    headers: {'Content-Type': 'application/json'},
                  );
                  print(itemList[index]['num_Incident']);
                  // Check the response status code
                  if (response.statusCode == 200) {
                    setState(() {
                      itemList[index]['nom_Poste']=editedNomPoste ;
                      itemList[index]['designation']=editedDesignation ;
                      itemList[index]['type']=Type;
                    });

                    print('Article mis à jour avec succès"');
                  } else {
                    // Error updating item
                    // You may want to handle this case and show an error message
                    print('Échec de la mise à jour de l\'élément');
                  }
                } catch (e) {
                  // Exception occurred during API call
                  // You may want to handle this case and show an error message
                  print('Erreur lors de la mise à jour de l\'élément: $e');
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

  void _deleteItem(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Supprimer Poste'),
          content: Text('Êtes-vous sûr de vouloir supprimer cet élément ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                // Make DELETE request to API
                _deleteItemFromApi(index);
                Navigator.pop(context);
              },
              child: Text('Supprimer'),
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
            'http://localhost:8080/poste/delete/${itemList[index]['nom_Poste']}'), // Replace 'id' with your item identifier
      );
      if (response.statusCode == 200) {
        setState(() {
          itemList.removeAt(index); // Remove the item locally from the itemList
        });
        // Show success message or handle the response as needed
      } else {
        // Show error message or handle the response as needed
        throw Exception('Échec de la suppression de l\'élément');
      }
    } catch (e) {
      // Handle error, display a message to the user, etc.
      print('Erreur lors de la suppression de l\'élément: $e');
    }
  }
}


