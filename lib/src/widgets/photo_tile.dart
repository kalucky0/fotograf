import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class PhotoTile extends StatefulWidget {
  const PhotoTile({
    required this.asset,
    required this.selectMode,
    required this.onTap,
    required this.onSelected,
    required this.onDeselected,
    super.key,
  });

  final AssetEntity asset;
  final bool selectMode;
  final VoidCallback onTap;
  final VoidCallback onSelected;
  final VoidCallback onDeselected;

  @override
  State<PhotoTile> createState() => _PhotoTileState();
}

class _PhotoTileState extends State<PhotoTile> {
  late final double ratio;
  late final ImageProvider provider;

  double opacity = 0;
  bool isSelected = false;

  @override
  void initState() {
    super.initState();
    ratio = widget.asset.width / widget.asset.height;
    provider = AssetEntityImageProvider(
      widget.asset,
      isOriginal: false,
      thumbnailFormat: ThumbnailFormat.jpeg,
    );
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => opacity = 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(milliseconds: 200),
      child: AspectRatio(
        aspectRatio: ratio,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: provider,
            ),
          ),
          child: Material(
            type: MaterialType.transparency,
            borderRadius: BorderRadius.circular(8),
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              onTap: () {
                if (isSelected) {
                  setState(() => isSelected = false);
                  widget.onDeselected();
                } else if (widget.selectMode) {
                  setState(() => isSelected = true);
                  widget.onSelected();
                } else {
                  widget.onTap();
                }
              },
              onLongPress: () {
                if (isSelected) {
                  setState(() => isSelected = false);
                  widget.onDeselected();
                } else {
                  setState(() => isSelected = true);
                  widget.onSelected();
                }
              },
              child: AnimatedOpacity(
                opacity: isSelected ? 1 : 0,
                duration: const Duration(milliseconds: 250),
                child: Container(
                  color: const Color(0x20000000),
                  child: const Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        PhosphorIconsBold.checkCircle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
