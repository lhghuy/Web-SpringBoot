import 'package:flutter/material.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final events = [
      {
        "title": "Sự Kiện Mừng Thành Lập TeamFoodHKD",
        "desc": "Chào mừng bạn đến với TeamFoodHKD",
        "time": "23/05/2025 18:00 - 21:00",
        "image":
        "https://dulichviet.com.vn/images/bandidau/van-hoa-am-thuc-viet-nam-co-gi-hap-dan-du-khach-khap-the-gioi.jpg"
      },
      {
        "title": "Khuyến Mãi Mùa Hè 2025",
        "desc": "Giảm giá 20% cho tất cả món ăn",
        "time": "01/06/2025 10:00 - 14:00",
        "image":
        "https://th.bing.com/th/id/OIP.JGcNj7AOtXYpJyTFpx3BggHaE8?cb=iwc2&rs=1&pid=ImgDetMain"
      },
      {
        "title": "Ngày Hội Ẩm Thực Châu Á",
        "desc": "Trải nghiệm các món ăn đặc sắc",
        "time": "15/06/2025 12:00 - 20:00",
        "image":
        "https://aztraining.vn/wp-content/uploads/2023/02/yeu-to-lich-su.jpg"
      },
      {
        "title": "Lễ Hội Trung Thu",
        "desc": "Chương trình bánh trung thu miễn phí",
        "time": "20/09/2025 17:00 - 22:00",
        "image":
        "https://aztraining.vn/wp-content/uploads/2023/02/am-thuc-la-gi.jpg"
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("🎉 Sự kiện"),
        backgroundColor: const Color(0xFF667EEA),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: events.length,
        itemBuilder: (context, i) {
          final e = events[i];
          final isDark = i.isOdd;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: isDark
                  ? const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
                  : const LinearGradient(
                colors: [Colors.white, Color(0xFFF5F5F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16)),
                  child: Image.network(
                    e["image"]!,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e["title"]!,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          e["desc"]!,
                          style: TextStyle(
                            color:
                            isDark ? Colors.white70 : Colors.grey.shade700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.access_time,
                                size: 14,
                                color: isDark
                                    ? Colors.white70
                                    : Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(
                              e["time"]!,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.white70
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
