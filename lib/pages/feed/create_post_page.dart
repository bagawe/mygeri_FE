import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/post.dart';
import '../../services/post_service.dart';
import '../../services/api_service.dart';
import '../../services/history_service.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final PostService _postService = PostService(ApiService());
  final HistoryService _historyService = HistoryService();
  final TextEditingController _contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  List<File> _selectedImages = [];
  final int _maxImages = 10;
  bool _isPosting = false;
  
  // NEW: Location and mentions
  String? _location;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  // Extract mentions from content (@username)
  List<String> _extractMentions(String content) {
    final RegExp mentionRegex = RegExp(r'@(\w+)');
    final matches = mentionRegex.allMatches(content);
    return matches.map((match) => match.group(1)!).toSet().toList();
  }

  // Show location dialog
  Future<void> _showLocationDialog() async {
    final controller = TextEditingController(text: _location);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Lokasi'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Masukkan nama lokasi',
            prefixIcon: Icon(Icons.location_on),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    
    if (result != null) {
      setState(() {
        _location = result;
      });
    }
    controller.dispose();
  }

  // Pick multiple images
  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFiles.isNotEmpty) {
        setState(() {
          for (var file in pickedFiles) {
            if (_selectedImages.length < _maxImages) {
              _selectedImages.add(File(file.path));
            }
          }
        });
        
        if (_selectedImages.length >= _maxImages && pickedFiles.length + _selectedImages.length > _maxImages) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Maksimal $_maxImages gambar'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar: $e')),
        );
      }
    }
  }

  // Remove specific image
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // Create post
  Future<void> _createPost() async {
    final content = _contentController.text.trim();

    if (content.isEmpty && _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tulis sesuatu atau pilih gambar')),
      );
      return;
    }

    // Extract mentions from content
    final mentions = _extractMentions(content);

    setState(() {
      _isPosting = true;
    });

    try {
      ApiResponse<PostModel> result;

      if (_selectedImages.isNotEmpty) {
        result = await _postService.createPostWithMultipleImages(
          content: content.isEmpty ? null : content,
          images: _selectedImages,
          location: _location,
          mentions: mentions.isNotEmpty ? mentions : null,
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw TimeoutException('Upload gambar timeout. Coba lagi.');
          },
        );
      } else {
        result = await _postService.createPost(
          content: content,
          location: _location,
          mentions: mentions.isNotEmpty ? mentions : null,
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException('Posting timeout. Coba lagi.');
          },
        );
      }

      if (result.success && mounted) {
        _historyService.logHistory(
          'create_post',
          description: content.isEmpty 
            ? 'Membuat postingan dengan ${_selectedImages.length} gambar'
            : 'Membuat postingan: ${content.substring(0, content.length > 50 ? 50 : content.length)}${content.length > 50 ? '...' : ''}',
          metadata: {
            'has_images': _selectedImages.isNotEmpty,
            'image_count': _selectedImages.length,
            'content_length': content.length,
            'has_location': _location != null,
            'mentions_count': mentions.length,
          },
        ).catchError((e) => print('⚠️ History log failed: $e'));
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post berhasil dibuat!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Gagal membuat post'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Postingan'),
        elevation: 1,
        actions: [
          // Location button
          IconButton(
            icon: Icon(
              _location != null ? Icons.location_on : Icons.location_on_outlined,
              color: _location != null ? Colors.blue : null,
            ),
            onPressed: _isPosting ? null : _showLocationDialog,
            tooltip: 'Tambah Lokasi',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text input
                  TextField(
                    controller: _contentController,
                    maxLines: null,
                    minLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'Apa yang ingin Anda bagikan?\nGunakan @username untuk mention',
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontSize: 16),
                    enabled: !_isPosting,
                    onChanged: (value) {
                      // Rebuild to show mentions
                      setState(() {});
                    },
                  ),

                  const SizedBox(height: 16),

                  // Location tag display
                  if (_location != null && _location!.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.location_on, size: 18, color: Colors.blue[700]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _location!,
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => setState(() => _location = null),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Mentions indicator
                  Builder(
                    builder: (context) {
                      final mentions = _extractMentions(_contentController.text);
                      if (mentions.isEmpty) return const SizedBox.shrink();
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.purple[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.purple[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.alternate_email, size: 18, color: Colors.purple[700]),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: mentions.map((username) => 
                                      Chip(
                                        label: Text('@$username'),
                                        backgroundColor: Colors.purple[100],
                                        labelStyle: TextStyle(
                                          fontSize: 12,
                                          color: Colors.purple[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      )
                                    ).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),

                  // Image preview grid
                  if (_selectedImages.isNotEmpty) ...[
                    Text(
                      '${_selectedImages.length} gambar dipilih',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: FileImage(_selectedImages[index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 4,
                              left: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Add image button
                  if (_selectedImages.length < _maxImages)
                    OutlinedButton.icon(
                      onPressed: _isPosting ? null : _pickImages,
                      icon: const Icon(Icons.add_photo_alternate),
                      label: Text(
                        _selectedImages.isEmpty 
                          ? 'Tambah Gambar' 
                          : 'Tambah Gambar (${_selectedImages.length}/$_maxImages)'
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 45),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Bottom action bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: ElevatedButton(
                onPressed: _isPosting ? null : _createPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isPosting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Posting',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
