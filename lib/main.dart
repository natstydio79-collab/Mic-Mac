import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';
import 'upload_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mic Mak',
      theme: ThemeData.dark(),
      home: const FeedScreen(),
    );
  }
}

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              Center(
                child: Text(
                  'Видео #${index + 1}',
                  style: const TextStyle(color: Colors.white, fontSize: 30),
                ),
              ),
              Positioned(
                right: 16,
                bottom: 100,
                child: Column(
                  children: [
                    _iconWithLabel(Icons.favorite, '1.2K'),
                    const SizedBox(height: 20),
                    _iconWithLabel(Icons.comment, '345'),
                    const SizedBox(height: 20),
                    _iconWithLabel(Icons.share, 'Share'),
                    const SizedBox(height: 20),
                    _iconWithLabel(
                      Icons.add_box,
                      'Загрузить',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UploadScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 16,
                bottom: 40,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '@user${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Описание видео #рек',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _iconWithLabel(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 40),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
