import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';
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

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<String> _videoUrls = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    try {
      final data = await Supabase.instance.client
          .from('videos')
          .select()
          .order('created_at', ascending: false);

      setState(() {
        _videoUrls = (data as List).map((e) => e['url'] as String).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      print('Ошибка загрузки: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.pink)),
      );
    }

    if (_videoUrls.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: Text('Пока нет видео. Загрузите первое!',
              style: TextStyle(color: Colors.white)),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.pink,
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UploadScreen()),
            );
            _loadVideos();
          },
          child: const Icon(Icons.add),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: RefreshIndicator(
        onRefresh: _loadVideos,
        child: PageView.builder(
          scrollDirection: Axis.vertical,
          itemCount: _videoUrls.length,
          itemBuilder: (context, index) {
            return VideoItem(url: _videoUrls[index]);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pink,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UploadScreen()),
          );
          _loadVideos();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class VideoItem extends StatefulWidget {
  final String url;
  const VideoItem({super.key, required this.url});

  @override
  State<VideoItem> createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _controller.setLooping(true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: _controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : const CircularProgressIndicator(color: Colors.pink),
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _iconWithLabel(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 40),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}
