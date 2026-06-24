import '../../data/models/book_model.dart';

class MockBooks {
  static const Book echoOfStarlight = Book(
    id: 'echo_starlight',
    title: 'The Echo of Starlight',
    author: 'Eleanor Thorne',
    coverAsset: 'assets/images/cover_echo_starlight.png',
    rating: 4.8,
    reviewCount: '1.2k',
    length: '320p',
    audioDuration: '8h 20m',
    language: 'Lang',
    description: 'Beneath the shifting sands of a dying world, a lone archivist discovers a frequency that shouldn\'t exist. "The Echo of Starlight" follows Lyra\'s journey across fractured continents as she decodes the remnants of a civilization that mastered the art of weaving memory into...',
    tags: [
      BookTag(text: 'Scifi', backgroundColorValue: 0xFFE8F5E9, textColorValue: 0xFF2E7D32),
      BookTag(text: 'Philosophical', backgroundColorValue: 0xFFE3F2FD, textColorValue: 0xFF1E88E5),
      BookTag(text: 'Award Winner', backgroundColorValue: 0xFFFFEBEA, textColorValue: 0xFFC0392B),
    ],
    reviews: [
      BookReview(
        reviewerName: 'Sarah J.',
        reviewerAvatarUrl: '',
        rating: 5,
        comment: '"A masterpiece of atmospheric storytelling. I haven\'t felt this immersed in a world since I first read The Left Hand of Darkness."',
      ),
      BookReview(
        reviewerName: 'Marcus T.',
        reviewerAvatarUrl: '',
        rating: 4,
        comment: '"Beautifully written, though the middle pacing slowed down a bit too much for my taste. Still worth it for that ending!"',
      ),
    ],
  );

  static const Book midnightLibrary = Book(
    id: 'midnight_library',
    title: 'The Midnight Library',
    author: 'Matt Haig',
    coverAsset: 'assets/images/cover_midnight_library.png',
    rating: 4.6,
    reviewCount: '4.8k',
    length: '288p',
    audioDuration: '7h 12m',
    language: 'Eng',
    description: 'Between life and death there is a library, and within that library, the shelves go on forever. Every book provides a chance to try another life you could have lived. To see how things would be if you had made other choices...',
    tags: [
      BookTag(text: 'Fantasy', backgroundColorValue: 0xFFECEFF1, textColorValue: 0xFF455A64),
      BookTag(text: 'Contemporary', backgroundColorValue: 0xFFFBEFE3, textColorValue: 0xFFE67E22),
    ],
    reviews: [
      BookReview(
        reviewerName: 'Clara D.',
        reviewerAvatarUrl: '',
        rating: 5,
        comment: '"An incredibly comforting read about life choices and regrets. Truly beautiful."',
      ),
    ],
    progress: 0.60,
  );

  static const Book becoming = Book(
    id: 'becoming',
    title: 'Becoming',
    author: 'Michelle Obama',
    coverAsset: 'assets/images/cover_becoming.png',
    rating: 4.9,
    reviewCount: '9.2k',
    length: '426p',
    audioDuration: '19h 03m',
    language: 'Eng',
    description: 'In a life filled with meaning and accomplishment, Michelle Obama has emerged as one of the most iconic and compelling women of our era. As First Lady of the United States of America—the first African American to serve in that role—she helped create the most welcoming and inclusive White House in history.',
    tags: [
      BookTag(text: 'Biography', backgroundColorValue: 0xFFEDE7F6, textColorValue: 0xFF5E35B1),
      BookTag(text: 'Inspirational', backgroundColorValue: 0xFFE0F2F1, textColorValue: 0xFF00796B),
    ],
    reviews: [
      BookReview(
        reviewerName: 'David L.',
        reviewerAvatarUrl: '',
        rating: 5,
        comment: '"Michelle Obamas narration makes this memoir feel like a personal conversation. Outstanding in every aspect."',
      ),
    ],
    progress: 0.45,
  );

  static const Book circe = Book(
    id: 'circe',
    title: 'Circe',
    author: 'Madeline Miller',
    coverAsset: 'assets/images/cover_circe.png',
    rating: 4.7,
    reviewCount: '3.1k',
    length: '400p',
    audioDuration: '12h 08m',
    language: 'Eng',
    description: 'In the house of Helios, god of the sun and mightiest of the Titans, a daughter is born. But Circe is a strange child - not powerful, like her father, nor viciously alluring like her mother. Turning to the world of mortals for companionship, she discovers she possesses the power of witchcraft, which can transform rivals into monsters and menace the gods themselves.',
    tags: [
      BookTag(text: 'Mythology', backgroundColorValue: 0xFFFFF3E0, textColorValue: 0xFFE65100),
      BookTag(text: 'Fiction', backgroundColorValue: 0xFFE8EAF6, textColorValue: 0xFF3F51B5),
    ],
    reviews: [
      BookReview(
        reviewerName: 'Sophia R.',
        reviewerAvatarUrl: '',
        rating: 5,
        comment: '"An breathtaking retelling of Homeric myths through the eyes of a deeply complex goddess. Madeline Millers prose is pure poetry."',
      ),
    ],
  );

  static const Book alchemist = Book(
    id: 'alchemist',
    title: 'The Alchemist',
    author: 'Paulo Coelho',
    coverAsset: 'assets/images/cover_alchemist.png',
    rating: 4.8,
    reviewCount: '12k',
    length: '208p',
    audioDuration: '4h 00m',
    language: 'Eng',
    description: 'Combining magic, mysticism, wisdom and wonder into an inspiring tale of self-discovery, The Alchemist has become a modern classic, selling millions of copies around the world and transforming the lives of countless readers across generations.',
    tags: [
      BookTag(text: 'Classic', backgroundColorValue: 0xFFFFFDE7, textColorValue: 0xFFF57F17),
      BookTag(text: 'Inspirational', backgroundColorValue: 0xFFE0F2F1, textColorValue: 0xFF00796B),
    ],
    reviews: [
      BookReview(
        reviewerName: 'Santiago F.',
        reviewerAvatarUrl: '',
        rating: 5,
        comment: '"A timeless fable about listening to your heart and following your dreams. Re-read it every year."',
      ),
    ],
  );

  static const Book projectHailMary = Book(
    id: 'project_hail_mary',
    title: 'Project Hail Mary',
    author: 'Andy Weir',
    coverAsset: '',
    rating: 4.8,
    reviewCount: '8.4k',
    length: '476p',
    audioDuration: '16h 10m',
    language: 'Eng',
    description: 'Ryland Grace is the sole survivor on a desperate, last-chance mission—and if he fails, humanity and the earth itself will perish. Except that right now, he doesn’t know that. He can’t even remember his own name, let alone the nature of his assignment or how to complete it.',
    tags: [
      BookTag(text: 'Scifi', backgroundColorValue: 0xFFE8F5E9, textColorValue: 0xFF2E7D32),
      BookTag(text: 'Adventure', backgroundColorValue: 0xFFFFF3E0, textColorValue: 0xFFE65100),
    ],
    reviews: [
      BookReview(
        reviewerName: 'Rocky A.',
        reviewerAvatarUrl: '',
        rating: 5,
        comment: '"Fabulous, sci-fi writing at its absolute best. The dynamic friendship and scientific problem solving are incredible."',
      ),
    ],
  );

  static const Book homegoing = Book(
    id: 'homegoing',
    title: 'Homegoing',
    author: 'Yaa Gyasi',
    coverAsset: 'assets/images/cover_homegoing.png',
    rating: 4.7,
    reviewCount: '2.4k',
    length: '300p',
    audioDuration: '10h 30m',
    language: 'Eng',
    description: 'A novel of breathtaking sweep and emotional power that traces three hundred years in Ghana and America. Two half-sisters, Effia and Esi, are born in different villages in eighteenth-century Ghana. Effia is married off to an Englishman and lives in comfort. Esi is imprisoned in Cape Coast Castle and shipped off to America.',
    tags: [
      BookTag(text: 'Historical', backgroundColorValue: 0xFFFFEBEA, textColorValue: 0xFFC0392B),
      BookTag(text: 'Drama', backgroundColorValue: 0xFFE8EAF6, textColorValue: 0xFF3F51B5),
    ],
    reviews: [
      BookReview(
        reviewerName: 'Ama K.',
        reviewerAvatarUrl: '',
        rating: 5,
        comment: '"A stunning, powerful epic that traces the legacy of slavery through generations. Highly emotional and unforgettable."',
      ),
    ],
  );

  static const Book thingsFallApart = Book(
    id: 'things_fall_apart',
    title: 'Things Fall Apart',
    author: 'Chinua Achebe',
    coverAsset: 'assets/images/cover_things_fall_apart.png',
    rating: 4.5,
    reviewCount: '3.6k',
    length: '209p',
    audioDuration: '5h 45m',
    language: 'Eng',
    description: 'Things Fall Apart is the first of three novels in Chinua Achebes popular African Trilogy. It deals with Okonkwo, a leader and local wrestling champion in Umuofia, and describes the clash of traditional Igbo culture with colonialism and missionaries.',
    tags: [
      BookTag(text: 'Classic', backgroundColorValue: 0xFFFFFDE7, textColorValue: 0xFFF57F17),
      BookTag(text: 'Fiction', backgroundColorValue: 0xFFE8EAF6, textColorValue: 0xFF3F51B5),
    ],
    reviews: [
      BookReview(
        reviewerName: 'Ngozi A.',
        reviewerAvatarUrl: '',
        rating: 5,
        comment: '"An absolute masterpiece of world literature that paints a rich, respectful picture of pre-colonial Igbo life."',
      ),
    ],
  );

  static const Book thinkingFastSlow = Book(
    id: 'thinking_fast_slow',
    title: 'Thinking, Fast and Slow',
    author: 'Daniel Kahneman',
    coverAsset: '',
    rating: 4.6,
    reviewCount: '5.8k',
    length: '499p',
    audioDuration: '9h 15m',
    language: 'Eng',
    description: 'In the international bestseller, Thinking, Fast and Slow, Daniel Kahneman, the renowned psychologist and winner of the Nobel Prize in Economics, takes us on a groundbreaking tour of the mind and explains the two systems that drive the way we think.',
    tags: [
      BookTag(text: 'Psychology', backgroundColorValue: 0xFFECEFF1, textColorValue: 0xFF455A64),
      BookTag(text: 'Science', backgroundColorValue: 0xFFE0F2F1, textColorValue: 0xFF00796B),
    ],
    reviews: [
      BookReview(
        reviewerName: 'John P.',
        reviewerAvatarUrl: '',
        rating: 4,
        comment: '"A dense but highly rewarding analysis of human cognitive biases. Fascinating and eye-opening."',
      ),
    ],
  );

  static const Book educated = Book(
    id: 'educated',
    title: 'Educated',
    author: 'Tara Westover',
    coverAsset: '',
    rating: 4.8,
    reviewCount: '7.3k',
    length: '352p',
    audioDuration: '12h 10m',
    language: 'Eng',
    description: 'Born to survivalists in the mountains of Idaho, Tara Westover was seventeen the first time she set foot in a classroom. Her family was so isolated from mainstream society that there was no one to ensure the children received an education, and no one to intervene when one of Taras older brothers became violent.',
    tags: [
      BookTag(text: 'Memoir', backgroundColorValue: 0xFFEDE7F6, textColorValue: 0xFF5E35B1),
      BookTag(text: 'Inspirational', backgroundColorValue: 0xFFE0F2F1, textColorValue: 0xFF00796B),
    ],
    reviews: [
      BookReview(
        reviewerName: 'Elena G.',
        reviewerAvatarUrl: '',
        rating: 5,
        comment: '"An incredible memoir showing the transformative power of self-education. Compelling and heartbreaking."',
      ),
    ],
  );

  static const Book normalPeople = Book(
    id: 'normal_people',
    title: 'Normal People',
    author: 'Sally Rooney',
    coverAsset: '',
    rating: 4.4,
    reviewCount: '6.1k',
    length: '273p',
    audioDuration: '8h 22m',
    language: 'Eng',
    description: 'Normal People is a story of mutual influence, class dynamics, and the complexities of young love, tracing the lives of Connell and Marianne as they navigate school, university, and the transitions of adulthood.',
    tags: [
      BookTag(text: 'Romance', backgroundColorValue: 0xFFFFECEB, textColorValue: 0xFFC0392B),
      BookTag(text: 'Drama', backgroundColorValue: 0xFFE8EAF6, textColorValue: 0xFF3F51B5),
    ],
    reviews: [
      BookReview(
        reviewerName: 'Conor M.',
        reviewerAvatarUrl: '',
        rating: 4,
        comment: '"Sally Rooney writes human relationships with incredible vulnerability and realism. Loved the pacing."',
      ),
    ],
  );

  static const Book klaraSun = Book(
    id: 'klara_sun',
    title: 'Klara and the Sun',
    author: 'Kazuo Ishiguro',
    coverAsset: '',
    rating: 4.5,
    reviewCount: '4.2k',
    length: '320p',
    audioDuration: '10h 16m',
    language: 'Eng',
    description: 'Klara and the Sun, the first novel by Kazuo Ishiguro since he was awarded the Nobel Prize in Literature, tells the story of Klara, an Artificial Friend with outstanding observational qualities, who, from her place in the store, watches carefully the behavior of those who come in to browse.',
    tags: [
      BookTag(text: 'Scifi', backgroundColorValue: 0xFFE8F5E9, textColorValue: 0xFF2E7D32),
      BookTag(text: 'Philosophical', backgroundColorValue: 0xFFE3F2FD, textColorValue: 0xFF1E88E5),
    ],
    reviews: [
      BookReview(
        reviewerName: 'Sunil K.',
        reviewerAvatarUrl: '',
        rating: 5,
        comment: '"An exceptionally gentle and moving exploration of human love and the soul, viewed through the eyes of an AI child."',
      ),
    ],
  );

  static const Book dune = Book(
    id: 'dune',
    title: 'Dune',
    author: 'Frank Herbert',
    coverAsset: 'assets/images/cover_dune.png',
    rating: 4.7,
    reviewCount: '5.2k',
    length: '608p',
    audioDuration: '21h 02m',
    language: 'Eng',
    description: 'Set on the desert planet Arrakis, Dune is the story of the boy Paul Atreides, heir to a noble family tasked with ruling an inhospitable world where the only thing of value is the spice melange, a drug capable of extending life and enhancing consciousness.',
    tags: [
      BookTag(text: 'Scifi', backgroundColorValue: 0xFFE8F5E9, textColorValue: 0xFF2E7D32),
      BookTag(text: 'Classic', backgroundColorValue: 0xFFFFFDE7, textColorValue: 0xFFF57F17),
    ],
    reviews: [
      BookReview(
        reviewerName: 'Paul A.',
        reviewerAvatarUrl: '',
        rating: 5,
        comment: '"An absolute sci-fi masterpiece. The world-building and political intrigue are unmatched."',
      ),
    ],
    progress: 0.15,
  );

  static const Book atomicHabits = Book(
    id: 'atomic_habits',
    title: 'Atomic Habits',
    author: 'James Clear',
    coverAsset: 'assets/images/cover_atomic_habits.png',
    rating: 4.8,
    reviewCount: '15.4k',
    length: '320p',
    audioDuration: '5h 35m',
    language: 'Eng',
    description: 'No matter your goals, Atomic Habits offers a proven framework for improving--every day. James Clear, one of the world\'s leading experts on habit formation, reveals practical strategies that will teach you exactly how to form good habits, break bad ones, and master the tiny behaviors that lead to remarkable results.',
    tags: [
      BookTag(text: 'Self-Help', backgroundColorValue: 0xFFE3F2FD, textColorValue: 0xFF1E88E5),
      BookTag(text: 'Nonfiction', backgroundColorValue: 0xFFECEFF1, textColorValue: 0xFF455A64),
    ],
    reviews: [
      BookReview(
        reviewerName: 'Alice W.',
        reviewerAvatarUrl: '',
        rating: 5,
        comment: '"Practical, actionable advice that changed the way I structure my day. Essential reading."',
      ),
    ],
    isFinished: true,
  );

  static const Book greatGatsby = Book(
    id: 'great_gatsby',
    title: 'The Great Gatsby',
    author: 'F. Scott Fitzgerald',
    coverAsset: 'assets/images/cover_great_gatsby.png',
    rating: 4.6,
    reviewCount: '8.9k',
    length: '180p',
    audioDuration: '4h 45m',
    language: 'Eng',
    description: 'The Great Gatsby, F. Scott Fitzgerald\'s third book, stands as the supreme achievement of his career. First published in 1925, this classic novel of the Jazz Age has been acclaimed by generations of readers which tells the story of the mysteriously wealthy Jay Gatsby and his love for Daisy Buchanan.',
    tags: [
      BookTag(text: 'Classic', backgroundColorValue: 0xFFFFFDE7, textColorValue: 0xFFF57F17),
      BookTag(text: 'Fiction', backgroundColorValue: 0xFFE8EAF6, textColorValue: 0xFF3F51B5),
    ],
    reviews: [
      BookReview(
        reviewerName: 'Nick C.',
        reviewerAvatarUrl: '',
        rating: 5,
        comment: '"A beautifully written critique of the American Dream. The prose is stunning and full of longing."',
      ),
    ],
    isFinished: true,
  );
}
