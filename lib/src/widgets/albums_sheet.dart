import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import 'album_tile.dart';

class AlbumsSheet extends StatelessWidget {
  const AlbumsSheet({
    required this.paths,
    super.key,
  });

  final List<AssetPathEntity> paths;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 1,
      minChildSize: 1,
      maxChildSize: 1,
      builder: (context, scrollController) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            color: Colors.transparent,
            child: MediaQuery(
              data: MediaQueryData.fromView(View.of(context)),
              child: SafeArea(
                left: false,
                bottom: false,
                right: false,
                child: Padding(
                  padding: const EdgeInsets.only(top: 64),
                  child: Material(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: paths.length,
                        itemBuilder: (context, int index) {
                          return AlbumTile(
                            index: index,
                            path: paths[index],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
