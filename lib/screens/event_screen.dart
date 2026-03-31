lib/screens/event_screen.dart 열고 아래 코드 붙여넣어 주세요:
dartimport 'package:flutter/material.dart';
import '../models/event.dart';

class EventScreen extends StatelessWidget {
  const EventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentEvent = EventData.getCurrentEvent();
    final nextEvent = EventData.getNextEvent();

    return Scaffold(
      backgroundColor: const Color(0xFF1B4332),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B4332),
        foregroundColor: Colors.white,
        title: const Text('이벤트'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 현재 이벤트
            if (currentEvent != null) ...[
              _buildSectionTitle('진행 중인 이벤트'),
              _buildCurrentEventCard(currentEvent),
              const SizedBox(height: 24),
            ] else ...[
              _buildNoEventCard(nextEvent),
              const SizedBox(height: 24),
            ],

            // 전체 이벤트 일정
            _buildSectionTitle('연간 이벤트 일정'),
            ...EventData.all.map((event) => _buildEventItem(event)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF95D5B2),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCurrentEventCard(GameEvent event) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(int.parse(event.bgColor)),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF95D5B2), width: 1.5),
      ),
      child: Column(
        children: [
          Text(event.emoji, style: const TextStyle(fontSize: 60)),
          const SizedBox(height: 8),
          Text(
            event.name,
            style: const TextStyle(
              color: Colors.white, fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            event.description,
            style: const TextStyle(
              color: Color(0xFF95D5B2), fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // 특별 동물
          Text(
            '특별 등장 동물',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6), fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: event.specialAnimals.map((id) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    id, style: const TextStyle(
                      color: Colors.white, fontSize: 11,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          // 이슬 보너스
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '💧 이슬 보너스 +${event.dewBonus}개',
              style: const TextStyle(
                color: Color(0xFF95D5B2), fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoEventCard(GameEvent? nextEvent) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text('🌲', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          const Text(
            '현재 진행 중인 이벤트가 없어요',
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
          if (nextEvent != null) ...[
            const SizedBox(height: 8),
            Text(
              '다음 이벤트: ${nextEvent.emoji} ${nextEvent.name}',
              style: const TextStyle(
                color: Color(0xFF95D5B2), fontSize: 13,
              ),
            ),
            Text(
              '${EventData.getDaysUntilNextEvent(nextEvent)}일 후',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5), fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEventItem(GameEvent event) {
    final now = DateTime.now();
    final start = DateTime(now.year, event.startMonth, event.startDay);
    final end = DateTime(now.year, event.endMonth, event.endDay, 23, 59);
    final isActive = now.isAfter(start) && now.isBefore(end);
    final isPast = now.isAfter(end);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isActive ? Colors.white.withOpacity(0.1) : Colors.white10,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive
              ? const Color(0xFF95D5B2)
              : Colors.white12,
          width: isActive ? 1.5 : 0.5,
        ),
      ),
      child: Row(
        children: [
          Text(
            event.emoji,
            style: TextStyle(
              fontSize: 28,
              color: isPast ? Colors.white38 : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.name,
                  style: TextStyle(
                    color: isPast ? Colors.white38 : Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${event.startMonth}/${event.startDay} ~ ${event.endMonth}/${event.endDay}',
                  style: TextStyle(
                    color: isPast ? Colors.white24 : Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isActive)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF95D5B2).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '진행 중',
                    style: TextStyle(
                      color: Color(0xFF95D5B2), fontSize: 11,
                    ),
                  ),
                )
              else if (isPast)
                const Text(
                  '종료',
                  style: TextStyle(color: Colors.white24, fontSize: 11),
                )
              else
                Text(
                  '${EventData.getDaysUntilNextEvent(event)}일 후',
                  style: const TextStyle(
                    color: Colors.white54, fontSize: 11,
                  ),
                ),
              Text(
                '💧+${event.dewBonus}',
                style: TextStyle(
                  color: isPast
                      ? Colors.white24
                      : const Color(0xFF95D5B2),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}