class Section {
  final name;
  final type;
  Section({required this.name, required this.type});
}

enum SectionTypes {
  arts,
  automobiles,
  books,
  business,
  fashion,
  food,
  health,
  home,
  insider,
  magazine,
  movies,
  nyregion,
  obituaries,
  opinion,
  politics,
  realestate,
  science,
  sports,
  sundayreview,
  technology,
  theater,
  t_magazine,
  travel,
  upshot,
  us,
  world
}

List<Section> sections = [
  Section(name: 'arts', type: SectionTypes.arts),
  Section(name: 'automobiles', type: SectionTypes.automobiles),
  Section(name: 'books', type: SectionTypes.books),
  Section(name: 'business', type: SectionTypes.business),
  Section(name: 'fashion', type: SectionTypes.fashion),
  Section(name: 'food', type: SectionTypes.food),
  Section(name: 'health', type: SectionTypes.health),
  Section(name: 'home', type: SectionTypes.home),
  Section(name: 'insider', type: SectionTypes.insider),
  Section(name: 'magazine', type: SectionTypes.magazine),
  Section(name: 'movies', type: SectionTypes.movies),
  Section(name: 'nyregion', type: SectionTypes.nyregion),
  Section(name: 'obituaries', type: SectionTypes.obituaries),
  Section(name: 'opinion', type: SectionTypes.opinion),
  Section(name: 'politics', type: SectionTypes.politics),
  Section(name: 'realestate', type: SectionTypes.realestate),
  Section(name: 'science', type: SectionTypes.science),
  Section(name: 'sports', type: SectionTypes.sports),
  Section(name: 'sundayreview', type: SectionTypes.sundayreview),
  Section(name: 'technology', type: SectionTypes.technology),
  Section(name: 'theater', type: SectionTypes.theater),
  Section(name: 't-magazine', type: SectionTypes.t_magazine),
  Section(name: 'travel', type: SectionTypes.travel),
  Section(name: 'upshot', type: SectionTypes.upshot),
  Section(name: 'us', type: SectionTypes.us),
  Section(name: 'world', type: SectionTypes.world),
];
