import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:photo_manager/photo_manager.dart';

import 'widgets/albums_sheet.dart';
import 'widgets/photo_tile.dart';

class GalleryView extends StatefulWidget {
  const GalleryView({
    this.multiple = false,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.doneText = 'Done',
    this.noAccessText = 'No access to photos',
    super.key,
  });

  final bool multiple;
  final Color backgroundColor;
  final Color textColor;
  final String doneText;
  final String noAccessText;

  @override
  State<GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
  final gridController = ScrollController();

  List<String> selected = [];
  List<AssetPathEntity> paths = [];
  List<AssetEntity> entities = [];

  int albumIndex = 0, pageIndex = 0;
  bool isAlbumsOpen = false;
  double previousExtent = 0;
  bool? noAccess;

  @override
  void initState() {
    super.initState();
    gridController.addListener(onScroll);
    requestPermission();
    getPhotos();
  }

  Future<void> onScroll() async {
    final pixels = gridController.position.pixels;
    final maxExtent = gridController.position.maxScrollExtent;
    if (pixels >= maxExtent - 200 && maxExtent > previousExtent) {
      previousExtent = maxExtent;
      await loadPhotos(++pageIndex, albumIndex);
    }
  }

  Future<void> getPhotos() async {
    paths = await PhotoManager.getAssetPathList(
      type: RequestType.image,
    );
    if (paths.isEmpty) return;
    loadPhotos(0, 0);
  }

  Future<void> loadPhotos(int page, int album) async {
    final newEntities = await paths[album].getAssetListPaged(
      page: page,
      size: 20,
    );
    entities = [...entities, ...newEntities];
    if (mounted) {
      setState(() {
        albumIndex = album;
        pageIndex = page;
      });
    }
  }

  Future<void> requestPermission() async {
    final permission = await PhotoManager.requestPermissionExtend(
      requestOption: const PermissionRequestOption(),
    );
    if (mounted) {
      setState(() {
        noAccess = !permission.isAuth && !permission.hasAccess;
      });
    }
  }

  Future onTileTap(int index) async {
    if (selected.isEmpty) {
      final file = await entities[index].file;
      if (file != null && mounted) {
        Navigator.of(context).maybePop([XFile(file.path)]);
      }
    }
  }

  Future onTileSelected(int index) async {
    final file = await entities[index].file;
    if (file != null) selected.add(file.path);
    setState(() {});
  }

  Future onTileDeselected(int index) async {
    final file = await entities[index].file;
    if (file != null) selected.remove(file.path);
    setState(() {});
  }

  Future openAlbumsSheet() async {
    setState(() => isAlbumsOpen = true);
    final int? album = await showModalBottomSheet(
      context: context,
      barrierColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => AlbumsSheet(paths: paths),
    );
    if (mounted) setState(() => isAlbumsOpen = false);
    if (album == null) return;

    entities = [];
    previousExtent = 0;
    gridController.jumpTo(0);
    await loadPhotos(0, album);
  }

  @override
  void dispose() {
    gridController.removeListener(onScroll);
    gridController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: widget.backgroundColor,
      appBar: AppBar(
        toolbarHeight: 64,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.backgroundColor,
                widget.backgroundColor.withOpacity(0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        centerTitle: true,
        title: TextButton(
          onPressed: openAlbumsSheet,
          style: ButtonStyle(
            overlayColor: WidgetStatePropertyAll(
              widget.textColor.withOpacity(.12),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                paths.isNotEmpty ? paths[albumIndex].name : '',
                style: TextStyle(
                  fontSize: 15,
                  color: widget.textColor,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isAlbumsOpen
                    ? PhosphorIconsBold.caretUp
                    : PhosphorIconsBold.caretDown,
                size: 20,
                color: widget.textColor,
              ),
            ],
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          splashRadius: 24,
          icon: Icon(
            PhosphorIconsBold.caretLeft,
            color: widget.textColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).maybePop(
              selected.map((path) => XFile(path)).toList(),
            ),
            child: Text(
              widget.doneText,
              style: TextStyle(
                color: widget.textColor,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
        ),
        child: Builder(
          builder: (context) {
            if (noAccess == true) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      PhosphorIconsRegular.images,
                      size: 72,
                      color: widget.textColor,
                    ),
                    const SizedBox(height: 16),
                    FractionallySizedBox(
                      widthFactor: .7,
                      child: Text(
                        widget.noAccessText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: widget.textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return MasonryGridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              physics: const BouncingScrollPhysics(),
              controller: gridController,
              itemCount: entities.length,
              itemBuilder: (context, index) {
                return PhotoTile(
                  asset: entities[index],
                  selectMode: selected.isNotEmpty,
                  onTap: () async => await onTileTap(index),
                  onSelected: () async => await onTileSelected(index),
                  onDeselected: () async => await onTileDeselected(index),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
