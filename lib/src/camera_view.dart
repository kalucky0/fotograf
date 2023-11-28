import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:photo_manager/photo_manager.dart';

import 'widgets/camera_actions.dart';
import 'widgets/no_cameras.dart';

class CameraView extends StatefulWidget {
  const CameraView({
    required this.onCapture,
    required this.onError,
    required this.onGalleryTap,
    super.key,
  });

  final Future<void> Function(XFile?) onCapture;
  final Function(Exception) onError;
  final Future<List<XFile>?> Function() onGalleryTap;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  final screenshotController = ScreenshotController();
  CameraController? controller;

  List<CameraDescription> cameras = [];
  bool isFrontCamera = false;
  bool isHidden = true;
  bool isCaptured = false;
  bool photoTaken = false;
  bool hideUi = false;
  Uint8List? preview;
  AssetEntity? galleryPreview;

  @override
  void initState() {
    super.initState();
    PhotoManager.getAssetListRange(start: 0, end: 1).then((value) {
      if (value.isNotEmpty) setState(() => galleryPreview = value.first);
    });
    initialize();
  }

  Future initialize() async {
    cameras = await availableCameras();
    if (cameras.isEmpty) {
      widget.onError(
        Exception('No cameras found'),
      );
      return;
    }
    controller = CameraController(cameras.first, ResolutionPreset.max);
    initializeCamera().catchError((e) => widget.onError(e));
  }

  Future initializeCamera() async {
    await controller?.initialize();
    if (mounted) setState(() {});
    await Future.delayed(const Duration(milliseconds: 50));
    if (mounted) setState(() => isHidden = false);
    controller?.setFlashMode(FlashMode.off);
  }

  Future takePhoto() async {
    if (controller == null || photoTaken) return;
    photoTaken = true;

    XFile? file;
    await Future.wait([
      controller!.takePicture().then((f) => file = f),
      showFakeFlash(),
    ]);

    if (!mounted) return;

    if (file != null) {
      await widget.onCapture(file);
    } else {
      widget.onError(
        Exception('An error occurred while taking a photo'),
      );
      return;
    }

    if (!mounted) return;

    setState(() {
      isHidden = false;
      isCaptured = false;
      photoTaken = false;
      hideUi = false;
      preview = null;
    });
  }

  void switchCamera() {
    if (cameras.length < 2) return;
    isFrontCamera = !isFrontCamera;
    controller?.setDescription(
      isFrontCamera ? cameras.last : cameras.first,
    );
  }

  Future showFakeFlash() async {
    setState(() => isCaptured = true);
    await Future.delayed(const Duration(milliseconds: 80));
    final image = await screenshotController.capture(
      pixelRatio: 0.5,
      delay: Duration.zero,
    );
    preview = image;
    setState(() {
      isCaptured = false;
      hideUi = true;
    });
  }

  Future openGallery() async {
    final files = await widget.onGalleryTap();
    if (files == null || files.isEmpty) return;
    await widget.onCapture(files.firstOrNull);

    if (!mounted) return;

    setState(() {
      isHidden = false;
      isCaptured = false;
      photoTaken = false;
      hideUi = false;
      preview = null;
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            splashRadius: 24,
            icon: const Icon(Icons.close),
          ),
          const SizedBox(width: 5),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              if (cameras.isEmpty)
                const Positioned.fill(
                  child: NoCameras(),
                ),
              if (controller?.value.isInitialized ?? false)
                Positioned.fill(
                  child: AnimatedOpacity(
                    opacity: isHidden ? 0 : 1,
                    duration: const Duration(milliseconds: 500),
                    child: Screenshot(
                      controller: screenshotController,
                      child: SizedBox(
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: 200,
                            child: CameraPreview(controller!),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (preview != null)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: MemoryImage(preview!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              if (!hideUi)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: CameraActions(
                    cameras: cameras,
                    galleryPreview: galleryPreview != null
                        ? AssetEntityImageProvider(
                            galleryPreview!,
                            isOriginal: false,
                            thumbnailFormat: ThumbnailFormat.jpeg,
                            thumbnailSize: const ThumbnailSize.square(100),
                          )
                        : null,
                    onGalleryTap: openGallery,
                    onCaptureTap: takePhoto,
                    onSwitchCameraTap: switchCamera,
                  ),
                ),
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    opacity: isCaptured ? 1 : 0,
                    duration: const Duration(milliseconds: 80),
                    child: Container(
                      color: Colors.white.withOpacity(.54),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
