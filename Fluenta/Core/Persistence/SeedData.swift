import Foundation

/// Yerel içerik. UUID'ler SABİT — aksi halde her açılışta kelime/ilerleme kaybolur.
enum SeedData {

    private static func uid(_ group: Int, _ n: Int) -> UUID {
        UUID(uuidString: String(format: "%08X-0000-4000-8000-%012X", group, n))!
    }
    private static func w(_ n: Int) -> UUID { uid(1, n) }   // words
    private static func p(_ n: Int) -> UUID { uid(2, n) }   // passages
    private static func q(_ n: Int) -> UUID { uid(3, n) }   // questions
    private static func pl(_ n: Int) -> UUID { uid(4, n) }  // placement
    private static func wr(_ n: Int) -> UUID { uid(5, n) }  // writing
    private static func sp(_ n: Int) -> UUID { uid(6, n) }  // speaking
    private static func bd(_ n: Int) -> UUID { uid(7, n) }  // badges

    static func generate() -> ContentBundle {
        ContentBundle(words: words(), passages: passages(), questions: questions(),
                      placementQuestions: placement(), writingPrompts: writing(),
                      speakingPrompts: speaking(), badges: badges())
    }

    // MARK: - Kelimeler

    private static func words() -> [Word] {
        var n = 0
        func mk(_ lvl: CEFRLevel, _ head: String, _ pos: String, _ ph: String,
                _ en: String, _ tr: String, _ ex: String) -> Word {
            n += 1
            return Word(id: w(n), level: lvl, headword: head, partOfSpeech: pos, phonetic: ph,
                        meaningEn: en, meaningTr: tr, example: ex, tags: nil)
        }
        return [
            // A1
            mk(.a1, "family", "noun", "/ˈfæməli/", "a group of related people", "aile", "My family lives in a small house."),
            mk(.a1, "teacher", "noun", "/ˈtiːtʃər/", "a person who teaches", "öğretmen", "My mother is a teacher."),
            mk(.a1, "garden", "noun", "/ˈɡɑːrdn/", "a piece of land for plants", "bahçe", "We have a garden behind the house."),
            mk(.a1, "breakfast", "noun", "/ˈbrekfəst/", "the first meal of the day", "kahvaltı", "I eat breakfast at seven."),
            mk(.a1, "friend", "noun", "/frend/", "a person you like and know well", "arkadaş", "I play with my friends."),
            mk(.a1, "morning", "noun", "/ˈmɔːrnɪŋ/", "the early part of the day", "sabah", "I wake up early in the morning."),
            // A2
            mk(.a2, "comfortable", "adjective", "/ˈkʌmftəbl/", "giving physical ease", "rahat", "This chair is very comfortable."),
            mk(.a2, "market", "noun", "/ˈmɑːrkɪt/", "a place where goods are sold", "pazar", "She goes to the market every Sunday."),
            mk(.a2, "healthy", "adjective", "/ˈhelθi/", "in good physical condition", "sağlıklı", "Walking keeps you healthy."),
            mk(.a2, "arrive", "verb", "/əˈraɪv/", "to reach a place", "varmak", "The train arrives at nine."),
            mk(.a2, "expensive", "adjective", "/ɪkˈspensɪv/", "costing a lot of money", "pahalı", "That phone is too expensive."),
            mk(.a2, "borrow", "verb", "/ˈbɑːroʊ/", "to take and use temporarily", "ödünç almak", "Can I borrow your pen?"),
            // B1
            mk(.b1, "persuade", "verb", "/pərˈsweɪd/", "to make someone agree", "ikna etmek", "She persuaded him to stay."),
            mk(.b1, "exercise", "noun", "/ˈeksərsaɪz/", "physical activity for health", "egzersiz", "Regular exercise improves health."),
            mk(.b1, "circulation", "noun", "/ˌsɜːrkjəˈleɪʃn/", "movement of blood in the body", "dolaşım", "Exercise improves circulation."),
            mk(.b1, "anxiety", "noun", "/æŋˈzaɪəti/", "a feeling of worry", "kaygı", "Exercise reduces anxiety."),
            mk(.b1, "recommend", "verb", "/ˌrekəˈmend/", "to advise something", "tavsiye etmek", "Experts recommend thirty minutes of activity."),
            mk(.b1, "moderate", "adjective", "/ˈmɑːdərət/", "average in intensity", "orta düzeyde", "Try moderate activity most days."),
            // B2
            mk(.b2, "resilience", "noun", "/rɪˈzɪliəns/", "the ability to recover quickly", "dayanıklılık", "Her resilience helped her succeed."),
            mk(.b2, "commute", "noun", "/kəˈmjuːt/", "a regular journey to work", "işe gidiş yolculuğu", "My commute takes an hour."),
            mk(.b2, "sustainable", "adjective", "/səˈsteɪnəbl/", "able to continue over time", "sürdürülebilir", "Cities need sustainable transport."),
            mk(.b2, "reduce", "verb", "/rɪˈduːs/", "to make smaller in amount", "azaltmak", "Cycling reduces air pollution."),
            mk(.b2, "congestion", "noun", "/kənˈdʒestʃən/", "the state of being overcrowded", "sıkışıklık", "Traffic congestion wastes time."),
            mk(.b2, "infrastructure", "noun", "/ˈɪnfrəstrʌktʃər/", "basic systems of a country", "altyapı", "Good infrastructure supports growth."),
            // C1
            mk(.c1, "ubiquitous", "adjective", "/juːˈbɪkwɪtəs/", "present everywhere", "her yerde bulunan", "Smartphones are ubiquitous today."),
            mk(.c1, "ratify", "verb", "/ˈrætɪfaɪ/", "to approve formally", "onaylamak", "The board ratified the decision."),
            mk(.c1, "compelling", "adjective", "/kəmˈpelɪŋ/", "convincing and powerful", "ikna edici", "She made a compelling argument."),
            mk(.c1, "mitigate", "verb", "/ˈmɪtɪɡeɪt/", "to make less severe", "hafifletmek", "Policies aim to mitigate the damage."),
            mk(.c1, "discrepancy", "noun", "/dɪsˈkrepənsi/", "a lack of agreement between facts", "tutarsızlık", "There is a discrepancy in the data."),
            // C2
            mk(.c2, "esoteric", "adjective", "/ˌesəˈterɪk/", "understood by only a few", "anlaşılması güç", "The lecture was rather esoteric."),
            mk(.c2, "paradigm", "noun", "/ˈpærədaɪm/", "a typical model or pattern", "paradigma", "The discovery shifted the paradigm."),
            mk(.c2, "inexorable", "adjective", "/ɪnˈeksərəbl/", "impossible to stop", "önüne geçilemez", "The inexorable rise of automation continues.")
        ]
    }

    // MARK: - Pasajlar

    private static func passages() -> [Passage] {
        [
            Passage(id: p(1), level: .a1, skill: .reading, examType: .general, title: "My Family",
                    body: "I have a small family. There are four people in my family: my mother, my father, my sister and me. My mother is a teacher and she works at a school near our house. My father is a doctor. My sister is a student. We live in a house with a small garden. Every morning we have breakfast together before we leave.",
                    wordCount: 66, timeLimitSeconds: 240),
            Passage(id: p(2), level: .b1, skill: .reading, examType: .general, title: "The Benefits of Exercise",
                    body: "Regular exercise is essential for maintaining good health. It strengthens the heart, improves circulation and helps people control their weight. Exercise also reduces stress and anxiety, so many people feel calmer and more energetic after a workout. Experts recommend at least thirty minutes of moderate activity on most days of the week. Importantly, the activity does not have to happen in a gym: walking to work, climbing stairs or cycling to the shops all count.",
                    wordCount: 78, timeLimitSeconds: 360),
            Passage(id: p(3), level: .b2, skill: .reading, examType: .ielts, title: "Cities and the Bicycle",
                    body: "Over the past two decades, many European cities have rebuilt their streets around the bicycle. The reasoning is practical rather than romantic. A bicycle takes up a fraction of the space of a car, produces no emissions, and costs the city very little to accommodate. Where protected lanes have been built, cycling rates have risen sharply and traffic congestion has fallen. Critics argue that the climate and the geography of some cities make cycling unrealistic, and that investment would be better spent on public transport. Supporters answer that the two are not in competition: a sustainable transport network needs both, and the bicycle is simply the cheapest piece of infrastructure a city can buy.",
                    wordCount: 116, timeLimitSeconds: 600),

            Passage(id: p(4), level: .a2, skill: .listening, examType: .general, title: "At the Train Station",
                    body: "Good afternoon. The train to Manchester will arrive at platform three in ten minutes. Passengers travelling to Liverpool should go to platform seven instead. Tickets can be bought at the machines near the main entrance. Please keep your luggage with you at all times. Thank you.",
                    wordCount: 47, timeLimitSeconds: 240),
            Passage(id: p(5), level: .b1, skill: .listening, examType: .general, title: "A Message from a Friend",
                    body: "Hi, it's Ellie. I'm calling about Saturday. The cinema was fully booked, so I bought tickets for the eight o'clock show on Sunday instead. If that doesn't work for you, we can just meet for coffee near the market. Let me know before Friday evening. Bye.",
                    wordCount: 47, timeLimitSeconds: 240)
        ]
    }

    // MARK: - Sorular

    private static func questions() -> [Question] {
        var n = 0
        func mk(_ pid: UUID?, _ lvl: CEFRLevel, _ skill: Skill, _ prompt: String,
                _ opts: [String], _ correct: Int, _ exp: String, _ diff: Int) -> Question {
            n += 1
            return Question(id: q(n), passageId: pid, level: lvl, skill: skill, examType: .general,
                            kind: .mcq, prompt: prompt, options: opts, correctIndex: correct,
                            explanation: exp, difficulty: diff)
        }
        return [
            // p1 - reading A1
            mk(p(1), .a1, .reading, "How many people are in the family?",
               ["Three", "Four", "Five", "Six"], 1,
               "Metin ailede dört kişi olduğunu söylüyor.", 1),
            mk(p(1), .a1, .reading, "What is the mother's job?",
               ["Doctor", "Student", "Teacher", "Nurse"], 2,
               "Anne bir öğretmen ve okulda çalışıyor.", 1),
            mk(p(1), .a1, .reading, "What do they do every morning?",
               ["Go to the garden", "Have breakfast together", "Visit the school", "Watch television"], 1,
               "Her sabah birlikte kahvaltı ediyorlar.", 1),

            // p2 - reading B1
            mk(p(2), .b1, .reading, "According to the text, exercise helps to:",
               ["Increase anxiety", "Control weight", "Weaken the heart", "Reduce energy"], 1,
               "Metin egzersizin kilo kontrolüne yardım ettiğini söylüyor.", 2),
            mk(p(2), .b1, .reading, "How much moderate activity do experts recommend?",
               ["10 minutes daily", "At least 30 minutes on most days", "Two hours daily", "Only at weekends"], 1,
               "Uzmanlar çoğu gün en az 30 dakika öneriyor.", 2),
            mk(p(2), .b1, .reading, "The writer suggests that exercise:",
               ["Must happen in a gym", "Is only for athletes", "Can be part of daily life", "Is dangerous for the heart"], 2,
               "Yürümek, merdiven çıkmak da sayılıyor — spor salonu şart değil.", 3),

            // p3 - reading B2 / IELTS
            mk(p(3), .b2, .reading, "Why do cities favour the bicycle, according to the text?",
               ["It is romantic", "It is cheap and space-efficient", "It is faster than any car", "It replaces public transport"], 1,
               "Neden pratik: az yer kaplar, ucuzdur, emisyon üretmez.", 3),
            mk(p(3), .b2, .reading, "What do critics argue?",
               ["Cycling causes congestion", "Climate and geography limit cycling", "Bicycles are expensive", "Lanes reduce cycling rates"], 1,
               "Eleştirmenler iklim ve coğrafyanın bisikleti gerçekçi kılmadığını söylüyor.", 4),
            mk(p(3), .b2, .reading, "Supporters believe that cycling and public transport are:",
               ["In competition", "Complementary", "Equally expensive", "Unnecessary"], 1,
               "Destekçilere göre ikisi rakip değil, birbirini tamamlıyor.", 4),

            // p4 - listening A2
            mk(p(4), .a2, .listening, "Which platform is the Manchester train arriving at?",
               ["Platform three", "Platform seven", "Platform ten", "Platform one"], 0,
               "Manchester treni üç numaralı perona geliyor.", 1),
            mk(p(4), .a2, .listening, "Where can passengers buy tickets?",
               ["On the train", "At the machines near the entrance", "At platform seven", "From the driver"], 1,
               "Biletler ana girişin yanındaki makinelerden alınır.", 2),

            // p5 - listening B1
            mk(p(5), .b1, .listening, "Why did Ellie change the plan?",
               ["She was ill", "The cinema was fully booked", "The film was cancelled", "She lost the tickets"], 1,
               "Sinema tamamen doluydu.", 2),
            mk(p(5), .b1, .listening, "What is the alternative Ellie offers?",
               ["Coffee near the market", "Dinner at her house", "A walk in the park", "Another cinema"], 0,
               "Alternatif olarak pazarın yanında kahve içmeyi öneriyor.", 2)
        ]
    }

    // MARK: - Seviye tespiti (her seviyeden 3 soru)

    private static func placement() -> [PlacementQuestion] {
        var n = 0
        func mk(_ lvl: CEFRLevel, _ skill: Skill, _ prompt: String, _ opts: [String], _ c: Int, _ d: Int) -> PlacementQuestion {
            n += 1
            return PlacementQuestion(id: pl(n), level: lvl, skill: skill, prompt: prompt,
                                     options: opts, correctIndex: c, difficulty: d)
        }
        return [
            mk(.a1, .grammar, "I ____ a student.", ["am", "is", "are", "be"], 0, 1),
            mk(.a1, .grammar, "She ____ got two brothers.", ["have", "has", "haves", "having"], 1, 1),
            mk(.a1, .vocabulary, "We eat breakfast in the ____.", ["night", "morning", "evening", "week"], 1, 1),

            mk(.a2, .grammar, "He ____ to the market every Sunday.", ["go", "goes", "going", "gone"], 1, 2),
            mk(.a2, .grammar, "Yesterday I ____ a great film.", ["see", "seen", "saw", "seeing"], 2, 2),
            mk(.a2, .vocabulary, "The opposite of 'hot' is ____.", ["warm", "cold", "cool", "boiling"], 1, 2),

            mk(.b1, .grammar, "If I ____ more time, I would travel more.", ["have", "had", "has", "having"], 1, 3),
            mk(.b1, .grammar, "She has lived here ____ 2019.", ["for", "since", "during", "from"], 1, 3),
            mk(.b1, .vocabulary, "He tried to ____ me to change my mind.", ["persuade", "prevent", "postpone", "permit"], 0, 3),

            mk(.b2, .grammar, "The report ____ by the team last week.", ["was written", "wrote", "has wrote", "is writing"], 0, 4),
            mk(.b2, .grammar, "I'd rather you ____ smoke in here.", ["don't", "didn't", "won't", "haven't"], 1, 4),
            mk(.b2, .vocabulary, "Cycling helps ____ traffic congestion.", ["reduce", "produce", "induce", "seduce"], 0, 4),

            mk(.c1, .grammar, "Rarely ____ such a compelling argument.", ["I have heard", "have I heard", "I heard have", "did I heard"], 1, 5),
            mk(.c1, .vocabulary, "The board finally ____ the agreement.", ["ratified", "rectified", "reduced", "refused"], 0, 5),
            mk(.c1, .vocabulary, "Smartphones have become ____ in modern life.", ["ubiquitous", "unanimous", "ambiguous", "anonymous"], 0, 5),

            mk(.c2, .vocabulary, "The discovery brought about a ____ shift in the field.", ["paradigm", "parameter", "paradox", "parallel"], 0, 5),
            mk(.c2, .vocabulary, "His argument was so ____ that few could follow it.", ["esoteric", "erratic", "eccentric", "erroneous"], 0, 5),
            mk(.c2, .grammar, "Had the committee acted sooner, the crisis ____ avoided.", ["would be", "would have been", "will be", "had been"], 1, 5)
        ]
    }

    // MARK: - Yazma / Konuşma / Rozet

    private static func writing() -> [WritingPrompt] {
        [
            WritingPrompt(id: wr(1), level: .a2, examType: .general, taskType: "Kısa paragraf",
                          prompt: "Describe your daily routine. What do you do in the morning, afternoon and evening?",
                          minWords: 60, timeLimitSeconds: 900),
            WritingPrompt(id: wr(2), level: .b1, examType: .general, taskType: "Açıklama",
                          prompt: "Describe your favourite place in your hometown and explain why you like it.",
                          minWords: 150, timeLimitSeconds: 1200),
            WritingPrompt(id: wr(3), level: .b2, examType: .ielts, taskType: "IELTS Task 2",
                          prompt: "Some people believe technology has made our lives easier. Others think it has made life more complicated. Discuss both views and give your own opinion.",
                          minWords: 250, timeLimitSeconds: 2400)
        ]
    }

    private static func speaking() -> [SpeakingPrompt] {
        [
            SpeakingPrompt(id: sp(1), level: .a1, examType: .general, kind: .teleprompter, title: "Daily Routine",
                           script: "I wake up at seven o'clock. I brush my teeth and eat breakfast. Then I go to school. After school I play with my friends. In the evening I read a book before I sleep.",
                           followUps: nil),
            SpeakingPrompt(id: sp(2), level: .b1, examType: .general, kind: .teleprompter, title: "Staying Healthy",
                           script: "Regular exercise is important for everyone. It makes the heart stronger and reduces stress. I try to walk for thirty minutes every day, and I take the stairs instead of the lift whenever I can.",
                           followUps: nil),
            SpeakingPrompt(id: sp(3), level: .b2, examType: .general, kind: .teleprompter, title: "City Transport",
                           script: "Many cities have decided to rebuild their streets around the bicycle, because a bicycle takes up very little space and produces no emissions. Where protected lanes exist, congestion has fallen and more people cycle to work.",
                           followUps: nil),
            SpeakingPrompt(id: sp(4), level: .b2, examType: .ielts, kind: .cueCard, title: "A Book You Recently Read",
                           script: "Describe a book you have recently read.\n\nYou should say:\n• what the book was about\n• when you read it\n• why you chose to read it\n\nand explain how you felt about the book.",
                           followUps: ["Do you prefer fiction or non-fiction?", "How have reading habits changed in your country?"])
        ]
    }

    private static func badges() -> [Badge] {
        [
            Badge(id: bd(1), code: "first_day", title: "İlk Adım", detail: "İlk çalışmanı tamamladın.", systemImage: "star.fill"),
            Badge(id: bd(2), code: "streak_7", title: "Kararlı", detail: "7 gün üst üste çalıştın.", systemImage: "flame.fill"),
            Badge(id: bd(3), code: "master_25", title: "Yükselen", detail: "25 kelimeyi ezberledin.", systemImage: "arrow.up.circle.fill"),
            Badge(id: bd(4), code: "master_100", title: "Kelime Ustası", detail: "100 kelimeyi ezberledin.", systemImage: "brain.head.profile"),
            Badge(id: bd(5), code: "comeback", title: "Hatadan Ustalığa", detail: "Yanlış yaptığın bir soruyu artık doğru yapıyorsun.", systemImage: "checkmark.seal.fill")
        ]
    }
}
