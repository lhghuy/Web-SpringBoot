import 'dart:async';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(viewportFraction: 1);
  int _currentSlide = 0;
  Timer? _autoTimer;

  final List<String> _slides = [
    // Replace with assets or network images as needed
    'https://your-cdn.com/images/slideshow2.avif',
    'https://your-cdn.com/images/slideshow3.jpg',
    'https://your-cdn.com/images/slideshow1.jpg',
  ];

  final List<Map<String, String>> _categories = [
    {
      'title': 'LẨU',
      'image':
      'https://your-cdn.com/images/lau-thap-cam.jpg',
    },
    {
      'title': 'TRÁNG MIỆNG',
      'image':
      'https://your-cdn.com/images/TRANG%20MIENG.jpg',
    },
    {
      'title': 'THỨC UỐNG',
      'image':
      'https://your-cdn.com/images/coke-zero.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _autoTimer?.cancel();
    _autoTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_slides.isEmpty) return;
      _currentSlide = (_currentSlide + 1) % _slides.length;
      _pageController.animateToPage(
        _currentSlide,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _onOrderNow() {
    // Navigate to menu screen or open menu modal
    Navigator.pushNamed(context, '/menu');
  }

  void _openMap(int index) {
    // Navigate to map screen with store index
    Navigator.pushNamed(context, '/map', arguments: {'store': index});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('TeamFOOD'),
        backgroundColor: const Color(0xFF667EEA),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () {
              // Example action (call / contact)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Hotline: 0868093133')),
              );
            },
          )
        ],
      ),
      body: ListView(
        children: [
          // Banner / CTA
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TeamFOOD – Đặt món dễ dàng, tận hưởng trọn vẹn!',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _onOrderNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF667EEA),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text('Đặt món ngay'),
                ),
              ],
            ),
          ),

          // Slideshow
          SizedBox(
            height: 180,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (i) => setState(() => _currentSlide = i),
                  itemBuilder: (context, i) {
                    final url = _slides[i];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Image.network(url,
                            fit: BoxFit.cover, width: double.infinity, errorBuilder: (_, __, ___) {
                              return Container(color: Colors.grey.shade300, alignment: Alignment.center, child: const Icon(Icons.image, size: 48));
                            }),
                      ),
                    );
                  },
                ),
                // dots
                Positioned(
                  bottom: 8,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(_slides.length, (i) => _buildDot(i == _currentSlide)),
                  ),
                )
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Features
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _featureTile('❤️', 'SẢN PHẨM AN TOÀN', 'Cam kết chất lượng'),
                const SizedBox(width: 12),
                _featureTile('👤', 'HỖ TRỢ 24/7', 'Tất cả các ngày'),
                const SizedBox(width: 12),
                _featureTile('💰', 'HOÀN TIỀN', 'Nếu sản phẩm hư hỏng'),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // About
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Về chúng tôi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          const Text(
                            'TeamFOOD là chuỗi nhà hàng hiện đại, phục vụ đa dạng món ăn... TeamFOOD cam kết mang đến bữa ăn ngon miệng và an toàn cho mọi khách hàng.',
                            style: TextStyle(fontSize: 13, color: Colors.black87),
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () => Navigator.pushNamed(context, '/menu'),
                            child: const Text('Xem thực đơn →'),
                          )
                        ],
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        'https://your-cdn.com/images/about1.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(width: 100, height: 100, color: Colors.grey.shade200, child: const Icon(Icons.restaurant_menu)),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Categories carousel (horizontal)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('DANH MỤC MÓN ĂN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 160,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, i) {
                      final c = _categories[i];
                      return GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/menu', arguments: {'tab': i}),
                        child: Container(
                          width: 200,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                                child: Image.network(c['image']!, width: 200, height: 96, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(height: 96, color: Colors.grey.shade200, child: const Icon(Icons.fastfood))),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                child: Column(
                                  children: [
                                    Text(c['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 6),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pushNamed(context, '/menu', arguments: {'tab': i}),
                                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF667EEA)),
                                      child: const Text('Xem thêm'),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Footer
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.network('https://your-cdn.com/images/logo.jpg', width: 48, height: 48, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 48, height: 48, color: Colors.grey.shade200))),
                    const SizedBox(width: 12),
                    const Text('TeamFOOD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('© 2025 TeamFOOD. All Rights Reserved.'),
                const SizedBox(height: 4),
                const Text('Email: foodhkdhotro@gmail.com'),
                const SizedBox(height: 4),
                const Text('Hotline: 0868093133'),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(onPressed: () => _launchUrl('https://www.facebook.com/lehonggiahuy2407'), child: const Text('Facebook')),
                    const SizedBox(width: 8),
                    TextButton(onPressed: () => _launchUrl('https://www.instagram.com/itismebomsu/'), child: const Text('Instagram')),
                  ],
                )
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _featureTile(String emoji, String title, String subtitle) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 6),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 10 : 6,
      height: active ? 10 : 6,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF667EEA) : Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
    );
  }

  static void _launchUrl(String url) {
    // TODO: use url_launcher package to open links
    // For now show debug message
    // You can implement with: url_launcher: ^6.1.10
    // launchUrlString(url);
    debugPrint('Open url: $url');
  }
}
