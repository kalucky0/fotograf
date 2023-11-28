import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:camera/camera.dart';

class CameraActions extends StatelessWidget {
  const CameraActions({
    required this.cameras,
    required this.galleryPreview,
    required this.onGalleryTap,
    required this.onCaptureTap,
    required this.onSwitchCameraTap,
    super.key,
  });

  final List<CameraDescription> cameras;
  final ImageProvider? galleryPreview;
  final VoidCallback onGalleryTap;
  final VoidCallback onCaptureTap;
  final VoidCallback onSwitchCameraTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 30,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: onGalleryTap,
                child: Container(
                  width: 48,
                  height: 46,
                  decoration: BoxDecoration(
                    image: galleryPreview == null
                        ? null
                        : DecorationImage(
                            image: galleryPreview!,
                            fit: BoxFit.cover,
                          ),
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              Opacity(
                opacity: cameras.length < 2 ? 0.5 : 1,
                child: Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 6,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(39),
                    onTap: onCaptureTap,
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(10, 10),
                child: Opacity(
                  opacity: cameras.length < 2 ? 0.5 : 1,
                  child: IconButton(
                    onPressed: onSwitchCameraTap,
                    splashRadius: 30,
                    iconSize: 30,
                    icon: const Icon(
                      PhosphorIconsFill.cameraRotate,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
