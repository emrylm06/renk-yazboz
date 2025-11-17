import 'package:flutter/material.dart';

void main() {
  runApp(const RenkYazbozApp());
}

class RenkYazbozApp extends StatelessWidget {
  const RenkYazbozApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Renk Yazboz',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const RenkYazbozGame(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Player {
  String name;
  List<int?> scores;
  List<int> indicators;
  int total;

  Player({
    required this.name,
    required this.scores,
    required this.indicators,
    this.total = 0,
  });

  Player copyWith({
    String? name,
    List<int?>? scores,
    List<int>? indicators,
    int? total,
  }) {
    return Player(
      name: name ?? this.name,
      scores: scores ?? List.from(this.scores),
      indicators: indicators ?? List.from(this.indicators),
      total: total ?? this.total,
    );
  }
}

class RenkYazbozGame extends StatefulWidget {
  const RenkYazbozGame({super.key});

  @override
  State<RenkYazbozGame> createState() => _RenkYazbozGameState();
}

class _RenkYazbozGameState extends State<RenkYazbozGame> {
  List<Player> players = [
    Player(name: '1. OYUNCU', scores: List.filled(11, null), indicators: []),
    Player(name: '2. OYUNCU', scores: List.filled(11, null), indicators: []),
    Player(name: '3. OYUNCU', scores: List.filled(11, null), indicators: []),
    Player(name: '4. OYUNCU', scores: List.filled(11, null), indicators: []),
  ];

  bool showIndicatorModal = false;
  bool showScoreModal = false;
  bool showGameOver = false;
  bool showSettingsModal = false;
  bool gameFinished = false;
  int? selectedPlayer;
  int? selectedRound;
  String inputScore = '';

  // Ayarlar için yeni değişkenler
  int roundCount = 11;
  final List<TextEditingController> playerNameControllers = [
    TextEditingController(text: '1. OYUNCU'),
    TextEditingController(text: '2. OYUNCU'),
    TextEditingController(text: '3. OYUNCU'),
    TextEditingController(text: '4. OYUNCU'),
  ];
  final TextEditingController roundController = TextEditingController(text: '11');

  @override
  void initState() {
    super.initState();
    roundController.text = roundCount.toString();
  }

  void addIndicator(int playerIndex, int value) {
    setState(() {
      players[playerIndex].indicators.add(-value);
      _updatePlayerTotal(playerIndex);
    });
  }

  void removeIndicator(int playerIndex, int indicatorIndex) {
    setState(() {
      players[playerIndex].indicators.removeAt(indicatorIndex);
      _updatePlayerTotal(playerIndex);
    });
  }

  void _updatePlayerTotal(int playerIndex) {
    int total = players[playerIndex].scores
        .where((score) => score != null)
        .fold(0, (sum, score) => sum + score!);
    setState(() {
      players[playerIndex] = players[playerIndex].copyWith(total: total);
    });
  }

  int getTotalIndicator(int playerIndex) {
    return players[playerIndex].indicators.fold(0, (sum, indicator) => sum + indicator);
  }

  int getRemainingPoints(int playerIndex) {
    return players[playerIndex].total + getTotalIndicator(playerIndex);
  }

  void calculateScore(int multiplier, {bool isDirectPlus = false}) {
    if (selectedPlayer == null || selectedRound == null) return;

    int finalScore;

    if (isDirectPlus) {
      finalScore = multiplier; // Artı puan olarak değiştirildi
    } else {
      int score = int.tryParse(inputScore) ?? 0;

      if (score == 0) {
        finalScore = -(multiplier * 10);
      } else {
        finalScore = score * multiplier;
      }
    }

    setState(() {
      List<int?> newScores = List.from(players[selectedPlayer!].scores);
      newScores[selectedRound!] = finalScore;

      players[selectedPlayer!] = players[selectedPlayer!].copyWith(scores: newScores);
      _updatePlayerTotal(selectedPlayer!);

      inputScore = '';
      showScoreModal = false;
      selectedPlayer = null;
      selectedRound = null;
    });
  }

  List<Player> getSortedPlayers() {
    List<Player> sorted = List.from(players);
    sorted.sort((a, b) {
      int totalA = a.total + getTotalIndicator(players.indexOf(a));
      int totalB = b.total + getTotalIndicator(players.indexOf(b));
      return totalA.compareTo(totalB);
    });
    return sorted;
  }

  void startNewGame() {
    setState(() {
      players = [
        Player(name: playerNameControllers[0].text, scores: List.filled(roundCount, null), indicators: []),
        Player(name: playerNameControllers[1].text, scores: List.filled(roundCount, null), indicators: []),
        Player(name: playerNameControllers[2].text, scores: List.filled(roundCount, null), indicators: []),
        Player(name: playerNameControllers[3].text, scores: List.filled(roundCount, null), indicators: []),
      ];
      gameFinished = false;
      showGameOver = false;
      inputScore = '';
    });
  }

  void applySettings() {
    int newRoundCount = int.tryParse(roundController.text) ?? 11;
    if (newRoundCount < 1) newRoundCount = 1;
    if (newRoundCount > 20) newRoundCount = 20;

    setState(() {
      roundCount = newRoundCount;

      // Oyuncu isimlerini BÜYÜK HARF olarak güncelle
      for (int i = 0; i < players.length; i++) {
        String newName = playerNameControllers[i].text.toUpperCase();
        players[i] = players[i].copyWith(name: newName);
        playerNameControllers[i].text = newName; // Controller'ı da güncelle
      }

      // Skor listelerini yeni round sayısına göre güncelle
      for (int i = 0; i < players.length; i++) {
        List<int?> newScores = List.filled(roundCount, null);
        for (int j = 0; j < players[i].scores.length && j < roundCount; j++) {
          newScores[j] = players[i].scores[j];
        }
        players[i] = players[i].copyWith(scores: newScores);
      }

      showSettingsModal = false;
    });
  }

  void _showIndicatorModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildIndicatorModal();
      },
    );
  }

  void _showScoreModal(int playerIndex, int roundIndex) {
    setState(() {
      selectedPlayer = playerIndex;
      selectedRound = roundIndex;
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildScoreModal();
      },
    );
  }

  void _showGameOverModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildGameOverModal(getSortedPlayers());
      },
    );
  }

  void _showSettingsModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildSettingsModal();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf8f9fa),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER - YENİ TASARIM
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              color: const Color(0xFF2c3e50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // SOL TARAF - Başlık ve Yazar
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'RENK YAZBOZ',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'by Emrah Yılmazer',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.7),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ORTA - Gösterge Butonu
                  ElevatedButton(
                    onPressed: _showIndicatorModal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFe74c3c),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    ),
                    child: const Text(
                      'GÖSTERGE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  // SAĞ TARAF - Ayarlar Butonu
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _showSettingsModal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3498db),
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    ),
                    child: const Icon(
                      Icons.settings,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // GÖSTERGELER BÖLÜMÜ - SADECE SİLME ÖZELLİĞİ
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              color: const Color(0xFF34495e),
              child: Column(
                children: [
                  const Text(
                    'GÖSTERGELER',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: players.asMap().entries.map((entry) {
                      int index = entry.key;
                      Player player = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 80,
                              child: Text(
                                player.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: player.indicators.isNotEmpty
                                      ? player.indicators.asMap().entries.map((indicatorEntry) {
                                    int indicatorIndex = indicatorEntry.key;
                                    int indicator = indicatorEntry.value;
                                    return Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFe74c3c),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            '$indicator',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          GestureDetector(
                                            onTap: () => removeIndicator(index, indicatorIndex),
                                            child: const Icon(Icons.close, size: 12, color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList()
                                      : [
                                    // Boş gösterge
                                    Container(),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // ANA TABLO - GRI ÇİZGİLİ
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Sütun Başlıkları
                    Container(
                      height: 35,
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            color: const Color(0xFFecf0f1),
                            alignment: Alignment.center,
                          ),
                          ...players.map((player) => Expanded(
                            child: Container(
                              color: const Color(0xFF3498db),
                              alignment: Alignment.center,
                              child: Text(
                                player.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )),
                        ],
                      ),
                    ),

                    // Skor Satırları - Dinamik round sayısı + GRI ÇİZGİLER
                    ...List.generate(roundCount, (roundIndex) => Container(
                      height: 35,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade300),
                          right: BorderSide(color: Colors.grey.shade300), // Dikey çizgiler
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            color: const Color(0xFFbdc3c7),
                            alignment: Alignment.center,
                            child: Text(
                              '${roundIndex + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          ...players.asMap().entries.map((entry) {
                            int playerIndex = entry.key;
                            Player player = entry.value;
                            return Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    right: BorderSide(color: Colors.grey.shade300), // Sütun çizgileri
                                  ),
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    if (!gameFinished) {
                                      _showScoreModal(playerIndex, roundIndex);
                                    }
                                  },
                                  child: Container(
                                    color: Colors.white,
                                    alignment: Alignment.center,
                                    child: Text(
                                      player.scores.length > roundIndex && player.scores[roundIndex] != null
                                          ? '${player.scores[roundIndex]}'
                                          : '',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    )),

                    // ALT BİLGİ ALANI
                    Container(
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFecf0f1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          // TOPLAM PUAN
                          _buildInfoRow('TOPLAM PUAN', players.map((p) => p.total).toList()),

                          // GÖSTERGE
                          _buildInfoRow('GÖSTERGE', List.generate(4, (i) => getTotalIndicator(i))),

                          // KALAN PUAN
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF27ae60),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: _buildInfoRow('KALAN PUAN', List.generate(4, (i) => getRemainingPoints(i))),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // OYUN BİTTİ / YENİ OYUN BUTONU
            Container(
              margin: const EdgeInsets.all(10),
              child: !gameFinished
                  ? ElevatedButton(
                onPressed: _showGameOverModal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFe74c3c),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'OYUN BİTTİ',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              )
                  : ElevatedButton(
                onPressed: startNewGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF27ae60),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'YENİ OYUN',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, List<int> values) {
    return Container(
      height: 30,
      child: Row(
        children: [
          Container(
            width: 80,
            alignment: Alignment.center,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2c3e50),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          ...values.map((value) => Expanded(
            child: Container(
              alignment: Alignment.center,
              child: Text(
                '$value',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2c3e50),
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildIndicatorModal() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFf5f5f5), // AÇIK GRİ
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'GÖSTERGE SEÇ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2c3e50),
              ),
            ),
            const SizedBox(height: 20),

            ...players.asMap().entries.map((entry) {
              int playerIndex = entry.key;
              Player player = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFe0e0e0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              player.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2c3e50),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // BÜYÜK GÖSTERGE BUTONLARI - TIKLANDIĞINDA OTOMATİK EKLE
                    SizedBox(
                      height: 70,
                      child: Row(
                        children: [30, 40, 50, 60].asMap().entries.map((valueEntry) {
                          int value = valueEntry.value;
                          int colorIndex = valueEntry.key;
                          List<Color> colors = [
                            const Color(0xFFFF6B6B),
                            const Color(0xFF4ECDC4),
                            const Color(0xFF45B7D1),
                            const Color(0xFF96CEB4),
                          ];

                          return Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              child: ElevatedButton(
                                onPressed: () {
                                  addIndicator(playerIndex, value);
                                  Navigator.of(context).pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colors[colorIndex],
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 4,
                                ),
                                child: Text(
                                  '$value',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 20),
            // KIRMIZI GERİ BUTONU
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFe74c3c),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 5,
              ),
              child: const Text(
                'GERİ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsModal() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFf5f5f5), // AÇIK GRİ
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'AYARLAR',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2c3e50),
              ),
            ),
            const SizedBox(height: 20),

            // Parti Oyun Sayısı
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFe8e8e8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Text(
                    'Parti Oyun Sayısı:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2c3e50),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: roundController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Color(0xFF2c3e50)),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF2c3e50)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF2c3e50)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF3498db)),
                        ),
                        hintText: '11',
                        hintStyle: TextStyle(color: Colors.grey),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              'Oyuncu İsimleri:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2c3e50),
              ),
            ),
            const SizedBox(height: 10),

            // Oyuncu İsimleri
            ...players.asMap().entries.map((entry) {
              int index = entry.key;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFe8e8e8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${index + 1}. Oyuncu:',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2c3e50),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: playerNameControllers[index],
                          style: const TextStyle(color: Color(0xFF2c3e50)),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF2c3e50)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF2c3e50)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF3498db)),
                            ),
                            hintText: 'OYUNCU İSMİ',
                            hintStyle: TextStyle(color: Colors.grey),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          ),
                          onChanged: (value) {
                            // Otomatik büyük harf yap
                            if (value != value.toUpperCase()) {
                              playerNameControllers[index].value = TextEditingValue(
                                text: value.toUpperCase(),
                                selection: playerNameControllers[index].selection,
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 20),
            const Text(
              'ⓘ Ayarları kaydettiğinide değişiklikler otomatik olarak yansıyacaktır.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFFe74c3c),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                // YEŞİL KAYDET BUTONU
                Expanded(
                  child: ElevatedButton(
                    onPressed: applySettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF27ae60),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      'KAYDET',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // KIRMIZI GERİ BUTONU
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFe74c3c),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      'GERİ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreModal() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFf5f5f5), // AÇIK GRİ
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${selectedPlayer != null ? players[selectedPlayer!].name : ""} - Tur ${selectedRound != null ? selectedRound! + 1 : ""}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2c3e50),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: TextEditingController(text: inputScore),
              onChanged: (value) => setState(() => inputScore = value),
              style: const TextStyle(color: Color(0xFF2c3e50), fontSize: 16),
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF2c3e50)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF2c3e50)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF3498db)),
                ),
                hintText: 'Puan yaz...',
                hintStyle: TextStyle(color: Colors.grey),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),
            const Text(
              'ⓘ Değer girildikten sonra SAYI KATI seçimi yapınız. Girilen değer seçilen kat ile çarpılarak sonuç aktarılacaktır.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF7f8c8d),
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'ⓘ Biten oyuncu için 0 (sıfır) girilerek SAYI KATI seçimi yapıldığında, seçilen katx10 eksi puan sonuç aktarılacaktır.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF7f8c8d),
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'ⓘ Oyun içerisinde altındaki oyuncuya okey atan oyuncu için oyun sonunda toplam puanına 100 puan eklenerek puan alanına giriş yapılmalı ve SAYI KATI seçilerek giriş yapılmalıdır.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF7f8c8d),  // GRİ (üstteki uyarılarla aynı)
                fontStyle: FontStyle.italic, // İTALİK
                // fontWeight: FontWeight.bold, // BU SATIRI KALDIRIYORUZ (kalın yazıyı kaldır)
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                // SAYI KATI SEÇİMİ - Başlık değiştirildi
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'SAYI KATI',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2c3e50),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: [3, 4, 5, 6].map((multiplier) => Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ElevatedButton(
                            onPressed: () {
                              calculateScore(multiplier);
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3498db),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text('$multiplier KAT'),
                          ),
                        )).toList(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // CEZA PUANI - Artı puan olarak değiştirildi
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'CEZA PUANI',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2c3e50),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: [300, 400, 500, 600].map((value) => Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ElevatedButton(
                            onPressed: () {
                              calculateScore(value, isDirectPlus: true); // Artı puan olarak değiştirildi
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFe74c3c),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text('+$value'), // Artı işareti eklendi
                          ),
                        )).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFe74c3c),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'GERİ',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOverModal(List<Player> sortedPlayers) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🎊 OYUN BİTTİ 🎊',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFe74c3c),
              ),
            ),
            const SizedBox(height: 20),

            ...sortedPlayers.asMap().entries.map((entry) {
              int index = entry.key;
              Player player = entry.value;
              int totalScore = player.total + getTotalIndicator(players.indexOf(player));

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: index == 0 ? const Color(0xFFd5edda) : const Color(0xFFecf0f1),
                  borderRadius: BorderRadius.circular(8),
                  border: index == 0 ? Border.all(color: const Color(0xFF28a745), width: 2) : null,
                ),
                child: Row(
                  children: [
                    Text(
                      '${index + 1}.',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        player.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '$totalScore',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF2c3e50),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 15),
            Text(
              '🏆 KAZANAN: ${sortedPlayers.isNotEmpty ? sortedPlayers[0].name : ""} 🏆',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFf39c12),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3498db),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('TAMAM'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      startNewGame();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF27ae60),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('YENİ OYUN'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}