import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:rxdart/rxdart.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class MeditationPlayerScreen extends StatefulWidget {
  final String title;
  const MeditationPlayerScreen({Key? key, required this.title}) : super(key: key);

  @override
  State<MeditationPlayerScreen> createState() => _MeditationPlayerScreenState();
}

class _MeditationPlayerScreenState extends State<MeditationPlayerScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Stream<DurationState>? _durationState;
  bool _isLooping = false;
  final playlist = ConcatenatingAudioSource(children: [
    AudioSource.asset('assets/audio/meditation.mp3'),
    AudioSource.asset('assets/audio/meditation.mp3'),
  ]);

  @override
  void initState() {
    super.initState();
    _setupAudio();
  }

  Future<void> _setupAudio() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    await _audioPlayer.setAudioSource(playlist);
    _audioPlayer.play();

    setState(() {
      _durationState = Rx.combineLatest2<Duration, Duration?, DurationState>(
        _audioPlayer.positionStream,
        _audioPlayer.durationStream,
            (position, duration) => DurationState(position: position, total: duration ?? Duration.zero),
      );
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  Future<void> _shareAudio() async {
    final file = File('assets/audio/meditation.mp3');
    if (await file.exists()) {
      Share.shareXFiles([XFile(file.path)], text: 'Check out this meditation!');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Audio file not found.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final double halfScreenHeight = MediaQuery.of(context).size.height / 2;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F0E6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F0E6),
        elevation: 0,
        iconTheme: const IconThemeData(color: const Color(0xFFda461b)),
        title: Text(
          widget.title,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFda461b),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: const Color(0xFFda461b)),
            onPressed: _shareAudio,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: halfScreenHeight,
                  height: halfScreenHeight,
                  color: Colors.grey.shade300,
                  child: Image.asset(
                    'assets/images/meditation.jpg',
                    fit: BoxFit.cover, // Ensures image is squeezed and fits perfectly
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              widget.title,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFda461b),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (_durationState != null)
              StreamBuilder<DurationState>(
                stream: _durationState,
                builder: (context, snapshot) {
                  final durationState = snapshot.data;
                  final progress = durationState?.position ?? Duration.zero;
                  final total = durationState?.total ?? Duration.zero;
                  return Column(
                    children: [
                      Slider(
                        value: progress.inSeconds.toDouble().clamp(0, total.inSeconds.toDouble()),
                        min: 0.0,
                        max: total.inSeconds.toDouble(),
                        onChanged: (value) {
                          _audioPlayer.seek(Duration(seconds: value.toInt()));
                        },
                        activeColor: Colors.redAccent,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_formatDuration(progress), style: const TextStyle(color: Colors.black)),
                            Text(_formatDuration(total), style: const TextStyle(color: Colors.black)),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 36,
                  icon: Icon(_isLooping ? Icons.repeat_one : Icons.repeat, color: Colors.black54),
                  onPressed: () {
                    setState(() => _isLooping = !_isLooping);
                    _audioPlayer.setLoopMode(_isLooping ? LoopMode.one : LoopMode.off);
                  },
                ),
                const SizedBox(width: 24),
                StreamBuilder<PlayerState>(
                  stream: _audioPlayer.playerStateStream,
                  builder: (context, snapshot) {
                    final playerState = snapshot.data;
                    final isPlaying = playerState?.playing ?? false;
                    return IconButton(
                      iconSize: 64,
                      icon: Icon(
                        isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                        color: Colors.redAccent,
                      ),
                      onPressed: () {
                        if (isPlaying) {
                          _audioPlayer.pause();
                        } else {
                          _audioPlayer.play();
                        }
                      },
                    );
                  },
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class DurationState {
  final Duration position;
  final Duration total;
  DurationState({required this.position, required this.total});
}