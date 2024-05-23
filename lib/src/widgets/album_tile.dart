import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class AlbumTile extends StatelessWidget {
  const AlbumTile({
    required this.index,
    required this.path,
    super.key,
  });

  final int index;
  final AssetPathEntity path;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Navigator.of(context).pop(index),
      leading: FutureBuilder(
        future: path.getAssetListRange(start: 0, end: 1),
        builder: (context, assets) {
          AssetEntity? asset;
          DecorationImage? image;
          if (assets.hasData && !assets.hasError) {
            asset = assets.data?.firstOrNull;
          }
          if (asset != null) {
            image = DecorationImage(
              fit: BoxFit.cover,
              image: AssetEntityImageProvider(
                asset,
                isOriginal: false,
                thumbnailFormat: ThumbnailFormat.jpeg,
                thumbnailSize: const ThumbnailSize.square(
                  100,
                ),
              ),
            );
          }
          return Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              image: image,
            ),
          );
        },
      ),
      title: Text(
        path.name,
        style: const TextStyle(
          fontSize: 15,
          fontVariations: [
            FontVariation('wght', 500),
          ],
        ),
      ),
      subtitle: FutureBuilder(
        future: path.assetCountAsync,
        builder: (context, count) {
          if (!count.hasData || count.hasError) return const SizedBox();
          return Text(
            '${count.data}',
            style: const TextStyle(
              fontSize: 13,
              fontVariations: [
                FontVariation('wght', 400),
              ],
            ),
          );
        },
      ),
    );
  }
}
