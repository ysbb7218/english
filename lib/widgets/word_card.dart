import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../models/word.dart';
import '../providers/app_provider.dart';

class WordCard extends StatefulWidget {
  final Word word;
  final VoidCallback onFavoriteToggle;

  const WordCard({Key? key, required this.word, required this.onFavoriteToggle})
    : super(key: key);

  @override
  _WordCardState createState() => _WordCardState();
}

class _WordCardState extends State<WordCard> {
  late FlutterTts flutterTts;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initTTS();
  }

  void _initTTS() {
    flutterTts = FlutterTts();
    flutterTts.setLanguage("en-US");
    flutterTts.setSpeechRate(0.5);
    flutterTts.setPitch(1.0);
    flutterTts.setVolume(1.0);

    flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() => _isSpeaking = false);
      }
    });

    flutterTts.setErrorHandler((msg) {
      if (mounted) {
        setState(() => _isSpeaking = false);
      }
    });
  }

  Future<void> _speak(String text) async {
    if (_isSpeaking) {
      await flutterTts.stop();
      setState(() => _isSpeaking = false);
      return;
    }

    setState(() => _isSpeaking = true);
    await flutterTts.speak(text);
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'A1':
        return Colors.green.shade500;
      case 'A2':
        return Colors.lightGreen.shade500;
      case 'B1':
        return Colors.orange.shade500;
      case 'B2':
        return Colors.red.shade500;
      default:
        return Colors.grey.shade500;
    }
  }

  Color _getLevelBackgroundColor(String level) {
    switch (level) {
      case 'A1':
        return Colors.green.shade50;
      case 'A2':
        return Colors.lightGreen.shade50;
      case 'B1':
        return Colors.orange.shade50;
      case 'B2':
        return Colors.red.shade50;
      default:
        return Colors.grey.shade50;
    }
  }

  String _getDifficultyText(double successRate) {
    if (successRate > 0.8) return 'Kolay';
    if (successRate > 0.5) return 'Orta';
    return 'Zor';
  }

  Color _getDifficultyColor(double successRate) {
    if (successRate > 0.8) return Colors.green;
    if (successRate > 0.5) return Colors.orange;
    return Colors.red;
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: FlipCard(
        direction: FlipDirection.HORIZONTAL,
        speed: 600,
        flipOnTouch: true,
        front: _buildFrontCard(appProvider),
        back: _buildBackCard(appProvider),
      ),
    );
  }

  Widget _buildFrontCard(AppProvider appProvider) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      shadowColor: Colors.indigo.withOpacity(0.2),
      child: Container(
        height: 170,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [appProvider.primaryColor, appProvider.secondaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ÜST KISIM: Seviye ve Favori
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Seviye badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _getLevelColor(widget.word.level),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'SEVİYE ${widget.word.level}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Favori butonu
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        widget.word.isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: widget.word.isFavorite
                            ? Colors.red.shade400
                            : Colors.white,
                        size: 18,
                      ),
                      onPressed: widget.onFavoriteToggle,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),

              // ORTA KISIM: Kelime ve Ses Butonu
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.word.english,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8),
                          Text(
                            '👆 Kartı çevir → Türkçe anlamı',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.7),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12),
                    // Ses butonu
                    _buildSpeechButton(widget.word.english, appProvider),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackCard(AppProvider appProvider) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      shadowColor: Colors.orange.withOpacity(0.2),
      child: Container(
        height: 170,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.orange.shade500, Colors.red.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ÜST KISIM: Türkçe badge ve Favori
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Türkçe badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.translate_rounded,
                          color: Colors.white,
                          size: 12,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'TÜRKÇE',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Favori butonu
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        widget.word.isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: widget.word.isFavorite
                            ? Colors.red.shade400
                            : Colors.white,
                        size: 18,
                      ),
                      onPressed: widget.onFavoriteToggle,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),

              // ORTA KISIM: Türkçe kelime ve Ses Butonu
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.word.turkish,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 6),
                          Text(
                            widget.word.english,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                              fontStyle: FontStyle.italic,
                            ),
                          ),

                          // Kullanıcı notu
                          if (widget.word.userNote != null &&
                              widget.word.userNote!.isNotEmpty) ...[
                            SizedBox(height: 4),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '"${widget.word.userNote!}"',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white.withOpacity(0.9),
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(width: 12),
                    // Ses butonu - Türkçe için
                    _buildSpeechButton(
                      widget.word.turkish,
                      appProvider,
                      isTurkish: true,
                    ),
                  ],
                ),
              ),

              // ALT KISIM: Seviye ve İstatistikler
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Seviye ve Zorluk
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getLevelBackgroundColor(widget.word.level),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _getLevelColor(widget.word.level),
                          ),
                        ),
                        child: Text(
                          'SEVİYE ${widget.word.level}',
                          style: TextStyle(
                            color: _getLevelColor(widget.word.level),
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      SizedBox(height: 4),
                      if (widget.word.correctCount + widget.word.wrongCount > 0)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(
                              widget.word.successRate,
                            ).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _getDifficultyText(widget.word.successRate),
                            style: TextStyle(
                              color: _getDifficultyColor(
                                widget.word.successRate,
                              ),
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),

                  // İstatistikler
                  if (widget.word.correctCount + widget.word.wrongCount > 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${(widget.word.successRate * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${widget.word.correctCount}/${widget.word.correctCount + widget.word.wrongCount}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),

                  // Geri çevir açıklaması
                  Text(
                    '👆 Geri çevir',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpeechButton(
    String text,
    AppProvider appProvider, {
    bool isTurkish = false,
  }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: _isSpeaking
            ? Colors.white.withOpacity(0.25)
            : Colors.white.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
      ),
      child: IconButton(
        icon: Icon(
          _isSpeaking ? Icons.volume_up_rounded : Icons.volume_up_outlined,
          color: Colors.white,
          size: 20,
        ),
        onPressed: () => _speak(text),
        padding: EdgeInsets.zero,
        tooltip: isTurkish ? 'Türkçe oku' : 'İngilizce oku',
      ),
    );
  }
}
