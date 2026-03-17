import 'package:flutter/material.dart';

import '../services/course_repository.dart';

class AddCourseScreen extends StatefulWidget {
  const AddCourseScreen({super.key});

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageController = TextEditingController();
  final _instructorController = TextEditingController();
  final _videoController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController(text: '8 soat');
  final _lessonsController = TextEditingController(text: '8');

  String _selectedCategory = 'IT';
  String _selectedLevel = 'Intermediate';
  bool _isFeatured = true;
  bool _isLoading = false;

  final List<String> _categories = const [
    'IT',
    'English',
    'Business',
    'Design',
    'Marketing',
    'Math',
  ];

  final List<String> _levels = const ['Beginner', 'Intermediate', 'Advanced'];

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    _instructorController.dispose();
    _videoController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _lessonsController.dispose();
    super.dispose();
  }

  Future<void> _saveCourse() async {
    if (_titleController.text.trim().isEmpty ||
        _instructorController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kurs nomi va mentor ismi majburiy")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await CourseRepository.instance.addCourse({
        'title': _titleController.text.trim(),
        'category': _selectedCategory,
        'price': _priceController.text.trim().isEmpty
            ? 'Bepul'
            : _priceController.text.trim(),
        'image': _imageController.text.trim().isEmpty
            ? 'https://picsum.photos/seed/new-course/900/600'
            : _imageController.text.trim(),
        'videoUrl': _videoController.text.trim().isEmpty
            ? 'https://www.youtube.com/watch?v=fq4N0hgOWzU'
            : _videoController.text.trim(),
        'instructor': _instructorController.text.trim(),
        'rating': '5.0',
        'description': _descriptionController.text.trim().isEmpty
            ? "Premium kontent, amaliy bloklar va mentor feedback bilan tuzilgan kurs."
            : _descriptionController.text.trim(),
        'duration': _durationController.text.trim(),
        'lessonsCount': int.tryParse(_lessonsController.text.trim()) ?? 8,
        'studentsCount': 0,
        'level': _selectedLevel,
        'isFeatured': _isFeatured,
      });

      if (!mounted) {
        return;
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Yangi kurs muvaffaqiyatli qo'shildi")),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Xatolik: $e")));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Yangi kurs yaratish")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _Section(
            title: "Asosiy ma'lumot",
            child: Column(
              children: [
                _InputField(
                  controller: _titleController,
                  label: "Kurs nomi",
                  icon: Icons.title_rounded,
                ),
                const SizedBox(height: 14),
                _InputField(
                  controller: _instructorController,
                  label: "Mentor",
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 14),
                _InputField(
                  controller: _descriptionController,
                  label: "Qisqa tavsif",
                  icon: Icons.notes_rounded,
                  maxLines: 3,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Section(
            title: "Struktura",
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _SelectField(
                        label: "Kategoriya",
                        value: _selectedCategory,
                        items: _categories,
                        onChanged: (value) {
                          setState(() => _selectedCategory = value!);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SelectField(
                        label: "Level",
                        value: _selectedLevel,
                        items: _levels,
                        onChanged: (value) {
                          setState(() => _selectedLevel = value!);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _InputField(
                        controller: _priceController,
                        label: "Narx",
                        icon: Icons.sell_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InputField(
                        controller: _durationController,
                        label: "Davomiylik",
                        icon: Icons.schedule_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _InputField(
                  controller: _lessonsController,
                  label: "Lesson soni",
                  icon: Icons.menu_book_outlined,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  value: _isFeatured,
                  onChanged: (value) {
                    setState(() => _isFeatured = value);
                  },
                  title: const Text("Featured kurs sifatida chiqarish"),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Section(
            title: "Media",
            child: Column(
              children: [
                _InputField(
                  controller: _imageController,
                  label: "Cover image URL",
                  icon: Icons.image_outlined,
                ),
                const SizedBox(height: 14),
                _InputField(
                  controller: _videoController,
                  label: "YouTube video URL",
                  icon: Icons.play_circle_outline_rounded,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _saveCourse,
            child: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.onPrimary,
                    ),
                  )
                : const Text("Kursni saqlash"),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;

  const _InputField({
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
    );
  }
}

class _SelectField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _SelectField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
