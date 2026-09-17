import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/personalization_service.dart';

class AiConciergeSheet extends StatefulWidget {
  const AiConciergeSheet({super.key});

  @override
  State<AiConciergeSheet> createState() => _AiConciergeSheetState();
}

class _AiConciergeSheetState extends State<AiConciergeSheet> {
  static const String _apiUrl = 'https://storefront-ochre.vercel.app/api/concierge';
  static const Color _terracotta = Color(0xFFB85C38);
  static const Color _ink = Color(0xFF1A1A1A);
  static const Color _bg = Color(0xFFFAF8F5);
  static const Color _surface = Color(0xFFF0EDE8);
  static const Color _muted = Color(0xFF8A8580);

  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _loading = false;
  String? _greeting;

  @override
  void initState() {
    super.initState();
    _loadGreeting();
  }

  Future<void> _loadGreeting() async {
    final svc = PersonalizationService();
    final distinctId = await svc.getDistinctId();

    if (distinctId.isEmpty) {
      setState(() => _greeting = "Hi, I'm your Reformly Concierge. How can I help you today?");
      return;
    }

    try {
      final res = await http.post(
        Uri.parse('https://storefront-ochre.vercel.app/api/concierge/greeting'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'distinctId': distinctId}),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() => _greeting = data['greeting'] ?? "Hi, I'm your Reformly Concierge.");
      }
    } catch (_) {
      setState(() => _greeting = "Hi, I'm your Reformly Concierge. How can I help you today?");
    }
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _loading) return;

    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _loading = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final svc = PersonalizationService();
      final distinctId = await svc.getDistinctId();
      final intent = await svc.getIntent();

      // Build full message history including greeting
      final allMessages = [
        if (_greeting != null) {'role': 'assistant', 'content': _greeting!},
        ..._messages,
      ];

      final res = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'messages': allMessages,
          'context': {
            'distinctId': distinctId,
            'intent': intent,
            'score': '50',
          },
        }),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() => _messages.add({'role': 'assistant', 'content': data['reply'] ?? 'Sorry, I could not process that.'}));
      } else {
        setState(() => _messages.add({'role': 'assistant', 'content': 'Sorry, something went wrong. Please try again.'}));
      }
    } catch (_) {
      setState(() => _messages.add({'role': 'assistant', 'content': 'Could not connect. Please check your connection.'}));
    } finally {
      setState(() => _loading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(),
          Expanded(child: _buildMessages()),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black.withOpacity(0.06))),
      ),
      child: Row(
        children: [
          Container(
            width: 8, height: 8,
            decoration: const BoxDecoration(
              color: _terracotta,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'REFORMLY CONCIERGE',
            style: TextStyle(fontSize: 11, letterSpacing: 2.5, fontWeight: FontWeight.w600, color: _terracotta),
          ),
        ],
      ),
    );
  }

  Widget _buildMessages() {
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      children: [
        // Greeting
        if (_greeting == null)
          _buildBubble('...', isUser: false, isLoading: true)
        else
          _buildBubble(_greeting!, isUser: false),

        // Conversation
        ..._messages.map((m) => _buildBubble(m['content']!, isUser: m['role'] == 'user')),

        // Typing indicator
        if (_loading) _buildBubble('...', isUser: false, isLoading: true),
      ],
    );
  }

  Widget _buildBubble(String text, {required bool isUser, bool isLoading = false}) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? _terracotta.withOpacity(0.1) : _surface,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isUser ? const Radius.circular(4) : null,
            bottomLeft: !isUser ? const Radius.circular(4) : null,
          ),
          border: Border.all(
            color: isUser ? _terracotta.withOpacity(0.2) : Colors.black.withOpacity(0.06),
          ),
        ),
        child: isLoading
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) => Container(
                  margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                  width: 6, height: 6,
                  decoration: BoxDecoration(color: _muted.withOpacity(0.5), shape: BoxShape.circle),
                )),
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: isUser ? _terracotta.withOpacity(0.9) : _ink,
                  fontWeight: FontWeight.w400,
                ),
              ),
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: BoxDecoration(
        color: _bg,
        border: Border(top: BorderSide(color: Colors.black.withOpacity(0.06))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black.withOpacity(0.06)),
              ),
              child: TextField(
                controller: _controller,
                onSubmitted: (_) => _send(),
                style: const TextStyle(fontSize: 14, color: _ink),
                decoration: const InputDecoration(
                  hintText: 'Ask me anything...',
                  hintStyle: TextStyle(color: Color(0xFF8A8580), fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _send,
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: _loading ? _terracotta.withOpacity(0.3) : _terracotta,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
