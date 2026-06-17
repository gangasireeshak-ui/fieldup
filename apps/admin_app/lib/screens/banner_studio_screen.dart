import 'package:flutter/material.dart';

const _kLime = Color(0xFFC8F23A);
const _kBg = Colors.black;
TextStyle _head(double sz, {Color c = Colors.white}) => TextStyle(fontFamily: 'Barlow Condensed', fontSize: sz, fontWeight: FontWeight.w800, color: c, letterSpacing: -0.5);
TextStyle _body(double sz, {Color c = const Color(0xFF9E9E9E)}) => TextStyle(fontFamily: 'Inter', fontSize: sz, fontWeight: FontWeight.w500, color: c);

class BannerStudioScreen extends StatefulWidget {
  const BannerStudioScreen({super.key});
  @override
  State<BannerStudioScreen> createState() => _BannerStudioScreenState();
}

class _BannerStudioScreenState extends State<BannerStudioScreen> {
  int _selected = 0;
  final _titleCtrl = TextEditingController(text: 'PLAY FOR FREE TODAY');
  final _subCtrl = TextEditingController(text: '100% free · No card needed');

  static const _gradients = [
    [Color(0xFF0D1500), Color(0xFF1A3000)],
    [Color(0xFF070F20), Color(0xFF0D1A40)],
    [Color(0xFF200A07), Color(0xFF3A1210)],
    [Color(0xFF1A0820), Color(0xFF2D0F38)],
  ];
  static const _gradientLabels = ['Lime Turf', 'Ocean Night', 'Red Zone', 'Purple Rain'];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('HERO BANNER STUDIO', style: _head(28, c: _kLime)),
            Text('Design the home screen hero banner', style: _body(12)),
            const SizedBox(height: 20),

            // Live preview
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _gradients[_selected],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(children: [
                  Positioned(
                    right: -20, top: -20,
                    child: Icon(Icons.sports_soccer, size: 160, color: Colors.white.withValues(alpha: 0.03)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _kLime,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text('LAUNCH OFFER', style: _body(9, c: const Color(0xFF1A2800))),
                        ),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(_titleCtrl.text, style: _head(30)),
                          Text(_subCtrl.text, style: _body(12, c: Colors.white.withValues(alpha: 0.5))),
                        ]),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 20),

            // Controls
            Text('BANNER TEXT', style: _body(11, c: Colors.white.withValues(alpha: 0.3))),
            const SizedBox(height: 8),
            _AdminInput(controller: _titleCtrl, hint: 'Hero title', onChanged: (_) => setState(() {})),
            const SizedBox(height: 10),
            _AdminInput(controller: _subCtrl, hint: 'Subtitle', onChanged: (_) => setState(() {})),
            const SizedBox(height: 16),

            Text('BACKGROUND THEME', style: _body(11, c: Colors.white.withValues(alpha: 0.3))),
            const SizedBox(height: 8),
            Row(children: List.generate(4, (i) => Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selected = i),
                child: Container(
                  margin: EdgeInsets.only(right: i < 3 ? 8 : 0),
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: _gradients[i]),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _selected == i ? _kLime : Colors.white.withValues(alpha: 0.1),
                      width: _selected == i ? 2 : 1,
                    ),
                  ),
                  child: _selected == i
                      ? const Icon(Icons.check, color: Color(0xFFC8F23A), size: 16)
                      : null,
                ),
              ),
            ))),
            const SizedBox(height: 20),

            GestureDetector(
              onTap: () {},
              child: Container(
                height: 52, alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _kLime,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: _kLime.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 6))],
                ),
                child: Text('PUBLISH BANNER →', style: _head(16, c: const Color(0xFF1A2800))),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _AdminInput extends StatelessWidget {
  const _AdminInput({required this.controller, required this.hint, required this.onChanged});
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    onChanged: onChanged,
    style: const TextStyle(fontFamily: 'Inter', color: Colors.white, fontSize: 14),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontFamily: 'Inter', color: Color(0xFF9E9E9E), fontSize: 14),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.04),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _kLime, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
  );
}
