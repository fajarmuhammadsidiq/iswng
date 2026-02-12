import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../domain/memory_game_engine.dart';
import '../controllers/home_controller.dart';

// =============== DATA ISLAMI ===============
final Map<String, List<String>> islamicCategories = {
  'Khalifah Rasyidin': ['أبو بكر', 'عمر', 'عثمان', 'علي'],
  'Rukun Iman': ['الله', 'الملائكة', 'الكتب', 'الرسل', 'اليوم الآخر', 'القدر'],
  'Asmaul Husna': [
    'الرحمن',
    'الرحيم',
    'الملك',
    'القدوس',
    'السلام',
    'المؤمن',
    'المهيمن',
    'العزيز'
  ],
  'Surat Pendek': ['الإخلاص', 'الفلق', 'الناس', 'الكوثر', 'النصر', 'العصر'],
  'Nabi & Rasul': ['آدم', 'نوح', 'إبراهيم', 'موسى', 'عيسى', 'محمد'],
  'Rukun Islam': ['الشهادة', 'الصلاة', 'الزكاة', 'الصوم', 'الحج'],
};

// =============== VIEW ===============
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomeView'),
        centerTitle: true,
      ),
      body: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CategorySelectionScreen()),
            );
          },
          child: const Text(
            'HomeView is working',
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}

// =============== PILIH KATEGORI ===============
class CategorySelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pilih Topik'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: islamicCategories.length,
          itemBuilder: (context, index) {
            String category = islamicCategories.keys.elementAt(index);
            return _CategoryCard(
              title: category,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MemoryGameScreen(category: category),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _CategoryCard({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

// =============== GAME SCREEN ===============
class MemoryGameScreen extends StatefulWidget {
  final String category;

  const MemoryGameScreen({required this.category});

  @override
  _MemoryGameScreenState createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  late final MemoryGameEngine _engine;

  List<MemoryCard> get cards => _engine.cards;
  int get attempts => _engine.attempts;
  bool get isProcessing => _engine.isProcessing;
  int get lives => _engine.lives;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    _engine = MemoryGameEngine(items: islamicCategories[widget.category]!);
  }

  void _flipCard(int index) {
    final selection = _engine.flipCard(index);
    if (!selection.changed) {
      return;
    }

    setState(() {});

    if (!selection.requiresResolution) {
      return;
    }

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) {
        return;
      }
      final resolution = _engine.resolveTurn();
      setState(() {});

      // Cek game over
      if (resolution.gameOver) {
        _showGameOver();
        return;
      }

      // Cek menang
      if (resolution.won) {
        _showWinDialog();
      }
    });
  }

  void _showGameOver() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Game Over 💔'),
        content: Text('Nyawa kamu habis!\nIngin coba lagi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              // 🔜 Nanti: showRewardedAd() → dapat nyawa
              setState(() {
                _engine.reset();
              });
            },
            child: Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  void _showWinDialog() {
    // 🔜 Nanti: showInterstitialAd()
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Masya Allah! 🌟'),
        content: Text('Kamu berhasil!\nPercobaan: $attempts'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop(); // kembali ke menu
            },
            child: Text('Kembali'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ❤️ Nyawa
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Percobaan: $attempts',
                  style: TextStyle(fontSize: 18),
                ),
                Row(
                  children: List.generate(3, (i) {
                    return Icon(
                      Icons.favorite,
                      color: i < lives ? Colors.red : Colors.grey,
                      size: 24,
                    );
                  }),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cards.length <= 8
                      ? 4
                      : cards.length <= 12
                          ? 4
                          : cards.length <= 16
                              ? 4
                              : 5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  return MatchableCard(
                    card: cards[index],
                    onTap: () => _flipCard(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============== WIDGET KARTU (SAMA SEPERTI SEBELUMNYA) ===============
class MatchableCard extends StatefulWidget {
  final MemoryCard card;
  final VoidCallback onTap;

  const MatchableCard({Key? key, required this.card, required this.onTap})
      : super(key: key);

  @override
  _MatchableCardState createState() => _MatchableCardState();
}

class _MatchableCardState extends State<MatchableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _shouldAnimate = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
        CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut));
  }

  @override
  void didUpdateWidget(covariant MatchableCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.card.isMatched && widget.card.isMatched) {
      _shouldAnimate = true;
      _scaleController.forward().then((_) {
        _scaleController.reverse();
      });
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleController,
        builder: (context, child) {
          return Transform.scale(
            scale: _shouldAnimate ? _scaleAnimation.value : 1.0,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: widget.card.isFlipped || widget.card.isMatched
                    ? (_shouldAnimate && widget.card.isMatched
                        ? Colors.green.shade100
                        : Colors.white)
                    : Colors.green.shade200,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(blurRadius: 4, color: Colors.black12),
                ],
              ),
              child: Center(
                child: (widget.card.isFlipped || widget.card.isMatched)
                    ? Text(
                        widget.card.text,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: widget.card.text.length > 12 ? 20 : 28,
                            fontFamily: 'Tajawal'),
                      )
                    : Icon(
                        Icons.mosque,
                        size: 28,
                        color: Colors.white,
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
