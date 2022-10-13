// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article_preview_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ArticleAdapter extends TypeAdapter<ArticlePreview> {
  @override
  final int typeId = 0;

  @override
  ArticlePreview read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ArticlePreview(
      section: fields[0] as String,
      title: fields[1] as String,
      abstract: fields[2] as String,
      url: fields[3] as String,
      byline: fields[4] as String,
      createdDate: fields[5] as String,
      multimediaUrl: fields[6] as String,
      uri: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ArticlePreview obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.section)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.abstract)
      ..writeByte(3)
      ..write(obj.url)
      ..writeByte(4)
      ..write(obj.byline)
      ..writeByte(5)
      ..write(obj.createdDate)
      ..writeByte(6)
      ..write(obj.multimediaUrl)
      ..writeByte(7)
      ..write(obj.uri);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArticleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
