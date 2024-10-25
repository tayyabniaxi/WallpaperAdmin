
class ImageData {
  final String url;
  final String title;
  final String description;
  final int timestamp;
   final String subcategory;

  ImageData({
    required this.url,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.subcategory,
  });

  factory ImageData.fromMap(Map<String, dynamic> map) {
    return ImageData(
      url: map['url'] ?? '',
      title: map['key'] ?? '',
      description: map['description'] ?? '',
      // status: map['isPro'] ?? '',
      timestamp: map['uploadTimestamp'],
      subcategory: map["subcategory"]
    );
  }
}
