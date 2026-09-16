import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';
import 'package:webdav_client_plus/webdav_client_plus.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _videoFile;
  String _status = 'Видео не выбрано';
  double _progress = 0;
  bool _isUploading = false;

  // ⚠️ ЗАМЕНИ НА СВОИ ДАННЫЕ
  final String _login = 'ali.ayder@mail.ru';
  final String _appPassword = '6CCcaHyBI0bge32ruPbh';

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickVideo(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _videoFile = File(picked.path);
        _status = 'Видео выбрано: ${picked.name}';
        _progress = 0;
      });
    }
  }

  Future<void> _uploadVideo() async {
    if (_videoFile == null) {
      setState(() => _status = 'Сначала выбери видео');
      return;
    }

    setState(() {
      _isUploading = true;
      _status = 'Конвертация в MP4...';
    });

    try {
      // 1. Конвертируем в MP4
      final MediaInfo? mediaInfo = await VideoCompress.compressVideo(
        _videoFile!.path,
        quality: VideoQuality.DefaultQuality,
        deleteOrigin: false,
      );

      if (mediaInfo == null || mediaInfo.path == null) {
        throw Exception('Не удалось конвертировать видео');
      }

      setState(() => _status = 'Загрузка в Облако Mail.ru...');

      // 2. Подключаемся к WebDAV
      final client = WebdavClient.basic(
        'https://webdav.cloud.mail.ru',
        _login,
        _appPassword,
      );

      // 3. Путь на облаке
      final cloudPath = '/videos/${DateTime.now().millisecondsSinceEpoch}.mp4';

      // 4. Загружаем с прогрессом
      await client.writeFile(
        mediaInfo.path!,
        cloudPath,
        onProgress: (count, total) {
          setState(() {
            _progress = count / total;
            _status = 'Загрузка: ${(_progress * 100).toStringAsFixed(0)}%';
          });
        },
      );

      setState(() {
        _status = 'Готово! Файл: $cloudPath';
        _isUploading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Ошибка: $e';
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Загрузить видео', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _status,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            if (_isUploading)
              LinearProgressIndicator(value: _progress, color: Colors.pink),

            const SizedBox(height: 30),

            ElevatedButton.icon(
              onPressed: _isUploading ? null : _pickVideo,
              icon: const Icon(Icons.video_library),
              label: const Text('Выбрать видео'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: _isUploading ? null : _uploadVideo,
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Опубликовать'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
