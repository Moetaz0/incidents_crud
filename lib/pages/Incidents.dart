import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:incidents_crud/pages/Ouvrages.dart';
import 'package:sticky_headers/sticky_headers.dart';
import '../classes/Pagination.dart';
import 'Cause.dart';
import 'Postes.dart';

class Incidents extends StatefulWidget {
  @override
  _IncidentsState createState() => _IncidentsState();
}

class _IncidentsState extends State<Incidents> {
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
          await http.get(Uri.parse('http://localhost:8080/incident/getAll'));
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

  Future<void> findIncidentByDesignation(String PostName) async {
    try {
      final response = await http.get(Uri.parse(
          'http://localhost:8080/incident/findIncidentByPostName/$PostName'));

      if (response.statusCode == 200) {
        // Parse the JSON response and update your UI with the search results
        List<dynamic> searchResults = json.decode(response.body);
        List<Map<String, dynamic>> mappedResults =
            searchResults.cast<Map<String, dynamic>>();
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

// Usage example

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
          backgroundColor: Colors.white38,
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
                      findIncidentByDesignation(PostName);
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
              ? Center(
                  child: Text(
                      'Aucune donnée disponible')) // Show message if itemList is empty
              : SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        DataColumn(
                          label: Text(
                            'Numéro l\'Incident',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),

                        DataColumn(
                          label: Text(
                            'Nom du Poste',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Nom du Départ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Code de la Cause',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Code Siège 1',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Code Nationale',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Date de l\'Incident',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Date de Retour',
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
                          DataCell(Text(item['num_Incident'].toString())),

                          DataCell(Text(item['nom_Poste'].toString())),
                          DataCell(Text(item['nom_Depart'].toString())),
                          DataCell(Text(item['code_Cause'].toString())),
                          DataCell(Text(item['code_Siege1'].toString())),
                          DataCell(Text(item['code_Nat_Dcl'].toString())),
                          DataCell(Text(
                              '${item['annee_Inc']}/${item['mois_Inc']}/${item['jour_Inc']}  ${item['heure_Inc']}:${item['minute_Inc']}')),
                          DataCell(Text(
                              '${item['annee_Ret']}/${item['mois_Ret']}/${item['jour_Ret']}  ${item['heure_Ret']}:${item['minute_Ret']}')),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  _editItem(index);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
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
        int editedJourRet = 0;
        int editedHeureRet = 0;
        int editedMoisRet = 0;
        int editedMinuteRet = 0;
        int editedJourInc = 0;
        int editedAnneeInc = 0;
        int editedMinuteInc = 0;
        int editedMoisInc = 0;
        int editedAnneeRet = 0;
        int editedNumIncident = 0;
        String editedCodeCause = '';
        String editedCodeSiege1 = '';
        int editedHeureInc = 0;
        String editedCodeNatDcl = '';
        String editedNomDepart = '';

        return AlertDialog(
          title: Text('Modifier l\'incident'),
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
                      editedNumIncident = int.tryParse(value) ?? 0;
                    },
                    controller: TextEditingController(text: ''),
                    decoration: InputDecoration(labelText: 'Numéro de l\'incident'),
                  ),
                  TextField(
                    onChanged: (value) {
                      editedNomPoste = value;
                    },
                    controller: TextEditingController(text: ''),
                    decoration: InputDecoration(labelText: 'Nom du Poste'),
                  ),
                  TextField(
                    onChanged: (value) {
                      editedNomDepart = value;
                    },
                    controller: TextEditingController(text: ''),
                    decoration: InputDecoration(labelText: 'Nom du Depart'),
                  ),
                  TextField(
                    onChanged: (value) {
                      editedCodeCause = value;
                    },
                    controller: TextEditingController(text: ''),
                    decoration: InputDecoration(labelText: 'Code de Cause'),
                  ),
                  TextField(
                    onChanged: (value) {
                      editedCodeSiege1 = value;
                    },
                    controller: TextEditingController(text: ''),
                    decoration: InputDecoration(labelText: 'Code de Siege1'),
                  ),
                  TextField(
                    onChanged: (value) {
                      editedCodeNatDcl = value;
                    },
                    controller: TextEditingController(text: ''),
                    decoration: InputDecoration(labelText: 'Code Nat Dcl'),
                  ),
                  TextField(
                    onChanged: (value) {
                      editedMinuteRet = int.tryParse(value) ?? 0;
                    },
                    controller: TextEditingController(text: ''),
                    decoration: InputDecoration(labelText: 'Minute de retour'),
                  ),
                  TextField(
                    onChanged: (value) {
                      editedHeureRet = int.tryParse(value) ?? 0;
                    },
                    controller: TextEditingController(text: ''),
                    decoration: InputDecoration(labelText: 'Heure de retour'),
                  ),
                  TextField(
                    onChanged: (value) {
                      editedJourRet = int.tryParse(value) ?? 0;
                    },
                    controller: TextEditingController(text: ''),
                    decoration: InputDecoration(labelText: 'Jour de retour'),
                  ),
                  TextField(
                    onChanged: (value) {
                      editedMoisRet = int.tryParse(value) ?? 0;
                    },
                    controller: TextEditingController(text: ''),
                    decoration: InputDecoration(labelText: 'Mois de retour'),
                  ),
                  TextField(
                    onChanged: (value) {
                      editedAnneeRet = int.tryParse(value) ?? 0;
                    },
                    controller: TextEditingController(text: ''),
                    decoration: InputDecoration(labelText: 'Année de retour'),
                  ),
                  TextField(
                    onChanged: (value) {
                      editedMinuteInc = int.tryParse(value) ?? 0;
                    },
                    controller: TextEditingController(text: ''),
                    decoration: InputDecoration(labelText: 'Minute de l\'incident'),
                  ),
                  TextField(
                    onChanged: (value) {
                      editedHeureInc = int.tryParse(value) ?? 0;
                    },
                    controller: TextEditingController(text: ''),
                    decoration: InputDecoration(labelText: 'Heure de l\'incident'),
                  ),
                  TextField(
                    onChanged: (value) {
                      editedJourInc = int.tryParse(value) ?? 0;
                    },
                    controller: TextEditingController(text: ''),
                    decoration: InputDecoration(labelText: 'Jour de l\'incident'),
                  ),
                  TextField(
                    onChanged: (value) {
                      editedMoisInc = int.tryParse(value) ?? 0;
                    },
                    controller: TextEditingController(text: ''),
                    decoration: InputDecoration(labelText: 'Mois de l\'incident'),
                  ),
                  TextField(
                    onChanged: (value) {
                      editedAnneeInc = int.tryParse(value) ?? 0;
                    },
                    controller: TextEditingController(text: ''),
                    decoration: InputDecoration(labelText: 'Année de l\'incident'),
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
                    editedCodeCause.isEmpty ||
                    editedCodeSiege1.isEmpty ||
                    editedCodeNatDcl.isEmpty ||
                    editedNomDepart.isEmpty) {
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
                  if (editedMinuteRet >= 60) {
                    editedHeureRet += editedMinuteRet ~/
                        60; // Add the quotient to editedHeureRet
                    editedMinuteRet %= 60; // Keep only the remainder
                  }
                  if (editedMinuteInc >= 60) {
                    editedHeureInc += editedMinuteInc ~/
                        60; // Add the quotient to editedHeureRet
                    editedMinuteInc %= 60; // Keep only the remainder
                  }
                  if (editedHeureRet >= 24) {
                    editedJourRet += editedHeureRet ~/ 24;
                    editedHeureRet %= 24;
                  }
                  if (editedHeureInc >= 24) {
                    editedJourInc += editedHeureInc ~/ 24;

                    editedHeureInc %= 24; // Adjust to be within 0-23
                  }
                  if (editedMoisInc > 12) {
                    editedAnneeInc += editedMoisInc ~/ 12;
                    editedMoisInc %= 12; // Adjust to be within 1-12
                  }
                  if (editedMoisRet > 12) {
                    editedAnneeRet += editedMoisRet ~/ 12;
                    editedMoisRet %= 12; // Adjust to be within 1-12
                  }
                  int getMaxDaysInMonth(int month, int year) {
                    switch (month) {
                      case 4: // April
                      case 6: // June
                      case 9: // September
                      case 11: // November
                        return 30;
                      case 2: // February
                        // Check for leap year
                        if ((year % 4 == 0 && year % 100 != 0) ||
                            year % 400 == 0) {
                          return 29; // Leap year
                        } else {
                          return 28; // Non-leap year
                        }
                      default:
                        return 31;
                    }
                  }

                  int maxDaysRet = getMaxDaysInMonth(editedMoisRet, editedAnneeRet);
                  if (editedJourRet > maxDaysRet) {
                    editedJourRet = maxDaysRet; // Set the day to the maximum days of the month
                  }
                  int maxDaysInc = getMaxDaysInMonth(editedMoisInc, editedAnneeInc);
                  if (editedJourInc > maxDaysInc) {
                    editedJourInc = maxDaysInc; // Set the day to the maximum days of the month
                  }
                  if (editedAnneeInc < 2000) {
                    editedAnneeInc = 2000; // Set the year to the minimum allowed value
                  } else if (editedAnneeInc > 2100) {
                    editedAnneeInc = 2100; // Set the year to the maximum allowed value
                  }

                  if (editedAnneeRet < 2000) {
                    editedAnneeRet = 2000; // Set the year to the minimum allowed value
                  } else if (editedAnneeRet > 2100) {
                    editedAnneeRet = 2100; // Set the year to the maximum allowed value
                  }
                  // Construct the request body with edited values
                  // Construct the request body with edited values
                  Map<String, dynamic> requestBody = {
                    "nom_Poste": editedNomPoste,
                    "jour_Ret": editedJourRet,
                    "heure_Ret": editedHeureRet,
                    "mois_Ret": editedMoisRet,
                    "minute_Ret": editedMinuteRet,
                    "jour_Inc": editedJourInc,
                    "annee_Inc": editedAnneeInc,
                    "minute_Inc": editedMinuteInc,
                    "mois_Inc": editedMoisInc,
                    "annee_Ret": editedAnneeRet,
                    "num_Incident": editedNumIncident,
                    "code_Cause": editedCodeCause,
                    "code_Siege1": editedCodeSiege1,
                    "heure_Inc": editedHeureInc,
                    "code_Nat_Dcl": editedCodeNatDcl,
                    "nom_Depart": editedNomDepart,
                  };

                  // Make the PUT request to update the item
                  final response = await http.post(
                    Uri.parse('http://localhost:8080/incident/add'),
                    // Adjust the API URL accordingly
                    body: json.encode(requestBody),
                    headers: {'Content-Type': 'application/json'},
                  );

                  // Check the response status code
                  if (response.statusCode == 200) {
                    setState(() {
                      fetchData();
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
              child: Text('Save'),
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
        int editedJourRet = itemList[index]['jour_Ret'];
        int editedHeureRet = itemList[index]['heure_Ret'];
        int editedMoisRet = itemList[index]['mois_Ret'];
        int editedMinuteRet = itemList[index]['minute_Ret'];
        int editedJourInc = itemList[index]['jour_Inc'];
        int editedAnneeInc = itemList[index]['annee_Inc'];
        int editedMinuteInc = itemList[index]['minute_Inc'];
        int editedMoisInc = itemList[index]['mois_Inc'];
        int editedAnneeRet = itemList[index]['annee_Ret'];
        int editedNumIncident = itemList[index]['num_Incident'];
        String editedCodeCause = itemList[index]['code_Cause'];
        String editedCodeSiege1 = itemList[index]['code_Siege1'];
        int editedHeureInc = itemList[index]['heure_Inc'];
        String editedCodeNatDcl = itemList[index]['code_Nat_Dcl'];
        String editedNomDepart = itemList[index]['nom_Depart'];

        return AlertDialog(
          title: Text('Modifier l\'incident'),
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
                      editedNumIncident = int.tryParse(value) ?? 0;
                    },
                    controller: TextEditingController(
                        text: itemList[index]['num_Incident'].toString()),
                    decoration: InputDecoration(labelText: 'Numéro d\'incident'),
                  ),

                  TextField(
                    onChanged: (value) {
                      editedNomPoste = value;
                    },
                    controller: TextEditingController(
                        text: itemList[index]['nom_Poste']),
                    decoration: InputDecoration(labelText: 'Nom du Poste'),
                  ),
                  TextField(
                    onChanged: (value) {
                      editedNomDepart = value;
                    },
                    controller: TextEditingController(
                        text: itemList[index]['nom_Depart']),
                    decoration: InputDecoration(labelText: 'Nom du Depart'),
                  ),
                  TextField(
                    onChanged: (value) {
                      editedCodeCause = value;
                    },
                    controller: TextEditingController(
                        text: itemList[index]['code_Cause']),
                    decoration: InputDecoration(labelText: 'Code de Cause'),
                  ),
                  TextField(
                    onChanged: (value) {
                      editedCodeSiege1 = value;
                    },
                    controller: TextEditingController(
                        text: itemList[index]['code_Siege1']),
                    decoration: InputDecoration(labelText: 'Code de Siege1'),
                  ),
                  TextField(
                    onChanged: (value) {
                      editedCodeNatDcl = value;
                    },
                    controller: TextEditingController(
                        text: itemList[index]['code_Nat_Dcl']),
                    decoration: InputDecoration(labelText: 'Code Nat Dcl'),
                  ),
                  TextField(
                    onChanged: (value) {
                      editedMinuteRet = int.tryParse(value) ?? 0;
                    },
                    controller: TextEditingController(
                        text: itemList[index]['minute_Ret'].toString()),
                    decoration: InputDecoration(labelText: 'Minute de retour'),
                  ),
                  TextField(
                    onChanged: (value) {
                      editedHeureRet = int.tryParse(value) ?? 0;
                    },
                    controller: TextEditingController(
                        text: itemList[index]['heure_Ret'].toString()),
                    decoration: InputDecoration(labelText: 'Heure de retour'),
                  ),
                  TextField(
                    onChanged: (value) {
                      editedJourRet = int.tryParse(value) ?? 0;
                    },
                    controller: TextEditingController(
                        text: itemList[index]['jour_Ret'].toString()),
                    decoration: InputDecoration(labelText: 'Jour de retour'),
                  ),

                  TextField(
                    onChanged: (value) {
                      editedMoisRet = int.tryParse(value) ?? 0;
                    },
                    controller: TextEditingController(
                        text: itemList[index]['mois_Ret'].toString()),
                    decoration: InputDecoration(labelText: 'Mois de retour'),
                  ),
                  TextField(
                    onChanged: (value) {
                      editedAnneeInc = int.tryParse(value) ?? 0;
                    },
                    controller: TextEditingController(
                        text: itemList[index]['annee_Ret'].toString()),
                    decoration: InputDecoration(labelText: 'Année de retour'),
                  ),
                  TextField(
                    onChanged: (value) {
                      editedHeureInc = int.tryParse(value) ?? 0;
                    },
                    controller: TextEditingController(
                        text: itemList[index]['minute_Inc'].toString()),
                    decoration: InputDecoration(labelText: 'Minute de l\'incident'),
                  ),
                  TextField(
                    onChanged: (value) {
                      editedHeureInc = int.tryParse(value) ?? 0;
                    },
                    controller: TextEditingController(
                        text: itemList[index]['heure_Inc'].toString()),
                    decoration: InputDecoration(labelText: 'Heure de l\'incident'),
                  ),

                  TextField(
                    onChanged: (value) {
                      editedJourInc = int.tryParse(value) ?? 0;
                    },
                    controller: TextEditingController(
                        text: itemList[index]['jour_Inc'].toString()),
                    decoration: InputDecoration(labelText: 'Jour de l\'incident'),
                  ),

                  TextField(
                    onChanged: (value) {
                      editedMoisInc = int.tryParse(value) ?? 0;
                    },
                    controller: TextEditingController(
                        text: itemList[index]['mois_Inc'].toString()),
                    decoration: InputDecoration(labelText: 'Mois de l\'incident'),
                  ),
                  TextField(
                    onChanged: (value) {
                      editedAnneeInc = int.tryParse(value) ?? 0;
                    },
                    controller: TextEditingController(
                        text: itemList[index]['annee_Inc'].toString()),
                    decoration: InputDecoration(labelText: 'Année de l\'incident'),
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
                    editedCodeCause.isEmpty ||
                    editedCodeSiege1.isEmpty ||
                    editedCodeNatDcl.isEmpty ||
                    editedNomDepart.isEmpty) {
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
                  if (editedMinuteRet >= 60) {
                    editedHeureRet += editedMinuteRet ~/
                        60; // Add the quotient to editedHeureRet
                    editedMinuteRet %= 60; // Keep only the remainder
                  }
                  if (editedMinuteInc >= 60) {
                    editedHeureInc += editedMinuteInc ~/
                        60; // Add the quotient to editedHeureRet
                    editedMinuteInc %= 60; // Keep only the remainder
                  }
                  if (editedHeureRet >= 24) {
                    editedJourRet += editedHeureRet ~/ 24;
                    editedHeureRet %= 24;
                  }
                  if (editedHeureInc >= 24) {
                    editedJourInc += editedHeureInc ~/ 24;

                    editedHeureInc %= 24; // Adjust to be within 0-23
                  }
                  if (editedMoisInc > 12) {
                    editedAnneeInc += editedMoisInc ~/ 12;
                    editedMoisInc %= 12; // Adjust to be within 1-12
                  }
                  if (editedMoisRet > 12) {
                    editedAnneeRet += editedMoisRet ~/ 12;
                    editedMoisRet %= 12; // Adjust to be within 1-12
                  }
                  int getMaxDaysInMonth(int month, int year) {
                    switch (month) {
                      case 4: // April
                      case 6: // June
                      case 9: // September
                      case 11: // November
                        return 30;
                      case 2: // February
                      // Check for leap year
                        if ((year % 4 == 0 && year % 100 != 0) ||
                            year % 400 == 0) {
                          return 29; // Leap year
                        } else {
                          return 28; // Non-leap year
                        }
                      default:
                        return 31;
                    }
                  }

                  int maxDaysRet = getMaxDaysInMonth(editedMoisRet, editedAnneeRet);
                  if (editedJourRet > maxDaysRet) {
                    editedJourRet = maxDaysRet; // Set the day to the maximum days of the month
                  }
                  int maxDaysInc = getMaxDaysInMonth(editedMoisInc, editedAnneeInc);
                  if (editedJourInc > maxDaysInc) {
                    editedJourInc = maxDaysInc; // Set the day to the maximum days of the month
                  }
                  if (editedAnneeInc < 2000) {
                    editedAnneeInc = 2000; // Set the year to the minimum allowed value
                  } else if (editedAnneeInc > 2100) {
                    editedAnneeInc = 2100; // Set the year to the maximum allowed value
                  }

                  if (editedAnneeRet < 2000) {
                    editedAnneeRet = 2000; // Set the year to the minimum allowed value
                  } else if (editedAnneeRet > 2100) {
                    editedAnneeRet = 2100; // Set the year to the maximum allowed value
                  }
                  // Construct the request body with edited values
                  // Construct the request body with edited values
                  Map<String, dynamic> requestBody = {
                    "nom_Poste": editedNomPoste,
                    "jour_Ret": editedJourRet,
                    "heure_Ret": editedHeureRet,
                    "mois_Ret": editedMoisRet,
                    "minute_Ret": editedMinuteRet,
                    "jour_Inc": editedJourInc,
                    "annee_Inc": editedAnneeInc,
                    "minute_Inc": editedMinuteInc,
                    "mois_Inc": editedMoisInc,
                    "annee_Ret": editedAnneeRet,
                    "num_Incident": editedNumIncident,
                    "code_Cause": editedCodeCause,
                    "code_Siege1": editedCodeSiege1,
                    "heure_Inc": editedHeureInc,
                    "code_Nat_Dcl": editedCodeNatDcl,
                    "nom_Depart": editedNomDepart,
                  };

                  // Make the PUT request to update the item
                  final response = await http.put(
                    Uri.parse(
                        'http://localhost:8080/incident/update/${itemList[index]['num_Incident']}'),
                    // Adjust the API URL accordingly
                    body: json.encode(requestBody),
                    headers: {'Content-Type': 'application/json'},
                  );
                  print(itemList[index]['num_Incident']);
                  // Check the response status code
                  if (response.statusCode == 200) {
                    setState(() {
                      // Update the itemList[index] with the edited values
                      itemList[index]['nom_Poste'] = editedNomPoste;
                      itemList[index]['jour_Ret'] = editedJourRet;
                      itemList[index]['heure_Ret'] = editedHeureRet;
                      itemList[index]['mois_Ret'] = editedMoisRet;
                      itemList[index]['minute_Ret'] = editedMinuteRet;
                      itemList[index]['jour_Inc'] = editedJourInc;
                      itemList[index]['annee_Inc'] = editedAnneeInc;
                      itemList[index]['minute_Inc'] = editedMinuteInc;
                      itemList[index]['mois_Inc'] = editedMoisInc;
                      itemList[index]['annee_Ret'] = editedAnneeRet;
                      itemList[index]['num_Incident'] = editedNumIncident;
                      itemList[index]['code_Cause'] = editedCodeCause;
                      itemList[index]['code_Siege1'] = editedCodeSiege1;
                      itemList[index]['heure_Inc'] = editedHeureInc;
                      itemList[index]['code_Nat_Dcl'] = editedCodeNatDcl;
                      itemList[index]['nom_Depart'] = editedNomDepart;
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
              child: Text('Save'),
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
          title: Text('Supprimer l\'incident'),
          content: Text('Êtes-vous sûr de vouloir supprimer cet incident ?'),
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
            'http://localhost:8080/incident/delete/${itemList[index]['num_Incident']}'), // Replace 'id' with your item identifier
      );
      if (response.statusCode == 200) {
        setState(() {
          itemList.removeAt(index); // Remove the item locally from the itemList
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
}
