class Article {
  String section;
  String subsection;
  String title;
  String abstract;
  String url;
  String uri;
  String byline;
  String itemType;
  String updatedDate;
  String createdDate;
  String publishedDate;
  String materialTypeFacet;
  String kicker;
  List<String> desFacet;
  List<String> orgFacet;
  List<String> perFacet;
  List<String> geoFacet;
  List<Multimedia> multimedia;
  String shortUrl;

  Article(
      {required this.section,
      required this.subsection,
      required this.title,
      required this.abstract,
      required this.url,
      required this.uri,
      required this.byline,
      required this.itemType,
      required this.updatedDate,
      required this.createdDate,
      required this.publishedDate,
      required this.materialTypeFacet,
      required this.kicker,
      required this.desFacet,
      required this.orgFacet,
      required this.perFacet,
      required this.geoFacet,
      required this.multimedia,
      required this.shortUrl});

  Article.fromJson(Map<String, dynamic> json)
      : section = json['section'],
        subsection = json['subsection'],
        title = json['title'],
        abstract = json['abstract'],
        url = json['url'],
        uri = json['uri'],
        byline = json['byline'],
        itemType = json['item_type'],
        updatedDate = json['updated_date'],
        createdDate = json['created_date'],
        publishedDate = json['published_date'],
        materialTypeFacet = json['material_type_facet'],
        kicker = json['kicker'],
        desFacet = json['des_facet'].cast<String>(),
        orgFacet = json['org_facet'].cast<String>(),
        perFacet = json['per_facet'].cast<String>(),
        geoFacet = json['geo_facet'].cast<String>(),
        multimedia = List.generate(json['multimedia'].length,
            (index) => Multimedia.fromJson(json['multimedia'][index])),
        shortUrl = json['short_url'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['section'] = section;
    data['subsection'] = subsection;
    data['title'] = title;
    data['abstract'] = abstract;
    data['url'] = url;
    data['uri'] = uri;
    data['byline'] = byline;
    data['item_type'] = itemType;
    data['updated_date'] = updatedDate;
    data['created_date'] = createdDate;
    data['published_date'] = publishedDate;
    data['material_type_facet'] = materialTypeFacet;
    data['kicker'] = kicker;
    data['des_facet'] = desFacet;
    data['org_facet'] = orgFacet;
    data['per_facet'] = perFacet;
    data['geo_facet'] = geoFacet;
    if (multimedia != null) {
      data['multimedia'] = multimedia.map((v) => v.toJson()).toList();
    }
    data['short_url'] = shortUrl;
    return data;
  }
}

class Multimedia {
  String url;
  String format;
  int height;
  int width;
  String type;
  String subtype;
  String caption;
  String copyright;

  Multimedia(
      {required this.url,
      required this.format,
      required this.height,
      required this.width,
      required this.type,
      required this.subtype,
      required this.caption,
      required this.copyright});

  Multimedia.fromJson(Map<String, dynamic> json)
      : url = json['url'],
        format = json['format'],
        height = json['height'],
        width = json['width'],
        type = json['type'],
        subtype = json['subtype'],
        caption = json['caption'],
        copyright = json['copyright'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['url'] = url;
    data['format'] = format;
    data['height'] = height;
    data['width'] = width;
    data['type'] = type;
    data['subtype'] = subtype;
    data['caption'] = caption;
    data['copyright'] = copyright;
    return data;
  }
}
