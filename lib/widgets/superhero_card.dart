import 'package:flutter/material.dart';
import 'package:superheroes/resources/superheroes_colors.dart';

class SuperheroCard extends StatelessWidget {
  final String name;
  final String realName;
  final String imageUrl;

  SuperheroCard({
    Key? key,
    required this.name,
    required this.realName,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      color: SuperheroesColors.gray,
      child: Row(
        children: [
          Image(
            image: NetworkImage(imageUrl),
            height: 70,
            width: 70,
            fit: BoxFit.cover,
          ),
          SizedBox(width: 8),
          Expanded(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                realName,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }
}
