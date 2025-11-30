import '../models/word.dart';

List<Word> words = [
  Word(english: 'Apple', turkish: 'Elma', level: 'A1'),
  Word(english: 'Book', turkish: 'Kitap', level: 'A1'),
  Word(english: 'Car', turkish: 'Araba', level: 'A1'),
  Word(english: 'Cat', turkish: 'Kedi', level: 'A1'),
  Word(english: 'Dog', turkish: 'Köpek', level: 'A1'),
  Word(english: 'House', turkish: 'Ev', level: 'A1'),
  Word(english: 'Sun', turkish: 'Güneş', level: 'A1'),
  Word(english: 'Water', turkish: 'Su', level: 'A1'),

  Word(english: 'Beautiful', turkish: 'Güzel', level: 'A2'),
  Word(english: 'Friend', turkish: 'Arkadaş', level: 'A2'),
  Word(english: 'Happy', turkish: 'Mutlu', level: 'A2'),
  Word(english: 'School', turkish: 'Okul', level: 'A2'),
  Word(english: 'Teacher', turkish: 'Öğretmen', level: 'A2'),

  Word(english: 'Amazing', turkish: 'Harika', level: 'B1'),
  Word(english: 'Challenge', turkish: 'Zorluk', level: 'B1'),
  Word(english: 'Discover', turkish: 'Keşfetmek', level: 'B1'),
  Word(english: 'Journey', turkish: 'Yolculuk', level: 'B1'),

  Word(english: 'Achievement', turkish: 'Başarı', level: 'B2'),
  Word(english: 'Confidence', turkish: 'Güven', level: 'B2'),
  Word(english: 'Opportunity', turkish: 'Fırsat', level: 'B2'),
  Word(english: 'Success', turkish: 'Başarı', level: 'B2'),
]..sort((a, b) => a.english.compareTo(b.english));
