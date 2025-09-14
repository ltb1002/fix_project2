import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../controllers/theory_controller.dart';
import '../model/lesson_model.dart';

class LessonDetailScreen extends StatefulWidget {
  final Lesson lesson;

  LessonDetailScreen({required this.lesson});

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  final TheoryController theoryController = Get.find<TheoryController>();
  bool _isLoading = true;
  late AnimationController _animController;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      lowerBound: 0.95,
      upperBound: 1.05,
    )..repeat(reverse: true);

    // Initialize completion status
    _isCompleted = theoryController.isCompleted(
        theoryController.subject,
        theoryController.grade,
        widget.lesson.title
    );
  }

  Future<void> _initializePlayer() async {
    try {
      _videoController = VideoPlayerController.network(widget.lesson.videoUrl);
      await _videoController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoController,
        autoPlay: false,
        looping: false,
        aspectRatio: _videoController.value.aspectRatio,
      );

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController?.dispose();
    _animController.dispose();
    super.dispose();
  }

  Widget _buildContentItem(ContentItem item) {
    switch (item.type) {
      case 'text':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            item.value,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        );
      case 'image':
        print("Loading image: ${item.value}");
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              item.value,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                print("Failed to load image: ${item.value}");
                print("Error: $error");
                return Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.broken_image, size: 50),
                  ),
                );
              },
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildExercise(Exercise exercise) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exercise.question,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...exercise.solutions.map(_buildContentItem).toList(),
          ],
        ),
      ),
    );
  }

  void _toggleCompletion() {
    theoryController.toggleComplete(
        theoryController.subject,
        theoryController.grade,
        widget.lesson.title
    );

    // Update local state after a short delay to avoid setState during build
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _isCompleted = theoryController.isCompleted(
            theoryController.subject,
            theoryController.grade,
            widget.lesson.title
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryGreen = const Color(0xFF4CAF50);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson.title),
        backgroundColor: primaryGreen,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: widget.lesson.title,
              child: Material(
                color: Colors.transparent,
                child: Text(
                  widget.lesson.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Display all content items
            ...widget.lesson.contents.map(_buildContentItem).toList(),

            const SizedBox(height: 20),

            // Video player
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : AspectRatio(
              aspectRatio: _videoController.value.aspectRatio,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Chewie(controller: _chewieController!),
              ),
            ),

            const SizedBox(height: 24),

            // Exercises section
            if (widget.lesson.exercises.isNotEmpty) ...[
              const Text(
                "Bài tập",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...widget.lesson.exercises.map(_buildExercise).toList(),
            ],

            const SizedBox(height: 24),

            // Complete button
            ScaleTransition(
              scale: _animController,
              child: ElevatedButton.icon(
                onPressed: _isCompleted ? null : _toggleCompletion,
                icon: Icon(
                  _isCompleted
                      ? Icons.check_circle
                      : Icons.done_all_outlined,
                ),
                label: Text(
                  _isCompleted ? "Đã hoàn thành" : "Đánh dấu hoàn thành",
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isCompleted ? Colors.green : primaryGreen,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),

            // Add some extra space at the bottom to prevent overflow
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}