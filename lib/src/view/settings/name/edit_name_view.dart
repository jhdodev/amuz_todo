import 'package:amuz_todo/src/view/settings/name/edit_name_view_state.dart';
import 'package:amuz_todo/src/service/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amuz_todo/src/view/settings/name/edit_name_view_model.dart';
import 'package:lucide_icons/lucide_icons.dart';

class EditNameView extends ConsumerStatefulWidget {
  final String currentName;

  const EditNameView({super.key, required this.currentName});

  @override
  ConsumerState<EditNameView> createState() => _EditNameViewState();
}

class _EditNameViewState extends ConsumerState<EditNameView> {
  late final TextEditingController _nameController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);

    // 초기 이름 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(editNameViewModelProvider.notifier)
          .loadCurrentName(widget.currentName);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editNameViewModelProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);

    // 에러 메시지 표시
    ref.listen<EditNameViewState>(editNameViewModelProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '이름 변경',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
        scrolledUnderElevation: 0,
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _nameController,
                  enabled: !state.isLoading,
                  cursorColor: isDarkMode ? Color(0xFFE5E5E5) : Colors.black,
                  style: TextStyle(
                    color: isDarkMode ? Color(0xFFFAFAFA) : Colors.black,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: '이름',
                    hintStyle: TextStyle(
                      color: isDarkMode ? Color(0xFFA0A0A0) : Colors.grey,
                    ),
                    prefixIcon: Icon(
                      LucideIcons.user,
                      size: 20,
                      color: isDarkMode ? Color(0xFFA0A0A0) : Colors.black,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: isDarkMode
                            ? Color(0xFF1A1A1A)
                            : Color(0xFFE5E5E5),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: isDarkMode
                            ? Color(0xFF1A1A1A)
                            : Colors.black.withValues(alpha: 0.4),
                        width: 3,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '이름을 입력해주세요';
                    }
                    if (value.trim().length < 2) {
                      return '이름은 2자 이상이어야 합니다';
                    }
                    if (value.trim().length > 20) {
                      return '이름은 20자 이하여야 합니다';
                    }
                    return null;
                  },
                  maxLength: 20,
                  onChanged: (value) {
                    // 에러 메시지가 있으면 입력 시 초기화
                    if (state.errorMessage != null) {
                      ref.read(editNameViewModelProvider.notifier).clearError();
                    }
                  },
                ),

                const SizedBox(height: 16),

                if (state.errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.red.shade900.withOpacity(0.3)
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDarkMode
                            ? Colors.red.shade700
                            : Colors.red.shade200,
                      ),
                    ),
                    child: Text(
                      state.errorMessage!,
                      style: TextStyle(
                        color: isDarkMode
                            ? Colors.red.shade300
                            : Colors.red.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ),

                ElevatedButton(
                  onPressed: state.isLoading ? null : _updateName,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode
                        ? Color(0xFFE5E5E5)
                        : Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: state.isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: isDarkMode ? Colors.black : Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          '저장',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.black : Colors.white,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _updateName() {
    if (_formKey.currentState!.validate()) {
      ref
          .read(editNameViewModelProvider.notifier)
          .updateName(_nameController.text, context);
    }
  }
}
