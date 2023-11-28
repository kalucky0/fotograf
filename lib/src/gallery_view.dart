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
    this.allPhotosText = 'All photos',
    super.key,
  });

  final bool multiple;
  final Color backgroundColor;
  final Color textColor;
  final String doneText;
  final String allPhotosText;

  @override
  State<GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
  final gridController = ScrollController();

  List<String> selected = [];
  List<AssetPathEntity> paths = [];
  List<AssetEntity> entities = [];
  bool isAlbumsOpen = false;
  String albumName = '';

  @override
  void initState() {
    super.initState();
    albumName = widget.allPhotosText;
    getPhotos();
  }

  Future onTileTap(int index) async {
    if (selected.isEmpty) {
      final file = await entities[index].file;
      if (file != null && mounted) {
        Navigator.of(context).pop([XFile(file.path)]);
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

  Future getPhotos() async {
    paths = await PhotoManager.getAssetPathList(
      type: RequestType.image,
    );
    if (paths.isEmpty) return;
    entities = await paths.first.getAssetListPaged(
      page: 0,
      size: 80,
    );
    if (mounted) setState(() {});
  }

  Future openAlbumsSheet() async {
    setState(() => isAlbumsOpen = true);
    final int? album = await showModalBottomSheet(
      context: context,
      barrierColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => AlbumsSheet(
        paths: paths,
      ),
    );
    if (mounted) setState(() => isAlbumsOpen = false);
    if (album == null) return;
    gridController.jumpTo(0);
    entities = await paths[album].getAssetListPaged(
      page: 0,
      size: 80,
    );
    if (paths[album].isAll) {
      setState(() => albumName = widget.allPhotosText);
    } else {
      setState(() => albumName = paths[album].name);
    }
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
            overlayColor: MaterialStatePropertyAll(
              widget.textColor.withOpacity(.12),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                albumName,
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
          onPressed: () => Navigator.of(context).pop(),
          splashRadius: 24,
          icon: Icon(
            PhosphorIconsBold.caretLeft,
            color: widget.textColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(
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
        child: MasonryGridView.count(
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
        ),
      ),
    );
  }
}
