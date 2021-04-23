/// Abstract class for auto mapping
abstract class AutoMapperModel {
  const AutoMapperModel();

  Map<String, dynamic> toAutoJson();
}
