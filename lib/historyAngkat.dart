import 'package:flutter/material.dart';

class HistoryAngkatPage extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  HistoryAngkatPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF041D31),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(0),
          ),
        ),
        title: const Text(
          'Riwayat Angkat',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16.0,
            color: Colors.white,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 15.0,
            top: 5.0,
            right: 15.0,
            bottom: 10.0,
          ),
          child: Column(
            children: data.map((item) {
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                color: Color(0xFF687E95), // Background color of the card
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 130,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tanggal',
                              style: TextStyle(
                                fontSize: 12.0,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD9D9D9),
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              item['tanggal'],
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.white, // Set text color to white
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 60,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Waktu',
                              style: TextStyle(
                                fontSize: 12.0,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD9D9D9),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              item['waktu'],
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.white, // Set text color to white
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 60,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Berat',
                              style: TextStyle(
                                fontSize: 12.0,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD9D9D9),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${item['berat']} Kg',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.white, // Set text color to white
                              ),
                              textAlign: TextAlign.end,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
