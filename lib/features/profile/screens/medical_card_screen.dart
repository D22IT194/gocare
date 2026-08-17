import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:public_file_saver/public_file_saver.dart';

import '../../authentication/providers/auth_provider.dart';
import '../models/health_information.dart';
import '../services/profile_service.dart';
import '/core/services/notification_service.dart';
import 'package:screenshot/screenshot.dart';

class MedicalCardScreen extends StatefulWidget {
  const MedicalCardScreen({super.key});

  @override
  State<MedicalCardScreen> createState() => _MedicalCardScreenState();
}

class _MedicalCardScreenState extends State<MedicalCardScreen> {
  final ProfileService _profileService = ProfileService();

  HealthInformation? _healthInformation;

  Map<String, dynamic>? _profileDetails;

  bool _isLoading = true;
  bool _isExporting = false;
  bool _exportInProgress = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ============================================================
  // LOAD DATA
  // ============================================================

  Future<void> _load() async {
    try {
      final user = context.read<AuthProvider>().user;

      if (user == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }

        return;
      }

      final results = await Future.wait([
        _profileService.getHealthInformation(userId: user.uid),
        _profileService.getProfileDetails(userId: user.uid),
      ]);

      if (!mounted) {
        return;
      }

      setState(() {
        _healthInformation = results[0] as HealthInformation?;

        _profileDetails = results[1] as Map<String, dynamic>?;

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to load medical card: $e')),
      );
    }
  }

  // ============================================================
  // USER DATA
  // ============================================================

  String get _userName {
    final authUser = context.read<AuthProvider>().user;

    final profileName = _profileDetails?['name'] as String?;

    if (profileName != null && profileName.trim().isNotEmpty) {
      return profileName.trim();
    }

    if (authUser?.displayName != null &&
        authUser!.displayName!.trim().isNotEmpty) {
      return authUser.displayName!.trim();
    }

    return 'User';
  }

  String get _email {
    final authUser = context.read<AuthProvider>().user;

    final profileEmail = _profileDetails?['email'] as String?;

    if (profileEmail != null && profileEmail.trim().isNotEmpty) {
      return profileEmail.trim();
    }

    return authUser?.email ?? '--';
  }

  String? get _phone {
    return _profileDetails?['phoneNumber'] as String?;
  }

  String? get _photoUrl {
    return _profileDetails?['photoUrl'] as String?;
  }

  // ============================================================
  // QR CODE
  // ============================================================

  String _qrData() {
    final user = context.read<AuthProvider>().user;

    if (user == null) {
      return 'GoCare Medical Card';
    }

    /*
     * IMPORTANT:
     *
     * This QR contains only a secure identifier,
     * not the user's complete medical information.
     *
     * Later this UID can be connected to a
     * secure emergency medical-card web page.
     */

    return 'gocare://medical-card/${user.uid}';
  }

  // ============================================================
  // SHARE TEXT
  // ============================================================

  String _cardText() {
    final health = _healthInformation;

    return '''
GoCare Medical Card

Name: $_userName
Email: $_email
Mobile: ${_value(_phone)}

Date of Birth: ${_date(health?.dateOfBirth)}
Blood Group: ${_value(health?.bloodGroup)}
Gender: ${_value(health?.gender)}
Height: ${_height(health?.height)}
Weight: ${_weight(health?.weight)}

Allergies:
${_value(health?.allergies)}

Medical Conditions:
${_value(health?.medicalConditions)}

Current Medications:
${_value(health?.currentMedications)}

Emergency Notes:
${_value(health?.emergencyNotes)}

GoCare Medical Card
''';
  }

  // ============================================================
  // SHARE
  // ============================================================

  Future<void> _shareCard() async {
    try {
      await SharePlus.instance.share(
        ShareParams(text: _cardText(), subject: 'GoCare Medical Card'),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to share medical card: $e')),
      );
    }
  }

  // ============================================================
  // DOWNLOAD IMAGE
  // ============================================================

  Future<void> _downloadImage() async {
    if (_exportInProgress) {
      return;
    }

    // Keep this guard non-reactive. Calling setState here rebuilds the
    // Screenshot/Medical Card subtree and can mark it debugNeedsPaint.
    _exportInProgress = true;

    try {
      final currentUser = context.read<AuthProvider>().user;

      final currentHealth = _healthInformation;

      final currentPhone = _profileDetails?['phoneNumber'] as String?;

      final Uint8List? image = await _captureMedicalCard(
        user: currentUser,
        phone: currentPhone,
        health: currentHealth,
      );

      if (image == null || image.isEmpty) {
        throw Exception('Unable to create medical card image.');
      }

      final fileName =
          'gocare_medical_card_${DateTime.now().millisecondsSinceEpoch}.png';

      final saved = await PublicFileSaver().saveBytes(
        bytes: image,
        fileName: fileName,
        mimeType: 'image/png',
        subDir: 'GoCare',
      );

      if (saved == null || !saved.isSuccess) {
        throw Exception('The image could not be saved to public storage.');
      }

      debugPrint('IMAGE DOWNLOAD SUCCESS');
      debugPrint('FILE NAME: ${saved.fileName}');
      debugPrint('PATH: ${saved.path}');
      debugPrint('URI: ${saved.uri}');

      // System notification: image was successfully saved.
      final fileUri = saved.uri;

      if (fileUri != null && fileUri.trim().isNotEmpty) {
        await NotificationService.showDownloadNotification(
          title: 'GoCare Medical Card Image',
          body: 'Image downloaded successfully. Tap to open.',
          uri: fileUri!,
          mimeType: 'image/png',
        );
      } else {
        debugPrint('IMAGE NOTIFICATION SKIPPED: URI IS NULL');
      }

      if (!mounted) {
        return;
      }

      await _showDownloadSuccess(
        title: 'Image Downloaded',
        fileName: saved.fileName,
        path: saved.path,
        uri: saved.uri,
      );
    } catch (e, stackTrace) {
      debugPrint('DOWNLOAD IMAGE ERROR: $e');
      debugPrint('$stackTrace');

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to save image: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      _exportInProgress = false;
    }
  }

  // ============================================================
  // CAPTURE MEDICAL CARD
  // ============================================================

  Future<Uint8List?> _captureMedicalCard({
    required dynamic user,
    required String? phone,
    required HealthInformation? health,
  }) async {
    try {
      if (!mounted) return null;

      // IMPORTANT:
      // Do not capture the on-screen Screenshot widget here. The screen is
      // rebuilt when the export state changes and screenshot.capture() can
      // then hit Flutter's `!debugNeedsPaint` assertion.
      //
      // Instead, render a fresh copy of the card off-screen. This gives the
      // screenshot package a clean render tree that is not inside the
      // ListView/scroll viewport and is independent of _isExporting.
      final mediaQuery = MediaQuery.of(context);
      final cardWidth = (mediaQuery.size.width - 40).clamp(280.0, 900.0);

      final widget = InheritedTheme.captureAll(
        context,
        MediaQuery(
          data: mediaQuery,
          child: Material(
            color: Colors.transparent,
            child: Directionality(
              textDirection: Directionality.of(context),
              child: SizedBox(
                width: cardWidth,
                child: _buildMedicalCard(user, phone, health),
              ),
            ),
          ),
        ),
      );

      final image = await ScreenshotController().captureFromWidget(
        widget,
        delay: const Duration(milliseconds: 250),
        pixelRatio: 3.0,
      );

      if (image.isEmpty) {
        debugPrint('CARD CAPTURE RETURNED EMPTY IMAGE');
        return null;
      }

      debugPrint('CARD CAPTURE SUCCESS: ${image.length} bytes');
      return image;
    } catch (e, stackTrace) {
      debugPrint('CARD CAPTURE ERROR: $e');
      debugPrint('$stackTrace');
      return null;
    }
  }

  // ============================================================
  // SHARE IMAGE
  // ============================================================

  Future<void> _shareImage() async {
    if (_exportInProgress) {
      return;
    }

    // Keep this guard non-reactive. Calling setState here rebuilds the
    // Screenshot/Medical Card subtree and can mark it debugNeedsPaint.
    _exportInProgress = true;

    try {
      final currentUser = context.read<AuthProvider>().user;

      final currentHealth = _healthInformation;

      final currentPhone = _profileDetails?['phoneNumber'] as String?;

      final Uint8List? image = await _captureMedicalCard(
        user: currentUser,
        phone: currentPhone,
        health: currentHealth,
      );

      if (image == null || image.isEmpty) {
        throw Exception('Unable to create medical card image.');
      }

      final directory = await getTemporaryDirectory();

      final fileName =
          'gocare_medical_card_${DateTime.now().millisecondsSinceEpoch}.png';

      final file = File('${directory.path}/$fileName');

      await file.writeAsBytes(image, flush: true);

      if (!await file.exists()) {
        throw Exception('Temporary image file was not created.');
      }

      debugPrint('SHARE IMAGE FILE: ${file.path}');
      debugPrint('SHARE IMAGE SIZE: ${await file.length()} bytes');

      final result = await SharePlus.instance.share(
        ShareParams(
          title: 'GoCare Medical Card',
          subject: 'GoCare Medical Card',
          text: 'GoCare Medical Card',
          files: [XFile(file.path, mimeType: 'image/png', name: fileName)],
        ),
      );

      debugPrint('SHARE IMAGE RESULT: ${result.status}');
    } catch (e, stackTrace) {
      debugPrint('SHARE IMAGE ERROR: $e');
      debugPrint('$stackTrace');

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to share image: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      _exportInProgress = false;
    }
  }

  // ============================================================
  // PDF
  // ============================================================

  Future<void> _downloadPdf() async {
    if (_isExporting) {
      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      final pdf = pw.Document();

      final qrImage = await QrPainter(
        data: _qrData(),
        version: QrVersions.auto,
        gapless: true,
      ).toImageData(400);

      final qrBytes = qrImage?.buffer.asUint8List();
      final health = _healthInformation;

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(28),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#1976D2'),
                    borderRadius: pw.BorderRadius.circular(18),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'GoCare Medical Card',
                              style: pw.TextStyle(
                                color: PdfColors.white,
                                fontSize: 22,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text(
                              'Emergency Medical Summary',
                              style: const pw.TextStyle(
                                color: PdfColors.white,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (qrBytes != null)
                        pw.Container(
                          width: 80,
                          height: 80,
                          padding: const pw.EdgeInsets.all(5),
                          color: PdfColors.white,
                          child: pw.Image(pw.MemoryImage(qrBytes)),
                        ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  _userName,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  _email,
                  style: const pw.TextStyle(
                    fontSize: 11,
                    color: PdfColors.grey700,
                  ),
                ),
                if (_phone != null && _phone!.trim().isNotEmpty)
                  pw.Text(
                    _phone!,
                    style: const pw.TextStyle(
                      fontSize: 11,
                      color: PdfColors.grey700,
                    ),
                  ),
                pw.SizedBox(height: 18),
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#F8FAFC'),
                    borderRadius: pw.BorderRadius.circular(12),
                  ),
                  child: pw.Column(
                    children: [
                      _pdfRow('Date of Birth', _date(health?.dateOfBirth)),
                      _pdfRow('Blood Group', _value(health?.bloodGroup)),
                      _pdfRow('Gender', _value(health?.gender)),
                      _pdfRow('Height', _height(health?.height)),
                      _pdfRow('Weight', _weight(health?.weight)),
                    ],
                  ),
                ),
                pw.SizedBox(height: 18),
                pw.Text(
                  'Medical Details',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                _pdfDetail('Allergies', _value(health?.allergies)),
                _pdfDetail(
                  'Medical Conditions',
                  _value(health?.medicalConditions),
                ),
                _pdfDetail(
                  'Current Medications',
                  _value(health?.currentMedications),
                ),
                _pdfDetail('Emergency Notes', _value(health?.emergencyNotes)),
                pw.Spacer(),
                pw.Divider(),
                pw.Text(
                  'GoCare • Emergency Medical Information',
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            );
          },
        ),
      );

      final pdfBytes = await pdf.save();

      final fileName =
          'gocare_medical_card_${DateTime.now().millisecondsSinceEpoch}.pdf';

      final saved = await PublicFileSaver().saveBytes(
        bytes: pdfBytes,
        fileName: fileName,
        mimeType: 'application/pdf',
        subDir: 'GoCare',
      );

      if (saved == null || !saved.isSuccess) {
        throw Exception('The PDF could not be saved to public storage.');
      }

      debugPrint('PDF DOWNLOAD SUCCESS');
      debugPrint('FILE NAME: ${saved.fileName}');
      debugPrint('PATH: ${saved.path}');
      debugPrint('URI: ${saved.uri}');

      // System notification: PDF was successfully saved.
      final fileUri = saved.uri;

      if (fileUri != null && fileUri.trim().isNotEmpty) {
        await NotificationService.showDownloadNotification(
          title: 'GoCare Medical Card PDF',
          body: 'PDF downloaded successfully. Tap to open.',
          uri: fileUri!,
          mimeType: 'application/pdf',
        );
      } else {
        debugPrint('PDF NOTIFICATION SKIPPED: saved.uri IS NULL');
      }

      if (!mounted) {
        return;
      }

      await _showDownloadSuccess(
        title: 'PDF Downloaded',
        fileName: saved.fileName,
        path: saved.path,
        uri: saved.uri,
      );
    } catch (e, stackTrace) {
      debugPrint('DOWNLOAD PDF ERROR: $e');
      debugPrint('$stackTrace');

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to create PDF: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  // ============================================================
  // DOWNLOAD SUCCESS DIALOG
  // ============================================================

  Future<void> _showDownloadSuccess({
    required String title,
    required String fileName,
    String? path,
    String? uri,
  }) async {
    final String location;

    if (path != null && path.trim().isNotEmpty) {
      location = path;
    } else {
      location = 'Downloads/GoCare/$fileName';
    }

    debugPrint('DOWNLOAD LOCATION: $location');
    debugPrint('DOWNLOAD URI: $uri');

    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.green),
              const SizedBox(width: 10),
              Expanded(child: Text(title)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your file was saved successfully.'),
              const SizedBox(height: 18),
              const Text(
                'File name',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              SelectableText(
                fileName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 14),
              const Text(
                'Download location',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              SelectableText(
                location,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              if (uri != null && uri.startsWith('content://')) ...[
                const SizedBox(height: 12),
                const Text(
                  'Android saved this file using MediaStore. Open the Downloads folder and then the GoCare folder to find it.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  static String _value(String? value) {
    final text = value?.trim() ?? '';

    return text.isEmpty ? '--' : text;
  }

  static String _date(DateTime? value) {
    if (value == null) {
      return '--';
    }

    return '${value.day.toString().padLeft(2, '0')}/'
        '${value.month.toString().padLeft(2, '0')}/'
        '${value.year}';
  }

  static String _height(double? value) {
    if (value == null) {
      return '--';
    }

    return '${value.toStringAsFixed(0)} cm';
  }

  static String _weight(double? value) {
    if (value == null) {
      return '--';
    }

    return '${value.toStringAsFixed(1)} kg';
  }

  static pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(child: pw.Text(value)),
        ],
      ),
    );
  }

  static pw.Widget _pdfDetail(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
          ),
          pw.SizedBox(height: 3),
          pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    final health = _healthInformation;

    final phone = _profileDetails?['phoneNumber'] as String?;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        title: const Text('Medical Card'),

        actions: [
          IconButton(
            tooltip: 'More options',
            onPressed: _isLoading ? null : _showExportOptions,
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),

      body: _isLoading
          ? SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _MedicalCardSkeleton(),
                  const SizedBox(height: 20),
                  _MedicalDetailsSkeleton(),
                  const SizedBox(height: 20),
                  _MedicalActionsSkeleton(),
                ],
              ),
            )
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // =================================================
                  // CARD PREVIEW
                  // =================================================
                  _buildMedicalCard(user, phone, health),

                  const SizedBox(height: 20),

                  // =================================================
                  // QR INFORMATION
                  // =================================================
                  _buildQrSection(),

                  const SizedBox(height: 18),

                  // =================================================
                  // MEDICAL DETAILS
                  // =================================================
                  _DetailPanel(
                    title: 'Medical Details',
                    children: [
                      _DetailRow(
                        icon: Icons.warning_amber_outlined,
                        label: 'Allergies',
                        value: _value(health?.allergies),
                      ),
                      _DetailRow(
                        icon: Icons.medical_information_outlined,
                        label: 'Medical Conditions',
                        value: _value(health?.medicalConditions),
                      ),
                      _DetailRow(
                        icon: Icons.medication_outlined,
                        label: 'Current Medications',
                        value: _value(health?.currentMedications),
                      ),
                      _DetailRow(
                        icon: Icons.emergency_outlined,
                        label: 'Emergency Notes',
                        value: _value(health?.emergencyNotes),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // =================================================
                  // ACTIONS
                  // =================================================
                  _buildActions(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  // ============================================================
  // MEDICAL CARD UI
  // ============================================================

  Widget _buildMedicalCard(
    dynamic user,
    String? phone,
    HealthInformation? health,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1976D2), Color(0xFF00A896)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1976D2).withValues(alpha: 0.20),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.health_and_safety_outlined,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(width: 12),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GoCare Medical Card',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Emergency summary',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),

                _buildSmallQr(),
              ],
            ),

            const SizedBox(height: 24),

            Text(
              _userName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              _email,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),

            if (_value(phone) != '--') ...[
              const SizedBox(height: 4),
              Text(
                phone!,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],

            const SizedBox(height: 20),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _MetricTile(label: 'DOB', value: _date(health?.dateOfBirth)),
                _MetricTile(label: 'Blood', value: _value(health?.bloodGroup)),
                _MetricTile(label: 'Gender', value: _value(health?.gender)),
                _MetricTile(label: 'Height', value: _height(health?.height)),
                _MetricTile(label: 'Weight', value: _weight(health?.weight)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallQr() {
    return Container(
      width: 68,
      height: 68,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: QrImageView(
        data: _qrData(),
        version: QrVersions.auto,
        backgroundColor: Colors.white,
      ),
    );
  }

  // ============================================================
  // QR SECTION
  // ============================================================

  Widget _buildQrSection() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: _showQrDialog,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE4E7EC)),
          ),
          child: Row(
            children: [
              Container(
                width: 100,
                height: 100,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE4E7EC)),
                ),
                child: QrImageView(
                  data: _qrData(),
                  version: QrVersions.auto,
                  errorCorrectionLevel: QrErrorCorrectLevel.H,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emergency QR Code',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF172B4D),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Tap to open a large, scannable QR code for this GoCare medical card.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: Color(0xFF667085),
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          size: 16,
                          color: Color(0xFF1976D2),
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Tap QR to enlarge',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1976D2),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF98A2B3)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showQrDialog() async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'GoCare Emergency QR',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Scan this QR code to identify the GoCare medical card.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF667085),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 250,
                  height: 250,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE4E7EC)),
                  ),
                  child: QrImageView(
                    data: _qrData(),
                    version: QrVersions.auto,
                    errorCorrectionLevel: QrErrorCorrectLevel.H,
                    backgroundColor: Colors.white,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Colors.black,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SelectableText(
                  _qrData(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF667085),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // ACTIONS
  // ============================================================

  Widget _buildActions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isExporting ? null : _downloadPdf,
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('PDF'),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isExporting ? null : _downloadImage,
                icon: const Icon(Icons.image_outlined),
                label: const Text('Image'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isExporting ? null : _shareImage,
                icon: const Icon(Icons.share_outlined),
                label: const Text('Share Image'),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: OutlinedButton.icon(
                onPressed: _shareCard,
                icon: const Icon(Icons.text_snippet_outlined),
                label: const Text('Share Text'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),
      ],
    );
  }

  // ============================================================
  // EXPORT MENU
  // ============================================================

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Material(
                  color: Colors.transparent,
                  child: ListTile(
                    title: Text(
                      'Medical Card',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text('Export or share your emergency card'),
                  ),
                ),

                ListTile(
                  leading: const Icon(Icons.picture_as_pdf_outlined),
                  title: const Text('Download PDF'),
                  onTap: () {
                    Navigator.pop(context);
                    _downloadPdf();
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.image_outlined),
                  title: const Text('Download Image'),
                  onTap: () {
                    Navigator.pop(context);
                    _downloadImage();
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.share_outlined),
                  title: const Text('Share Image'),
                  onTap: () {
                    Navigator.pop(context);
                    _shareImage();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ================================================================
// MEDICAL CARD SKELETON
// ================================================================

class _MedicalCardSkeleton extends StatefulWidget {
  const _MedicalCardSkeleton();

  @override
  State<_MedicalCardSkeleton> createState() => _MedicalCardSkeletonState();
}

class _MedicalCardSkeletonState extends State<_MedicalCardSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    _opacity = Tween<double>(
      begin: 0.35,
      end: 0.75,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _box({
    required double width,
    required double height,
    double radius = 8,
  }) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: const Color(0xFFD0D5DD),
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE4E7EC),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _box(width: 48, height: 48, radius: 14),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _box(width: 155, height: 17),
                    const SizedBox(height: 7),
                    _box(width: 100, height: 11),
                  ],
                ),
              ),
              _box(width: 68, height: 68, radius: 10),
            ],
          ),
          const SizedBox(height: 24),
          _box(width: 190, height: 25),
          const SizedBox(height: 9),
          _box(width: 180, height: 13),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(
              5,
              (_) => _box(width: 132, height: 62, radius: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// MEDICAL DETAILS SKELETON
// ================================================================

class _MedicalDetailsSkeleton extends StatelessWidget {
  const _MedicalDetailsSkeleton();

  @override
  Widget build(BuildContext context) {
    return _SkeletonPanel(
      // Increased because the panel contains
      // 4 detail rows + spacing.
      height: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StaticSkeletonBox(width: 145, height: 18),

          const SizedBox(height: 18),

          ...List.generate(
            4,
            (index) => const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StaticSkeletonBox(width: 22, height: 22, radius: 11),

                  SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _StaticSkeletonBox(width: 85, height: 11),

                        SizedBox(height: 6),

                        _StaticSkeletonBox(width: double.infinity, height: 14),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// MEDICAL ACTIONS SKELETON
// ================================================================

class _MedicalActionsSkeleton extends StatelessWidget {
  const _MedicalActionsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StaticSkeletonBox(
                width: double.infinity,
                height: 48,
                radius: 12,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StaticSkeletonBox(
                width: double.infinity,
                height: 48,
                radius: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StaticSkeletonBox(
                width: double.infinity,
                height: 48,
                radius: 12,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StaticSkeletonBox(
                width: double.infinity,
                height: 48,
                radius: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SkeletonPanel extends StatelessWidget {
  const _SkeletonPanel({required this.height, required this.child});

  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: child,
    );
  }
}

class _StaticSkeletonBox extends StatelessWidget {
  const _StaticSkeletonBox({
    required this.width,
    required this.height,
    this.radius = 7,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFD0D5DD),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ================================================================
// METRIC TILE
// ================================================================

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// DETAIL PANEL
// ================================================================

class _DetailPanel extends StatelessWidget {
  const _DetailPanel({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF172B4D),
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

// ================================================================
// DETAIL ROW
// ================================================================

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: const Color(0xFF1976D2)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF98A2B3),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF344054),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
