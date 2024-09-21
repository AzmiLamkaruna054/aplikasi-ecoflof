import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecoflow/historyAngkat.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:permission_handler/permission_handler.dart';
import 'firestore_service.dart';
import 'package:flutter/material.dart';
import 'notifikasi.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:d_info/d_info.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'package:firebase_core/firebase_core.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isFirebaseInitialized = false;

  @override
  void initState() {
    super.initState();
    // Panggil fungsi untuk memeriksa koneksi Firebase saat widget diinisialisasi
    _checkFirebaseConnection();
    _requestNotificationPermission();
  }

  Future<void> _requestNotificationPermission() async {
    PermissionStatus status = await Permission.notification.status;
    if (!status.isGranted) {
      status = await Permission.notification.request();
      if (status.isGranted) {
        print("Notification permission granted");
      } else if (status.isDenied) {
        print("Notification permission denied");
      } else if (status.isPermanentlyDenied) {
        openAppSettings();
      }
    }
  }

  Future<void> _checkFirebaseConnection() async {
    try {
      // Inisialisasi Firebase
      await Firebase.initializeApp();
      // Jika berhasil terhubung, set _isFirebaseInitialized menjadi true
      setState(() {
        _isFirebaseInitialized = true;
      });
      // print('Firebase connected successfully');
    } catch (e) {
      // Jika gagal terhubung, cetak pesan kesalahan
      // print('Error connecting to Firebase: $e');
    }
  }

  void _goToNotificationsPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NotifikasiPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF041D31),
        title: HeaderContent(),
        automaticallyImplyLeading: false,
        toolbarHeight: 120.0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
        ),
        actions: [
          IconButton(
            icon: Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            onPressed: () {
              _goToNotificationsPage(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              _isFirebaseInitialized
                  ? Container()
                  : AlertDialog(
                      title: Text('Error'),
                      content: Text('Error connecting to Firebase'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('OK'),
                        ),
                      ],
                    ),
              SizedBox(height: 12.0),
              BarStatusSampah(),
              TampungSampahSekarang(),
              RiwayatAngkat(),
              // Riwayat(),
              SizedBox(height: 10.0),
            ],
          ),
        ),
      ),
    );
  }
}

class HeaderContent extends StatefulWidget {
  @override
  _HeaderContentState createState() => _HeaderContentState();
}

class _HeaderContentState extends State<HeaderContent> {
  late Stream<DateTime> _dateTimeStream;
  late StreamController<DateTime> _controller;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    _controller = StreamController<DateTime>();
    _dateTimeStream = _controller.stream;
    _startTimer();
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  void _startTimer() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      _controller.add(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hai,\nSelamat datang di aplikasi',
                      style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),

                    Text(
                      'EcoFlow',
                      style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SizedBox(
                        height: 8), // Tambahkan jarak antara teks dan tanggal
                    StreamBuilder<DateTime>(
                      stream: _dateTimeStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          String formattedDate =
                              DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
                                  .format(snapshot.data!);
                          return Text(
                            formattedDate,
                            style: TextStyle(
                                fontSize: 12.0,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          );
                        } else {
                          return Text(
                              '.........................................................',
                              style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white));
                        }
                      },
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BarStatusSampah extends StatefulWidget {
  @override
  _BarStatusSampahState createState() => _BarStatusSampahState();
}

class _BarStatusSampahState extends State<BarStatusSampah> {
  final databaseReference = FirebaseDatabase.instance.ref('status_sampah');
  double statusPenampungan = 0.0;
  double statusJaring = 0.0;
  bool _isNotificationSent = false;
  bool _isJaringNotificationSent = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    initFirebaseData();
  }

  void initFirebaseData() {
    final firebaseApp = Firebase.app();
    final rtdb = FirebaseDatabase.instanceFor(
        app: firebaseApp,
        databaseURL:
            'https://ecoflow-11-7-default-rtdb.asia-southeast1.firebasedatabase.app/');
    databaseReference.keepSynced(true);

    // Listen to status jaring changes
    DatabaseReference ref = rtdb.ref().child('status_sampah').child('status_jaring');
    Stream<DatabaseEvent> stream = ref.onValue;
    stream.listen((DatabaseEvent event) {
      var snapshot = event.snapshot;
      if (snapshot.value != null) {
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(seconds: 2), () {
          setState(() {
            statusJaring = double.parse(snapshot.value.toString());
            checkJaringStatus(); // Panggil checkJaringStatus setelah status jaring berubah
          });
        });
      }
    });

    // Listen to status penampungan changes
    DatabaseReference ref2 = rtdb.ref().child('status_sampah').child('status_penampungan');
    Stream<DatabaseEvent> stream2 = ref2.onValue;
    stream2.listen((DatabaseEvent event) {
      var snapshot = event.snapshot;
      if (snapshot.value != null) {
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(seconds: 2), () {
          setState(() {
            statusPenampungan = double.parse(snapshot.value.toString());
            checkPenampunganStatus(); // Panggil checkPenampunganStatus setelah status penampungan berubah
          });
        });
      }
    });
  }

// Fungsi untuk mengecek status penampungan sampah
void checkPenampunganStatus() async {
  double maxLoad = 4.0;
  double warningLoad = 2.0;
  bool shouldSendNotification = false;
  String title = '';
  String description = '';
  String level = '';

  // Cek apakah penampungan penuh atau hampir penuh
  if (statusPenampungan >= maxLoad && !_isNotificationSent) {
    shouldSendNotification = true;
    title = 'Penampungan Sampah Penuh';
    description = 'Penampungan sampah telah mencapai kapasitas maksimal.';
    level = 'danger';
  } else if (statusPenampungan >= warningLoad &&
      statusPenampungan < maxLoad &&
      !_isNotificationSent) {
    shouldSendNotification = true;
    title = 'Penampungan Sampah Hampir Penuh';
    description = 'Penampungan sampah hampir mencapai kapasitas maksimal.';
    level = 'warning';
  }

  // Kirim notifikasi jika perlu
  if (shouldSendNotification) {
    _isNotificationSent = true;
    await sendNotification(title, description, level, statusPenampungan, null);
  } else if (statusPenampungan < warningLoad) {
    _isNotificationSent = false;
  }
}

// Fungsi untuk mengecek status jaring sampah
void checkJaringStatus() async {
  double maxCapacity = 1.8;
  // Batasi nilai status jaring agar tidak melebihi kapasitas maksimum
  if (statusJaring > maxCapacity) {
    statusJaring = maxCapacity;
  }

  // Hitung persentase kapasitas jaring yang terisi
  double valueCapacity = (statusJaring / maxCapacity) * 100;

  bool shouldSendJaringNotification = false;
  String title = '';
  String description = '';
  String level = '';

  // Cek apakah status jaring mencapai 100%
  if (valueCapacity >= 100 && !_isJaringNotificationSent) {
    shouldSendJaringNotification = true;
    title = 'Sampah melebihi kapasitas';
    description = 'Beban sampah melebihi kapasitas maksimal!.';
    level = 'critical';
  }

  // Kirim notifikasi jika perlu
  if (shouldSendJaringNotification) {
    _isJaringNotificationSent = true;
    await sendNotification(title, description, level, null, statusJaring);
  } else if (valueCapacity < 100) {
    _isJaringNotificationSent = false;
  }
}

// Fungsi untuk mengirim notifikasi dengan status penampungan dan jaring
Future<void> sendNotification(String title, String description, String level, double? statusPenampungan, double? statusJaring) async {
  try {
    Map<String, dynamic> notificationData = {
      'judul': title,
      'deskripsi': description,
      'level': level,
      'waktu': Timestamp.now(),
    };

    // Tambahkan status penampungan atau jaring jika tersedia
    if (statusPenampungan != null) {
      notificationData['statusPenampungan'] = statusPenampungan;
    }
    if (statusJaring != null) {
      notificationData['statusJaring'] = statusJaring;
    }

    await FirebaseFirestore.instance.collection('notifikasi').add(notificationData);
    print('Notifikasi baru telah ditambahkan ke Firestore.');
  } catch (e) {
    print('Error saat menambahkan notifikasi ke Firestore: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    double maxLoad = 4.0;
    double value = (statusPenampungan / maxLoad) * 100;

    double maxCapacity = 1.8;
    if (statusJaring > 1.8) {
      statusJaring = 1.8;
    }
    double valueCapacity = (statusJaring / maxCapacity) * 100;
  
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      margin: const EdgeInsets.all(16.0),
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.7),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status Penampungan Sampah',
              style: TextStyle(
                fontSize: 13.0,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6.0),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: LinearProgressIndicator(
                    borderRadius: BorderRadius.circular(8.0),
                    value: value / 100,
                    backgroundColor: const Color(0xFFD9D9D9),
                    minHeight: 7.0,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      getValueColor(value),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  flex: 1,
                  child: Text(
                    '${statusPenampungan.toStringAsFixed(1)} Kg / ${maxLoad.toStringAsFixed(1)} Kg',
                    style: const TextStyle(
                      fontSize: 11.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black45,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14.0),
            const Text(
              'Status Jaring Sampah',
              style: TextStyle(
                fontSize: 13.0,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6.0),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: LinearProgressIndicator(
                    borderRadius: BorderRadius.circular(8.0),
                    value: valueCapacity / 100,
                    minHeight: 7.0,
                    backgroundColor: const Color(0xFFD9D9D9),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      getValueColor(valueCapacity, isCapacity: true),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  flex: 1,
                  child: Text(
                    '${valueCapacity.toStringAsFixed(1)} %',
                    style: const TextStyle(
                      fontSize: 11.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black45,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6.0),
          ],
        ),
      ),
    );
  }
}

class TampungSampahSekarang extends StatefulWidget {
  final VoidCallback? onLiftingCompleted;

  const TampungSampahSekarang({Key? key, this.onLiftingCompleted})
      : super(key: key);

  @override
  State<TampungSampahSekarang> createState() => _TampungSampahSekarangState();
}

class _TampungSampahSekarangState extends State<TampungSampahSekarang> {
  final FirestoreService _firestoreService = FirestoreService();

  void _customProgress(BuildContext context) async {
    ProgressDialog pd = ProgressDialog(context: context);

    try {
      // Ambil data status penampungan sebelum proses angkat sampah dimulai
      double statusPenampunganSebelum = await _getStatusPenampungan();

      // Set 'angkat' value to true in Firebase when the lifting process starts
      await FirebaseDatabase.instance.ref('angkat').set("ON");

      pd.show(
        max: 100,
        msg: 'Menyiapkan...',
        progressType: ProgressType.valuable,
        backgroundColor: Colors.white,
        progressValueColor: Color.fromARGB(255, 29, 47, 111),
        progressBgColor: Colors.white12,
        msgColor: Colors.black,
        valueColor: Colors.black45,
        barrierColor: Colors.black.withOpacity(0.7),
      );

      // Simulate initial preparation delay
      await Future.delayed(Duration(milliseconds: 1000));

      // Duration for lifting process
      const liftingDuration = Duration(seconds: 19);
      const interval = Duration(milliseconds: 100);
      final steps = (liftingDuration.inMilliseconds / interval.inMilliseconds).floor();

      // Loop to simulate the lifting process
      for (int i = 0; i <= steps; i++) {
        final progress = ((i / steps) * 100).toInt();
        pd.update(value: progress, msg: 'Mengangkat sampah...');
        await Future.delayed(interval);
      }

      pd.close();

      // Set 'angkat' value back to false when the lifting process finishes
      await Future.delayed(Duration(milliseconds: 500));
      await FirebaseDatabase.instance.ref('angkat').set("OFF");

      // Ambil data status penampungan setelah proses angkat sampah selesai
      double statusPenampunganSesudah = await _getStatusPenampungan();


      // Hitung berat sampah yang diangkat
      double beratSampah = double.parse(
          (statusPenampunganSesudah - statusPenampunganSebelum)
              .toStringAsFixed(1));

      // Show success dialog
      DInfo.dialogSuccess(
          context, 'Sampah berhasil diangkat!\nHistori akan disimpan...');
      DInfo.closeDialog(context,
          durationBeforeClose: const Duration(seconds: 2));

      // Wait for 10 seconds before saving to Firestore
      await Future.delayed(Duration(seconds: 10));

      // Save lifting status and timestamp to Firestore
      await _saveToFirestore(beratSampah);

      // Show success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Histori berhasil disimpan'),
          duration: Duration(seconds: 3),
        ),
      );

      // Setelah proses pengangkatan sampah selesai
      widget.onLiftingCompleted?.call();
    } catch (e) {
      // print('Error in _customProgress: $e');
    }
  }

  Future<double> _getStatusPenampungan() async {
    DatabaseReference reference = FirebaseDatabase.instance
        .ref()
        .child('status_sampah')
        .child('status_penampungan');

    try {
      DataSnapshot snapshot = (await reference.once()).snapshot;

      if (snapshot.value != null) {
        // Convert the snapshot value to a double type before returning
        return double.parse(snapshot.value.toString());
      } else {
        throw Exception('Snapshot does not have a value');
      }
    } catch (e) {
      // print('Error in _getStatusPenampungan: $e');
      throw Exception('Failed to get status penampungan');
    }
  }

  Future<void> _saveToFirestore(double beratSampah) async {
    // Simpan berat sampah ke Firestore
    await _firestoreService.addHistoryAngkat(beratSampah.toString());

    // print('Data saved to Firestore: Berat Sampah: $beratSampah');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      color: const Color.fromRGBO(4, 29, 49, 1),
      margin: EdgeInsets.all(30.0),
      elevation: 6,
      shadowColor: Color.fromARGB(255, 0, 0, 0).withOpacity(0.7),
      child: Container(
        width: 250,
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 12),
                Text('Tampung Sampah',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    )),
                SizedBox(height: 12),
              ],
            ),
            GestureDetector(
              onTap: () async {
                bool? isYes = await DInfo.dialogConfirmation(
                  context,
                  'Tampung Sampah Sekarang?',
                  'Apakah anda yakin ingin mengambil sampah?',
                );
                if (isYes ?? false) {
                  print('user click yes');
                  _customProgress(context);
                } else {
                  print('user click no');
                }
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.0),
                ),
                margin: EdgeInsets.all(0),
                child: SizedBox(
                  width: 50,
                  height: 35,
                  child: Center(
                    child: Icon(
                      // Icons.power_settings_new_rounded,
                      Icons.power_settings_new_sharp,
                      color: const Color.fromARGB(255, 0, 0, 0),
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RiwayatAngkat extends StatefulWidget {
  RiwayatAngkat({Key? key}) : super(key: key);

  @override
  _RiwayatAngkatState createState() => _RiwayatAngkatState();
}

class _RiwayatAngkatState extends State<RiwayatAngkat> {
  List<Map<String, dynamic>> historyAngkatData = []; // Menyimpan data riwayat

  @override
  void initState() {
    super.initState();
    _fetchHistoryAngkatData();
  }

  Future<void> _fetchHistoryAngkatData() async {
    try {
      final FirebaseFirestore _firestore = FirebaseFirestore.instance;
      QuerySnapshot querySnapshot = await _firestore
          .collection('riwayatAngkat')
          .orderBy('waktu',
              descending:
                  true) // Sorting berdasarkan 'tanggal' dengan descending true
          .get();

      List<Map<String, dynamic>> fetchedData = [];

      querySnapshot.docs.forEach((doc) {
        Timestamp timestamp = doc['waktu'];
        DateTime dateTime = timestamp.toDate();
        String formattedDate =
            DateFormat('EEEE dd/MM/yyyy', 'id_ID').format(dateTime);
        String formattedTime = DateFormat('HH:mm').format(dateTime);
        fetchedData.add({
          'tanggal': formattedDate,
          'waktu': formattedTime,
          'berat': doc['berat'].toString(),
        });
      });

      setState(() {
        historyAngkatData = fetchedData;
      });
    } catch (e) {
      // print('Error fetching history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> limitedData =
        historyAngkatData.isNotEmpty ? historyAngkatData.take(3).toList() : [];

    return Container(
      padding: const EdgeInsets.only(
        left: 15.0,
        top: 10.0,
        right: 15.0,
        bottom: 60.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white, // Warna latar belakang
        borderRadius: BorderRadius.circular(25.0), // Radius border
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(1), // Warna bayangan
            spreadRadius: 2, // Radius penyebaran
            blurRadius: 5, // Radius blur
            offset: Offset(0, 3), // Offset bayangan (x, y)
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Riwayat',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  _navigateToHistoryAngkatPage();
                },
                child: Row(
                  children: [
                    Text(
                      'Lihat Semua',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14.0,
                      ),
                    ),
                    SizedBox(width: 0.0), // Jarak antara teks dan ikon
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16.0,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: limitedData.map((item) {
              return _buildDataRow(
                  item['tanggal'], item['waktu'], item['berat']);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(String date, String time, String weight) {
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
                    date,
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
                    time,
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
                    '$weight kg',
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
  }

  void _navigateToHistoryAngkatPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => HistoryAngkatPage(data: historyAngkatData)),
    ).then((_) {
      // Panggil _fetchHistoryAngkatData setelah kembali dari halaman histori
      _fetchHistoryAngkatData();
    });
  }
}

Color getValueColor(double value, {bool isCapacity = false}) {
  if (isCapacity) {
    if (value <= 45) {
      return Colors.green;
    } else if (value <= 80) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  } else {
    if (value <= 45) {
      return Colors.green;
    } else if (value <= 80) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }
}
