import 'package:flutter/material.dart';
import 'package:luxresapp/models/NearbyResponse.dart';

class DetailsScreen extends StatefulWidget {
  final String name;
  final String address;
  final dynamic rating;
  final List<Photos>? photos;

  DetailsScreen({
    super.key,
    required this.name,
    required this.address,
    required this.rating,
    required this.photos,
  });

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text("Address"),
              subtitle: Text(widget.address),
            ),
            ListTile(
              title: Text("Rating"),
              subtitle: Text(widget.rating.toString() + ' / 5'),
            ),
            if (widget.photos != null && widget.photos!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 200, // Adjust the height as needed
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.photos!.length,
                    itemBuilder: (context, index) {
                      final photo = widget.photos![index];
                      final photoUrl =
                          'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${photo.photoReference}&key=AIzaSyAwQa2odTPLwOvCxOONH3qqoMZQoLv2HZ0';
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.network(
                          photoUrl,
                          width: 200, // Adjust the width as needed
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Get Direction'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Call Now'),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
