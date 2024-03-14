class GooglePhoto {
  final bool isVisitorImage;
  final String thumbnailUrl;

  GooglePhoto({
    required this.isVisitorImage,
    required this.thumbnailUrl,
  });

  GooglePhoto copyWith({
    bool? isVisitorImage,
    String? thumbnailUrl,
  }) {
    return GooglePhoto(
      isVisitorImage: isVisitorImage ?? this.isVisitorImage,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    );
  }

  @override
  String toString() =>
      'GooglePhoto(isVisitorImage: $isVisitorImage, thumbnailUrl: $thumbnailUrl)';

  @override
  bool operator ==(covariant GooglePhoto other) {
    if (identical(this, other)) return true;

    return other.isVisitorImage == isVisitorImage &&
        other.thumbnailUrl == thumbnailUrl;
  }

  @override
  int get hashCode => isVisitorImage.hashCode ^ thumbnailUrl.hashCode;
}
