import 'dart:io';
import 'package:flutter/material.dart';
import '../models/content_item.dart';

class ContentCard extends StatelessWidget {
  final ContentItem item;
  final bool editable;
  final VoidCallback? onTitleTap;
  final VoidCallback? onUserInfoTap;
  final VoidCallback? onTagTap;
  final VoidCallback? onTimeTap;
  final VoidCallback? onImageTap;

  const ContentCard({
    super.key,
    required this.item,
    this.editable = false,
    this.onTitleTap,
    this.onUserInfoTap,
    this.onTagTap,
    this.onTimeTap,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 7,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 18, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _EditableText(
                          text: item.title,
                          editable: editable,
                          onTap: onTitleTap,
                          style: const TextStyle(
                            fontSize: 17,
                            color: Color(0xFF000000),
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(0, -25),
                          child: _EditableText(
                            text: item.userInfo,
                            editable: editable,
                            onTap: onUserInfoTap,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color.fromARGB(160, 136, 136, 136),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            _EditableTag(
                              text: item.tag,
                              editable: editable,
                              onTap: onTagTap,
                            ),
                            const SizedBox(width: 6),
                            _EditableText(
                              text: item.time,
                              editable: editable,
                              onTap: onTimeTap,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF888888),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12, top: 12),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 0, bottom: 40),
                    child: _EditableImage(
                      imageUrl: item.imageUrl,
                      editable: editable,
                      onTap: onImageTap,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1, color: Color(0xFFEEEEEE)),
      ],
    );
  }
}

// ── 可编辑文字 ──
class _EditableText extends StatelessWidget {
  final String text;
  final bool editable;
  final VoidCallback? onTap;
  final TextStyle style;

  const _EditableText({
    required this.text,
    required this.editable,
    this.onTap,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    final child = Text(text, style: style);
    if (!editable) return child;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue.withAlpha(80), width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: child,
      ),
    );
  }
}

// ── 可编辑标签 ──
class _EditableTag extends StatelessWidget {
  final String text;
  final bool editable;
  final VoidCallback? onTap;

  const _EditableTag({
    required this.text,
    required this.editable,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final child = Container(
      padding: const EdgeInsets.only(left: 4, right: 4, top: 1, bottom: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10, color: Color.fromARGB(255, 52, 51, 51)),
      ),
    );
    if (!editable) return child;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue.withAlpha(80), width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: child,
      ),
    );
  }
}

// ── 可编辑图片 ──
class _EditableImage extends StatelessWidget {
  final String imageUrl;
  final bool editable;
  final VoidCallback? onTap;

  const _EditableImage({
    required this.imageUrl,
    required this.editable,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final child = imageUrl.startsWith('lib/')
        ? Image.asset(imageUrl, width: 40 * 2.6, height: 32 * 2.6, fit: BoxFit.cover)
        : Image.file(File(imageUrl), width: 40 * 2.6, height: 32 * 2.6, fit: BoxFit.cover);
    if (!editable) return child;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue.withAlpha(120), width: 2),
        ),
        child: child,
      ),
    );
  }
}
