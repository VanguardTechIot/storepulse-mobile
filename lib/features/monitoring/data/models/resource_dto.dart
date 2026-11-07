class ResourceDto {
  final int id;
  final String name;
  final String? reference;

  const ResourceDto({required this.id, required this.name, this.reference});

  factory ResourceDto.fromJson(Map<String, dynamic> json) {
    return ResourceDto(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      reference: json['reference'] as String?,
    );
  }
}
