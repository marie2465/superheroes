import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:superheroes/blocs/main_bloc.dart';
import 'package:superheroes/resources/superheroes_colors.dart';
import 'package:superheroes/resources/superheroes_images.dart';

class SuperheroCard extends StatelessWidget {
  final SuperheroInfo superheroInfo;
  final VoidCallback onTap;

  SuperheroCard({
    Key? key,
    required this.superheroInfo,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: SuperheroesColors.indigo,
        ),
        child: Row(
          children: [
            Container(
              height: 70,
              width: 70,
              color: Colors.white24,
              child: CachedNetworkImage(
                imageUrl: superheroInfo.imageUrl,
                height: 70,
                width: 70,
                fit: BoxFit.cover,
                progressIndicatorBuilder: (context, url, progress) {
                  return Container(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                        color: SuperheroesColors.blue,
                        value: progress.progress),
                  );
                },
                errorWidget: (context, url, error) {
                  return Center(
                    child: Image.asset(SuperheroesImages.unknown,
                      height: 62,
                      width: 20,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  superheroInfo.name.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  superheroInfo.realName,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }
}
