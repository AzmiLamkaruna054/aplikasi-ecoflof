import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getHistory() async {
    List<Map<String, dynamic>> historyList = [];

    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('riwayat').get();

      initializeDateFormatting(
          'id_ID', null); // Inisialisasi lokal bahasa Indonesia

      querySnapshot.docs.forEach((doc) {
        Timestamp timestamp = doc['tanggal'];
        DateTime dateTime = timestamp.toDate();
        String formattedDate = DateFormat('EEEE dd/MM/yyyy', 'id_ID').format(
            dateTime); // Format tanggal dengan nama hari dalam bahasa Indonesia
        historyList.add({
          'tanggal': formattedDate,
          'berat': doc['berat'].toString(), // Convert berat to string
        });
      });
      print(historyList);
    } catch (e) {
      print('Error fetching history: $e');
    }

    return historyList;
  }

  Future<void> addHistoryAngkat(String berat) async {
    try {
      // Buat referensi koleksi 'riwayat' di Firestore dan tambahkan dokumen baru
      await _firestore.collection('riwayatAngkat').add({
        'waktu': DateTime.now(), // Tambahkan timestamp saat ini
        'berat': berat,
      });
      print('History added to Firestore');
    } catch (e) {
      print('Error adding history to Firestore: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getHistoryAngkat() async {
    List<Map<String, dynamic>> historyAngkatList = [];

    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('riwayatAngkat').get();

      initializeDateFormatting(
          'id_ID', null); // Inisialisasi lokal bahasa Indonesia

      querySnapshot.docs.forEach((doc) {
        Timestamp timestamp = doc['waktu'];
        DateTime dateTime = timestamp.toDate();
        String formattedDate = DateFormat('EEEE dd/MM/yyyy', 'id_ID').format(
            dateTime); // Format tanggal dengan nama hari dalam bahasa Indonesia
        String formattedTime = DateFormat.Hm().format(dateTime); // Format waktu

        historyAngkatList.add({
          'waktu': formattedTime, // Tambahkan waktu ke dalam map
          'tanggal': formattedDate,
          'berat': doc['berat'].toString(), // Convert berat to string
        });
      });
      print(historyAngkatList);
    } catch (e) {
      print('Error fetching history: $e');
    }

    return historyAngkatList;
  }
}
