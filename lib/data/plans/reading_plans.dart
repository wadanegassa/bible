class PlanDay {
  final int day;
  final String bookId;
  final int chapter;
  final String title;

  const PlanDay({
    required this.day,
    required this.bookId,
    required this.chapter,
    required this.title,
  });
}

class ReadingPlan {
  final String id;
  final String title;
  final String subtitle;
  final List<PlanDay> days;

  const ReadingPlan({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.days,
  });

  int get length => days.length;
}

class ReadingPlans {
  static const List<ReadingPlan> all = [
    ReadingPlan(
      id: 'john_21',
      title: 'Gospel of John',
      subtitle: '21 days · one chapter a day',
      days: [
        PlanDay(day: 1, bookId: 'JHN', chapter: 1, title: 'John 1'),
        PlanDay(day: 2, bookId: 'JHN', chapter: 2, title: 'John 2'),
        PlanDay(day: 3, bookId: 'JHN', chapter: 3, title: 'John 3'),
        PlanDay(day: 4, bookId: 'JHN', chapter: 4, title: 'John 4'),
        PlanDay(day: 5, bookId: 'JHN', chapter: 5, title: 'John 5'),
        PlanDay(day: 6, bookId: 'JHN', chapter: 6, title: 'John 6'),
        PlanDay(day: 7, bookId: 'JHN', chapter: 7, title: 'John 7'),
        PlanDay(day: 8, bookId: 'JHN', chapter: 8, title: 'John 8'),
        PlanDay(day: 9, bookId: 'JHN', chapter: 9, title: 'John 9'),
        PlanDay(day: 10, bookId: 'JHN', chapter: 10, title: 'John 10'),
        PlanDay(day: 11, bookId: 'JHN', chapter: 11, title: 'John 11'),
        PlanDay(day: 12, bookId: 'JHN', chapter: 12, title: 'John 12'),
        PlanDay(day: 13, bookId: 'JHN', chapter: 13, title: 'John 13'),
        PlanDay(day: 14, bookId: 'JHN', chapter: 14, title: 'John 14'),
        PlanDay(day: 15, bookId: 'JHN', chapter: 15, title: 'John 15'),
        PlanDay(day: 16, bookId: 'JHN', chapter: 16, title: 'John 16'),
        PlanDay(day: 17, bookId: 'JHN', chapter: 17, title: 'John 17'),
        PlanDay(day: 18, bookId: 'JHN', chapter: 18, title: 'John 18'),
        PlanDay(day: 19, bookId: 'JHN', chapter: 19, title: 'John 19'),
        PlanDay(day: 20, bookId: 'JHN', chapter: 20, title: 'John 20'),
        PlanDay(day: 21, bookId: 'JHN', chapter: 21, title: 'John 21'),
      ],
    ),
    ReadingPlan(
      id: 'psalms_30',
      title: 'Psalms Comfort',
      subtitle: '30 days · selected psalms',
      days: [
        PlanDay(day: 1, bookId: 'PSA', chapter: 1, title: 'Psalm 1'),
        PlanDay(day: 2, bookId: 'PSA', chapter: 8, title: 'Psalm 8'),
        PlanDay(day: 3, bookId: 'PSA', chapter: 16, title: 'Psalm 16'),
        PlanDay(day: 4, bookId: 'PSA', chapter: 19, title: 'Psalm 19'),
        PlanDay(day: 5, bookId: 'PSA', chapter: 23, title: 'Psalm 23'),
        PlanDay(day: 6, bookId: 'PSA', chapter: 27, title: 'Psalm 27'),
        PlanDay(day: 7, bookId: 'PSA', chapter: 32, title: 'Psalm 32'),
        PlanDay(day: 8, bookId: 'PSA', chapter: 34, title: 'Psalm 34'),
        PlanDay(day: 9, bookId: 'PSA', chapter: 37, title: 'Psalm 37'),
        PlanDay(day: 10, bookId: 'PSA', chapter: 40, title: 'Psalm 40'),
        PlanDay(day: 11, bookId: 'PSA', chapter: 42, title: 'Psalm 42'),
        PlanDay(day: 12, bookId: 'PSA', chapter: 46, title: 'Psalm 46'),
        PlanDay(day: 13, bookId: 'PSA', chapter: 51, title: 'Psalm 51'),
        PlanDay(day: 14, bookId: 'PSA', chapter: 63, title: 'Psalm 63'),
        PlanDay(day: 15, bookId: 'PSA', chapter: 67, title: 'Psalm 67'),
        PlanDay(day: 16, bookId: 'PSA', chapter: 73, title: 'Psalm 73'),
        PlanDay(day: 17, bookId: 'PSA', chapter: 84, title: 'Psalm 84'),
        PlanDay(day: 18, bookId: 'PSA', chapter: 90, title: 'Psalm 90'),
        PlanDay(day: 19, bookId: 'PSA', chapter: 91, title: 'Psalm 91'),
        PlanDay(day: 20, bookId: 'PSA', chapter: 96, title: 'Psalm 96'),
        PlanDay(day: 21, bookId: 'PSA', chapter: 100, title: 'Psalm 100'),
        PlanDay(day: 22, bookId: 'PSA', chapter: 103, title: 'Psalm 103'),
        PlanDay(day: 23, bookId: 'PSA', chapter: 119, title: 'Psalm 119'),
        PlanDay(day: 24, bookId: 'PSA', chapter: 121, title: 'Psalm 121'),
        PlanDay(day: 25, bookId: 'PSA', chapter: 127, title: 'Psalm 127'),
        PlanDay(day: 26, bookId: 'PSA', chapter: 130, title: 'Psalm 130'),
        PlanDay(day: 27, bookId: 'PSA', chapter: 139, title: 'Psalm 139'),
        PlanDay(day: 28, bookId: 'PSA', chapter: 145, title: 'Psalm 145'),
        PlanDay(day: 29, bookId: 'PSA', chapter: 146, title: 'Psalm 146'),
        PlanDay(day: 30, bookId: 'PSA', chapter: 150, title: 'Psalm 150'),
      ],
    ),
    ReadingPlan(
      id: 'gospels_28',
      title: 'Walk with Jesus',
      subtitle: '28 days · Gospel highlights',
      days: [
        PlanDay(day: 1, bookId: 'MAT', chapter: 1, title: 'Matthew 1'),
        PlanDay(day: 2, bookId: 'MAT', chapter: 5, title: 'Matthew 5'),
        PlanDay(day: 3, bookId: 'MAT', chapter: 6, title: 'Matthew 6'),
        PlanDay(day: 4, bookId: 'MAT', chapter: 7, title: 'Matthew 7'),
        PlanDay(day: 5, bookId: 'MAT', chapter: 13, title: 'Matthew 13'),
        PlanDay(day: 6, bookId: 'MAT', chapter: 28, title: 'Matthew 28'),
        PlanDay(day: 7, bookId: 'MRK', chapter: 1, title: 'Mark 1'),
        PlanDay(day: 8, bookId: 'MRK', chapter: 4, title: 'Mark 4'),
        PlanDay(day: 9, bookId: 'MRK', chapter: 5, title: 'Mark 5'),
        PlanDay(day: 10, bookId: 'MRK', chapter: 10, title: 'Mark 10'),
        PlanDay(day: 11, bookId: 'MRK', chapter: 15, title: 'Mark 15'),
        PlanDay(day: 12, bookId: 'MRK', chapter: 16, title: 'Mark 16'),
        PlanDay(day: 13, bookId: 'LUK', chapter: 1, title: 'Luke 1'),
        PlanDay(day: 14, bookId: 'LUK', chapter: 2, title: 'Luke 2'),
        PlanDay(day: 15, bookId: 'LUK', chapter: 4, title: 'Luke 4'),
        PlanDay(day: 16, bookId: 'LUK', chapter: 10, title: 'Luke 10'),
        PlanDay(day: 17, bookId: 'LUK', chapter: 15, title: 'Luke 15'),
        PlanDay(day: 18, bookId: 'LUK', chapter: 24, title: 'Luke 24'),
        PlanDay(day: 19, bookId: 'JHN', chapter: 1, title: 'John 1'),
        PlanDay(day: 20, bookId: 'JHN', chapter: 3, title: 'John 3'),
        PlanDay(day: 21, bookId: 'JHN', chapter: 10, title: 'John 10'),
        PlanDay(day: 22, bookId: 'JHN', chapter: 11, title: 'John 11'),
        PlanDay(day: 23, bookId: 'JHN', chapter: 14, title: 'John 14'),
        PlanDay(day: 24, bookId: 'JHN', chapter: 15, title: 'John 15'),
        PlanDay(day: 25, bookId: 'JHN', chapter: 17, title: 'John 17'),
        PlanDay(day: 26, bookId: 'JHN', chapter: 19, title: 'John 19'),
        PlanDay(day: 27, bookId: 'JHN', chapter: 20, title: 'John 20'),
        PlanDay(day: 28, bookId: 'JHN', chapter: 21, title: 'John 21'),
      ],
    ),
  ];

  static ReadingPlan? byId(String? id) {
    if (id == null) return null;
    for (final plan in all) {
      if (plan.id == id) return plan;
    }
    return null;
  }
}
